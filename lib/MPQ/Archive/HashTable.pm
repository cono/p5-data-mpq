package MPQ::Archive::HashTable;

use strict;
use warnings;

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub parse {
}

1;

=head1 AUTHOR

C corporation (c)

