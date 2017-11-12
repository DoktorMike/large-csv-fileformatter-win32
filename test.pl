#!/usr/bin/perl
use strict;
use Tk;
use Tk::BrowseEntry;
my $mw = MainWindow->new;

# Mainwindow: sizex/y, positionx/y
$mw->geometry("200x200+100+120");

&create_dropdown($mw);
MainLoop;

sub create_dropdown {
	my $mother  = shift;
	# Create dropdown and another element which shows my selection
	my $dropdown_value;
	my $dropdown = $mother->BrowseEntry(
		-label => "Label",
		-variable => \$dropdown_value,
		)->pack;
	my $showlabel = $mother->Label(
		-text => "nothing selected",
		)->pack;

	# Configure dropdown
	$dropdown->configure(
		# What to do when an entry is selected
		-browsecmd => sub {
			$showlabel->configure(-text => "You selected: $dropdown_value" ),
		},
	);

	# Populate dropdown with values
	foreach ( qw/printers screens computers keyboards/ ) {
		$dropdown->insert('end', $_);
	}
	# Set the initial value for the dropdown
	$dropdown_value = "keyboards";
}