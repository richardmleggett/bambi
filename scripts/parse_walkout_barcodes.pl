#!/usr/bin/perl -w

use Getopt::Long;
use File::Path;

my %ids_to_bc;

# Requires list of read IDs to barcodes - format ID	barcode
open(IDFILE, "/Users/leggettr/Desktop/BAMBI/BAMBI_EvenMock_nbc_11032019_lt3000_ss11111_ids_to_barcodes.txt") or die;
while(<IDFILE>) {
    chomp(my $line = $_);
    my @arr = split("\t", $line);
    $ids_to_bc{$arr[0]} = $arr[1];
}
close(IDFILE);

for (my $bc=1; $bc<=9; $bc++) {
    print "\nBARCODE ".$bc."\n";
    open(WALKOUTFILE, "/Users/leggettr/Desktop/BAMBI/BAMBI_EvenMock_nbc_11032019_insilico_88888/walkout/walkout_results.txt") or die;
    <WALKOUTFILE>;
    while(<WALKOUTFILE>) {
        chomp(my $line = $_);
        my @arr = split("\t", $line);
        my $id = $arr[0];
        my $yn = $arr[3];
        
        if (defined $ids_to_bc{$id}) {
            my $b = $ids_to_bc{$id};
            if (($b >= 1) && ($b <= 9)) {
                if ($b == $bc) {
                    if ($yn eq "Y") {
                        #printf "%35s %60s %30s     %s\n", $id, $arr[4], $arr[1], $arr[6];
                        print $id."\t".$arr[4]."\t".$arr[1]."\t".$arr[6]."\n";
                    }
                }
            } else {
                die "bc not in range\n";
            }
        } else {
            die "Not defined.\n";
        }
    }
    close(WALKOUTFILE);
}
