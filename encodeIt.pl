#!/usr/bin/perl -w

use strict;
use warnings;
use Encode;
use Win32::Codepage;
use Win32;

my $encoding = Win32::Codepage::get_encoding() || q{};

if ($encoding) {
    $encoding = Encode::resolve_alias($encoding) || q{};
}

print "$encoding\n";
print Win32::GetLongPathName('.');

sub encode_filename {
    my ($filename) = @_;
    return $encoding ? encode($encoding, $filename) : $filename;
}
