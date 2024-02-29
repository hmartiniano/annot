# rules for revel annotation

rule download_revel_data:
	output: "revel-v1.3_all_chromosomes.zip"
	shell: "wget https://rothsj06.u.hpc.mssm.edu/{output}"


rule unzip_revel:
	input: "revel-v1.3_all_chromosomes.zip"
	output: "revel_with_transcript_ids" 
	shell:
		"unzip {input}"

rule convert_revel:
	input: "revel_with_transcript_ids" 
	output: tsv="annotations/revel.tsv.gz",
		tbi="annotations/revel.tsv.gz.tbi"
	shell:
		"cat <(cat revel_with_transcript_ids | head -n1 | tr ',' '\t' | sed '1s/.*/#&/' ) <(cat revel_with_transcript_ids | tr ',' '\t' | "
		"tail -n+2 | awk '$3 != \".\" ' | sort -k1,1 -k3,3n - ) | bgzip -c > {output.tsv} &&"
		"rm revel-v1.3_all_chromosomes.zip revel_with_transcript_ids &&"
		"tabix -f -s 1 -b 3 -e 3 -c \"#\" {output.tsv}"
