#!/bin/bash

#grabs 150nt 'flank' either side of sRNA sequences. Flank 1 is upstream, flank 2 is downstream.


GFF=$1;
INDEX=$2;
OUT=$3

for i in `cut -f3 ${GFF} | sort | uniq`; do
	grep -E "\s+$i\s+" ${GFF} | awk -v OFS='\t' '{ if ($7 =="+") {$3 = $3"_1.fasta"; $5=$4; $4 = $4-150; print} else {$3 = $3"_1.fasta"; $4=$5; $5 = $5+150; print}}' | fetchGff.pl ${INDEX} >> ${OUT}/$i\_1.fasta
	grep -E "\s+$i\s+" ${GFF} | awk -v OFS='\t' '{ if ($7 =="+") {$3 = $3"_2.fasta"; $4=$5; $5 = $5+150; print} else {$3 = $3"_1.fasta"; $5=$4; $4 = $4-150; print}}' | fetchGff.pl ${INDEX} >> ${OUT}/$i\_2.fasta
done

