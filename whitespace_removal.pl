#!/usr/bin/env perl

use strict;
use warnings;

while (<STDIN>) {
	s/\s+//g;
	print "$_\n" if $_;
}


exit(0);

