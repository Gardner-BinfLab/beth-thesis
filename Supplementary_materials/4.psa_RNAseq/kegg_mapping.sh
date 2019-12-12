#find best matches between Psa and PSPTO proteins
cd kegg/BLAST
makeblastdb -in PST_prots.fasta -dbtype prot -out PST 
blastp -outfmt 6 -db PST -evalue 0.1 -query all_prots_IYOs.fasta -num_threads 8 > IYO_VS_PST.txt
cd ../..
#select all significantly differentially expressed genes from Psa in vitro media comparisons
cut -d, -f1 ../DESeq_analysis/*SIG.csv | tr -d '"' | grep IYO | sort | uniq > in_vitro_sig_all.txt

#select best BLAST PSPTO hit for each gene
while read i; do grep $i kegg/BLAST/IYO_VS_PST.txt | sort -nr -k12,12 | head -n 1 ; done < all_genes.txt | cut -f1,2 > kegg/IYO_PST_mapped.txt

cut -f2 kegg/IYO_PST_mapped.txt > kegg/PST_mapped.txt
#get pathways for each gene
while read i;do
		for x in `curl https://www.genome.jp/dbget-bin/www_bget?pst:$i | grep -Eo "pst[0-9]+</a>&nbsp" | cut -d '<' -f1`;do
			echo $i,$x
		done
	sleep 2 #be nice to kegg :)
done < kegg/PST_mapped.txt > PST_and_pathway.txt

#file PST_pathway_descriptions.txt is from https://www.genome.jp/dbget-bin/get_linkdb?-t+pathway+gn:T00035

#get Psa sig_DE genes that have also been mapped to a PSPTO gene
grep --file=in_vitro_sig_all.txt kegg/IYO_PST_mapped.txt > IYO_PST_mapped_sig.tmp
cut -f1 IYO_PST_mapped_sig.tmp > IYO_sig_mapped.tmp
cut -f2 IYO_PST_mapped.sig.tmp > PST.tmp

#find pathways with highest number of DE genes
grep --file=PST.tmp kegg/PST_and_pathway.txt | cut -d, -f2 | xargs -ifoo grep foo kegg/PST_pathway_descriptions.txt | sort | uniq -c | sort -k1,1nr > kegg/pathway_freq_PST.txt 

#create summary table of L2FC for each in vitro media comparison
#any sig DE gene (p< 0.0001) for any comparison is included
#format:
#Psa_gene,mapped_PSTPTO_gene,rvs_L2FC,rvm_L2FC,mvs_L2FC

grep --file=IYO_sig_mapped.txt ../DESeq_analysis/rich_vs_starv.csv | cut -d, -f3 > rvs.tmp
grep --file=IYO_sig_mapped.txt ../DESeq_analysis/rich_vs_min.csv | cut -d, -f3 > rvm.tmp
grep --file=IYO_sig_mapped.txt ../DESeq_analysis/min_vs_starv.csv | cut -d, -f3 > mvs.tmp

echo "gene,kegg,rvs,rvm,mvs" > pathview_summary_PST.csv
paste -d, IYO_sig_mapped.tmp PST.tmp rvs.tmp rvm.tmp mvs.tmp >> pathview_summary_PST.csv
rm *.tmp
#run Pseudomonas_Pathview_PST.R to generate plots
#run format_xml.sh to fix plot labelling
cd pathview/
cat Expression_table_*.csv | sed 's/","/;/g' | cut -d';' -f4 | grep -E "^PSP.*," | sed 's/,/ /g' > ../orthologs.tmp
cd ..
#orthologous genes mapping to nodes, choose gene with highest change in expression
while read line; do for i in $line; do grep $i pathview_summary_PST.csv | tr -d '-' | sed 's/,/ /g' | awk '{print $2"\t"$1"\t"($3+$4+$5)}'; done | sort -s -k3,3rn | head -n 1; done < orthologs.tmp > tmp_best.txt
cp tmp_orthologs.txt orthologs.tmp
sed -Ei 's/[[:blank:]]+/,/g' tmp_orthologs.txt
paste tmp_orthologs.txt tmp_best.txt > best_PSPTO.txt

#get list of names to fix
for i in `grep -hEv "NA" Expression_table_for_0* | grep -v mapped | cut -d, -f10-12 | sed 's/^/,/g'`; do grep -E "$i" pathview_summary_PST.csv ; done | sort | uniq | cut -d, -f1-2 | sed 's/,/	/g;s/IYO_//g' > IYOPST2.txt
#replace any orthologues with biggest diff exp gene, rename all Psa mapped genes with IYO numbers and Pst genes with pst numbers.
for i in `ls *.xml`; do ./best_xml.pl best_PSPTO.txt $i > tmp && ./xml_fixer.pl IYOPST2.txt tmp > $i; sed -Ei 's/"PSPTO_/"pst/g' $i ; done
#re-run R script with xml downloads turned off
