#!/usr/bin/env perl

use strict;
use warnings;
use lib $ENV{EUK_MODULES};
use Fastq_reader;


my $usage = "\n\n\tusage: $0 interleaved.fastq output_filename_prefix\n\n";

my $interleaved_fastq_file = $ARGV[0] or die $usage;
my $output_filename_prefix = $ARGV[1] or die $usage;


main: {
    
    my $fastq_reader = new Fastq_reader($interleaved_fastq_file);

    
    open(my $left_ofh, ">${output_filename_prefix}_1.fastq") or die $!;
    open(my $right_ofh, ">${output_filename_prefix}_2.fastq") or die $!;
    
    
    my $left_fq_record = $fastq_reader->next();

    while (my $right_fq_record = $fastq_reader->next()) {
        
        if ($left_fq_record->get_core_read_name() eq $right_fq_record->get_core_read_name()
            &&
            &get_direction($left_fq_record->get_full_read_name()) eq "1"
            &&
            &get_direction($right_fq_record->get_full_read_name()) eq "2") {
            
            print $left_ofh $left_fq_record->get_fastq_record();

            print $right_ofh $right_fq_record->get_fastq_record();
        
            ## reprime left record
            $left_fq_record = $fastq_reader->next();
        }
        else {
            ## might have an unpaired read inbetween.
            $left_fq_record = $right_fq_record;
        }
    }
    
    print STDERR "done\n";
    
    exit(0);
}      


####
sub get_direction {
    my ($full_read_name) = @_;

    if ($full_read_name =~ m|/(\d)$|) {
        return("$1");
    }
    else {
        return("0");
    }
}


