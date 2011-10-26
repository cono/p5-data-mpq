package MPQ::Crypt;

use strict;
use warnings;

use Math::BigInt try => 'GMP';

use MPQ::Constants qw/
    IS_OVERFLOW KEY_HASH_TABLE KEY_BLOCK_TABLE CRYPT_OFFSET_DECRYPT_TABLE
/;

sub CRYPT_BUFFER_SIZE() { 0x500 }
sub INIT_SEED()         { 0x00100001 }
sub HASH_STRING_SEED1() { 0x7FED7FED }
sub HASH_STRING_SEED2() { 0xEEEEEEEE }

my $_singleton;

sub new {
    return $_singleton if $_singleton;

    my ($class, %param) = @_;
    my $_singleton = bless(\%param, $class);

    $_singleton->_init;

    return $_singleton;
}

sub _to_dword {
    return ( $_[0] & 0xFFFF_FFFF )
}

sub _init {
    my $self = shift;

    my $seed = IS_OVERFLOW ? Math::BigInt->new(INIT_SEED) : INIT_SEED;
    my ($temp1, $temp2);
    $self->{'_buffer'} = [];

    for my $index1 ( 0 .. 0x100 ) {
        for my $index2 ( map { $index1 + 0x100 * $_ } 0 .. 4 ) {
            $seed  = _to_dword( $seed * 125 + 3 ) % 0x2AAAAB;
            $temp1 = ( $seed & 0xFFFF ) << 0x10;

            $seed  = _to_dword( $seed * 125 + 3 ) % 0x2AAAAB;
            $temp2 = ( $seed & 0xFFFF );

            $temp1 |= $temp2;
            $self->{'_buffer'}->[$index2] = IS_OVERFLOW ? $temp1->numify : $temp1;
        }
    }
}

sub hash_string {
    my ($self, $word, $offset) = @_;
    my $seed1 = IS_OVERFLOW ? Math::BigInt->new(HASH_STRING_SEED1) : HASH_STRING_SEED1;
    my $seed2 = IS_OVERFLOW ? Math::BigInt->new(HASH_STRING_SEED2) : HASH_STRING_SEED2;

    for my $ch ( unpack('C*', uc $word) ) {
        $seed1 = _to_dword($self->{'_buffer'}->[$offset + $ch] ^ ($seed1 + $seed2));
        $seed2 = _to_dword($ch + $seed1 + $seed2 + ($seed2 << 5) + 3);
    }

    return IS_OVERFLOW ? $seed1->numify : $seed1;
}

sub decrypt_table {
    my ($self, $file, $length, $seed1) = @_;
    my $seed2 = IS_OVERFLOW ? Math::BigInt->new(HASH_STRING_SEED2) : HASH_STRING_SEED2;
    $seed1 = Math::BigInt->new($seed1) if IS_OVERFLOW;
    my ($word, $temp);
    my $result = [];

    while ($length--) {
        my $word = $file->read_int32;
        $seed2 = _to_dword( $seed2 + $self->{'_buffer'}->[CRYPT_OFFSET_DECRYPT_TABLE + ($seed1 & 0xFF)]);
        $temp = $word ^ _to_dword( $seed1 + $seed2 );

        $seed1 = _to_dword( ((~$seed1 << 0x15) + 0x1111_1111) | ($seed1 >> 0x0B) );
        $seed2 = _to_dword( $temp + $seed2 + ($seed2 << 5) + 3 );

        push @$result, IS_OVERFLOW ? $temp->numify : $temp;
    }

    return $result;
}

sub decrypt_block_table {
    my $self = shift;

    return $self->decrypt_table(@_, KEY_BLOCK_TABLE);
}

sub decrypt_hash_table {
    my $self = shift;

    return $self->decrypt_table(@_, KEY_HASH_TABLE);
}

1;

=head1 AUTHOR

C corporation (c)

