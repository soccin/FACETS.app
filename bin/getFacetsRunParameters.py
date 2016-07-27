#!/opt/common/CentOS_6-dev/bin/current/python2.7

import sys

FACETS_OUTFILE=sys.argv[1]

p=dict()
with open(FACETS_OUTFILE) as fp:
    for line in fp:
        if line.startswith("#"):
            if line.find("=")>-1:
                (key,value)=[x.strip() for x in line[2:].split("=")]
                if value=="":
                    value="NA"
                p[key]=value
            elif line.find(": ")>-1:
                (key,value)=[x.strip() for x in line[2:].split(": ")]
                if value=="":
                    value="NA"
                p[key]=value

#print "#FACETS:Version:%(Version)s Rversion:%(Built)s LibPath:%(LibPath)s" % p
print "#FACETS:Version:%(Facets version)s" % p
print "#FACETS:Params:Cval:%(cval)s PurityCval:%(purity_cval)s SNP.Nbhd:%(snp.nbhd)s" % p,
print "nDepth:%(ndepth)s Min.nHet:%(min.nhet)s Genome:%(genome)s" % p
