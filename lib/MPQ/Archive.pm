package MPQ::Archive;

use strict;
use warnings;

use MPQ::Constants;
use MPQ::Archive::Header;

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'});
    $self->do_magic;

    $self->{'_header'} = MPQ::Archive::Header->new(
        file   => $self->{'file'},
        offset => $self->{'file'}->tell
    );
    $self->{'_header'}->parse;
}

sub header { $_[0]->{'_header'} }

sub do_magic {
    my $self = shift;
    my $str = $self->{'file'}->read_str(4);

    if ($str ne MAGIC . ARCHIVE_TYPE) {
        die "Archive is not an appropriate MPQ archive";
    }
}

1;

=head1 AUTHOR

C corporation (c)

