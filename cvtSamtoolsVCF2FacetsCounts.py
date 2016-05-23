#!/usr/bin/env python2.7

import sys
import gzip
import vcf


snpin=vcf.Reader(open(sys.argv[1],'r'))
for r in snpin:
	print r

sys.exit()
normal=sys.argv[3]
tumor=sys.argv[4]
vin=vcf.Reader(open(sys.argv[2],'r'))
for r in vin:
	print r, r.genotype(normal)["AD"]

