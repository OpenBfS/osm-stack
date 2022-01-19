#!/usr/bin/perl
#
# Test whether a metatile file is valid.

use Fcntl qw(SEEK_SET SEEK_CUR O_RDONLY);
use strict;

my $filename = shift;

die "no filename given" unless defined($filename);
sysopen(F, $filename, O_RDONLY) or die "cannot open $filename for reading";

my $header;
my $offsets;
sysread(F, $header, 20);
die "not a meta file" unless (substr($header, 0, 4) eq "META");

my ($magic, $count, $tilex, $tiley, $tilez) = unpack("lllll", $header);
sysread(F, $offsets, 8 * $count);

my $rows = int(sqrt($count));
my $cols = int(sqrt($count));
die "cannot determine number of rows and colums" unless ($rows * $cols == $count);

my @offset = unpack("ll" x $count, $offsets);
my @img;

my $png; 

for (my $i = 0; $i < $count; $i++)
{
    die "problem with file offsets" unless (sysseek(F,0,SEEK_CUR) == $offset[$i*2]);
    sysread(F, $png, $offset[$i*2+1]);
    die "file truncated" unless (length($png) == $offset[$i*2+1]);
}
