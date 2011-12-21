#!/usr/bin/perl
#ABSTRACT: Save original SQLite3 schemas, so we can track changes

use strict;
use warnings;

my $basedir = shift @ARGV || '/media/READER/Sony_Reader/database';
$basedir =~ s{/$}{};
-d $basedir || die "Could not find directory $basedir";

my @files = qw(books notepads sync/sync sync/deleted audios images);
foreach my $file (@files) {
	my ($from,$to) = ("$basedir/file.db","original/$file.sql");
	print "$from => $to\n";
	system("echo .schema | sqlite3 $from > $to");
}
