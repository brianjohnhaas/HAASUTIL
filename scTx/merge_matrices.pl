#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "usage: $0 label1:matrix_file1 label2:matrix_file2 [....]\n\n";

my @files_n_labels = @ARGV;

unless (scalar(@files_n_labels) >= 2) {
    die $usage;
}

main: {

    my %genes_to_cells;
    my %cells;

    foreach my $label_n_file (@files_n_labels) {
        &parse_matrix($label_n_file, \%genes_to_cells, \%cells);
    }

    my @all_cells = sort keys %cells;

    my @genes = sort keys %genes_to_cells;

    ## output matrix;
    
    print "\t" . join("\t", @all_cells) . "\n";
    foreach my $gene (@genes) {
        my @vals = ($gene);
        foreach my $cell (@all_cells) {
            my $expr = $genes_to_cells{$gene}->{$cell} || 0;

            push (@vals, $expr);
        }
        
        print join("\t", @vals) . "\n";
    }
    
    print STDERR "Done.\n";
    
    exit(0);
    
    
}


####
sub parse_matrix {
    my ($label_n_file, $genes_to_cells_href, $cells_href) = @_;

    my ($label, $file) = split(/:/, $label_n_file);
    unless ($label) { die "Error, need label as label:file format for parsing"; }
    
    open (my $fh, $file) or die "Error, cannot open file $file";
    print STDERR "-parsing file: $file, label: $label\n";
    
    my $header = <$fh>;
    chomp $header;
    my @cells = split(/\t/, $header);
    if ($cells[0] !~ /\w/) {
        shift @cells;
    }
    
    # add label to cells
    foreach my $cell (@cells) {
        $cell = "$label" . "_" . $cell;
        $cells_href->{$cell} = 1;
    }
    
    print STDERR "Got cells: " . join(", ", @cells) . "\n";
    
    while (<$fh>) {
        chomp;
        my @x = split(/\t/);
        my $gene_id = shift @x;
        #print STDERR "gene_id: $gene_id\n";
        
        for (my $i = 0; $i <= $#x; $i++) {
            my $expr_val = $x[$i];
            if ($expr_val > 0) {
                my $cell = $cells[$i];
                #print STDERR "Cell: $cell, expr: $expr_val\n";
                $genes_to_cells_href->{$gene_id}->{$cell} = $expr_val;
            }
        }
    }
    
    
    close $fh;

    return;
}
