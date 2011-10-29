#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('Data::MPQ::Archive::File::Uncompress'); }
my $uncompress = new_ok('Data::MPQ::Archive::File::Uncompress');

