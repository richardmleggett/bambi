#!/usr/bin/perl -w

use warnings;
use strict;
use Getopt::Long;

my $input_file;
my $output_file;
my %species_counts;
my %not_long_enough_species_counts;
my $min_overlap = 50;

$species_counts{"Small overlap"} = 0;
$species_counts{"No match"} = 0;

&GetOptions(
'i|input:s'       => \$input_file,
'o|output:s'      => \$output_file,
'm|minoverlap:o'  => \$min_overlap
);

die if not defined $input_file;

open(INFILE, $input_file) or die "Can't open $input_file\n";
open(OUTFILE, ">".$output_file) or die "Can't open $output_file\n";
print OUTFILE "ReadId\tCardId\tCardDescription\tLongEnough\tSpecies\n";

my $card_id="";
my $nt_id="";
my $found_nt_hit = 0;
my $card_start;
my $card_end;
my $best_so_far_id="";
my $best_so_far_species="";
my $best_so_far_start_overlap = 0;
my $best_so_far_end_overlap = 0;


while(<INFILE>) {
    chomp(my $line = $_);
    my @arr = split(/\t/, $line);
    my $db = $arr[0];
    my $query_id = $arr[1];
    my $subject_id = $arr[2];
    my $query_start = $arr[7];
    my $query_end = $arr[8];
    my $description = $arr[13];
    
    if ($db eq "CARD") {
        if ($query_id ne $card_id) {
            if ($nt_id eq "") {
                if ($found_nt_hit == 0) {
                    $species_counts{"No match"} = $species_counts{"No match"} + 1;
                    print "    No NT match\n";
                    print OUTFILE "\tNo\tNo match\n";
                } else {
                    $species_counts{"Small overlap"} = $species_counts{"Small overlap"} + 1;
                    print "    Not long enough (".$best_so_far_start_overlap.", ".$best_so_far_end_overlap."): $best_so_far_species\n";
                    print OUTFILE "\tNo\t".$best_so_far_species."\n";                    

                    if (defined $not_long_enough_species_counts{$best_so_far_species}) {
                        $not_long_enough_species_counts{$best_so_far_species} = $not_long_enough_species_counts{$best_so_far_species} + 1;
                    } else {
                        $not_long_enough_species_counts{$best_so_far_species} = 1;
                    }

                }
            }

            $card_id = $query_id;
            $card_start = $query_start;
            $card_end = $query_end;
            $nt_id = "";
            $found_nt_hit = 0;
            $best_so_far_id="";

            print $card_id;

            print OUTFILE $query_id;
            print OUTFILE "\t".$subject_id;
            print OUTFILE "\t".$description;
            # Print ID and description
            # print $subject_id."\t".$description."\t";
        }
    } elsif ($db eq "NT") {
        # Check for badly formatted files
        if ($query_id ne $card_id) {
            print "Error: Mismatching NT id - something went wrong!";
            exit;
        }
        $found_nt_hit = 1;
        # Have we got a good hit yet?
        if ($nt_id eq "") {
            my $species = "";

            # Get species from description
            if ($description =~ /(\S+) (\S+)/) {
                $species = $1." ".$2;
            } else {
                die "Can't get species from description $description\n";
            }
            
            # If it overlaps the start or end by at least 20 bases, we count it...
            if (($query_end >= ($card_end + $min_overlap)) ||
                ($query_start <= ($card_start) - $min_overlap))
            {
                $nt_id = $query_id;
            
                # Print ID and description
                # print $subject_id."\t".$description."\n";
                print $description."\t";
                print $species."\n";

                print OUTFILE "\tYes\t".$species."\n";
                
                if (defined $species_counts{$species}) {
                    $species_counts{$species} = $species_counts{$species} + 1;
                } else {
                    $species_counts{$species} = 1;
                }
            } elsif ($best_so_far_id eq "") {
                # Store the "Best so far" in case this doesn't have an overlap big enough
                $best_so_far_id = $query_id;
                $best_so_far_species = $species;
                $best_so_far_start_overlap = $card_start - $query_start;
                $best_so_far_end_overlap = $query_end - $card_end;
            }

        }
    }
}

close(OUTFILE);
close(INFILE);

print "\n\n\nSpecies counts:\n";
foreach my $species (sort {$species_counts{$b} <=> $species_counts{$a}} keys %species_counts) {
    print $species."\t".$species_counts{$species}."\n";
}

print "\n\n\nNot long enough species counts:\n";
foreach my $species (sort {$not_long_enough_species_counts{$b} <=> $not_long_enough_species_counts{$a}} keys %not_long_enough_species_counts) {
    print $species."\t".$not_long_enough_species_counts{$species}."\n";
}
