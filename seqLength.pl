#!/usr/bin/env perl

use strict;

my $seqLen = 0;

while (<>) {
    if (/^>/) {
	next; # header
    }
    s/\s//g;
    $seqLen += length($_);
}

print "length: $seqLen\n";

exit(0);

