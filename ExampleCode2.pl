#!/usr/bin/perl -w

use strict;
use warnings;

my $fname = shift @ARGV;

if (open(my $fh, '<', $fname)){
	while (my $line = <$fh>){}
	close $fh;
}else{ print "Couldn't open file: $!\n";}