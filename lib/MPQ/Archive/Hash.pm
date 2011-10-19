package MPQ::Archive::Hash;

use strict;
use warnings;

my $language_type = {
    0x000 => 'Neutral',
    0x404 => 'Chinese',
    0x405 => 'Czech',
    0x407 => 'German',
    0x409 => 'English',
    0x40a => 'Spanish',
    0x40c => 'French',
    0x410 => 'Italian',
    0x411 => 'Japanese',
    0x412 => 'Korean',
    0x413 => 'Dutch',
    0x415 => 'Polish',
    0x416 => 'Portuguese',
    0x419 => 'Russsian',
    0x809 => 'EnglishUK'
};

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub dump {
    my $self = shift;

    print "language: $language_type->{$self->{'language'}}\n",
        "platform: $self->{'platform'}\n",
        "file_block_index; $self->{'file_block_index'}\n";
}

1;

=head1 AUTHOR

C corporation (c)

