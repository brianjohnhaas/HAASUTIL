#!/usr/bin/env perl

use strict;
use warnings;

use lib ($ENV{EUK_MODULES});
use Fasta_reader;


my $usage = "usage: $0  seqs.fasta\n\n";

my $seqs_file = $ARGV[0] or die $usage;


my $seqs_file_nr_fa = "$seqs_file.nr.fa";
my $seqs_file_nr_details = "$seqs_file.nr.details";


open(my $ofh_fa, ">$seqs_file_nr_fa");
open(my $ofh_details, ">$seqs_file_nr_details");


my $fasta_reader = new Fasta_reader($seqs_file);

my %seq_to_acc_list;

while (my $seq_obj = $fasta_reader->next()) {
    my $accession = $seq_obj->get_accession();
    my $sequence = $seq_obj->get_sequence();
    if (! exists $seq_to_acc_list{$sequence}) {
        print $ofh_fa ">$accession\n$sequence\n";
    }
    push (@{$seq_to_acc_list{$sequence}}, $accession);
}


foreach my $sequence (keys %seq_to_acc_list) {
    my @accs = @{$seq_to_acc_list{$sequence}};
    my $num_accs = scalar(@accs);
    my $ref_entry = shift @accs;
    print $ofh_details "$ref_entry\t$num_accs\t" . join(",", @accs) . "\n";
}

exit(0);

