#!/usr/bin/env python2.7

import sys
import csv
import Struct
import gzip

counts=dict()

TUMOR=sys.argv[1]
NORMAL=sys.argv[2]
MINCOV_NORMAL=25

print >>sys.stderr, "Reading normal ..."
cin=csv.DictReader(gzip.open(NORMAL),delimiter="\t")
CovStruct=Struct.Struct
CovStruct.setFields(cin.fieldnames)
for recD in cin:
	rec=Struct.Struct(recD)
	if len(rec.Ref)>1 or len(rec.Alt)>1:
		continue
	if rec.Ref=="N":
		continue
	if int(rec.BASEQ_depth)<MINCOV_NORMAL:
		continue
	key=(rec.Chrom, rec.Pos, rec.Ref, rec.Alt)
	counts[key]=rec
print >>sys.stderr, "done"
print >>sys.stderr, "Reading tumor ..."

HEADER="""
Chrom Pos Ref Alt
TUM.DP
TUM.Ap TUM.Cp TUM.Gp TUM.Tp
TUM.An TUM.Cn TUM.Gn TUM.Tn
NOR.DP
NOR.Ap NOR.Cp NOR.Gp NOR.Tp
NOR.An NOR.Cn NOR.Gn NOR.Tn
"""
print "\t".join(HEADER.strip().split())

cin=csv.DictReader(gzip.open(TUMOR),delimiter="\t")
for recD in cin:
	rec=Struct.Struct(recD)
	key=(rec.Chrom, rec.Pos, rec.Ref, rec.Alt)
	if key in counts:
		out=list(key)
		tRec=counts[key]
		out.append(rec.BASEQ_depth)
		out.extend([rec.A,rec.C,rec.G,rec.T])
		out.extend([rec.a,rec.c,rec.g,rec.t])
		out.append(tRec.BASEQ_depth)
		out.extend([tRec.A,tRec.C,tRec.G,tRec.T])
		out.extend([tRec.a,tRec.c,tRec.g,tRec.t])
		print "\t".join(out)

"""
Chrom Pos Ref Alt Refidx
TOTAL_depth MAPQ_depth BASEQ_depth A C
G T a c g
t INS DEL
"""
