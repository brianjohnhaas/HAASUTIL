#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "usage: $0 file.fq modVal [append]\n\n";

my $fq_file = $ARGV[0] or die $usage;
my $mod = $ARGV[1] or die $usage;
my $append = $ARGV[2];

my $count = 0;
open (my $fh, $fq_file) or die "Error, cannot open file $fq_file";
while (my $line1 =  <$fh>) {
	my $line2 = <$fh>;
	my $line3 = <$fh>;
	my $line4 = <$fh>;
	
	chomp ($line1, $line2, $line3, $line4);
	
	$count++;
	
	
	if ($append) {
		$line1 .= "\\" . $append;
	}
	
	if ($count % $mod == 0) {
		print join("\n", $line1, $line2, $line3, $line4) . "\n";
	}
}

exit(0);

