#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "usage: $0 filename.fq\n\n";

my $fastq = $ARGV[0] or die $usage;


my $cmd = "~/bio_tools/FASTX_TOOLKIT/bin/fastq_quality_filter  -v -q 15 -p 50 -i $fastq -o $fastq.q15-p50.fq";
my $ret = system($cmd);

if ($ret) {
	die "Error, cmd: $cmd died with ret $ret";
}

exit(0);

