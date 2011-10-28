package MPQ::Archive::HashTable;

use strict;
use warnings;

use MPQ::Archive::HashEntry;
use MPQ::Constants qw/CRYPT_OFFSET_HASH_BUCKET/;

sub HASH_ENTRY_FREE() { 0xFFFF_FFFF }
sub HASH_ENTRY_DEL()  { 0xFFFF_FFFE }

sub new {
    my ($class, %param) = @_;

    $param{'_crypt'} = new MPQ::Crypt;
    $param{'_table'} = [];

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'} + $self->{'archive_offset'});
    {
        my $buf = $self->{'_crypt'}->decrypt_hash_table(
            $self->{'file'},
            $self->{'entries'} * 4 # 4 fields in structure
        );

        my $table = $self->{'_table'};
        for (my $i = 0; $i < $self->{'entries'}; $i++) {
            my $language = $buf->[$i * 4 + 2] & 0xFFFF_0000;
            $language >>= 16;
            my $platform = $buf->[$i * 4 + 2] & 0x0000_FF00;
            $platform >>= 8;

            push @$table, MPQ::Archive::HashEntry->new(
                file_path_hash_a => $buf->[$i * 4],
                file_path_hash_b => $buf->[$i * 4 + 1],
                language         => $language,
                platform         => $platform,
                file_block_index => $buf->[$i * 4 + 3]
            );
        }
    }
}

sub find_hash_entry {
    my ($self, $path, $language, $platform) = @_;
    my $table       = $self->{'_table'};
    my $entry_index = $self->{'_crypt'}->hash_string($path, CRYPT_OFFSET_HASH_BUCKET);
    my $hash_mask   = $self->{'entries'} ? $self->{'entries'} - 1 : 0;
    $entry_index   &= $hash_mask;
    my $first_entry = $entry_index;

    do {
        my $file_block_index = $table->[$entry_index]->file_block_index;
        if ($file_block_index == HASH_ENTRY_FREE) {
            last;
        }
        if (
            $file_block_index != HASH_ENTRY_DEL &&
            $table->[$entry_index]->equal($path, $language, $platform)
        ) {
            return $table->[$entry_index];
        }

        $entry_index++;
        if ($entry_index == $self->{'entries'}) {
            $entry_index = 0;
        }
    } while ($entry_index != $first_entry);

    return undef;
}

# For debug
sub dump {
    my $self = shift;
    my $table = $self->{'_table'};
    my $c = 0;

    for my $b ( @$table ) {
        print "Block $c\n";
        $c++;

        $b->dump;
    }
}

1;

=head1 AUTHOR

C corporation (c)

