#!/usr/bin/perl -w

use strict;
use warnings;
use Tkx;
#use Win32::Unicode::File;
use Encode;

# Global vars
my $types = [['All Text Files', ['.txt', '.text', '.csv'], 'TEXT'], ['CSV Files only', '.csv', 'TEXT']];
my $search;
my $replace;
my $fname;
my $outfname;
my $nlines;
my $separator;
my $comma;
my $option1 = 0;
my $option2 = 0;
my $option3 = 0;
my $option4 = 0;
my $option5 = 0;
my $option6 = 0;

# Main Window
#my $mw = new MainWindow;
my $mw = Tkx::widget->new(".");
my $lab = $mw ->new_label(-text=>"This program converts a text file to Unicode \nand formats it to a suitable MySQL format.",
		-font=>"ansi 12 bold"); # -> pack(-pady => 10);

# Status section
my $status = $mw ->new_label(-text=>"Status: ", -font=>"ansi 12 bold");# -> pack(-pady => 10, -side => 'bottom', -expand => 1, -anchor => 'w');

#my $bar2 = $mw->ProgressBar( -padx=>2, -pady=>2, -borderwidth=>2,
#			  -troughcolor=>'#BFEFFF', -colors=>[ 0, '#104E8B' ],
#			  -length=>300 )->pack(-side => 'bottom', -anchor => 'w', -pady => 10, -expand => 1);

# Separator selection
my $frm_separator = $mw->new_frame(-borderwidth=>3, -relief=>'sunken');
my $lbl_separator = $frm_separator->new_label(-text=>"Separator: "); #->pack(-side => 'left', -expand => 1);
my $rb = $frm_separator->new_radiobutton(-text=>";", -value=>";", -variable=>\$separator); #->pack(-side => 'left', -expand => 1, -padx => 10);
$frm_separator->new_radiobutton(-text=>",", -value=>",",-variable=>\$separator); #->pack(-side => 'left', -expand => 1, -padx => 10);
$frm_separator->new_radiobutton(-text=>"TAB", -value=>"\t",-variable=>\$separator); #->pack(-side => 'left', -expand => 1, -padx => 10);
#$frm_separator->pack(-anchor => 'w', -pady => 10);
$rb->select();

# Comma separator selection
my $frm_comma = $mw ->new_frame(-borderwidth=>3, -relief=>'sunken');
my $lbl_comma = $frm_comma ->new_label(-text=>"Comma character: "); #->pack(-side => 'left', -expand => 1);
my $rb2 = $frm_comma -> new_radiobutton(-text=>".", -value=>".",  -variable=>\$comma); #->pack(-side => 'left', -expand => 1, -padx => 10);
$frm_comma ->new_radiobutton(-text=>",", -value=>",",-variable=>\$comma); #->pack(-side => 'left', -expand => 1, -padx => 10);
#$frm_comma->pack(-anchor => 'w', -pady => 10);
$rb2->select();

# General search and replace
my $cb6 = $mw->new_checkbutton(-text => "Use own search and replace", -variable=>\$option6, -command =>\&deactivateRegExp); #->pack(-anchor=>'w');
my $frm_sr = $mw -> new_frame(-borderwidth=>3, -relief=>'sunken');
$frm_sr->new_label(-text => "Use Perl regular expressions\nto search and replace. This allows you\nto perform powerful replacements!"); #->pack(-side => 'left', -expand => 1, -anchor=>'w');
$frm_sr->new_label(-text=>"Search: "); #->pack(-side => 'top');
my $sEntry = $frm_sr->new_entry(-state=>'disabled', -textvariable => \$search ); #->pack(-side => 'top');
my $rEntry = $frm_sr->new_entry(-state=>'disabled', -textvariable => \$replace ); #->pack(-side => 'bottom');
$frm_sr->new_label(-text=>"Replace: "); #->pack(-side => 'bottom');
#$frm_sr->pack(-pady => 5);

# What to replace
my $cb1 = $mw->new_checkbutton(-text => "Replace ASCII NUL with \\N", -variable=>\$option1); #->pack(-side => 'top', -expand => 1, -anchor=>'w');
my $cb2 = $mw->new_checkbutton(-text => "Format .000000 to 0.00", -variable=>\$option2); #->pack(-side => 'top', -expand => 1, -anchor=>'w');
my $cb3 = $mw->new_checkbutton(-text => "Format all numbers to two decimals", -variable=>\$option3); #->pack(-side => 'top', -expand => 1, -anchor=>'w');
my $cb4 = $mw->new_checkbutton(-text => "Convert to Unicode", -variable=>\$option4); #->pack(-side => 'top', -expand => 1, -anchor=>'w');
my $cb5 = $mw->new_checkbutton(-text => "Remove timestame from date", -variable=>\$option5); #->pack(-side => 'top', -expand => 1, -anchor=>'w');

