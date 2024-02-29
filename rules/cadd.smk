# rules for downloading CADD

rule download_SNVs_hg38:
	output: SNV="annotations/whole_genome_SNVs.tsv.gz",
		SNVtbi="annotations/whole_genome_SNVs.tsv.gz.tbi"
	shell: "wget https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/whole_genome_SNVs.tsv.gz -P annotations &&"
		"wget https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/whole_genome_SNVs.tsv.gz.tbi -P annotations"


rule download_inDELs_hg38:
	output: inDEL="annotations/gnomad.genomes.r3.0.indel.tsv.gz",
		inDELtbi="annotations/gnomad.genomes.r3.0.indel.tsv.gz.tbi"
	shell: "wget https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/gnomad.genomes.r3.0.indel.tsv.gz -P annotations &&"
		"wget https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/gnomad.genomes.r3.0.indel.tsv.gz.tbi -P annotations"

