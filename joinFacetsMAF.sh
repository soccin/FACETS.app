#!/bin/bash

if [ "$#" != "1" ]; then
    echo "usage: joinFacetsMAF.sh POSTFOLDER"
    exit
fi

FACETS_VERSION=$(~/bin/getCurrentGitTag.sh /home/socci/Code/Pipelines/FACETS/FACETS.app)
FACETS_SUITE_VERSION=$(~/bin/getCurrentGitTag.sh /home/socci/Code/Pipelines/FACETS/FACETS.app/facets-suite)

RUNDIR=$1
cd $RUNDIR/facets
PTAG=$(pwd | awk -F"/" '{print $7}')

/home/socci/Code/Pipelines/FACETS/FACETS.app/doJoinMaf.py
ORIGMAF=$(ls ../post/*___SOMATIC.vep.maf)
FACETMAF=${ORIGMAF/___SOMATIC.vep.maf/___SOMATIC_FACETS.vep.maf}


ls facets/*/*hisens.seg | head -1 | xargs head -1 >${PTAG}____hisens.seg
ls facets/*/*hisens.seg | xargs egrep -hv chrom >>${PTAG}____hisens.seg
cd ../..
