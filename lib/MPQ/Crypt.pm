package MPQ::Crypt;

use strict;
use warnings;

use MPQ::Constants;

sub CRYPT_BUFFER_SIZE() { 0x500 }
sub INIT_SEED()         { 0x00100001 }
sub HASH_STRING_SEED1() { 0x7FED7FED }
sub HASH_STRING_SEED2() { 0xEEEEEEEE }

sub new {
    my ($class, %param) = @_;
    my $self = bless(\%param, $class);

    $self->_init;

    return $self;
}

sub _to_dword {
    return ( $_[0] & 0xFFFF_FFFF )
}

sub _init {
    my $self = shift;

    my $seed = INIT_SEED;
    my ($temp1, $temp2);
    $self->{'_buffer'} = [];

    for my $index1 ( 0 .. 0x100 ) {
        for my $index2 ( map { $index1 + 0x100 * $_ } 0 .. 4 ) {
            $seed  = ( $seed * 125 + 3 ) % 0x2AAAAB;
            $temp1 = ( $seed & 0xFFFF ) << 0x10;

            $seed  = ( $seed * 125 + 3 ) % 0x2AAAAB;
            $temp2 = ( $seed & 0xFFFF );

            $self->{'_buffer'}->[$index2] = ($temp1 | $temp2);
        }
    }
}

sub hash_string {
    my ($self, $word, $offset) = @_;
    my $seed1 = HASH_STRING_SEED1;
    my $seed2 = HASH_STRING_SEED2;

    for my $ch ( unpack('C*', uc $word) ) {
        $seed1 = _to_dword($self->{'_buffer'}->[$offset + $ch] ^ ($seed1 + $seed2));
        $seed2 = _to_dword($ch + $seed1 + $seed2 + ($seed2 << 5) + 3);
    }

    return $seed1;
}

1;

=head1 AUTHOR

C corporation (c)

