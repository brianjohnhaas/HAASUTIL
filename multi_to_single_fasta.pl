#!/usr/bin/env perl

use strict;
use warnings;

use lib ($ENV{EUK_MODULES});
use Fasta_reader;

my $fasta_file = $ARGV[0] || *STDIN{IO};

my $fasta_reader = new Fasta_reader($fasta_file);

while (my $seq_obj = $fasta_reader->next()) {
	
	my $sequence = $seq_obj->get_sequence();

	my $accession = $seq_obj->get_accession();

	my $header = $seq_obj->get_header();

	$accession =~ s/[^\w\.]/_/g;
	
	open (my $fh, ">$accession") or die $!;
	print $fh ">$header\n$sequence\n";
	close $fh;
}

exit(0);

