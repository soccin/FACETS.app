#!/usr/bin/env python2.7

import sys
import gzip
import csv
from parseVCF import parseVCF

def addCall(r):
	r["CALL"]="addCall"
	return r


for r in parseVCF(open(sys.argv[1]),addCall):
	print r["CALL"]





