#!/usr/bin/perl -w

use Getopt::Long;
use File::Path;

my $in_filename;
my $groups_filename;
my %gene_to_group;
my %group_counts;

&GetOptions(
'groups|g:s'        => \$groups_filename,
'in|i:s'            => \$in_filename
);

die if not defined $groups_filename;
die if not defined $in_filename;

open(GROUPSFILE, $groups_filename) or die;
while(<GROUPSFILE>) {
    chomp(my $line = $_);
    my @arr = split(/\t/, $line);
    my $group = $arr[0];
    my $count = $arr[1];

    for (my $i=0; $i<$count; $i++) {
        my $gene = $arr[$i+2];
        $gene_to_group{$gene} = $group;
        $group_counts{$group} = $count;
    }
}
close(GROUPSFILE);

print"ReadId	HostTopHit	HostLCAHit	CARDHit	CARDGroup	PercentID	Length	Distance\n";

open(WOFILE, $in_filename) or die;
<WOFILE>;
while(<WOFILE>) {
    chomp(my $line = $_);
    my @arr = split(/\t/, $line);
    my $readid = $arr[0];
    my $chunk = $arr[1];
    my $organism = $arr[2];
    my $card_hit = $arr[3];
    my $percent_id = $arr[4];
    my $length = $arr[5];    
    my $overlap = $arr[6];
    my $lca = $arr[7];
    my $aro;
    my $gene_id;


        #if ($card_hit =~ /^.*\|(\S)$/) {
        #    $gene_id = $1;
        #} else {
        #    die "Can't get ID from: ".$card_hit."\n";
        #}


my @fields=split(/\|/, $card_hit);
$aro=$fields[0];
$gene_id=$fields[1];

        #if ($card_hit =~ /ARO:(\d+)\|.*/) {
        #    $aro="ARO:".$1;
        #    $gene_id = $2;
        #}
        
        print $readid."\t".$organism."\t".$lca."\t".$card_hit."\t";

        if ($aro eq "ARO:3003840") {
            print "cysB";
        } elsif ($aro eq "ARO:3003830") {
            print "alaS"; 
        }elsif (defined($gene_to_group{$gene_id})) {
            my $group = $gene_to_group{$gene_id};
            
            if ($group_counts{$group} == 1) {
                    print $gene_id;
            } else {
                print "group ".$group;
            }
        } else { 
            if ($gene_id eq "Bifidobacterium ileS") {
               print "ileS";
            } else {
                print $gene_id;
            }
        }

        print "\t".$percent_id."\t".$length."\t".$overlap."\n";
}
close(WOFILE);
