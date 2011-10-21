package MPQ::Archive::File::Uncompress;

use strict;
use warnings;

use File::Temp qw/tempfile/;
use IO::Uncompress::Bunzip2 qw/bunzip2 $Bunzip2Error/;

use base 'MPQ::Archive::File::Filter';

sub process {
    my $self = shift;
    my $type = "_$self->{'type'}";

    my $result = $self->$type(@_);
    $self->SUPER::process(@_);

    return $result;
}

sub _bunzip2 {
    my ($self, $in_filename) = @_;
    my ($out_fh, $out_filename) = tempfile;

    bunzip2 $in_filename => $out_fh
        or die "bunzip2 failed: $Bunzip2Error";

    return $out_filename;
}

1;

=head1 AUTHOR

C corporation (c)

