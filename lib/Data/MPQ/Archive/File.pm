package Data::MPQ::Archive::File;

=head1 NAME

Data::MPQ::Archive::BlockTable - Perl module to work with MPQ archive files

=head1 SYNOPSIS

    use Data::MPQ;

    my $mpq = Data::MPQ->new(filename => 'my_game.sc2replay');
    $mpq->parse;

    my $archive = $mpq->archive;

    print $archive->file('(listfile)')->slurp;

=head1 DESCRIPTION

This module grant you a simple interface to the archived files

=head1 METHODS

=cut

use strict;
use warnings;

use File::Temp qw/tempfile/;

use Data::MPQ::Archive::File::Uncompress;

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
                push @filters, Data::MPQ::Archive::File::Uncompress->new(
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

sub DESTROY {
    my $self = shift;

    unlink($self->{'_filename'}) if $self->{'_filename'} && -e $self->{'_filename'};
}

1;

=head1 AUTHOR

cono C<q@cono.org.ua>

C corporation (c)

