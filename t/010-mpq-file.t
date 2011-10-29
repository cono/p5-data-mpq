#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('Data::MPQ::File'); }
my $file = new_ok('Data::MPQ::File');

