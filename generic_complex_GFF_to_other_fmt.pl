#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

use lib ($ENV{EUK_MODULES});
use Gene_obj;
use URI::Escape;

use Getopt::Long qw(:config no_ignore_case bundling pass_through);


my $usage = <<__EOUSAGE__;

###############################################################################
#
#  --gff <string>     gff input file
#  
#  --ignore <string>   list of features to ignore (ie.  "repeat_region|region|telomere|binding_site")
#                      include the list as pipe-separated (a regex)
#
#  --UTR <int>         length to extend transcript length on each end
#
#  --out_fmt <string>   output format.  Options include: (transcript_GTF, GFF3)  By default: transcript_GTF
#
#
################################################################################

__EOUSAGE__

    ;



my $help_flag;


my $gff_file;
my $extend_UTRs = 0;
my $IGNORE_STRING = "";
my $out_fmt = "transcript_GTF";

&GetOptions ( 'h' => \$help_flag,
              'gff=s' => \$gff_file,
              'UTR=i' => \$extend_UTRs,
              'ignore=s' => \$IGNORE_STRING,
              
              'out_fmt=s' => \$out_fmt,
              
              );



if ($help_flag || ! $gff_file) {
    die $usage;
}

if ($out_fmt !~ /^(transcript_GTF|GFF3)$/) {
    
    die $usage;
}


my %data;
my %chromosome_coords;

main: {
    
    my @parent_structs = &parse_gff($gff_file);

    foreach my $struct (@parent_structs) {

        my @structs_have_term_children;
        &get_structs_have_term_children($struct, \@structs_have_term_children); # recursive call

        foreach my $struct_has_term (@structs_have_term_children) {
            
        
            my %exon_coords = &get_exon_coords($struct_has_term);

            my $gene_id = $struct->{ID};
            my $trans_id = $struct_has_term->{ID};
            
            my $gene_obj = new Gene_obj();
            

            
            
            #$gene_obj->join_adjacent_exons();
            
            if (my %cds_coords = &get_CDS_coords($struct_has_term)) {
                $gene_obj = new Gene_obj();
                
                #print STDERR "------------------------------\n";
                #print STDERR "Exons: " . Dumper(\%new_exon_coords) . "\n";
                #print STDERR "CDSs: " . Dumper(\%cds_coords) . "\n\n";

                unless (%exon_coords) {
                    %exon_coords = %cds_coords;
                }
                    
                $gene_obj->populate_gene_obj(\%cds_coords, \%exon_coords);
            }
            elsif (%exon_coords) {
                $gene_obj->populate_gene_obj({}, \%exon_coords);
            }
            else {
                print STDERR "-no exons for feature: $gene_id, skipping...\n";
                next;
            }
            
            $gene_obj->{TU_feat_name} = $gene_id;
            $gene_obj->{Model_feat_name} = $trans_id;
            $gene_obj->{asmbl_id} = $struct->{chr};
            
            $gene_obj->{com_name} = "";
            if (my $name = $struct->{info}->{Name}) {
                $gene_obj->{com_name} = $name;
            }
            if (my $note = $struct->{info}->{Note}) {
                $gene_obj->{com_name} .= " $note";
            }
            
            
            if ($extend_UTRs) {
                &extend_UTRs($gene_obj, $extend_UTRs);
            }
            
            if ($out_fmt eq 'transcript_GTF') {
                print $gene_obj->to_transcript_GTF_format();
            }
            elsif ($out_fmt eq 'GFF3') {
                print $gene_obj->to_GFF3_format();
            }
            else {
                die "Error, output format \'$out_fmt\' is unsupported.    ";
            }
            
        }
    }

    exit(0);
}


####
sub get_exon_coords {
    my ($struct) = @_;
    
    my @feats = @{$struct->{children}};
    unless (@feats) {
        @feats = ($struct);
    }
    
    my %coords;

    foreach my $feat (@feats) {
        if ($feat->{feat_type} =~ /exon/i) {
            my ($end5, $end3) = ($feat->{orient} eq '+') ? ($feat->{lend}, $feat->{rend}) : ($feat->{rend}, $feat->{lend});
            
            $coords{$end5} = $end3;
        }
    }
    

    return(%coords);
}


####
sub get_CDS_coords {
    my ($struct) = @_;

    my %coords;
    
    my @feats = &get_children($struct);
    
    foreach my $feat (@feats) {
        if ($feat->{feat_type} eq 'CDS') {
            my ($end5, $end3) = ($feat->{orient} eq '+') ? ($feat->{lend}, $feat->{rend}) : ($feat->{rend}, $feat->{lend});
            
            $coords{$end5} = $end3;
        }
    }
    
    return(%coords);
}   


sub get_children {
    my $struct = shift;
    return (@{$struct->{children}}); 
}

