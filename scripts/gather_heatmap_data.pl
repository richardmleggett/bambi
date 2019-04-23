#!/usr/bin/perl -w

use warnings;
use strict;
use DateTime;
use Getopt::Long;
use File::Copy;

# Filenames - BAMBI_1D_19092017
#my $sample = "BAMBI_1D_19092017";
#my $prefix=$sample."_Template_pass_card_summary_";
#my $max_chunk = 202;
#my $exp_start_time = "2017-09-19 15:14:08"; # From fast5 file
#my $sample_dir="/Volumes/group-si/BAMBI_Pt6/".$sample;

# Filenames - 20180112_1634_BAMBI_P205G_1D_12012018
#my $sample = "20180112_1634_BAMBI_P205G_1D_12012018";
#my $prefix=$sample."_Template_pass_card_summary_";
#my $max_chunk = 955;
#my $exp_start_time = "2018-01-12 16:34:12"; # From fast5 file
#my $sample_dir="/Volumes/group-si/BAMBI_Pt7/".$sample;

# Filenames - 20180202_1307_BAMBI_P106I_LSQK108_02022018
#my $sample = "20180202_1307_BAMBI_P106I_LSQK108_02022018";
#my $prefix=$sample."_Template_pass_card_summary_";
#my $max_chunk = 199;
#my $exp_start_time = "2018-02-02 13:07:49";  # From fast5 file
#my $sample_dir="/Volumes/group-si/BAMBI_Pt7/".$sample;

# Filenames - 20180202_1324_BAMBI_P116I_SQK108_02022018
#my $sample = "20180202_1324_BAMBI_P116I_SQK108_02022018";
#my $prefix=$sample."_Template_pass_card_summary_";
#my $max_chunk = 199;
#my $exp_start_time = "2018-02-02 13:24:16";  # From fast5 file
#my $sample_dir="/Volumes/group-si/BAMBI_Pt7/".$sample;

# Filenames - 20171220_1133_BAMBI_P103M_400ng_RAD4_20122017
my $sample = "20171220_1133_BAMBI_P103M_400ng_RAD4_20122017";
my $prefix=$sample."_Template_pass_card_summary_";
my $max_chunk = 330;
my $exp_start_time = "2017-12-20 11:33:19";  # From fast5 file
my $sample_dir="/Volumes/group-si/BAMBI_Pt7/".$sample;

# Filenames - 20180112_1459_BAMBI_P49A_1D_12012018
#my $sample = "20180112_1459_BAMBI_P49A_1D_12012018";
#my $prefix=$sample."_Template_pass_card_summary_";
#my $max_chunk = 143;
#my $exp_start_time = "2018-01-12 14:59:02";  # From fast5 file
#my $sample_dir="/Volumes/group-si/BAMBI_Pt7/".$sample;

# Generated names
my $summary_sheet = $sample."/".$prefix.$max_chunk.".txt";
my $group_names_file = $sample."/groups.txt";
my $sample_chunktime_file = $sample."/CARD_chunktimes_Template_pass.txt"; # originally $sample_dir."/reporter/chunktimes.txt"
my $output_chunktime_file= $sample."/".$sample."_yield.txt";
my $output_hits_file=$sample."/".$sample."_hits.txt";
my $output_hits_file_sorted=$sample."/".$sample."_hits_sorted.txt";

my %aro_to_group;
my $start_time;


#my $original_summary_sheet = $sample_dir."/reporter/".$prefix.$max_chunk.".txt";
#copy($original_summary_sheet, $summary_sheet) or die "Can't copy ".$original_summary_sheet."\n";

make_aro_to_group_file();
read_start_times();
process_chunktime_file();
write_hits_file();

print "DONE\n";

