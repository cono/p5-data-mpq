#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('Data::MPQ::Archive::File::Filter'); }
my $filter = new_ok('Data::MPQ::Archive::File::Filter');

