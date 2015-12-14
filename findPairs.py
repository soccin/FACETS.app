#!/usr/bin/env python2.7

import sys
import re

def getSampleName(line):
    BICTAG="_indelRealigned_recal_"
    DMPTAG="_mrg_cl_aln_srt_MD_IR_BR"
    dmpRe=re.compile("/([^/]+?)_bc\d+_")
    if line.find(BICTAG)>-1:
        # BIC Pipeline BAM
        pos=line.find(BICTAG)
        return line[(pos+len(BICTAG)):-4]
    elif line.find(DMPTAG)>-1:
        # DMP Pipeline BAM
        mm=dmpRe.search(line)
        return mm.groups()[0]
    else:
        raise ValueError("INVALID BAM FILE FORMAT [%s]" % line)

BAMS=sys.argv[1]
NORMAL=sys.argv[2].rstrip()
TUMOR=sys.argv[3].rstrip()

name2BamMap=dict()
with open(BAMS) as fp:
    for line in fp:
        name2BamMap[getSampleName(line.strip())]=line.strip()

print name2BamMap[NORMAL], name2BamMap[TUMOR]
