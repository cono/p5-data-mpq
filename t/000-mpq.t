#! /usr/bin/perl

use strict;
use warnings;

use File::Spec;
use Test::More tests => 2;

BEGIN { use_ok('Data::MPQ'); }
my $mpq = new_ok('Data::MPQ' => [ filename => File::Spec->devnull ] );

