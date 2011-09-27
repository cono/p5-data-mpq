package MPQ;

use strict;
use warnings;

use MPQ::File;
use MPQ::Constants;
use MPQ::Archive;
use MPQ::Shunt;

sub ARCHIVE_TYPE() { "\x1a" }
sub SHUNT_TYPE()   { "\x1b" }

sub new {
    my ($class, %param) = @_;

    $param{'_file'} = MPQ::File->new(
        filename => $param{'filename'}
    );

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;

    $self->{'_file'}->open;
    $self->do_magic;

    $self->recognize_type;
}

sub recognize_type {
    my $self = shift;
    my $str = $self->{'_file'}->read_str(1);

    if ($str eq ARCHIVE_TYPE) {
        $self->{'_archive'} = MPQ::Archive->new(
            offset => 0x4,
            file   => $self->{'_file'}
        );
    } elsif ($str eq SHUNT_TYPE) {
        $self->{'_shunt'} = MPQ::Shunt->new(
            offset => 0x4,
            file   => $self->{'_file'}
        );
        $self->{'_shunt'}->parse;
        $self->{'_archive'} = MPQ::Archive->new(
            offset => $self->{'_shunt'}->archive_header_offset,
            file   => $self->{'_file'}
        );
    } else {
        my $hex = unpack("H*", $str);
        die "Undefined type 0x$hex";
    }

    $self->{'_archive'}->parse;
}

sub do_magic {
    my $self = shift;
    my $str = $self->{'_file'}->read_str(3);

    die "File is not a MPQ format (wrong magic)" unless $str eq MAGIC;
}

sub shunt { $_[0]->{'_shunt'} }

sub archive { $_[0]->{'_archive'} }

1;

=head1 AUTHOR

C corporation (c)

