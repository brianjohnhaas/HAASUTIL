#!/usr/bin/env perl

unless (@params = @ARGV) {
    die "usage: $0 [-t|-s] <number list | range>\n";
}

$delimeter = pop @params;

if ($delimeter eq '-s' || $delimeter eq '-t') {
    if ($delimeter eq '-s') {
        $delimeter = '\s+';
    } elsif ($delimeter eq '-t') {
        $delimeter = '\t';
    }
    pop @ARGV;
} else {
    $delimeter = '\t';
}

if ($ARGV[0] =~ /(^\d+)\-(\d+)/) {
    #print "$1\t$2\n";
    @array = ($1 .. $2);
    
} else {
    @array = @ARGV;
}




my $EXCLUSION_MODE = 0;

foreach $entry (@array) {
        
    if ($entry < 0) {
        if (! $EXCLUSION_MODE) { print STDERR " -- running in exclusion mode.\n"; }
        $EXCLUSION_MODE = 1;
    }

    $here{ abs($entry) } = 1;

}


while (<STDIN>) {
    chomp;
    #my $tab = 0;
    @columns = split (/$delimeter/, $_);
    my $output = "";
    for ($i = 0; $i <= $#columns; $i++) {
		#if ($tab) { print "\t";}
		if ( 
            ($here{$i} && ! $EXCLUSION_MODE) 
            ||
            ($EXCLUSION_MODE && ! $here{$i}) 
            ) {
			#print $columns[$i];
			$output .= "$columns[$i]\t";
			#$tab = 1;
		}
    }
	$output =~ s/\s+$//; # remove trailing ws.
    print "$output\n";
}

