package App::Marginalia;

use File::ShareDir qw(dist_dir dist_file);

our $SHAREDIR;
BEGIN {
   $SHAREDIR = dist_dir('App-Marginalia');
}

1;
