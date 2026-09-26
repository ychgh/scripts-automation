#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP;
use Text::ParseWords qw(parse_line);

my $input = shift @ARGV or die "Usage: $0 <input.csv>\n";
open my $fh, '<', $input or die "Cannot open $input: $!\n";

my @rows;
while (my $line = <$fh>) {
  chomp $line;
  next if $line =~ /^\s*$/;
  my @row = parse_line(',', 0, $line);
  next if !@row;
  die "Expected exactly 2 columns at line $. in $input\n" if @row != 2;
  my ($name, $value) = @row;
  push @rows, { name => ($name // ''), value => ($value // '') };
}

print JSON::PP->new->utf8->pretty->encode(\@rows);
