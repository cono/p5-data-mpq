package MPQ::Archive;

use strict;
use warnings;

use MPQ::Constants;
use MPQ::Archive::Header;
use MPQ::Archive::HashTable;
use MPQ::Archive::BlockTable;

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'});
    $self->do_magic;

    $self->{'_header'} = MPQ::Archive::Header->new(
        file   => $self->{'file'},
        offset => $self->{'file'}->tell
    );
    $self->{'_header'}->parse;

    $self->{'_hash_table'} = MPQ::Archive::HashTable->new(
        file   => $self->{'file'},
        offset => $self->{'_header'}->hash_table_offset + $self->{'offset'}
    );
    $self->{'_hash_table'}->parse;

    $self->{'_block_table'} = MPQ::Archive::BlockTable->new(
        file    => $self->{'file'},
        offset  => $self->{'_header'}->block_table_offset + $self->{'offset'},
        entries => $self->{'_header'}->block_table_entries
    );
    $self->{'_block_table'}->parse;
}

sub header { $_[0]->{'_header'} }
sub hash_table { $_[0]->{'_hash_table'} }
sub block_table { $_[0]->{'_block_table'} }

sub do_magic {
    my $self = shift;
    my $str = $self->{'file'}->read_str(4);

    if ($str ne MAGIC . ARCHIVE_TYPE) {
        die "Archive is not an appropriate MPQ archive";
    }
}

1;

=head1 AUTHOR

C corporation (c)

