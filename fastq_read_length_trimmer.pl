#!/usr/bin/env perl

use strict;
use warnings;

use lib ($ENV{EUK_MODULES});
use Fastq_reader;

my $usage = "usage: $0 reads.fastq targeted_length\n\n";

my $fastq_file = $ARGV[0] or die $usage;
my $targeted_length = $ARGV[1] or die $usage;

main: {

    my $fastq_reader = new Fastq_reader($fastq_file);
    
    while (my $fastq_obj = $fastq_reader->next()) {

        my $record = $fastq_obj->get_fastq_record();
        chomp $record;
        my @x = split(/\n/, $record);
        $x[1] = substr($x[1], 0, $targeted_length);
        $x[3] = substr($x[3], 0, $targeted_length);

        print join("\n", @x) . "\n";
    }

    exit(0);
}


      
