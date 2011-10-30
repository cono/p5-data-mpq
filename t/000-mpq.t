#! /usr/bin/perl

use strict;
use warnings;

use Test::MockObject;
use File::Spec;
use Test::More tests => 16;

BEGIN { use_ok('Data::MPQ'); }

my ($archive_offset, $buf);

my $file = Test::MockObject->new;
$file->set_true('open');
$file->mock(
    read_str => sub {
        my $self = shift;
        my $len  = shift;

        return substr($buf, 0, $len, '');
    }
);
$file->fake_module(
    'Data::MPQ::File',
    new => sub {
        my $class = shift;
        my %param = @_;

        ok($param{'filename'} eq 'fake_filename', 'Internal creation Data::MPQ::File');

        return $file;
    }
);

my $archive = Test::MockObject->new;
$archive->set_true('parse');
$archive->fake_module(
    'Data::MPQ::Archive',
    new => sub {
        my $class = shift;
        my %param = @_;

        $archive_offset = $param{'offset'};
        ok($param{'file'} eq $file, 'File passed to Archive constructor');

        return $archive;
    }
);

my $shunt = Test::MockObject->new;
$shunt->set_true('parse');
$shunt->set_always(archive_header_offset => 42);
$shunt->fake_module(
    'Data::MPQ::Shunt',
    new => sub {
        my $class = shift;
        my %param = @_;

        ok($param{'offset'} eq 0x4, 'Shunt offset constructor parameter');
        ok($param{'file'} eq $file, 'File passed to Shunt constructor');

        return $shunt;
    }
);

sub init_vars {
    undef $@;
    $file->clear;
    $archive->clear;
    $shunt->clear;
    $archive_offset = 0;
    $buf = shift;
}

my $mpq = new_ok('Data::MPQ' => [ filename => 'fake_filename' ] );

init_vars("this is not a right MPQ");
eval { $mpq->parse };
$file->called_ok('open', 'File opened before work');
ok($@, 'Handle wrong MPQ files');

init_vars("MPQ\x1a"); # archive type
$mpq->parse;
$archive->called_ok('parse', 'Data::MPQ::Archive->parse call (archive type)');
ok($archive_offset == 0x4, 'Offset for the Data::MPQ::Archive (archive type)');

init_vars("MPQ\x1b"); # shunt type
$mpq->parse;
$archive->called_ok('parse', 'Data::MPQ::Archive->parse call (with shunt present)');
ok($archive_offset == 42, 'Offset for the Data::MPQ::Archive (with shunt present)');

ok($mpq->shunt eq $shunt, 'Data::MPQ->shunt accessor');
ok($mpq->archive eq $archive, 'Data::MPQ->archive accessor');

init_vars("MPQ good magic, but wrong data type");
eval { $mpq->parse };
ok($@, 'Handle wrong data type');

done_testing;