sub has_children { 
    my $struct = shift;
    
    return( scalar (&get_children($struct) > 0) ); 
}


####
sub parse_gff {
    my ($gff_file) = @_;

    my %ID_to_feature;
    my @all_features;

    open (my $fh, $gff_file) or die $!;
    while (<$fh>) {
        my $line = $_;
        if (/^\#/) { next; }
        unless (/\w/) { next; }
        chomp;
        my @x = split(/\t/);
        
        unless (scalar(@x) >= 9) { 
            #print STDERR "-ignoring line: $line";
            next;
        }
        
        my $chr = $x[0];
        my $feat_type = $x[2];
        my $lend = $x[3];
        my $rend = $x[4];
        my $orient = $x[6];
        my $info = $x[8];


        if ($feat_type eq 'chromosome') {
            $chromosome_coords{$chr} = $rend;
        }
        
        if ($IGNORE_STRING && $feat_type =~ /^($IGNORE_STRING)$/) { next; }
        
        my %info_parsed = &parse_info_into_keyval_pairs($info);


        
        
        my $struct = { chr => $chr,
                       feat_type => $feat_type,
                       lend => $lend,
                       rend => $rend,
                       orient => $orient,
                       info => \%info_parsed,
                       parent => undef,
                       ID => undef,
                       line => $line,
                       children => [],

        };
        

        if (my $parent = $info_parsed{Parent}) {

            $struct->{parent} = $parent;

        }
        if (my $ID = $info_parsed{ID}) {
            $struct->{ID} = $ID;
            $ID_to_feature{$ID} = $struct;
        }
        
        push (@all_features, $struct);
 
    }


    my @parent_features = &trickle_to_parents(\%ID_to_feature, \@all_features);

    return(@parent_features);
        
}

####
sub trickle_to_parents {
    my ($ID_to_feature_href, $all_features_aref) = @_;

    my @parent_features;
    
    foreach my $feature (@$all_features_aref) {
        if (my $parent = $feature->{parent}) {
            my $parent_struct = $ID_to_feature_href->{$parent} or die "Error, no struct found for parent: $parent";
            push (@{$parent_struct->{children}}, $feature);
        }
        else {
            # has no parent, so is a parent
            push (@parent_features, $feature);
        }
    }
    
    return(@parent_features);
}




####
sub parse_info_into_keyval_pairs {
    my ($info) = @_;
    
    unless ($info) { 
        return(); 
    }
    

    my %data;

    my @pts = split(/;/, $info);

    foreach my $pt (@pts) {
        my ($key, $val) = split(/=/, $pt);

        $val = uri_unescape($val);

        $val =~ s/\"//g;
        
        $data{$key} = $val;
        
    }

    return(%data);

}


####
sub extend_UTRs {
    my ($gene_obj, $extend_len) = @_;

    my $chr = $gene_obj->{asmbl_id};
    my $chr_end = $chromosome_coords{$chr} or die "Error, no max coord for $chr";

    my @exons = $gene_obj->get_exons();
    
    my $first_exon = $exons[0];
    my $last_exon = $exons[$#exons]; # ok to be the same as first if single exon
    
    if ($gene_obj->get_orientation() eq '+') {
        
        $first_exon->{end5} -= $extend_len;
        if ($first_exon->{end5} < 1) { $first_exon->{end5} = 1; }
        
        $last_exon->{end3} += $extend_len;
        
        if ($last_exon->{end3} > $chr_end) { $last_exon->{end3} = $chr_end; }
    }
    else {
        
        $first_exon->{end5} += $extend_len;
        
        if ($first_exon->{end5} > $chr_end) { $first_exon->{end5} = $chr_end; }
        
        $last_exon->{end3} -= $extend_len;
        
        if ($last_exon->{end3} < 1) { $last_exon->{end3} = 1; }
        
    }

    return;
}


####
sub get_exon_coords_from_gene_obj {
    my ($gene_obj) = @_;

    my %exon_coords;
    
    my @exons = $gene_obj->get_exons();
    foreach my $exon (@exons) {
        my ($end5, $end3) = $exon->get_coords();
        $exon_coords{$end5} = $end3;
    }

    return(%exon_coords);
}

####
sub get_structs_have_term_children {
    my ($struct, $structs_have_term_children_aref) = @_;

    # recursive function
    
    my @children = &get_children($struct);

    if (@children) {
        my $child_has_children_flag = 0;
        foreach my $child (@children) {
            if (&has_children($child)) {
                $child_has_children_flag = 1;
                &get_structs_have_term_children($child, $structs_have_term_children_aref);
            }
        }
        unless ($child_has_children_flag) {
            # at a struct that has term children
            push (@$structs_have_term_children_aref, $struct);
        }
    }


    return;
}


    
        
