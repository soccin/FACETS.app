#!/bin/bash

if [ "$#" != "1" ]; then
    echo "usage: FACETS.app/bProcess.sh pipelineOutputDir"
    exit
fi

SDIR="$( cd "$( dirname "$0" )" && pwd )"

PIPELINEDIR=$1
projectNo=$(echo $PIPELINEDIR | perl -ne 'm|/Proj_([^/\s]*)|; print $1')
PROJECTDIR=$(find /ifs/projects/BIC -type d | egrep "Proj_$projectNo$")
BAMDIR=$PIPELINEDIR/alignments

echo
echo PROJECTDIR=$PROJECTDIR
echo PIPELINEDIR=$PIPELINEDIR
echo pairingFile=$PROJECTDIR/*_sample_pairing.txt
echo projectNo=$projectNo
echo BAMDIR=$BAMDIR
echo
echo

ls $BAMDIR/*bam >bams_$$

cat $PROJECTDIR/*_sample_pairing.txt \
    | fgrep -vw "na" \
    | xargs -n 2  $SDIR/findPairs.sh bams_$$ \
    | xargs -n 2 $SDIR/run.sh
