package Data::MPQ::Archive;

=head1 NAME

Data::MPQ::Archive - Perl module to work with MPQ archive block

=head1 SYNOPSIS

    use Data::MPQ;

    my $mpq = Data::MPQ->new(filename => 'my_game.sc2replay');
    $mpq->parse;

    my $archive = $mpq->archive;

    print for $archive->list_file;

=head1 DESCRIPTION

This module parse and give you an access to MPQ archive block - heart of the
MPQ file

=head1 METHODS

=cut

use strict;
use warnings;

use Data::MPQ::Constants qw(MAGIC ARCHIVE_TYPE DEFAULT_LANGUAGE DEFAULT_PLATFORM);
use Data::MPQ::Archive::Header;
use Data::MPQ::Archive::HashTable;
use Data::MPQ::Archive::BlockTable;
use Data::MPQ::Archive::File;

=head2 new

Constructor for the Data::MPQ::Shunt class. Requires two parameters:

    file   - Filehandle of the MPQ archive
    offset - Offset of the beginning of the shunt block

=cut

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

=head2 parse

Method to parse archive block of the MPQ file which consist of 3 data blocks:

=over 8

=item header - L<Data::MPQ::Archive::Header>

=item hash table - L<Data::MPQ::Archive::HashTable>

=item data table - L<Data::MPQ::Archive::BlockTable>

=back

=cut

sub parse {
    my $self = shift;

    $self->{'file'}->seek($self->{'offset'});
    $self->_do_magic;

    my $header = $self->{'_header'} = Data::MPQ::Archive::Header->new(
        file   => $self->{'file'},
        offset => $self->{'file'}->tell
    );
    $header->parse;

    $self->{'_hash_table'} = Data::MPQ::Archive::HashTable->new(
        archive_offset => $self->{'offset'},
        file           => $self->{'file'},
        offset         => $header->hash_table_offset,
        entries        => $header->hash_table_entries
    );
    $self->{'_hash_table'}->parse;

    $self->{'_block_table'} = Data::MPQ::Archive::BlockTable->new(
        archive_offset => $self->{'offset'},
        file           => $self->{'file'},
        offset         => $header->block_table_offset,
        entries        => $header->block_table_entries
    );
    $self->{'_block_table'}->parse;
}

=head2 list_file

Returns an array of the files inside of the archive

=cut

sub list_file {
    my $self = shift;

    unless (exists $self->{'_file_table'}) {
        my $file = $self->file('(listfile)', DEFAULT_LANGUAGE, DEFAULT_PLATFORM);
        die "Could not find (listfile) file" unless defined $file;

        my $ft = $self->{'_file_table'};
        for my $f ( split /[\n\r;]/, $file->slurp ) {
            $ft->{$f} = undef unless exists $ft->{$f};
        }
    }

    return keys %{$self->{'_file_table'}};
}

=head2 file

Takes filename as a parameter.

Returns an instance of the L<Data::MPQ::Archive::File> for the given filename
or undef if the file could not be find.

=cut

sub file {
    my ($self, $filename, $language, $platform) = @_;

    if (exists $self->{'_file_table'} && defined $self->{'_file_table'}->{$filename}) {
        return $self->{'_file_table'}->{$filename};
    }

    my $hash_entry = $self->{'_hash_table'}->find_hash_entry($filename, $language, $platform);
    return undef unless defined $hash_entry;

    my $block = $self->{'_block_table'}->get_block($hash_entry->file_block_index);
    $self->{'_file_table'}->{$filename} = Data::MPQ::Archive::File->new(
        file           => $self->{'file'},
        archive_header => $self->{'_header'},
        hash_entry     => $hash_entry,
        block          => $block
    );
    $self->{'_file_table'}->{$filename}->extract;

    return $self->{'_file_table'}->{$filename};
}

=head2 header

Accessor for the instance of the L<Data::MPQ::Archive::Header> which represent
the archive header data block

=cut

sub header { $_[0]->{'_header'} }

=head2 hash_table

Accessor for the instance of the L<Data::MPQ::Archive::HashTable> which represent
the archive hash table data block

=cut

sub hash_table { $_[0]->{'_hash_table'} }

=head2 block_table

Accessor for the instance of the L<Data::MPQ::Archive::BlockTable> which represent
the archive block table data block

=cut

sub block_table { $_[0]->{'_block_table'} }

sub _do_magic {
    my $self = shift;
    my $str = $self->{'file'}->read_str(4);

    if ($str ne MAGIC . ARCHIVE_TYPE) {
        die "Archive is not an appropriate MPQ archive";
    }
}

1;

=head1 AUTHOR

cono C<q@cono.org.ua>

C corporation (c)

