#!/usr/bin/perl -w

# Script:  remove_low_abundance_taxa.pl
# Purpose: Given a MEGAN exported file, remove nodes with count lower than threshold
# Author:  Richard Leggett

my $threshold = 50;

open(INFILE, "megan_files/P10NV_comparison_taxonomy_summarised.txt") or die;
open(OUTFILE, ">megan_files/P10NV_comparison_taxonomy_summarised_trimmed.txt") or die;

my $line = <INFILE>;

print OUTFILE $line;

while (<INFILE>) {
    my $line = $_;
    my @arr = split(/\t/, $line);
    my $total = $arr[1] + $arr[2] + $arr[3] + $arr[4] + $arr[5] + $arr[6] + $arr[7] + $arr[8];
    if ($total >= $threshold) {
        print OUTFILE $line;
    }
}

close(OUTFILE);
close(INFILE);

