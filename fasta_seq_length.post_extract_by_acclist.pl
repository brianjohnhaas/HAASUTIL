#!/usr/bin/env perl

use strict;
use warnings;

my %accs;

my $usage = "usage: $0  seq_len_file   acc_list_file\n\n";

my $seqlen_file = $ARGV[0] or die $usage;
my $acc_list_file  = $ARGV[1] or die $usage;


open (my $fh, $acc_list_file) or die "Error, cannot open file $acc_list_file";
while (<$fh>) {
	s/\s+//g;
	$accs{$_} = 1;
}
close $fh;


open ($fh, $seqlen_file) or die "Error, cannot open file $seqlen_file";
while (<$fh>) {
	my $line = $_;
	chomp;
	my ($len, $acc) = split (/\s+/);
	
	if ($accs{$acc}) {
		print $line;
	}
}

	
exit(0);


