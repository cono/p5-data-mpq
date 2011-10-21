#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('MPQ::Shunt'); }
my $shunt = new_ok('MPQ::Shunt');

