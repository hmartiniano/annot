 # GRCh38 and gnomAD genomes:

rule download_data:
        output: "gnomad.genomes.r3.0.1.coverage.summary.tsv.bgz"
	shell: "wget https://storage.googleapis.com/gcp-public-data--gnomad/release/3.0.1/coverage/genomes/{output}"

rule rename_chr:
	input: "gnomad.genomes.r3.0.1.coverage.summary.tsv.bgz"
	output: "annotations/gnomADc.gz"
	shell:
		"zcat {input} | sed -e '1s/^locus/#chrom\tpos/; s/:/\t/' | bgzip > {output} && rm {input}"

rule index:
	input: "annotations/gnomADc.gz"
	output: "annotations/gnomADc.gz.tbi"
	shell: "cd annotations && tabix -s 1 -b 2 -e 2 gnomADc.gz"

