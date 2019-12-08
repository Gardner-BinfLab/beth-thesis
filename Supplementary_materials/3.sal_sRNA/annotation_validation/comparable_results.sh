for gene in `cat ragan_comparable_srnas.txt`; do for genome in `cat ragan_genomes.txt` ; do grep -Eh "$genome.*$gene" ../conservation/data/FILT_*.gff; done; done > comparable_results.gff

