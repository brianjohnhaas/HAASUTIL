#!/usr/bin/env perl

use strict;
use warnings;

my $usage = "usage: $0 max_filesize [DEBUG] < file_listing.txt\n\n";

my $max_file_size = $ARGV[0] or die $usage;
my $DEBUG = $ARGV[1] || 0;

if ($max_file_size =~ /(\D)$/) {
    my $type = uc $1;
    $max_file_size =~ s/\D$//;
    if ($type eq 'K') {
        $max_file_size *= 1e3;
    }
    elsif ($type eq 'M') {
        $max_file_size *= 1e6;
    }
    elsif ($type eq 'G') {
        $max_file_size *= 1e9;
    }
}

while (<STDIN>) {
    chomp;
    my $filename = $_;
    if (-f $filename) {
        my $filesize = -s $filename;
        if ($filesize >= $max_file_size) {
            print "$filesize\t$filename";
            if ($DEBUG) {
                print " [DEBUG mode]\n";
            }
            else {
                print " // removing.\n";
                unlink($filename) or print STDERR "Error, cannot remove file: $filename\n";
            }
        }
    }
}


exit(0);
