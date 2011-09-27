package MPQ::Constants;

use strict;
use warnings;

our @EXPORT_OK = qw/ MAGIC /;

sub import {
    my $caller = caller;
    my $pkg    = __PACKAGE__;

    no strict 'refs';
    no warnings 'redefine';

    for my $c (@EXPORT_OK) {
        my $dest = $caller .'::'. $c;
        my $src  = __PACKAGE__ .'::'. $c;
        *$dest = *$src;
    }
}

sub MAGIC() { 'MPQ' }

1;

=head1 AUTHOR

C corporation (c)

