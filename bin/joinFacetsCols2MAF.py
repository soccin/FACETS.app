#!/opt/common/CentOS_6-dev/bin/current/python2.7

import sys
import csv

JOINMAF=sys.argv[1]
SRCMAF=sys.argv[2]

def skipHeader(fp):
    for line in fp:
        if line.startswith("#"):
            continue
        yield line
        
def getKey(r):
    return (r["Chromosome"],
            r["Start_Position"],
            r["End_Position"],
            r["Reference_Allele"],
            r["Tumor_Seq_Allele2"],
            r["Tumor_Sample_Barcode"],
            r["Matched_Norm_Sample_Barcode"])

facetsDb=dict()
with open(JOINMAF) as fp:
    cin=csv.DictReader(fp,delimiter="\t")
    for r in cin:
        facetsDb[getKey(r)]=r
      
FACETS_COLS="""
dipLogR seg.mean cf
tcn lcn
purity ploidy
ccf_Mcopies ccf_Mcopies_lower ccf_Mcopies_upper 
ccf_Mcopies_prob95 ccf_Mcopies_prob90
ccf_1copy ccf_1copy_lower ccf_1copy_upper
ccf_1copy_prob95 ccf_1copy_prob90
""".strip().split()
        
with open(SRCMAF) as fp:
    cin=csv.DictReader(skipHeader(fp),delimiter="\t")
    newfields=cin.fieldnames+FACETS_COLS
    cout=csv.DictWriter(sys.stdout,newfields,delimiter="\t",lineterminator="\n")
    cout.writeheader()
    for r in cin:
        for fi in FACETS_COLS:
            r[fi]=facetsDb[getKey(r)][fi]
        cout.writerow(r)
        
            