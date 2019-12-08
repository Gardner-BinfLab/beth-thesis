#!/bin/bash

DIR=$1
DB1=$2
DB2=$3
make_alignments(){
	#Make maaft alignments of all annotations
	esl-sfetch --index ${DIR}/data/${DB2}
	export DIR 
	export DB1
	export DB2

	mkdir -p ${DIR}/QC/alignments
	cat ${DIR}/data/sRNA_list.txt | parallel --env DIR --env DB1 'grep -E "\s+{}\s+" ${DIR}/data/FILT_startingSeqs.gff | ./fetchGff.pl -g -i ${DIR}/data/${DB1} >> ${DIR}/QC/{}.fasta'
	cat ${DIR}/data/sRNA_list.txt | parallel --env DIR --env DB2 'grep -E "\s+{}\s+" ${DIR}/data/FILT_trainingSeqs.gff | ./fetchGff.pl -g -i ${DIR}/data/${DB2} >> ${DIR}/QC/{}.fasta'


	for i in `cat ${DIR}/data/sRNA_list.txt`; do
	    mafft-qinsi --retree 1 --thread 20 --quiet ${DIR}/QC/$i.fasta > ${DIR}/QC/alignments/$i.maf
	done
}

run_QC(){
	#Takes maf alignments produced by sRNA_evo.sh, runs RNA QC programs and produces summary stats in QC.csv
	for i in ${DIR}/QC/alignments/*.maf; do
	    sreformat clustal $i | RNAcode > $i.RNAcode
	done
	for i in `ls ${DIR}/QC/alignments/*.maf | sed 's/.maf//'`; do
	    weight -f 0.95 $i.maf > $i.maf.strip
	    sreformat clustal $i.maf.strip | RNAalifold --id-prefix=$i --aln-stk=$i > $i.alifold
	    sreformat clustal $i.maf.strip | RNAcode > $i.RNAcode
	    R-scape $i.stk > $i.rscape
	    ./runr2r.sh $i.stk
	done
}

make_csv(){
	#Parse output files from various RNA QC programs. 
	echo "name,ali_energy,ali_MFE,ali_cov,Rsc_cov_min,Rsc_conv_max,code_length,code_score,code_P"
	for i in `ls ${DIR}/QC/alignments/*.maf | sed 's/.maf//'`; do
	    echo -n "$i,"
	    #RNAalifold
	    if [[ -s $i.alifold ]]; then
		echo -n `sed 's| (|\t|;s|)||g' $i.alifold | cut -f2 | tail -n1 | awk 'BEGIN{OFS=","} {print $1,$3,$5}'`
	    else
		echo -n ",NA,NA,NA"
	    fi
	    #R-scape
	    if [[ -s $i.rscape && $(( `grep GTp $i.rscape | wc -l` )) -gt 0 ]]; then
		echo -n "," `grep GTp $i.rscape | tr -d '[]|#GTp' |  sed -E 's/^\s+//g;s/\s+$//g;s/\s+/,/g' | cut -d "," -f2-3`
	    else
		echo -n ",NA,NA"
	    fi
	    #RNAcode
	    if [[ -s $i.maf.RNAcode && $(( `grep HSS $i.maf.RNAcode | wc -l` )) -gt 0 ]]; then
		    grep -P '^\s+\d+' $i.maf.RNAcode | head -n 1 | perl -lane 'print ",",$F[2],",",$F[6],",",$F[8]; '
	    else
		echo ",NA,NA,NA"
	    fi
	done > QC.csv
}

#make_alignments
#run_QC
make_csv
