package MPQ::Shunt;

use strict;
use warnings;

sub USER_DATA_OFFSET() { 0x8 }

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'});
    $self->{'_user_data_size'} = $self->{'file'}->read_int32;
    $self->{'_archive_header_offset'} = $self->{'file'}->read_int32;

    return $self;
}

sub user_data_size { $_[0]->{'_user_data_size'} }

sub archive_header_offset { $_[0]->{'_archive_header_offset'} }

sub user_data {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'} + USER_DATA_OFFSET);
    return $self->{file}->read_str($self->user_data_size);
}

1;

=head1 AUTHOR

C corporation (c)

