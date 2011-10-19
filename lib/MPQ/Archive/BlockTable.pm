package MPQ::Archive::BlockTable;

use strict;
use warnings;

use MPQ::Crypt;
use MPQ::Archive::Block;

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
        my $buf = $self->{'_crypt'}->decrypt_block_table(
            $self->{'file'},
            $self->{'entries'} * 4 # 4 fields in structure
        );

        my $table = $self->{'_table'};
        for (my $i = 0; $i < $self->{'entries'}; $i++) {
            push @$table, MPQ::Archive::Block->new(
                offset    => $buf->[$i * 4],
                size      => $buf->[$i * 4 + 1],
                file_size => $buf->[$i * 4 + 2],
                flags     => $buf->[$i * 4 + 3]
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

