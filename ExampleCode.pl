#!/usr/bin/perl -w

use strict;
use warnings;
use Win32::Unicode::File;

my $fname = shift @ARGV;
my $fh = Win32::Unicode::File->new;

if ($fh->open('<', $fname)){
	while (my $line = $fh->readline()){}
	close $fh;
}else{
	print "Couldn't open file: $!\n";
}