#!/usr/bin/env python2.7

import sys
import gzip
import csv

def vcfStream(fp):
    for line in fp:
        if line.startswith("##"):
            continue
        if line.startswith("#CHROM"):
            yield line[1:]
        else:
            yield line

def parseVCF(fp,callback=None):
	cin=csv.DictReader(vcfStream(fp),delimiter="\t")
	if len(cin.fieldnames)>8:
		samples=cin.fieldnames[9:]
	else:
		samples=False

	formatFields=""
	for r in cin:
		if samples:
			r["_SAMPLES"]=samples
			if formatFields=="":
				formatFields=r["FORMAT"].split(":")
			for si in samples:
				r[si]=dict(zip(formatFields, r[si].split(":")))
		if callback:
			r=callback(r)
		yield r

