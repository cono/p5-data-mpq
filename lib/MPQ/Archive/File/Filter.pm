package MPQ::Archive::File::Filter;

use strict;
use warnings;

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub process {
    my ($self, $filename) = @_;

    unlink($filename);
}

1;

=head1 AUTHOR

C corporation (c)

