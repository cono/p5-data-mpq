package MPQ::Archive;

use strict;
use warnings;

use MPQ::Constants;
use MPQ::Archive::Header;
use MPQ::Archive::HashTable;
use MPQ::Archive::BlockTable;
use MPQ::Archive::File;

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'});
    $self->do_magic;

    my $header = $self->{'_header'} = MPQ::Archive::Header->new(
        file   => $self->{'file'},
        offset => $self->{'file'}->tell
    );
    $header->parse;

    $self->{'_hash_table'} = MPQ::Archive::HashTable->new(
        archive_offset => $self->{'offset'},
        file           => $self->{'file'},
        offset         => $header->hash_table_offset,
        entries        => $header->hash_table_entries
    );
    $self->{'_hash_table'}->parse;

    $self->{'_block_table'} = MPQ::Archive::BlockTable->new(
        archive_offset => $self->{'offset'},
        file           => $self->{'file'},
        offset         => $header->block_table_offset,
        entries        => $header->block_table_entries
    );
    $self->{'_block_table'}->parse;
}

sub list_file {
    my $self = shift;

    unless (exists $self->{'_file_table'}) {
        my $file = $self->file('(listfile)', 'Neutral', 0);
        die "Could not find (listfile) file" unless defined $file;

        my $ft = $self->{'_file_table'};
        for my $f ( split /[\n\r;]/, $file->slurp ) {
            $ft->{$f} = undef unless exists $ft->{$f};
        }
    }

    return keys %{$self->{'_file_table'}};
}

sub file {
    my ($self, $filename, $language, $platform) = @_;

    if (exists $self->{'_file_table'} && defined $self->{'_file_table'}->{$filename}) {
        return $self->{'_file_table'}->{$filename};
    }

    my $hash_entry = $self->{'_hash_table'}->find_hash_entry($filename, $language, $platform);
    return undef unless defined $hash_entry;

    my $block = $self->{'_block_table'}->get_block($hash_entry->file_block_index);
    $self->{'_file_table'}->{$filename} = MPQ::Archive::File->new(
        file           => $self->{'file'},
        archive_header => $self->{'_header'},
        hash_entry     => $hash_entry,
        block          => $block
    );
    $self->{'_file_table'}->{$filename}->extract;

    return $self->{'_file_table'}->{$filename};
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

