#!/usr/bin/env python2.7

import sys
import os
import sh

#old version uses full somatic MAF
#SOMATICTAG="___SOMATIC.vep.maf"
#def getMAF():
#    for fname in os.listdir("../post"):
#        if fname.endswith(SOMATICTAG):
#            return os.path.join("../post",fname)
#    raise RuntimeError("Can not find SOMATIC maf in "+os.getcwd()+"/../post")

def getMAF():
    return "../post/_scratch/merge_maf3"

def getPairingFile():
    with open("../config") as fp:
        for line in fp:
            if line.startswith("PROJECTDIR:"):
                projectDir=line.strip().split()[-1]
                pairingFile=[x for x in os.listdir(projectDir)
                                if x.endswith("_pairing.txt")][0]
                return os.path.join(projectDir,pairingFile)

def getProjectNo():
    with open("../config") as fp:
        for line in fp:
            if line.startswith("ProjectNo:"):
                projectNo=line.strip().split()[-1]
                return projectNo


def fixSampleName(x):
    if x.startswith("s_"):
        x=x[2:]
    return x

def getTumorSamplesFromPairs(pairingFile):
    samples=set()
    with open(pairingFile) as fp:
        for line in fp:
            sample=line.strip().split()[1]
            samples.add(sample)
        return list(samples)

samples=getTumorSamplesFromPairs(getPairingFile())
rdataFiles=sh.find("facets","-name","*_hisens.Rdata").strip().split("\n")
projectNo=getProjectNo()
rdataSampleMap=dict()
for si in samples:
    tag="Proj_%s__%s" % (projectNo,fixSampleName(si))
    for ri in rdataFiles:
        pos = ri.find(tag)
        if pos > -1:
            rdataSampleMap[si]=ri

facetsMappingFile="mapping.txt"
with open(facetsMappingFile,"w") as fp:
    HEADER="Tumor_Sample_Barcode Rdata_filename".split()
    print >>fp, "\t".join(HEADER)
    for si in sorted(rdataSampleMap):
        print >>fp, "\t".join([si,rdataSampleMap[si]])

facets=sh.Command("/home/socci/Code/Pipelines/FACETS/FACETS.app/facets-suite/facets")
maf=getMAF()
#joinMaf=maf.replace(SOMATICTAG,"___SOMATIC_FACETS.vep.maf")
joinMaf="join.maf"
facets("mafAnno","-m",maf,"-f",facetsMappingFile,"-o",joinMaf,
        _err="joinMaf.err",_out="joinMaf.out")


