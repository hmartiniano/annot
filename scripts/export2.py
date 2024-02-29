#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import csv

import cyvcf2

from pybiomart import Dataset



def find_annotations(vcf):
    result = []
    # default to the VEP CSQ key
    annotation_key = "CSQ"
    for record in vcf.header_iter():
        #if record["HeaderType"] == "INFO" and "Functional annotations:" in record["Description"]:
        #    result = record["Description"][:-1].split(":")[-1].strip()[1:-1]
        #    result = [item.strip().replace(" ", "") for item in result.split("|")]
        #    annotation_key = "ANN"
        if record["HeaderType"] == "INFO" and "Consequence annotations from Ensembl VEP" in record["Description"]:
            result = record["Description"][:-1].split(":")[-1].strip()
            result = [item.strip().replace(" ", "") for item in result.split("|")]
    return annotation_key, result


def parse_header(vcf):
    annotation_key, annotations = find_annotations(vcf)
    info_keys = [record for record in vcf.header_iter() if record["HeaderType"] == "INFO"]
    return info_keys, annotation_key, annotations


def get_biomart_data(): 
    dataset = Dataset(name='hsapiens_gene_ensembl',
                  host='http://www.ensembl.org')
    df = dataset.query(attributes=['ensembl_gene_id', 'external_gene_name', 'ensembl_transcript_id', 'transcript_is_canonical'],
                       use_attr_names=True)
    return df


def main(fname):
    vcf = cyvcf2.VCF(fname, lazy=True, gts012=True, threads=4)
    all_info_keys, annotation_key, annotations = parse_header(vcf)
    info_keys = [k["ID"] for k in all_info_keys if k["ID"] not in (annotation_key, "ANN")]
    samples = vcf.samples
    columns = ["chrom", "pos", "id", "ref", "alt", "call_rate", "num_called", "num_hom_ref", "num_het", "num_hom_alt"] + info_keys + annotations
    columns = columns + [sample + "_GT" for sample in samples]
    columns = columns + [sample + "_DP" for sample in samples]
    columns = columns + [sample + "_AD_ref" for sample in samples]
    columns = columns + [sample + "_AD_alt" for sample in samples]
    columns = columns + [sample + "_GQ" for sample in samples]
    writer = csv.writer(sys.stdout, quoting=csv.QUOTE_MINIMAL)
    writer.writerow(columns)
    for v in vcf:
        if v.call_rate < 0.9:
            continue
        for consequence in v.INFO.get(annotation_key, "").split(","):
            keep = False
            csq = {k: v for k, v in zip(annotations, consequence.split("|"))}
            #print(csq["IMPACT"], csq["SIFT"], csq["PolyPhen"])
            print(csq)
            if csq.get("IMPACT", None) is None:
                continue
                print("######## FAIL filter IMPACT", csq["IMPACT"])
            if (csq["IMPACT"] == "HIGH"):
                keep = True
                print("######## PASS filter IMPACT:", csq["IMPACT"])
            elif (csq["IMPACT"] == "MODERATE"): 
                keep = True
                print("######## PASS filter IMPACT:", csq["IMPACT"])
            if csq["gnomAD_AF"] != '' and float(csq["gnomAD_AF"]) > 0.05:
                keep = False
                print("######## FAIL filter gnomAD_AF", csq["gnomAD_AF"])
            elif (csq["CADD_PHRED"] != "" and  float(csq["CADD_PHRED"]) >= 30): 
                keep = True
                print("######## PASS filter CADD_PHRED:", csq["CADD_PHRED"])
            if keep:
                writer.writerow((v.CHROM, v.POS, v.ID, v.REF, v.ALT[0], v.call_rate, v.num_called, v.num_hom_ref, v.num_het, v.num_hom_alt,
                      *(v.INFO.get(field, None) for field in info_keys), *(csq[a] for a in annotations),
                      *v.gt_types.tolist(), *v.gt_depths.tolist(), *v.gt_ref_depths.tolist(), *v.gt_alt_depths.tolist(), *v.gt_quals.tolist()))

if __name__ == '__main__':
    import sys
    main(sys.argv[1])


