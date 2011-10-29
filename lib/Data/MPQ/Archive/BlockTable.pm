package Data::MPQ::Archive::BlockTable;

=head1 NAME

Data::MPQ::Archive::BlockTable - Perl module to work with MPQ archive block table

=head1 SYNOPSIS

    use Data::MPQ;
    use Data::MPQ::Constants qw(DEFAULT_LANGUAGE DEFAULT_PLATFORM);

    my $mpq = Data::MPQ->new(filename => 'my_game.sc2replay');
    $mpq->parse;

    my $archive = $mpq->archive;

    my $block_id = $archive->
        hash_table->
        find_hash_entry('(listfile)', DEFAULT_LANGUAGE, DEFAULT_PLATFORM)->
        file_block_index;
    print $archive->
        block_table->
        get_block($block_id)->
        is_file;

=head1 DESCRIPTION

This module parse and give you an access to MPQ block table

=head1 METHODS

=cut

use strict;
use warnings;

use Data::MPQ::Crypt;
use Data::MPQ::Archive::Block;

sub new {
    my ($class, %param) = @_;

    $param{'_crypt'} = new Data::MPQ::Crypt;
    $param{'_table'} = [];

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'} + $self->{'archive_offset'});
    {
        my $buf = $self->{'_crypt'}->decrypt_block_table(
            $self->{'file'},
            $self->{'entries'} * 4 # 4 fields in structure
        );

        my $table = $self->{'_table'};
        for (my $i = 0; $i < $self->{'entries'}; $i++) {
            push @$table, Data::MPQ::Archive::Block->new(
                offset    => $buf->[$i * 4] + $self->{'archive_offset'},
                size      => $buf->[$i * 4 + 1],
                file_size => $buf->[$i * 4 + 2],
                flags     => $buf->[$i * 4 + 3]
            );
        }
    }
}

sub get_block {
    my ($self, $block_id) = @_;

    return $self->{'_table'}->[$block_id];
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

cono C<q@cono.org.ua>

C corporation (c)

