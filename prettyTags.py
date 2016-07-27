#!/opt/common/CentOS_6-dev/bin/current/python2.7

import sys

##############
def fixSampleNames(s):
	if s.startswith("s_"):
		s=s[2:]
	return s
##############

tag=sys.argv[1]
ptag=tag

if tag.find("_indelRealigned_recal_") > -1:
	F=tag.split("_indelRealigned_recal_")
	project=F[0]
	tumor=fixSampleNames(F[1].split("____")[0])
	normal=fixSampleNames(F[2])
	ptag = "__".join([project,tumor,normal])
print ptag
