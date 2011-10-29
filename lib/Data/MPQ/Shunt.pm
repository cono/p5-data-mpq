package Data::MPQ::Shunt;

=head1 NAME

Data::MPQ::Shunt - Perl module to work with MPQ shunt block

=head1 SYNOPSIS

    use Data::MPQ;

    my $mpq = Data::MPQ->new(filename => 'my_game.sc2replay');
    $mpq->parse;

    my $shunt = $mpq->shunt;
    print $shunt->user_data_size;
    print $shunt->archive_header_offset;

=head1 DESCRIPTION

This module parse and give you an access to MPQ shunt block, in other words:
user data information block

=head1 METHODS

=cut

use strict;
use warnings;

sub USER_DATA_OFFSET() { 0x8 }

=head2 new

Constructor for the Data::MPQ::Shunt class. Requires two parameters:

    file   - Filehandle of the MPQ archive
    offset - Offset of the beginning of the shunt block

=cut

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

=head2 parse

Method to parse shunt block of the MPQ file

=cut

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'});
    $self->{'_user_data_size'} = $self->{'file'}->read_int32;
    $self->{'_archive_header_offset'} = $self->{'file'}->read_int32;

    return $self;
}

=head2 user_data_size

Accessor to the user_data_size field of the shunt block

=cut

sub user_data_size { $_[0]->{'_user_data_size'} }

=head2 archive_header_offset

Accessor to the archive_header_offset field of the shunt block

=cut

sub archive_header_offset { $_[0]->{'_archive_header_offset'} }

=head2 user_data

Acessor to raw user_data of the shunt block

=cut

sub user_data {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'} + USER_DATA_OFFSET);
    return $self->{file}->read_str($self->user_data_size);
}

1;

=head1 AUTHOR

cono C<q@cono.org.ua>

C corporation (c)

