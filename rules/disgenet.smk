## DisgeNET rules

rule download_association:
        output: "all_variant_disease_pmid_associations.tsv.gz"
	shell: "wget https://www.disgenet.org/static/disgenet_ap1/files/downloads/{output}"

rule transformation:
	input: "all_variant_disease_pmid_associations.tsv.gz"
	output: "annotations/all_variant_disease_pmid_associations_final.tsv.gz"
	shell:
		"gunzip -c {input} | awk '($1 ~ /^snpId/ || $2 ~ /NA/) {{next}} {{print $0}}' | "
		"sort -t $'\t' -k2,2 -k3,3n | "
		"awk '{{ gsub (/\t +/, \"\t\", $0); print}}' | "
		"bgzip -c > {output} && tabix -s 2 -b 3 -e 3 {output}"
