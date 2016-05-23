#!/usr/bin/env python2.7

import sys
import csv

if len(sys.argv)==1:
    infp=sys.stdin
    outfp=sys.stdout
elif len(sys.argv)==2:
    infp=open(sys.argv[1])
    outfp=sys.stdout
elif len(sys.argv)==3:
    infp=open(sys.argv[1])
    outfp=open(sys.argv[2],"w")


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

print >>outfp, "\t".join(HEADER)

formatFields=""
for r in cin:
    if formatFields=="":
        formatFields=r["FORMAT"].split(":")
    normalDat=dict(zip(formatFields, r[normal].split(":")))
    tumorDat=dict(zip(formatFields, r[tumor].split(":")))
    if int(normalDat["DP"])>NORMAL_DEPTH_CUTOFF:
        out=[r["CHROM"],r["POS"]]
        out.append(tumorDat["DP"])
        out.append(tumorDat["RD"])
        out.append(tumorDat["AD"])
        out.append(normalDat["DP"])
        out.append(normalDat["RD"])
        out.append(normalDat["AD"])
        print >>outfp, "\t".join(out)
