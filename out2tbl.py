#!/usr/bin/env python2.7

import sys
import csv

tbl=[]
for fname in sys.argv[1:]:
    with open(fname) as fp:
        row=dict()
        for line in fp:
            F=line.strip().split()
            if len(F)==4:
                (_,key,_,value)=F
            elif len(F)==3:
                key=F[1]
                value="NA"
            else:
                print >>sys.stderr, "FATAL ERROR", fname
                print >>sys.stderr, line,
                print >>sys.stderr, len(F), F
                print >>sys.stderr
                raise ValueError()

            row[key]=value
        tbl.append(row)

HEADER="""
Project Tumor Normal Purity Ploidy dipLogR dipt loglik cval snp.nbhd min.nhet Version
""".strip().split()

print "\t".join(HEADER)
for row in tbl:
    out=[]
    for key in HEADER:
        out.append(row[key])
    print "\t".join(out)

