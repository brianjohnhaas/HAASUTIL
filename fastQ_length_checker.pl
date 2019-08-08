#!/usr/bin/env perl

use strict;
use warnings;


my $counter = 0;

while (<>) {
	if (/^\@/) {
		$counter++;
        my $seqHeader = $_;
		chomp $seqHeader;
		
		my $seq = <>;
		my $qualHeader = <>;
		my $quals = <>;
		
        chomp $seq;
        chomp $qualHeader;
        chomp $quals;

#        print join("\n", $seqHeader, $seq, $qualHeader, $quals) . "\n\n";

        if (length($seq) != length($quals)) {
            print "[entry $counter] Error, seq length = " . length($seq) . ", length of quals: " . length($quals) . "\n";
            print join("\n", $seqHeader, $seq, $qualHeader, $quals) . "\n\n";

        }
        

		
	}
}

exit(0);

