package MPQ::File;

use strict;
use warnings;

use Fcntl qw(:seek);

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub open {
    my $self = shift;

    open($self->{'_fh'}, '<', $self->{'filename'})
        or die "Can't open file $self->{'filename'}: $!";
}

sub seek {
    my ($self, $pos) = @_;

    seek($self->{'_fh'}, $pos, SEEK_SET);
}

sub tell { tell $_[0]->{'_fh'} }

sub read_str {
    my ($self, $length) = @_;
    my $buf;

    read $self->{'_fh'}, $buf, $length;

    return $buf;
}

sub read_int32 {
    my $self = shift;
    my $str = $self->read_str(4);

    return unpack("V", $str);
}

sub DESTROY {
    my $self = shift;

    close($self->{'_fh'}) if $self->{'_fh'};
}

1;

=head1 AUTHOR

C corporation (c)

