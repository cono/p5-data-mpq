package Data::MPQ::Archive::Header;

=head1 NAME

Data::MPQ::Archive::Header - Perl module to work with MPQ archive header

=head1 SYNOPSIS

    use Data::MPQ;

    my $mpq = Data::MPQ->new(filename => 'my_game.sc2replay');
    $mpq->parse;

    my $archive = $mpq->archive;

    print $archive->header->format_version;

=head1 DESCRIPTION

This module parse and give you an access to MPQ archive header structure

=head1 METHODS

=cut

use strict;
use warnings;

sub ORIGINAL_FORMAT_VERSION() { 0x0  }
sub CRUSADE_FORMAT_VERSION()  { 0x1  }
sub ORIGINAL_ARCHIVE_SIZE()   { 0x20 }
sub CRUSADE_ARCHIVE_SIZE()    { 0x2c }
sub OFFSET_TO_OFFSETS()       { 0xc  }

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub parse {
    my $self = shift;
    my $file = $self->{'file'};

    $file->seek($self->{'offset'});
    $self->{'_header_size'} = $file->read_int32;
    $self->{'_archive_size'} = $file->read_int32;
    $self->{'_format_version'} = $file->read_int16;

    $self->validate_format;

    $self->{'_sector_size_shift'} = $file->read_int8;

    $file->seek($self->{'offset'} + OFFSET_TO_OFFSETS);
    $self->{'_hash_table_offset'} = $file->read_int32;
    $self->{'_block_table_offset'} = $file->read_int32;
    $self->{'_hash_table_entries'} = $file->read_int32;
    $self->{'_block_table_entries'} = $file->read_int32;

    if ($self->{'_format_version'} == CRUSADE_FORMAT_VERSION) {
        $self->{'_extended_block_table_offset'} = $file->read_int64;
        $self->{'_hash_table_offset_high'} = $file->read_int16;
        $self->{'_block_table_offset_high'} = $file->read_int16;
    }
}

sub validate_format {
    my $self = shift;

    if ($self->{'_format_version'} == ORIGINAL_FORMAT_VERSION) {
        if ($self->{'_header_size'} ne ORIGINAL_ARCHIVE_SIZE) {
            die "Wrong archive header size for format version 0x0h.".
                " Must be ".  ORIGINAL_ARCHIVE_SIZE .", instead of ".
                $self->{'_header_size'};
        }
    } elsif ($self->{'_format_version'} == CRUSADE_FORMAT_VERSION) {
        if ($self->{'_header_size'} ne CRUSADE_ARCHIVE_SIZE) {
            die "Wrong archive header size for format version 0x1h.".
                " Must be ".  CRUSADE_ARCHIVE_SIZE .", instead of ".
                $self->{'_header_size'};
        }
    } else {
        die "Unexpected archive format version (0x0h and 0x1h only supported)";
    }
}

sub header_size { $_[0]->{'_header_size'} }
sub archive_size { $_[0]->{'_archive_size'} }
sub format_version { $_[0]->{'_format_version'} }
sub sector_size_shift { $_[0]->{'_sector_size_shift'} }
sub hash_table_offset { $_[0]->{'_hash_table_offset'} }
sub block_table_offset { $_[0]->{'_block_table_offset'} }
sub hash_table_entries { $_[0]->{'_hash_table_entries'} }
sub block_table_entries { $_[0]->{'_block_table_entries'} }
sub extended_block_table_offset { $_[0]->{'_extended_block_table_offset'} }
sub hash_table_offset_high { $_[0]->{'_hash_table_offset_high'} }
sub block_table_offset_high { $_[0]->{'_block_table_offset_high'} }

1;

=head1 AUTHOR

cono C<q@cono.org.ua>

C corporation (c)

