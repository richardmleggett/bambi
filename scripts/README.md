scripts
=======

Scripts used for analysis of data:

* **gather_heatmap_data.pl** - take summary files from NanoOK Reporter and generate a file summarising hits per group at each timepoint.
* **plot_card_heatmap.R** - R script to make heat map from output of gather_heatmap_data.pl.
* **remove_low_abundance_taxa.pl** - given a MEGAN exported file, remove nodes with count lower than threshold.
* **bambi_summary.pl** - summarises BLAST output from NanoOKReporter.
* **bambi_summary_all.sh** - example of running bambi_summary.pl.

Also, see https://github.com/richardmleggett/scripts for other scripts:

* **subsample.pl** - to subsample reads from a FASTQ file.
* **remove_pcr_duplicates.pl** - to remove PCR duplicates.