sub make_aro_to_group_file
{
    my %group_counts;

    # Read annotated summary file
    print "Mapping ARO to group\n";
    open(MYFILE, $summary_sheet) or die "Can't open $summary_sheet";
    while(<MYFILE>) {
        chomp(my $line = $_);
        if ($line !~ /^Rank/) {
            my @arr = split(/\t/, $line);
            my $group = ucfirst(lc($arr[7]));
            my $aro = $arr[6];
            
            print "ARO ".$aro."\n";
            
            if (!defined $group_counts{$group}) {
                $group_counts{$group} = 1;
            } else {
                $group_counts{$group} = $group_counts{$group} + 1;
            }
            
            if (defined $aro_to_group{$aro}) {
                if ($aro_to_group{$aro} ne $group) {
                    die "Error: different group defined for $aro\n";
                }
            } else {
                $aro_to_group{$aro} = $group;
            }
        }
    }
    close(MYFILE);
}

sub read_start_times
{
    my ($y, $mm, $dd, $hours, $mins, $secs) = ($exp_start_time =~ m/(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/);
    $start_time = DateTime->new(
    year       => $y,
    month      => $mm,
    day        => $dd,
    hour       => $hours,
    minute     => $mins,
    second     => $secs
    );
    print "Time coded: ".$start_time->datetime."\n";
}

sub process_chunktime_file
{
    my @chunk_delay;

    # Read chunk time file and write modified file
    print "Reading ".$sample_chunktime_file."\n";
    print "Writing ".$output_chunktime_file."\n";
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
            my $time_hour = ($chunk_delay[$c] / 60);
            my $reads = (($c+1) * 500);
            printf CHUNKFILE "%.2f\t%d\n",$time_hour,$reads;
            $c++;
            
        }
    }
    close(CHUNKFILE);
    close(MYFILE);
}

sub write_hits_file
{
    my %group_aro_counts;
    
    # Write hits file out
    my $chunk = 0;
    my $got_one = 0;
    my @counts_table;
    my %last_row;
    
    do {
        $got_one = 0;
        my @counts;
        my $filename = $sample_dir."/reporter/".$prefix.$chunk.".txt";
        print "Reading ".$filename."\n";
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
                    my $group = $aro_to_group{$aro};
                    
                    if (defined $group_aro_counts{$chunk}{$group}) {
                        $group_aro_counts{$chunk}{$group} = $group_aro_counts{$chunk}{$group} + $count;
                    } else {
                        $group_aro_counts{$chunk}{$group} = $count;
                    }
                    
                    $last_row{$group} = $group_aro_counts{$chunk}{$group};
                    
                } else {
                    die "Error: can't find ARO ".$aro."\n";
                }
            }
            close(MYFILE);
            
            $chunk+=1;
        }
        
        } while (($got_one == 1) && ($chunk <= $max_chunk));
        #} while (($got_one == 1) && ($chunk <= 95));

    my %sorted_groups;

    # Order groups
    my $number_of_groups = 0;
    my @sorted_groups;
    foreach my $group (sort {$last_row{$a} <=> $last_row{$b}} keys %last_row) {
        $sorted_groups[$number_of_groups++] = $group;
    }
    
    print "Number of groups: ".$number_of_groups."\n";
    
    print "Writing ".$group_names_file."\n";
    open(OUTFILE, ">".$group_names_file) or die "Can't open $group_names_file";
    print OUTFILE "Group\tName\n";
    for (my $i=0; $i<$number_of_groups; $i++) {
        my $group = $sorted_groups[$i];
        print OUTFILE "G".($i+1)."\t".$group."\n";
    }
    close(OUTFILE);
    
    print "Writing ".$output_hits_file_sorted."\n";
    open(HITSFILE, ">".$output_hits_file_sorted) or die;

    for (my $c=0; $c<$chunk; $c++) {
        if ($c == 0) {
            print HITSFILE "Reads";
            for (my $i=1; $i<=$number_of_groups; $i++) {
                print HITSFILE "\tG".$i;
            }
            print HITSFILE "\n";
        }
        
        my $nr = ($c+1)*500;
        print HITSFILE $nr;
        
        for (my $i=0; $i<$number_of_groups; $i++) {
            my $group = $sorted_groups[$i];
            print HITSFILE "\t";
            if (defined $group_aro_counts{$c}{$group}) {
                print HITSFILE $group_aro_counts{$c}{$group};
            }
        }
        print HITSFILE "\n";
    }
    close(HITSFILE);
}
