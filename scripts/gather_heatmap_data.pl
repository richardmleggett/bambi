#!/usr/bin/perl -w

use warnings;
use strict;
use DateTime;

# Input filenames
my $sample="BAMBI_P8_2D_Local_070317";
my $sample_dir="/Volumes/group-si/BAMBI_Pt4/".$sample;
my $prefix=$sample."_Template_pass_card_summary_";
my $sample_chunktime_file="nanook_reporter_files/CARD_chunktimes_Template_pass.txt"; # originally $sample_dir."/reporter/chunktimes_Template_pass.txt"
my $group_names_file="nanook_reporter_files/groups.txt";
my $aro_group_file="nanook_reporter_files/aro_to_group.txt";
my $times_file="nanook_reporter_files/times.txt"; # originally $sample_dir."/reporter/times.txt"

# Output filenames
my $output_hits_file="nanook_reporter_files/".$sample."_hits.txt";
my $output_chunktime_file="nanook_reporter_files/".$sample."_yield.txt";

my $n_groups = 0;
my @groups;
my @chunk_delay;
my %aro_to_group;

# Read group names
open(MYFILE, $group_names_file) or die;
while(<MYFILE>) {
    chomp(my $line = $_);
    if ($line !~ /^Group/) {
        my @arr = split(/\t/, $line);
        my $group;
        
        if ($arr[0] =~ /G(\d+)/) {
            $group = $1;
        } else {
            $group = $arr[0];
        }
        
        print "Group ".$group."\n";
        
        $groups[$group] = $arr[1];
        if ($group > $n_groups) {
            $n_groups = $group;
        }
    }
}
close(MYFILE);

# Read ARO to group conversion
open(MYFILE, $aro_group_file) or die;
while(<MYFILE>) {
    chomp(my $line = $_);
    my @arr = split(/\t/, $line);
    $aro_to_group{$arr[0]} = $arr[1];
}
close(MYFILE);

# Read start times of mux, sequencing etc.
my $start_time;
open(MYFILE, $times_file) or die;
while(<MYFILE>) {
    chomp(my $line = $_);
    while(<MYFILE>) {
        if ($line =~ /^mux\_scan\_start\_time:/) {
            my ($dd, $mm, $yy, $hours, $mins, $secs) = ($line =~ m/(\d+)\/(\d+)\/(\d+) (\d+):(\d+):(\d+)/);
            $start_time = DateTime->new(
                year       => 2000+$yy,
                month      => $mm,
                day        => $dd,
                hour       => $hours,
                minute     => $mins,
                second     => $secs
            );
            #print $start_time->datetime."\n";
        }
    }
}
close(MYFILE);

# Read chunk time file and write modified file
my $c = 0;
open(MYFILE, $sample_chunktime_file) or die;
open(CHUNKFILE, ">".$output_chunktime_file) or die;
print CHUNKFILE "Hours\tReads\n";

while(<MYFILE>) {
    chomp(my $line = $_);
    while(<MYFILE>) {
        chomp(my $line = $_);
        my @arr = split(/\t/, $line);
        #print $arr[1]."\n";

        my ($dd, $mm, $yy, $hours, $mins, $secs) = ($arr[1] =~ m/(\d+)\/(\d+)\/(\d+) (\d+):(\d+):(\d+)/);
        my $chunk_time = DateTime->new(
        year       => 2000+$yy,
        month      => $mm,
        day        => $dd,
        hour       => $hours,
        minute     => $mins,
        second     => $secs
        );
        
        my $duration = $chunk_time->subtract_datetime($start_time);
        $chunk_delay[$c] = $duration->in_units( 'minutes' );
        printf CHUNKFILE "%.2f\t%d\n",($chunk_delay[$c] / 60),(($c+1) * 500);
        $c++;
    }
}
close(CHUNKFILE);
close(MYFILE);

# Write hits file out
open(HITSFILE, ">".$output_hits_file) or die;
my $chunk = 0;
my $got_one = 0;

print HITSFILE "Reads";

for (my $i=1; $i<=$n_groups; $i++) {
    print HITSFILE "\tG".$i;
}
print HITSFILE "\n";

do {
    $got_one = 0;
    my @counts;
    my $filename = $sample_dir."/reporter/".$prefix.$chunk.".txt";
    #print $filename."\n";
    if (-e $filename) {
        $got_one = 1;
        open(MYFILE, $filename) or die;
        my $header = <MYFILE>;
        while(<MYFILE>) {
            chomp(my $line = $_);
            my @arr = split(/,/, $line);
            my $id = $arr[2];
            my $count = $arr[1];
            my $aro = "";
            
            if ($id =~ /\|ARO:(\d+)\|/) {
                $aro = "ARO:".$1;
            } else {
                die"Error: can't get ARO";
            }

            #print $aro." ".$count."\n";
            
            if (defined $aro_to_group{$aro}) {
                $counts[$aro_to_group{$aro}] += $count;
            } else {
                die "Error: can't find ARO\n";
            }
        }
        close(MYFILE);

        my $nr = ($chunk+1)*500;
        print HITSFILE $nr;
        #print $chunk_delay[$chunk];
        for (my $i=1; $i<=$n_groups; $i++) {
            if (defined $counts[$i]) {
                if ($counts[$i] == 0) {
                    print HITSFILE "\t";
                } else {
                    print HITSFILE "\t".$counts[$i];
                }
            } else {
                print HITSFILE "\t";
            }
        }
        print HITSFILE "\n";
        
        $chunk+=1;
    }
    
} while ($got_one == 1);
close(HITSFILE);
