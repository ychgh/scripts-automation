#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP;

my $input = shift @ARGV or die "Usage: $0 <input.csv>\n";
open my $fh, '<', $input or die "Cannot open $input: $!\n";

my @rows;
while (my $line = <$fh>) {
  chomp $line;
  next if $line =~ /^\s*$/;
  my ($name, $value) = split /,/, $line, 2;
  push @rows, { name => ($name // ''), value => ($value // '') };
}

print JSON::PP->new->utf8->pretty->encode(\@rows);
