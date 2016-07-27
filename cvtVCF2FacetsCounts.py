#!/opt/common/CentOS_6-dev/bin/current/python2.7

import sys
import csv
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-f','--fragments',help="output fragment counts", action="store_true")
parser.add_argument('input',help="input VCF file [- for stdin]",type=str,default="-")
parser.add_argument('output',help="output counts file [- for stdout]",type=str,default="-")
args=parser.parse_args()


if args.input == "-":
    infp = sys.stdin
else:
    infp = open(args.input)

if args.output == "-":
    outfp = sys.stdout
else:
    outfp = open(args.output,"w")

def vcfStream(fp):
    for line in fp:
        if line.startswith("##"):
            continue
        if line.startswith("#CHROM"):
            yield line[1:]
        else:
            yield line

NORMAL_DEPTH_CUTOFF=20

cin=csv.DictReader(vcfStream(infp),delimiter="\t")
normal=cin.fieldnames[-2]
tumor=cin.fieldnames[-1]

HEADER="""
Chrom Pos TUM.DP  TUM.RD  TUM.AD  NOR.DP  NOR.RD  NOR.AD
""".strip().split()

print >>outfp, "#cvtVCF2FacetCounts.py (v1)",
if args.fragments:
    print >>outfp, "FragmentCounts"
else:
    print >>outfp, "ReadCounts"
print >>outfp, "\t".join(HEADER)

formatFields=""
for r in cin:
    if formatFields=="":
        formatFields=r["FORMAT"].split(":")
    normalDat=dict(zip(formatFields, r[normal].split(":")))
    tumorDat=dict(zip(formatFields, r[tumor].split(":")))
    if int(normalDat["DP"])>NORMAL_DEPTH_CUTOFF:
        out=[r["CHROM"],r["POS"]]
        if args.fragments:
            out.append(tumorDat["DPF"])
            out.append(tumorDat["RDF"])
            out.append(tumorDat["ADF"])
            out.append(normalDat["DPF"])
            out.append(normalDat["RDF"])
            out.append(normalDat["ADF"])
        else:
            out.append(tumorDat["DP"])
            out.append(tumorDat["RD"])
            out.append(tumorDat["AD"])
            out.append(normalDat["DP"])
            out.append(normalDat["RD"])
            out.append(normalDat["AD"])
        print >>outfp, "\t".join(out)
