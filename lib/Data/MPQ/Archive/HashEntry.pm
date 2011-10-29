package Data::MPQ::Archive::HashEntry;

use strict;
use warnings;

use Data::MPQ::Crypt;
use Data::MPQ::Constants qw/CRYPT_OFFSET_HASH_NAME_A CRYPT_OFFSET_HASH_NAME_B/;

my $language_id2name = {
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
my $language_name2id = { };

sub new {
    my ($class, %param) = @_;

    $param{'_crypt'} = new Data::MPQ::Crypt;
    # fill $language_name2id hash
    while (my ($k, $v) = each %$language_id2name) {
        $language_name2id->{$v} = $k;
    }

    return bless(\%param, $class);
}

sub equal {
    my ($self, $path, $language, $platform) = @_;
    my $crypt = $self->{'_crypt'};

    if ($language) {
        my $language_id = $language_name2id->{$language};
        if ($self->{'language'} != $language_id) {
            return 0;
        }
    }
    if ($platform && $self->{'platform'} != $platform) {
        return 0;
    }

    my $hash_a = $crypt->hash_string($path, CRYPT_OFFSET_HASH_NAME_A);
    my $hash_b = $crypt->hash_string($path, CRYPT_OFFSET_HASH_NAME_B);

    if (
        $hash_a == $self->{'file_path_hash_a'} &&
        $hash_b == $self->{'file_path_hash_b'}
    ) {
        return 1;
    }

    return 0;
}

sub file_block_index { $_[0]->{'file_block_index'} }

sub dump {
    my $self = shift;

    print "language: $language_id2name->{$self->{'language'}}\n",
        "platform: $self->{'platform'}\n",
        "file_block_index; $self->{'file_block_index'}\n";
}

1;

=head1 AUTHOR

C corporation (c)

