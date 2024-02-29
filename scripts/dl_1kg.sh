#!/bin/bash
bcftools view -s "HG00157,HG00171,HG00176" ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot/20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr20.recalibrated_variants.vcf.gz | head -n 10000 | bcftools view -Oz -o data/test.vcf.gz
cd data && tabix -pvcf test.vcf.gz

