#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';
use App::Marginalia;

use Pod::Usage;
use Getopt::Long;
use File::Basename;
use DBI;
use Cwd qw(abs_path);
use Data::Dumper;
use Data::Tabular::Dumper;
use File::ShareDir;
use IPC::Run qw(run);

# Get command line options and check environment
my ($help,$man,$from,$to);
GetOptions(
    'from:s'   => \$from,
    'to:s'     => \$to,
    'help|?'   => \$help, 
    'man'      => \$man,
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

my %cmd = map { $_ => undef } qw(notepads books markups database okular);
$cmd{database} = 1; # always needed
foreach (@ARGV) {
    $cmd{$_} = 1 if exists($cmd{$_});
}

checkdir( $from => '/media/READER' );
checkdir( $to   => '.' );

my $xsltproc = `which xsltproc` or fail('missing xsltproc');
my $notepad2svg = $App::Marginalia::SHAREDIR."/notepad2svg.xsl";
-r $notepad2svg or die "Missing $notepad2svg";
my $notepad2okular = $App::Marginalia::SHAREDIR."/notepad2okular.xsl";
-r $notepad2okular or die "Missing $notepad2okular";

# download and convert notepads
if ($cmd{notepads}) {
    my $note_from = "$from/Sony_Reader/media/notepads";
    my $note_to   = "$to/notepads";
    checkdir( $note_from );
    checkdir( $note_to );

    print "notepads...\n";
    foreach my $note_file (<$note_from/*.note>) {
        my $id = basename($note_file,'.note');
        system('cp', $note_file, "$note_to/" );
        if ( system("xsltproc", "-o", "$note_to/$id.svg", $notepad2svg, "$note_file") ) {
            print "processing $note_file with xslt failed: $?\n";
            exit 2;
        } else {
            print "$note_to/$id.svg\n";
        }
    }
}

# Databases
my $db_from = "$from/Sony_Reader/database";
my $db_to   = "$to/database";
checkdir($db_from);

if ($cmd{database}) {
    print "databases...\n";
    `cp $db_from/*.db $db_to`;
    # `cp $db_from/sync/*.db $db_to/sync`;
}

# we always at least need some information about books
print "books...\n";
my %books;

my $dbh = dbconnect('books.db');
my $res = $dbh->selectall_hashref("SELECT * FROM books", 1);

foreach my $id ( sort { $a <=> $b } keys %$res ) {
    my $row = $res->{$id};
#   print Dumper($row);
    my $from_file = $row->{file_path};
    my $filename = basename($from_file); # == $row->{file_name};
    my $to_file;
    if ($from_file =~ qr{^Sony_Reader/media/books/}) {
        $to_file = "books/$filename";
    } elsif ($from_file =~ qr{^download/} ) {
        $to_file = "download/$filename";
    } else {
        print STDERR "Skipping book $id with unknown location $from_file\n";
    }

    if ( $cmd{books} ) {
          $from_file = "$from/$from_file";
        system('cp',$from_file,$to_file);
    }
    # TODO: save to books.csv
    print "$id,$filename\n";

    $books{$id} = {
        to_file => $to_file,
        # TODO: thumbnail may be interesting too
    };
}

if ($cmd{markups}) {
    print "markups...\n";
    $res = $dbh->selectall_hashref("SELECT * FROM markups", 1);
    foreach my $id ( sort { $a <=> $b } keys %$res ) {
        my $row = $res->{$id};
    #   print Dumper($row);
        
        my $book_id = $row->{content_id};
        my $page = int($row->{page} + 0.5);
        my $file = $row->{file1};
        my $type = $row->{markup_type};
        my $name = $row->{name};
        if ($type == 20) {
            -d "$to/markup/$book_id" or `mkdir -p $to/markup/$book_id`;
            system('cp',"$from/$file","markup/$book_id/");
            my $filename = basename($file);
            print "book $book_id page $page: $filename\n";
        } else {
            print "ignoring markup type $type for book $book_id page $page\n";
        }
    }
}

if ( $cmd{okular} ) {
    print "okular...\n";
    my $kdeprefix = `kde4-config --localprefix`;
    $kdeprefix =~ s{/?\n$}{}m;
    my $docdata = "$kdeprefix/share/apps/okular/docdata";
    checkdir($docdata);

    my $book_ids = $dbh->selectall_arrayref("SELECT DISTINCT content_id FROM markups WHERE markup_type = 20");
    $book_ids = [ map { 1*$_->[0] } @$book_ids ];
    foreach my $book_id (@$book_ids) {
        my $book_url = abs_path($books{$book_id}->{to_file});
        my $book_size = -s $book_url;
        my $book_filename = basename($book_url); # TODO: distinguish download/books/other 
        my $outfile = "$docdata/$book_size.$book_filename.xml";

        open (OKFILE, ">", $outfile);
        print "$outfile\n";

        my $sql = "SELECT page, added_date, file1 FROM markups WHERE markup_type=20 AND content_id=$book_id ORDER BY page";
        $res = $dbh->selectall_arrayref($sql);

        my $cur_page;
print OKFILE <<XML;
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE documentInfo>
<documentInfo url="$book_url">
 <pageList>
XML
        foreach my $row (@$res) {
            my $page = int($row->[0]+0.5);
            if (!defined $cur_page or $cur_page ne $page) {
                print OKFILE "  </page>\n" if defined $cur_page;
                print OKFILE "  <page number='".($page-1)."'>\n";
                $cur_page = $page;
            }
            my $created = $row->[1];
            my $file = "$from/$row->[2]";
            # TODO: catch xslt errors
            # TODO: stringparam created $created
            # 
            run ["xsltproc", $notepad2okular, $file], ">>", \*OKFILE;
        }
        # additional information (history and current viewport) omitted (TODO)
        print OKFILE "  </page>\n" if defined $cur_page;
        print OKFILE " </pageList>\n</documentInfo>\n";
        close OKFILE;
    }
}

### some handy functions

sub dbconnect {
    my $name = shift;
    my $dbfile = "$to/database/$name";
    -r $dbfile || die "missing file $dbfile";
    my $dbargs = {AutoCommit => 0, PrintError => 1};
    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "", $dbargs);
    return $dbh;    
}

sub checkdir {
    $_[0] = $_[1] unless defined $_[0];
    $_[0] =~ s{/$}{};
    -d $_[0] and return $_[0];
    fail("missing directory $_[0]");
}

sub fail {
    print STDERR shift() . "\n";
    exit (shift || 1);
}

=head1 NAME

prst1 - Sony PRS T1 command line utility

=head1 SYNOPSIS

prst1 [options] [commands]

 Options [and default values]:
   -from DIR   base directory of eReader [/media/READER]
   -to DIR     base directory of target [current directory]
   -help|-?    brief help message
   -man        full documentation

 Commands:
   books       copy all books to target
   database    copy all SQLite3 databases to target
   notepads    convert and copy all notepads to target
   markups     copy all markups to target
   okular      add annotations file for okular PDF reader

=head1 DESCRIPTION

This command line script loads some information from a Sony PRS T1 eReader
device for further processing. See L<https://github.com/nichtich/sony-prs-t1>
for more documentation and source code.

=head1 OPTIONS

=over 4

=item B<-from>

Base directory of the mounted reader. Defaults to `/media/READER`.

=item B<-to>

Base directory to write information to. Defaults to the current directory.

=back

=cut
