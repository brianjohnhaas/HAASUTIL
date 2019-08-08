#!/usr/bin/env perl

use strict;
use warnings;

use lib ($ENV{EUK_MODULES});
use Fastq_reader;
use Nuc_translator;

my $usage = "usage: $0 reads.fastq\n\n";

my $fastq_file = $ARGV[0] or die $usage;

main: {

    my $fastq_reader = new Fastq_reader($fastq_file);
    
    while (my $fastq_obj = $fastq_reader->next()) {

        my $record = $fastq_obj->get_fastq_record();
        chomp $record;
        my @x = split(/\n/, $record);
        my $acc = $x[0];
        my $seq = $x[1];
        my $qual = $x[3];

        my $new_acc;
        if ($acc =~ /\S+ 1:/) {
            my @pts = split(/\s+/, $acc);
            my @vals = split(//, $pts[1]);
            $vals[0] = 2;
            $acc = $pts[0] . " " . join("", @vals);
        }
        elsif ($acc =~ /\/1/) {
            $acc =~ s/\/1/\/2/;
        }
        else {
            die "Error, cannot decipher acc: $acc";
        }
        
        $seq = &reverse_complement($seq);
        
        my @qual_vals = split(//, $qual);
        @qual_vals = reverse @qual_vals;
        $qual = join("", @qual_vals);
        
        print join("\n", $acc, $seq, $x[2], $qual) . "\n";
    }
    
    exit(0);
}


      
