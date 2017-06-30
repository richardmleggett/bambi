sampledir=BAMBI_P8_2D_Local_070317

#cat ${sampledir}/fasta_chunks/all_Template_pass_*.fasta > all_Template_pass.fasta
cat ${sampledir}/blastn_card/all_Template_pass_*.txt > all_Template_pass.txt
cat all_Template_pass.txt | awk '{print $1}' | sort | uniq > all_Template_ids.txt

type=Template
echo "DB	qseqid	sseqid	pident	length	mismatch	gapopen	qstart	qend	sstart	send	evalue	bitscore	stitle" > ${type}_pass_all_CARD_hits.txt
for id in `cat all_${type}_ids.txt`
do
    echo ${id}
    grep --no-filename "${id}" ../blastn_card/all_${type}_pass_*.txt | while read line; do echo "CARD	$line"; done >> ${type}_pass_all_CARD_hits.txt
    grep --no-filename "${id}" ../blastn_nt/all_${type}_pass_*.txt | while read line; do echo "NT	$line"; done >> ${type}_pass_all_CARD_hits.txt
    #grep -A 1 "${id}" all_${type}_pass.fasta >> all_${type}_pass_hits.fasta
done
