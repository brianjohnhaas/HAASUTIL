#!/usr/bin/env perl

use strict;
use warnings;

use lib ($ENV{EUK_MODULES});
use Fastq_reader;
use File::Basename;

my $usage = "usage: $0 left.fq right.fq num_entries\n\n";

my $left_fq = $ARGV[0] or die $usage;
my $right_fq = $ARGV[1] or die $usage;
my $num_entries = $ARGV[2] or die $usage;

main: {
    
    print STDERR "-counting entries in file: ";
    my $total_entries = `wc -l $left_fq`;
    $total_entries =~ /^\s*(\d+)/ or die "Error, cannot determine number of reads in $left_fq";
    
    $total_entries = $1;
    $total_entries /= 4; # 4 lines per fastq record

    print STDERR "$total_entries, now randomly selecting $num_entries\n";
    
    if ($num_entries >= $total_entries) {
        die "Error, num_entries $num_entries >= total records available: $total_entries ";
    }
        
    print STDERR "-selecting entries.\n";
    
    my $left_fq_reader = new Fastq_reader($left_fq);
    my $right_fq_reader = new Fastq_reader($right_fq);
    
    my $num_M_entries = $num_entries/1e6;
    $num_M_entries .= "M";
    my $base_left_fq = basename($left_fq);
    my $base_right_fq = basename($right_fq);
    
    open (my $left_ofh, ">$base_left_fq.$num_M_entries.fq") or die $!;
    open (my $right_ofh, ">$base_right_fq.$num_M_entries.fq") or die $!;
    
    srand();

    my $num_skipped = 0;
    my $num_output_entries = 0;
    my $num_entries_read = 0;
    while ($num_output_entries < $num_entries) {
        
        my $num_entries_remaining = $num_output_entries - $num_entries_read;
        my $num_entries_still_need = $num_entries - $num_output_entries;
        
        if ($num_entries_remaining == $num_entries_still_need
            ||
            rand(1) <= $num_entries/$total_entries) {
            
            my $left_entry = $left_fq_reader->next();
            my $right_entry = $right_fq_reader->next();

            unless ($left_entry && $right_entry) {
                die "Error, didn't retrieve both left and right entries from file ($left_entry, $right_entry) ";
            }
            unless ($left_entry->get_core_read_name() eq $right_entry->get_core_read_name()) {
                die "Error, core read names don't match: " 
                    . "Left: " . $left_entry->get_core_read_name() . "\n"
                    . "Right: " . $right_entry->get_core_read_name() . "\n";
            }

            $num_output_entries++;

            print $left_ofh $left_entry->get_fastq_record();
            print $right_ofh $right_entry->get_fastq_record();

        }
        else {
            $num_skipped++;

        }

        #print STDERR "\r[selected: $num_output_entries, skipped: $num_skipped]   " if ( ($num_skipped + $num_output_entries) % 1000 == 0);
        
    }
    
    print STDERR "\r[selected: $num_output_entries, skipped: $num_skipped]   ";

    print STDERR "\n\nDone.\n";

    close $left_ofh;
    close $right_ofh;


    exit(0);
}


