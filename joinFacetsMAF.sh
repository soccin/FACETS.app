#!/bin/bash

if [ "$#" != "1" ]; then
    echo "usage: joinFacetsMAF.sh POSTFOLDER"
    exit
fi

SDIR="$( cd "$( dirname "$0" )" && pwd )"

FACETS_VERSION=$($SDIR/bin/getCurrentGitTag.sh $SDIR)
FACETS_SUITE_VERSION=$($SDIR/bin/getCurrentGitTag.sh $SDIR/facets-suite)

RUNDIR=$1
cd $RUNDIR/facets

if [ "$?" != "0" ]; then
    echo "FATAL ERROR could not cd to facets dir"
    echo $RUNDIR/facets
    exit 1
fi

PTAG=$(pwd | awk -F"/" '{print $7}')
echo $PTAG

$SDIR/doJoinMaf.py

if [ "$?" != "0" ]; then
    echo "FATAL ERROR doJoinMaf.py FAILED"
    exit 1
fi

ORIGMAF=$(ls ../post/*___SOMATIC.vep.maf)
FACETMAF=${ORIGMAF/___SOMATIC.vep.maf/___SOMATIC_FACETS.vep.maf}

egrep "^#" $ORIGMAF >$FACETMAF
echo "#CBE:$FACETS_VERSION" >>$FACETMAF
echo "#CBE:SubMod:$FACETS_SUITE_VERSION" >>$FACETMAF
echo "#CBE:$0 $*" >>$FACETMAF
$SDIR/bin/getFacetsRunParameters.py $(ls facets/*/*hisens.out | head -1) >>$FACETMAF
cat join.maf >>$FACETMAF

ls facets/*/*hisens.seg | head -1 | xargs head -1 >${PTAG}____hisens.seg
ls facets/*/*hisens.seg | xargs egrep -hv chrom >>${PTAG}____hisens.seg
cd ../..
