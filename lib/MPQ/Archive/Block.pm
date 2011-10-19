package MPQ::Archive::Block;

use strict;
use warnings;

#80000000h   Block is a file, and follows the file data format; otherwise, block is free space or unused. 
#            If the block is not a file, all other flags should be cleared, and FileSize should be 0.
sub FLAG_FILE()        { 0x8000_0000 }

#04000000h   File has checksums for each sector (explained in the File Data section). Ignored if file is not
#            compressed or imploded.
sub FLAG_CHECKSUM()    { 0x0400_0000 }

#02000000h   File is a deletion marker, indicating that the file no longer exists. This is used to allow
#            patch archives to delete files present in lower-priority archives in the search chain.
sub FLAG_DEL_MARK()    { 0x0200_0000 }

#01000000h   File is stored as a single unit, rather than split into sectors.
sub FLAG_SINGLE_UNIT() { 0x0100_0000 }

#00020000h   The file's encryption key is adjusted by the block offset and file size (explained in detail in the 
#            File Data section). File must be encrypted.
sub FLAG_KEY_ADJUST()  { 0x0002_0000 }

#00010000h   File is encrypted.
sub FLAG_ENCRYPT()     { 0x0001_0000 }

#00000200h   File is compressed. File cannot be imploded.
sub FLAG_COMPRESS()    { 0x0000_0200 }

#00000100h   File is imploded. File cannot be compressed.
sub FLAG_IMPLODE()     { 0x0000_0100 }

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub is_file {
    $_[0]->{'flags'} & FLAG_FILE ? 1 : 0;
}

sub is_checksum {
    $_[0]->{'flags'} & FLAG_CHECKSUM ? 1 : 0;
}

sub is_single_unit {
    $_[0]->{'flags'} & FLAG_SINGLE_UNIT ? 1 : 0;
}

sub is_encrypt {
    $_[0]->{'flags'} & FLAG_ENCRYPT ? 1 : 0;
}

sub is_compress {
    $_[0]->{'flags'} & FLAG_COMPRESS ? 1 : 0;
}

# For debug
sub dump {
    my $self = shift;

    print "offset: $self->{'offset'}\n",
        "size: $self->{'size'}\n",
        "file size: $self->{'file_size'}\n",
        "is_file: ". $self->is_file ."\n",
        "is_checksum: ". $self->is_checksum ."\n",
        "is_single_unit: ". $self->is_single_unit ."\n",
        "is_encrypted: ". $self->is_encrypt ."\n",
        "is_compress: ". $self->is_compress ."\n";
}

1;

=head1 AUTHOR

C corporation (c)

