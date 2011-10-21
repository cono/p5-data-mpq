#! /usr/bin/perl

use strict;
use warnings;

use File::Spec;
use Test::More tests => 2;

BEGIN { use_ok('MPQ'); }
my $mpq = new_ok('MPQ' => [ filename => File::Spec->devnull ] );

