#!/usr/bin/env perl

use strict;
use warnings;

my @params = @ARGV;
unless (@params = @ARGV) {
    die "usage: $0 [-t|-s] <number list | range>\n";
}

my $delimeter = pop @params;

if (defined($delimeter) && ($delimeter eq '-s' || $delimeter eq '-t')) {
    if ($delimeter eq '-s') {
        $delimeter = " ";
    } elsif ($delimeter eq '-t') {
        $delimeter = "\t";
    }
    pop @ARGV;
} else {
    $delimeter = "\t";
}

my @array;
if ($ARGV[0] =~ /(^\d+)\-(\d+)/) {
    #print "$1\t$2\n";
    @array = ($1 .. $2);
    
} else {
    @array = @ARGV;
}
    
my %here;
foreach my $entry (@array) {
    $here{$entry} = 1;
}


while (<STDIN>) {
    chomp;
    #my $tab = 0;
    my @columns = split (/$delimeter/, $_);

    my @fields;
    for (my $i = 0; $i <= $#columns; $i++) {
        if ($here{$i}) {
            push (@fields, "$columns[$i]");
        }
    }
    
    print join($delimeter, @fields) . "\n";
}

