#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';
use App::Marginalia;

use Pod::Usage;
use Getopt::Long;
use File::Basename;
use DBI;
use Data::Dumper;
use Data::Tabular::Dumper;
use File::ShareDir;

# Get command line options and check environment
my ($help,$man,$from,$to,$opt_database,$opt_notepads,$opt_books);
GetOptions(
    'from:s'   => \$from,
    'to:s'     => \$to,
    'notepads' => \$opt_notepads,
	'books'    => \$opt_books,
	'database' => \$opt_database,
    'help|?'   => \$help, 
    'man'      => \$man,
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

if (@ARGV) {
   $opt_notepads = 1 if ( grep { $_ =~ /^notepads$/ } @ARGV );
   $opt_books    = 1 if ( grep { $_ =~ /^books$/ } @ARGV );
   $opt_database = 1 if ( grep { $_ =~ /^database$/ } @ARGV );
}

checkdir( $from => '/media/READER' );
checkdir( $to   => '.' );

my $xsltproc = `which xsltproc` or fail('missing xsltproc');
my $notepad2svg = $App::Marginalia::SHAREDIR."/notepad2svg.xsl";
-r $notepad2svg or die "Missing $notepad2svg";

# download and convert notepads
if ($opt_notepads) {
    my $note_from = "$from/Sony_Reader/media/notepads";
    my $note_to   = "$to/notepads";
    checkdir( $note_from );
    checkdir( $note_to );

    print "notepads...\n";
    foreach my $note_file (<$note_from/*.note>) {
        my $id = basename($note_file,'.note');
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

if ($opt_database) {
	print "databases...\n";
	`cp $db_from/*.db $db_to`;
	# `cp $db_from/sync/*.db $db_to/sync`;
}

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

	if ( $opt_books ) {
  	    $from_file = "$from/$from_file";
		system('cp',$from_file,$to_file);
	}
	print "$id,$filename\n"; # TODO: books.csv

	$books{$id} = {
		to_file => $to_file,
	};
    #print join(",", map { $row->{$_} } qw(_id author title file_path), ) . "\n";
    # thumbnail may be interesting too
}

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
		print "book $book_id page $page\n";
		-d "$to/markup/$book_id" or `mkdir -p $to/markup/$book_id`;
	    system('cp',"$from/$file","markup/$book_id/");
		my $filename = basename($file);
		print "book $book_id page $page: $filename\n";
	} else {
		print "ignoring markup type $type for book $book_id page $page\n";
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
   -notepads   convert and copy all notepads to target
   -books      copy all boks to target
   -help|-?    brief help message
   -man        full documentation

 Commands:
   notepads
   books

=head1 DESCRIPTION

This command line script loads some information from a Sony PRS T1 eReader
device.

=head1 OPTIONS

=over 4

=item B<-from>

Base directory of the mounted reader. Defaults to `/media/READER`.

=item B<-to>

Base directory to write information to. Defaults to current directory.

=item B<-notepads>

Get notepads.

=cut
