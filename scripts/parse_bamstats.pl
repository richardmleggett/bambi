#!/usr/bin/perl -w

use Getopt::Long;
use File::Path;

my $in_filename;
my %ids_to_name;
my @id_order;
my %ids_to_counts;
my %ids_to_bp;
my $count = 0;

GetOptions(
'in|i:s' => \$in_filename
);

open(IDFILE, "hmp_mock_ids.txt") or die;
while(<IDFILE>) {
    chomp(my $line = $_);
    my @arr  = split(/\t/, $line);
    $ids_to_name{$arr[1]} = $arr[2];
    $id_order[$count++] = $arr[1];
}
close(IDFILE);

open(MYFILE, $in_filename) or die;
while(<MYFILE>) {
    chomp(my $line = $_);
    my @arr = split(/\t/, $line);
    my $id = $arr[0];
    my $l = $arr[2];
    
    if (defined $ids_to_counts{$id}) {
        $ids_to_counts{$id} = $ids_to_counts{$id} + 1;
        $ids_to_bp{$id} = $ids_to_bp{$id} + $l;
    } else {
        $ids_to_counts{$id} = 1;
        $ids_to_bp{$id} = $l;
    }
}
close(MYFILE);

for (my $i=0; $i<23; $i++) {
    my $id = $id_order[$i];
    
    if (($i == 7) || ($i == 17)) {
        # Do nothing
    } elsif (($i == 6) || ($i == 16)) {
        my $next_id = $id_order[$i+1];
        print $id."\t".($ids_to_counts{$id} + $ids_to_counts{$next_id})."\t".($ids_to_bp{$id} + $ids_to_bp{$next_id})."\t".$ids_to_name{$id}."\n";
    } else {
        print $id."\t".$ids_to_counts{$id}."\t".$ids_to_bp{$id}."\t".$ids_to_name{$id}."\n";
    }
}
