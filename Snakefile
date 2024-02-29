#!/usr/bin/env python
#filetype: py
import os


shell.prefix("unset pipefail; ")

configfile: "config.yml"

TARGETS = config["annotated"]
REF = config["ref"]
VCFS = [line.strip() for line in open(config["vcfs"])]
#VCFS = [vcf.replace(".vcf.gz", ".annotated.vcf.gz") for vcf in VCFS]
#TARGETS = ["output/{}".format(t.split("/")[1].replace("vcf.gz", "bed")) for t in VCFS]
#TARGETS += ["output/{}".format(t.split("/")[1].replace("vcf.gz", "high_moderate.bed")) for t in VCFS]
TARGETS = ["output/{}".format(t.split("/")[-1].replace("vcf.gz", "annotated.vcf.gz")) for t in VCFS]
print(TARGETS)
INPUT_DIR = "/".join(VCFS[0].split("/")[:-1]) 
print(INPUT_DIR)
#CADD_DIR = config["cadd_dir"]
LOFTEE_DIR = config["loftee_dir"]
LOFTEE_DATA = config["loftee_data"]
VEP_CACHE_DIR = config["vep_cache_dir"]
VEP_PLUGIN_DIR = VEP_CACHE_DIR+ "/Plugins"
THREADS = config["threads"]
os.environ["PERL5LIB"] = VEP_PLUGIN_DIR


include: "rules/gnomad.smk"
include: "rules/loftee.smk"
include: "rules/revel.smk"
include: "rules/cadd.smk"
include: "rules/disgenet.smk"
include: "rules/rnacentral.smk"
include: "rules/install_vep_cache.smk"


rule all:
    input: 
        TARGETS

rule index_vcf:
    input: "{name}.vcf.gz"
    output: "{name}.vcf.gz.tbi"
    shell: "tabix -p vcf {input}"


rule index_bcf:
    input: "{name}.bcf"
    output: "{name}.bcf.csi"
    shell: "bcftools index {input}"

rule index_csi:
    input: "{name}.vcf.gz"
    output: "{name}.vcf.gz.csi"
    shell: "bcftools index {input}"


rule filter:
    input: INPUT_DIR + "/{name}.vcf.gz"
    output: temp("output/{name}.filtered.vcf.gz")
    threads: THREADS
    shell: 
        "bcftools norm -m -any -f {REF} -c w {input} "
        " | bcftools view -f 'PASS,.' "
        " | bcftools view -i'ALT!=\"*\"' "
        " | bcftools filter -i 'FMT/DP >= 10 & FMT/GQ >= 20 ' -S . "
        " | bcftools view -c 1:alt1 "
        " | bcftools filter -i 'F_MISSING < 0.1' --threads 4 -Oz -o {output}"
                
"""
           gnomad="annotations/gnomADc.gz",
           gnomad_tbi="annotations/gnomADc.gz.tbi",
"""

rule annotate:
    input: vcf="output/{name}.filtered.vcf.gz",
           idx="output/{name}.filtered.vcf.gz.tbi",
           loftee_ancestor=LOFTEE_DATA + "/human_ancestor.fa.gz",
           revel="annotations/revel.tsv.gz",
           revel_index="annotations/revel.tsv.gz.tbi",
           cadd_indels="annotations/gnomad.genomes.r3.0.indel.tsv.gz",
           cadd_snvs="annotations/whole_genome_SNVs.tsv.gz",
           disgenet="annotations/all_variant_disease_pmid_associations_final.tsv.gz",
           spliceai_snv="annotations/spliceai_scores.masked.snv.hg38.vcf.gz",
           spliceai_indel="annotations/spliceai_scores.masked.indel.hg38.vcf.gz",
           rnacentral="annotations/rnacentral_homo_sapiens.GRCh38.bed.gz",
           rnacentral_index="annotations/rnacentral_homo_sapiens.GRCh38.bed.gz.tbi",
           vep_cache=".vep",
           loftee=".loftee"
    output: vcf="output/{name}.annotated.vcf.gz"
    threads: 16
    shell:
        "PERL5LIB={LOFTEE_DIR}:$PER5LIB"
        " vep "
        " --offline "
        " --dir {VEP_CACHE_DIR} "
        " --assembly GRCh38 "
        " -i {input.vcf} "
        " --fork 8 "
        " --everything "
        " --vcf "
        " --af_gnomad "
        " --buffer_size 500 "
        " --gene_phenotype "
        " --output_file {output.vcf}"
        " --no_stats"
        " --plugin LoF,loftee_path:{LOFTEE_DIR},human_ancestor_fa:{LOFTEE_DATA}/human_ancestor.fa.gz,conservation_file:{LOFTEE_DATA}/loftee.sql,gerp_bigwig:{LOFTEE_DATA}/gerp_conservation_scores.homo_sapiens.GRCh38.bw "
        " --plugin REVEL,{input.revel}"
        " --custom {input.rnacentral},RNACENTRAL,bed"
        " --plugin DisGeNET,file={input.disgenet},disease=1"
        " --plugin SpliceAI,snv={input.spliceai_snv},indel={input.spliceai_indel}"
        " --plugin CADD,{input.cadd_indels},{input.cadd_snvs}"
        " --compress_output bgzip"
        

