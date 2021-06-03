#!/usr/bin/env perl

use strict;

my $usage = "usage: $0 chunk_size core_filename < fasta_file \n";

my $chunk_size = $ARGV[0] or die $usage;
my $core_filename = $ARGV[1] or die $usage;

my $count = -1;

my $fh;
while (<STDIN>) {
    if (/^>/) {
        $count++;
    

        if (($count==0) || ($count % $chunk_size == 0)) {
            if ($fh) {
                close $fh;
                undef($fh);
            }
            print "-processing: $core_filename.s_$count.fa\n";
            open ($fh, ">$core_filename.s_$count.fa\n") or die $!;
        }
    }
    
    print $fh $_ if $fh;

}

if ($fh) {
    close $fh;
}

exit(0);