# Action buttons
my $quitbutton = $mw->new_button(-text=>"Quit", -command => \&quitProgram); #->pack(-side => 'right', -expand => 1, -pady => 10);
my $runbutton = $mw->new_button(-text=>"Convert it!", -command => \&convertIt); #->pack(-side => 'right', -expand => 1, -pady => 10);
my $button = $mw->new_button(-text=>"Load file", -command => \&chooseFile); #->pack(-side => 'right', -expand => 1, -pady => 10);

# SUBROUTINES
sub chooseFile {
	$fname = $mw -> getOpenFile(-filetypes=>$types);
	if(defined $fname){
		my($directory, $filename) = $fname =~ m/(.*\/)(.*)$/;
		$status->configure(-text => "Status: Selected file $filename");
		$outfname = "$directory"."new_$filename";
		countLinesFast();
	}
	#print STDERR "$directory\n";
	#print STDERR "$option1\n";
	#$mw -> messageBox(-type=>"ok", -message=>"$fname");
}

sub deactivateRegExp {
	$sEntry->configure(-state=>'disabled') if $option6 == 0;
	$sEntry->configure(-state=>'normal') if $option6 == 1;
	$rEntry->configure(-state=>'disabled') if $option6 == 0;
	$rEntry->configure(-state=>'normal') if $option6 == 1;
}

sub convertIt {
	unless(defined $fname){
		$mw -> messageBox(-type=>"ok", -message=>"You have to load a file before you can convert it!");
	}else{
		$replace = "" unless defined $replace;
		$search = "" unless defined $search;
		my $searchReg = eval { qr/$search/ }; warn $@ if $@; #print "$searchReg\n";
		my $fh = Win32::Unicode::File->new;
		my $outfh = Win32::Unicode::File->new;
		if ($fh->open('<', $fname) && $outfh->open('>', $outfname)){
			$status->configure(-text => "Status: Converting file.....");
			my $cntr = 0;
			while (my $line = $fh->readline()){
				$line =~ s/\0/\\N/g if $option1 == 1;
				$line =~ s/ 00:00:00\.000//g if $option5 == 1;
				$line =~ s/$separator\Q$comma\E([0-9]{2})[0-9]*/$separator\E0$comma$1/g if $option2 == 1;
				$line =~ s/(-?[0-9]+)\Q$comma\E([0-9]{2})[0-9]*/$1$comma$2/g if $option3 == 1;
				$line =~ s/$searchReg/$replace/g if ($option6 == 1 && defined $searchReg);
				$line = encode("utf-8",$line,Encode::FB_CROAK) if $option4 == 1;
				print $outfh $line;
				if($cntr % 100 == 0){
					my $prog = int($cntr/$nlines*1000)/10;
					$status->configure(-text => "Status: Converted $cntr lines of $nlines ($prog\%) ");
					$mw->update();
				}
				$cntr++;
			}
			close $fh;
			close $outfh;
			$status->configure(-text => "Status: Finished converting file!");
		}else{
			$mw -> messageBox(-type=>"ok", -message=>"Couldn't open file: $!");
		}
	}
}

sub quitProgram { exit; }

sub countLines {
	$status->configure(-text => "Status: Checking number of lines in $fname");
	$nlines = 0;
	my $fh = Win32::Unicode::File->new;
	if ($fh->open('<', $fname)){
		while(<$fh>){
			++$nlines;
			if($nlines % 100 == 0){
				$status->configure(-text => "Status: Reading $nlines lines");
				$mw->update();
			}
		}
		close $fh;
	}else{
		$mw -> messageBox(-type=>"ok", -message=>"Couldn't open file: $!");
	}
	$status->configure(-text => "Status: Number of lines in $fname is $nlines");
}

sub countLinesFast {
	$status->configure(-text => "Status: Checking number of lines in $fname");
	$nlines = 0;
	my $fh = Win32::Unicode::File->new;
	if ($fh->open('<', $fname)){
		my $crap = <$fh>; $crap = <$fh>;
		my $filesize = file_size($fh);
		$nlines = int($filesize / length($crap));
		close $fh;
	}else{
		$mw -> messageBox(-type=>"ok", -message=>"Couldn't open file: $!");
	}
	$status->configure(-text => "Status: Number of lines in file is $nlines");
}

Tkx::MainLoop();
