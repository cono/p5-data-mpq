package MPQ::Archive::File::Filter;

use strict;
use warnings;

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub process {
    die ref($_[0]) ."::process need to be implemented";
}

1;

=head1 AUTHOR

C corporation (c)

