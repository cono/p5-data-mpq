package MPQ::Archive::File;

use strict;
use warnings;

use File::Temp qw/tempfile/;

use MPQ::Archive::File::Uncompress;

sub new {
    my ($class, %param) = @_;

    return bless(\%param, $class);
}

sub extract {
    my $self  = shift;
    my $block = $self->{'block'};
    my $file  = $self->{'file'};

    $file->seek($block->offset);
    if ($block->is_single_unit) {
        my $length = $block->size;
        my @filters;

        if ($block->is_compress) {
            my $compress_flag = $file->read_int8;
            $length--;

            if ($compress_flag & 0x10) { # Bzip2
                push @filters, MPQ::Archive::File::Uncompress->new(
                    type => 'bunzip2'
                );
            }
        }

        my ($fh, $filename) = tempfile;
        print $fh $file->read_str($length);
        close($fh);

        for my $f ( @filters ){
            $filename = $f->process($filename);
        }

        $self->{'_filename'} = $filename;
    } else {
        die "Non-single_unit files not implemented";
    }
}

sub slurp {
    my $self = shift;

    open(my $fh, '<', $self->{'_filename'})
        or die "Could not open file $self->{'_filename'}: $!";
    local $/;
    my $content = <$fh>;

    return $content;
}

1;

=head1 AUTHOR

C corporation (c)

