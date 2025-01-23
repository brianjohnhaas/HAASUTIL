#!/usr/bin/env perl

use strict;
use warnings;

use lib $ENV{EUK_MODULES};
use Fasta_reader;

my $usage = "usage: $0 fastaFile\n\n";

my $file = $ARGV[0] or die $usage;

my $fasta_reader = new Fasta_reader($file);
while (my $seq_obj = $fasta_reader->next()) {
    my $sequence = $seq_obj->get_sequence();
    my $accession = $seq_obj->get_accession();
	my $header = $seq_obj->get_header();
    print length($sequence) . "\t$accession\t$header\n";
}

exit(0);

