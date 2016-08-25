#!/usr/bin/env perl


# See: https://rstudio-pubs-static.s3.amazonaws.com/13301_6641d73cfac741a59c0a851feb99e98b.html
#  for nice intro to VennDiagram

use strict;
use warnings;

my $usage = "\n\n\tusage: $0 venn.txt [ranked classes to consider otherwise lexically ordered]\n\n";

my $venn_txt_file = shift @ARGV;
unless ($venn_txt_file) {
    die $usage;
}

my %classes;

my $rank = 0;
while (@ARGV) {
    $rank++;
    my $ele = shift @ARGV;
    $classes{$ele} = $rank;
    
    
}


my %VENN_PARTITIONS = ( SIZE_2 => ["1", "2", "1,2"],
                        SIZE_3 => ["1", "2", "3", "1,2", "1,3", "2,3", "1,2,3"],
                        SIZE_4 => ["1", "2", "3", "4", 
                                   "1,2", "1,3", "1,4",
                                   "2,3", "2,4",
                                   "3,4",
                                   "1,2,3", "1,2,4", "1,3,4",
                                   "2,3,4",
                                   "1,2,3,4"]
);




main : {


    my %class_to_feature_list;
    
    open (my $fh, $venn_txt_file) or die "Error, cannot open file $venn_txt_file";
    while (<$fh>) {
        chomp;
        my @x = split(/\t/);
        my ($feature, $class_list) = ($x[0], $x[1]);

        my @c = split(",", $class_list);

        foreach my $class (@c) {
            unless (exists $classes{$class}) {
                $classes{$class} = -1; # placeholder. update ranking later
            }
            $class_to_feature_list{$class}->{$feature} = 1;
        }
                
    }
    close $fh;


    my %rank_to_class;
    foreach my $class (sort keys %classes) {
        if ($classes{$class} < 0) {
            $rank++;
            $classes{$class} = $rank;
        }
        $rank_to_class{ $classes{$class} } = $class;
    }
    
    
    my $num_classes = scalar(keys %classes);
    
    my $size_token = "SIZE_${num_classes}";
    my $venn_partitions_aref = $VENN_PARTITIONS{$size_token} or die "Error, no size partition listing for $size_token";

    my @counts;
    foreach my $venn_partition (@$venn_partitions_aref) {
        
        my @classes_want;
        foreach my $rank (split(/,/, $venn_partition)) {
            my $class = $rank_to_class{$rank};

            push (@classes_want, $class);
        }
        my $classes_want_string = join(",", @classes_want);
        
        my $first_class = shift @classes_want;
        my $first_class_features_href = $class_to_feature_list{$first_class};
        
        my $venn_counts = 0;
        if (@classes_want) {
            foreach my $feature (keys %$first_class_features_href) {
                my $missing_flag = 0;
                foreach my $class (@classes_want) {
                    unless ($class_to_feature_list{$class}->{$feature}) {
                        $missing_flag = 1;
                        last;
                    }
                }
                unless ($missing_flag) {
                    $venn_counts++;
                }
            }
            
        }
        else {
            # just one class. Count features.
            $venn_counts = scalar(keys %$first_class_features_href);
        }
        push (@counts, $venn_counts);
        print join("\t", $venn_partition, $classes_want_string, $venn_counts) . "\n";
    }
    
        
    my @ranked_classes = sort {$classes{$a}<=>$classes{$b}} keys %classes;

    my $Rcmd = "";
    if ($num_classes == 4) {
        $Rcmd = &draw_quad(\@counts, \@ranked_classes);
    }

    my $rscript = "__tmp.vennDiag$num_classes.Rscript";
    open(my $ofh, ">$rscript") or die $!;
    print $ofh "library(VennDiagram)\n";
    print $ofh "pdf(\"vennDiag$num_classes.pdf\")\n";
    print $ofh $Rcmd;
    close $ofh;
    
    my $ret = system("Rscript $rscript");
    if ($ret) {
        die "Error, cmd Rscript $rscript died with ret $ret";
    }
    print STDERR "Done.  See vennDiagram$num_classes.pdf\n\n";
    
    
    exit(0);
}

####
sub draw_quad {
    my ($counts_aref, $classes_aref) = @_;
    
    my $cmd = "draw.quad.venn(" . join(",", @$counts_aref)
        . ", category=c(\'" . join("\',\'", @$classes_aref) . "\')"
        . ", fill = c('skyblue', 'pink1', 'mediumorchid', 'orange' ) )\n";
    
    return($cmd);

}


