#!/usr/bin/env perl

use strict;
use warnings;

while (<>) {
	if (/^\@/) {
		my $seqHeader = $_;
		chomp $seqHeader;
		
		my $seq = <>;
		my $qualHeader = <>;
		my $quals = <>;
		chomp $quals;

		my @qual_chars = split (//, $quals);
		my @qual_vals;
		foreach my $char (@qual_chars) {
			my $qual_val = ord($char)-33;
			push (@qual_vals, $qual_val);
		}
		
		if (scalar(@qual_vals) != length($seq) -1) {
			die "Error, quals and seq do not match length-wise ";
		}
		
		print "$seqHeader\n$seq$qualHeader" . join (" ", @qual_vals) . "\n";
		
	}
}

exit(0);

