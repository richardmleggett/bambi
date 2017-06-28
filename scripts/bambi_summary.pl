#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use File::Basename;

my $sample;
my $process_file;
my $output_file;
my $help_requested;
my $chosen_name;
my %names;
my %descriptions;
my %hit_counts;
my $type;
my $pf;
my $n_files = 0;

&GetOptions(
'f|pf:s'      => \$pf,
'h|help'      => \$help_requested,
'n|name:s'    => \$chosen_name,
'o|output:s'  => \$output_file,
'p|process:s' => \$process_file,
's|sample:s'  => \$sample,
't|type:s'    => \$type
);

if (defined $help_requested) {
    print "Summarise BLAST results.\n\n";
    print "Usage: $0 <-s sample> <-n name> <-p process>\n\n";
    print "Options:\n";
    print "    -f | -pf           pass or fail\n";
    print "    -n | -name         Name of BLAST search in process file\n";
    print "    -o | -output       Output file\n";
    print "    -p | -process      Process file\n";
    print "    -s | -sample       Sample name\n";
    print "    -t | -type         Type (Template or 2D)\n";
    print "\n";
    
    exit;
}

die "You must specify a name\n" if not defined $chosen_name;
die "You must specify a sample\n" if not defined $sample;
die "You must specify a process file\n" if not defined $process_file;
die "You must specify a type\n" if not defined $type;
die "You must specify pass or fail\n" if not defined $pf;

die "Unknown type: ".$pf."\n" if (($pf ne "pass") && ($pf ne "fail"));

if (not defined $output_file) {
    $output_file = $sample."_".$chosen_name."_".$type."_".$pf."_summary.txt";
}

print "Output file: ".$output_file."\n";

open(PROCESSFILE, $process_file) or die "Can't open ".$process_file."\n";
while (<PROCESSFILE>) {
   chomp(my $line = $_);

    if ($line =~ /^Blast:(\S+)$/) {
        my @tokens = split(/,/, $1);
        my $name = $tokens[0];
        my $tool = $tokens[1]; 
        my $db = $tokens[2];       
        my $blast_dir = $sample."/".$tool."_".$name;
        my $log_dir = $sample."/logs/".$tool."_".$name;
       
        if ($chosen_name eq $name) {
            if ($name eq "card") {
                my $card_file = dirname($db)."/aro.csv"; 
				print "Reading CARD database...\n";
				
                open(CARDFILE, $card_file) or die "Can't open CARD file ".$card_file."\n";
				chomp(my $header = <CARDFILE>);

				if ($header ne "Accession,Name,Description") {
    				print "Unexpected header line (".$header.") - can't read CARD file.\n";
    				die;
				}

				while(<CARDFILE>) {
    				chomp(my $line = $_);
    				my @fields = split(/,/, $line);
    				$names{$fields[0]} = $fields[1];
    				$descriptions{$fields[0]} = $fields[2];
				}
				close(CARDFILE); 
                print "Done\n";
           }

            opendir(my $dh, $blast_dir) or die "Can't open $blast_dir: $!";
        	while (readdir $dh) {
            	my $filename = $_;
                if ($filename =~ /_${type}_${pf}_/) {
                    if ($filename =~ /(\S+)\.txt$/) {
                        my $blast_pathname = $blast_dir."/".$filename;
                        my $log_pathname = $log_dir."/".$1.".log";
                        my $last_qseqid = "";
                        my $last_evalue = 100000;
                        my $last_line = "";
                        print $blast_pathname."\n";
                        #print $log_pathname."\n";

                        $n_files++;
                        
                        open(BLASTFILE, $blast_pathname) or die "Can't open BLAST file ".$blast_pathname."\n";
                        while(<BLASTFILE>) {
                            chomp (my $line = $_);
                            my @arr = split(/\t/, $line);
                            my $qseqid = $arr[0];
                            my $sseqid = $arr[1];
                            my $pident = $arr[2];
                            my $length = $arr[3];
                            my $mismatch = $arr[4];
                            my $gapopen = $arr[5];
                            my $qstart = $arr[6];
                            my $qend = $arr[7];
                            my $sstart = $arr[8];
                            my $send = $arr[9];
                            my $evalue = $arr[10];
                            my $bitscore = $arr[11];
                            my $stitle = $arr[12];

                            if ($qseqid eq $last_qseqid) {
                                if ($evalue < $last_evalue) {
                                    print "Got better one: $line\n";
                                    $last_evalue = $evalue;
                                    $last_line = $line; 
                                }
                            } else {
                                if ($last_line ne "") {
                                    store_best_hit($last_line);
                                }
                                $last_qseqid = $qseqid;
                                $last_evalue = $evalue;
                                $last_line = $line;
                            }
                            
                        }
                        close(BLASTFILE);
                        if ($last_line ne "") {
                            store_best_hit($last_line);
                        }
                    }
            	}
        	}
        	closedir($dh);
        }
    }
}
close(PROCESSFILE);

print "\nSorting hits...\n";

my @sorted = sort { $hit_counts{$b} <=> $hit_counts{$a} } keys %hit_counts;

print "Outputting file...\n";

open(OUTFILE, ">".$output_file) or die "Can't open ".$output_file."\n";

print OUTFILE "Hits\tAccession\tName\tDescription\n";

foreach my $aro (@sorted) {
    print OUTFILE $hit_counts{$aro}."\t".$aro."\t".$names{$aro}."\t".$descriptions{$aro}."\n";
}

print OUTFILE "\n";
print OUTFILE $n_files."\t files processed\n";
print OUTFILE ($n_files * 500)."\t reads processed\n";

close(OUTFILE);

sub store_best_hit
{
    my $line = $_[0];
    my @arr = split(/\t/, $line);
    
    if ($arr[1] =~ /\|ARO:(\d+)\|/) {
        my $aro="ARO:".$1;
        if (defined $hit_counts{$aro}) {
            $hit_counts{$aro} = $hit_counts{$aro} + 1;
        } else {
            $hit_counts{$aro} = 1;
        }
    } else {
        print "Error: can't get ARO from ".$arr[1]."\n";
    }
    
}