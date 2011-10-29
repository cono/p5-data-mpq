#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('Data::MPQ::Archive::Header'); }
my $header = new_ok('Data::MPQ::Archive::Header');

