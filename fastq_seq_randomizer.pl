#!/usr/bin/env perl

use strict;
use warnings;
use List::Util qw (shuffle);

my $usage = "usage: $0 file.fastq\n\n";

my $fastq_file = $ARGV[0] or die $usage;

main: {

    open (my $fh, "$fastq_file") or die $!;
    while (my $line1 = <$fh>) {
        my $line2 = <$fh>;
        my $line3 = <$fh>;
        my $line4 = <$fh>;

        unless ($line1 =~ /^\@/ && $line3 =~ /^\+/) {
            die "Error, formatting seems not matching fastq:\n" . join("\n", $line1, $line2, $line3, $line4) . "\n";
        }

        $line1 =~ s/^\@/\@rand/;

        chomp $line2;
        my @chars = split(//, $line2);
        @chars = shuffle (@chars);
        $line2 = join("", @chars) . "\n";

        print join("", $line1, $line2, $line3, $line4);
        
        
    }

    close $fh;

    exit(0);
}
