#!/usr/bin/env perl

use strict;
use warnings;
use lib ($ENV{EUK_MODULES});
use Fasta_reader;
use Overlap_piler;



my $usage = "\n\n\tusage: $0 genome.fasta mask.bed\n\n";

my $fasta_file = $ARGV[0] or die $usage;
my $coords_file = $ARGV[1] or die $usage;



my %acc_to_coords;

open(my $fh, $coords_file);
while(my $line = <$fh>) {
    chomp $line;
    my @x = split(/\t/, $line);

    unless (scalar(@x) >= 3) { next; }
    
    my $contig_acc = $x[0];
    my $begin = int($x[1]);
    my $end = int($x[2]);
    ($begin, $end) = sort {$a<=>$b} ($begin, $end);
    
    push (@{$acc_to_coords{$contig_acc}}, [$begin, $end]);

}


my $fasta_reader = new Fasta_reader($fasta_file);
while (my $seq_obj = $fasta_reader->next()) {
    my $accession = $seq_obj->get_accession();
    
    if (exists $acc_to_coords{$accession}) {
        print STDERR "-performing masking on $accession\n";
        my @coords = @{$acc_to_coords{$accession}};
        @coords = &Overlap_piler::simple_coordsets_collapser(@coords);
        
        # mask them:
        my $sequence = $seq_obj->get_sequence();
        my @chars = split(//, $sequence);
        foreach my $coordset (@coords) {
            my ($lend, $rend) = @$coordset;
            for (my $i = $lend - 1; $i < $rend; $i++) {
                $chars[$i] = 'N';
            }
        }
        $seq_obj->{sequence} = join("", @chars);
        
        
    }

    my $fasta_record = $seq_obj->get_FASTA_format();
    print($fasta_record);
    
}
