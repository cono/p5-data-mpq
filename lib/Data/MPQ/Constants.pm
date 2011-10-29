package Data::MPQ::Constants;

use strict;
use warnings;

our @EXPORT = qw//;

our @EXPORT_OK = qw/
    IS_OVERFLOW
    MAGIC ARCHIVE_TYPE SHUNT_TYPE
    KEY_HASH_TABLE KEY_BLOCK_TABLE
    CRYPT_OFFSET_HASH_BUCKET  CRYPT_OFFSET_HASH_NAME_A  CRYPT_OFFSET_HASH_NAME_B
    CRYPT_OFFSET_HASH_FILE_KEY CRYPT_OFFSET_DECRYPT_TABLE
    DEFAULT_LANGUAGE DEFAULT_PLATFORM
/;

sub import {
    shift;
    my $caller = caller;
    my $pkg    = __PACKAGE__;

    no strict 'refs';
    no warnings 'redefine';

    my @export = (@EXPORT, @_);
    for my $c (@export) {
        my $dest = $caller .'::'. $c;
        my $src  = __PACKAGE__ .'::'. $c;
        *$dest = *$src;
    }
}

sub IS_OVERFLOW()  { 4294967296 & 1 }

sub MAGIC()        { 'MPQ' }
sub ARCHIVE_TYPE() { "\x1a" }
sub SHUNT_TYPE()   { "\x1b" }

sub KEY_HASH_TABLE()   { 0xC3AF3770 } # Obtained by HashString("(hash table)", MPQ_HASH_FILE_KEY)
sub KEY_BLOCK_TABLE()  { 0xEC83B3A3 } # Obtained by HashString("(block table)", MPQ_HASH_FILE_KEY)

sub CRYPT_OFFSET_HASH_BUCKET()   { 0x000 }
sub CRYPT_OFFSET_HASH_NAME_A()   { 0x100 }
sub CRYPT_OFFSET_HASH_NAME_B()   { 0x200 }
sub CRYPT_OFFSET_HASH_FILE_KEY() { 0x300 }
sub CRYPT_OFFSET_DECRYPT_TABLE() { 0x400 }

sub DEFAULT_LANGUAGE() { 'Neutral' }
sub DEFAULT_PLATFORM() { 0 }

1;

=head1 AUTHOR

cono C<q@cono.org.ua>

C corporation (c)

