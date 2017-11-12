#!/usr/bin/perl -w

use strict;
use warnings;
# use Win32::Unicode::File;
use Encode;

my $comma = ',';
my $separator = ';';
my $replace = '';
my $search = '';

my $nlines;

my $fname = shift @ARGV;
my $outfname = $fname.".bla";

# Options
my $option1 = 0;
my $option2 = 0;
my $option3 = 0;
my $option4 = 0;
my $option5 = 0;
my $option6 = 0;

countLinesFast();
convertIt();

sub countLinesFast {
	$nlines = 0;
	if (open(my $fh, "< :encoding(UTF-8)", $fname)){
		my $crap = <$fh>; $crap = <$fh>;
        my $filesize = -s "$fname";
		$nlines = int($filesize / length($crap));
		close $fh;
	}else{
		print "Couldn't open file: $!\n";
	}
	print "Status: Number of lines in file is $nlines\n";
}

sub convertIt {
	$replace = "" unless defined $replace;
    $search = "" unless defined $search;
    my $searchReg = eval { qr/$search/ }; warn $@ if $@; #print "$searchReg\n";
    #open(my $fh, "< :encoding(UTF-8)", $fname) or die "Couldn't open file $!\n";
    open(my $fh, "<", $fname) or die "Couldn't open file $!\n";
    open(my $outfh, ">:encoding(UTF-8)", $outfname) or die "Couldn't open file $!\n";
    print "Status: Converting file.....\n";
    my $cntr = 0;
    while (my $line = <$fh>){
        #$line =~ s/\0/\\N/g if $option1 == 1;
        #$line =~ s/ 00:00:00\.000//g if $option5 == 1;
        #$line =~ s/$separator\Q$comma\E([0-9]{2})[0-9]*/$separator\E0$comma$1/g if $option2 == 1;
        #$line =~ s/(-?[0-9]+)\Q$comma\E([0-9]{2})[0-9]*/$1$comma$2/g if $option3 == 1;
        #$line =~ s/$searchReg/$replace/g if ($option6 == 1 && defined $searchReg);
        #$line = encode("utf-8",$line,Encode::FB_CROAK) if $option4 == 1;
        print $outfh $line;
        if($cntr % 100 == 0){
            my $prog = int($cntr/$nlines*1000)/10;
            print "Status: Converted $cntr lines of $nlines ($prog\%)\n";
        }
        $cntr++;
    }
    close $fh;
    close $outfh;
    print "Status: Finished converting file!\n";
}

