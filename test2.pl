#!/usr/bin/perl 

use Tk;

my $window = MainWindow->new;
$window->title("Host Access Report");
($lab = $window->Label(-text => "Results go here"))->pack;
$window->Entry(-textvariable => \$nnn )->pack;
$window->Button(-text => "Go", -command => \&but )->pack;
$window->Button(-text => "This is the quit button ", -command => \&finito )->pack;
MainLoop;

#########################################################

sub but {
    open (FH,"access_log");
    $xxx = grep(/^$nnn /,<FH>);
    $lab -> configure(-text => "$nnn called in $xxx times");
    $nnn = "";
    close FH;
}

sub finito{
    exit;
}

