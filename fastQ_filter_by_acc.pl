#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

my $usage = "usage: $0 inputFile.fq accs.list.file [monitor=0]\n\n";

my $inputFile = $ARGV[0] or die $usage;
my $accs_list_file = $ARGV[1] or die $usage;
my $MONITOR = $ARGV[2];


unless ($inputFile =~ /fq|fastq/) {
    die "Error, fastq file lacks fq or fastq in name\n\n\t$usage\n";
}

my %accs_want;
{
    open (my $fh, $accs_list_file) or die $!;
    while (<$fh>) {
        chomp;
        my $acc = $_;
        $acc =~ s|/[12]$||; # remove any read end indicator
        $accs_want{$acc} = 1;
    }
    close $fh;
}

my $fh;


my %missing = %accs_want;

if ($inputFile =~ /\.gz$/) {
    open ($fh, "gunzip -c $inputFile | ") or die "Error, cannot open $inputFile";
}
else {
    open ($fh, $inputFile) or die "Error, cannot open $inputFile";
}


my $counter = 0;
my $num_clean = 0;
my $num_dirty = 0;

my @rec;

my $line = <$fh>;

while ($line) {

	if ($line =~ /^\@/) {
		$counter++;
		
		print STDERR "\r[$counter] [$num_clean clean] [$num_dirty dirty]       " if ($MONITOR && $counter % 10000 == 0);
		
		push (@rec, $line);
		
		$line = <$fh>;
		for (1..3) {
			push (@rec, $line);
			$line = <$fh>;
		}
		
		my $record_text = join("", @rec);

		my $header = shift @rec;
		my $seq = shift @rec;
		my $qual_header = shift @rec;
		my $qual_line = shift @rec;
				
		chomp $header;
		chomp $seq if $seq;
		chomp $qual_header if $qual_header;
		chomp $qual_line if $qual_line;
		
        my $acc = $header;
        my @y = split(/\s+/, $acc);
        $acc = $y[0];
        $acc =~ s/^\@//;
        $acc =~ s/\/[12]$//;
        #print STDERR "ACC: $acc\n";
        unless ($accs_want{$acc}) {
            next;
        }


        
		if ($header && $seq && $qual_header && $qual_line && 
			$qual_header =~ /^\+/ && length($seq) == length($qual_line)

            
            
            ) {
			
			# can do some more checks here if needed to be sure that the lines are formatted as expected.
			print join("\n", $header, $seq, $qual_header, $qual_line) . "\n";
			$num_clean++;

            delete($missing{$acc});
        }
		else {

			$num_dirty++;
		}
		@rec = ();
	} else {
		$line = <$fh>;
	}
	
}


print STDERR "[$counter] [$num_clean clean] [$num_dirty dirty]       \n";

if (%missing) {
    print STDERR "-error, missing retrieval for accessions: " . Dumper(%missing);
}

exit(0);


		
		
		
		
