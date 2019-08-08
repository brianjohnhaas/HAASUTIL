#!/usr/bin/env perl

use strict;
use warnings;


use lib ("/home/radon01/bhaas/EUK_modules");
use Nuc_translator;

my $usage = "usage: $0 file.fq kmer\n\n";

my $fq_file = $ARGV[0] or die $usage;
my $kmer = $ARGV[1] or die $usage;

$kmer = uc $kmer;

my $rev_kmer = &reverse_complement($kmer);

my $count = 0;
open (my $fh, $fq_file) or die "Error, cannot open file $fq_file";
while (my $line1 =  <$fh>) {
	my $line2 = <$fh>;
	my $line3 = <$fh>;
	my $line4 = <$fh>;
	
	chomp ($line1, $line2, $line3, $line4);
	
	if ($line2 =~ /$kmer|$rev_kmer/) {
		print join("\n", $line1, $line2, $line3, $line4) . "\n";
	}
}

exit(0);

