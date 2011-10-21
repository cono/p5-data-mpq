#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('MPQ::File'); }
my $file = new_ok('MPQ::File');

