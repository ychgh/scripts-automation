#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP;
use Text::ParseWords qw(parse_line);

my $input = shift @ARGV or die "Usage: $0 <input.csv>\n";
open my $fh, '<', $input or die "Cannot open $input: $!\n";

my @rows;
my $has_text_csv = eval { require Text::CSV; 1 };

if ($has_text_csv) {
  my $csv = Text::CSV->new({ binary => 1 })
    or die "Failed to initialize Text::CSV\n";
  while (my $row = $csv->getline($fh)) {
    next if !@$row || join('', @$row) =~ /^\s*$/;
    die "Expected exactly 2 columns in $input\n" if @$row != 2;
    my ($name, $value) = @$row;
    push @rows, { name => ($name // ''), value => ($value // '') };
  }
  if (!$csv->eof()) {
    die "CSV parse error in $input: " . $csv->error_diag() . "\n";
  }
} else {
  while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;
    my $quote_count = () = $line =~ /"/g;
    if ($quote_count % 2 != 0) {
      die "Quoted multiline CSV fields require Text::CSV in $input\n";
    }
    my @row = parse_line(',', 0, $line);
    next if !@row;
    die "Expected exactly 2 columns in $input\n" if @row != 2;
    my ($name, $value) = @row;
    push @rows, { name => ($name // ''), value => ($value // '') };
  }
}

print JSON::PP->new->utf8->pretty->encode(\@rows);
