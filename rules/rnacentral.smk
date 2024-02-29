## RNAcentral

rule download_rnacentral_annotations:
  output: "annotations/homo_sapiens.GRCh38.bed.gz"
	shell: "wget http://ftp.ebi.ac.uk/pub/databases/RNAcentral/current_release/genome_coordinates/bed/homo_sapiens.GRCh38.bed.gz -O {output}"

rule process_rnacentral_annotations:
  input: "annotations/homo_sapiens.GRCh38.bed.gz"
  output: "annotations/rnacentral_homo_sapiens.GRCh38.bed.gz"
	shell: """zcat {input} | sort -k1,1 -k2,2n -k3,3n -t$'\t' | bgzip -c > {output}"""

rule index_rnacentral_annotations:
  input: "annotations/rnacentral_homo_sapiens.GRCh38.bed.gz"
  output: "annotations/rnacentral_homo_sapiens.GRCh38.bed.gz.tbi"
  shell: "tabix -p bed {input}"

