package MPQ::Archive::HashTable;

use strict;
use warnings;

use MPQ::Archive::Hash;

sub new {
    my ($class, %param) = @_;

    $param{'_crypt'} = new MPQ::Crypt;
    $param{'_table'} = [];

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'});
    {
        my $buf = $self->{'_crypt'}->decrypt_hash_table(
            $self->{'file'},
            $self->{'entries'} * 4 # 4 fields in structure
        );

        my $table = $self->{'_table'};
        for (my $i = 0; $i < $self->{'entries'}; $i++) {
            my $language = $buf->[$i * 4 + 2] & 0xffff_0000;
            $language >>= 16;
            my $platform = $buf->[$i * 4 + 2] & 0x0000_ff00;
            $platform >>= 8;

            push @$table, MPQ::Archive::Hash->new(
                file_path_hash_a => $buf->[$i * 4],
                file_path_hash_b => $buf->[$i * 4 + 1],
                language         => $language,
                platform         => $platform,
                file_block_index => $buf->[$i * 4 + 3]
            );
        }
    }
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

