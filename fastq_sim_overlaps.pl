#!/usr/bin/env perl

use strict;
use warnings;

use lib ($ENV{EUK_MODULES});
use Fastq_reader;
use Nuc_translator;

my $usage = "usage: $0 reads.fastq overlap_length output_prefix\n\n";

my $fastq_file = $ARGV[0] or die $usage;
my $overlap_length = $ARGV[1] or die $usage;
my $output_prefix = $ARGV[2] or die $usage;

##  Original read:
##
##   ----------------------------------------------------->
##
## sim reads:
##
##   -------------------------------->
##                   <------------------------------------
##
##                   |<--- overlap -->|

main: {

    
    my $left_fq = "${output_prefix}_O${overlap_length}_1.fastq";
    my $right_fq = "${output_prefix}_O${overlap_length}_2.fastq";

    my $fastq_reader = new Fastq_reader($fastq_file);

    open(my $left_fq_ofh, ">$left_fq") or die "Error, cannot write to file: $left_fq";
    open(my $right_fq_ofh, ">$right_fq") or die "Error, cannot write to file: $right_fq";
    
    
    while (my $fastq_obj = $fastq_reader->next()) {

        my $record = $fastq_obj->get_fastq_record();
        chomp $record;
        my @x = split(/\n/, $record);
        my $acc = $x[0];
        my $seq = $x[1];
        my $spacer = $x[2];
        my $qual = $x[3];

        my $acc2 = $acc;
        if ($acc =~ /\S+ 1:/) {
            my @pts = split(/\s+/, $acc);
            my @vals = split(//, $pts[1]);
            $vals[0] = 2;
            $acc2 = $pts[0] . " " . join("", @vals);
        }
        elsif ($acc =~ /\/1/) {
            $acc2 =~ s/\/1/\/2/;
        }
        else {
            die "Error, cannot decipher acc: $acc";
        }
        
        my $seq2 = &reverse_complement($seq);
        
        my @qual_vals = split(//, $qual);
        @qual_vals = reverse @qual_vals;
        my $qual2 = join("", @qual_vals);
        
        ## cut to overlap requirements.
        ## make ends unique and equal in length.
        my $unique_part_length = length($seq) - $overlap_length;
        $unique_part_length = int($unique_part_length/2);
        
        ## make seq1
        my $adj_seq_length = $unique_part_length + $overlap_length;
        my $seq1 = substr($seq, 0, $adj_seq_length);
        my $qual1 = substr($qual, 0, $adj_seq_length);
        
        ## make seq2
        $seq2 = substr($seq2, 0, $adj_seq_length);
        $qual2 = substr($qual2, 0, $adj_seq_length);
        
        ## print seq records:
        
        print $left_fq_ofh join("\n", $acc, $seq1, $spacer, $qual1) . "\n";
        
        print $right_fq_ofh join("\n", $acc2, $seq2, $spacer, $qual2) . "\n";
    }
    
    exit(0);
}


      
