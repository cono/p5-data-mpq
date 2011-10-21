#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use MPQ::Constants qw/ KEY_HASH_TABLE KEY_BLOCK_TABLE CRYPT_OFFSET_HASH_FILE_KEY /;

BEGIN { use_ok( 'MPQ::Crypt' ); }
my $crypt = new_ok( 'MPQ::Crypt' );

is $crypt->hash_string('(hash table)', CRYPT_OFFSET_HASH_FILE_KEY), KEY_HASH_TABLE, 'Key for hash table';
is $crypt->hash_string('(block table)', CRYPT_OFFSET_HASH_FILE_KEY), KEY_BLOCK_TABLE, 'Key for block table';

done_testing();
