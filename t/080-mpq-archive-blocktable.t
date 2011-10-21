#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('MPQ::Archive::BlockTable'); }
my $table = new_ok('MPQ::Archive::BlockTable');

