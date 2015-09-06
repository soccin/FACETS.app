#!/bin/bash

if [ "$#" != "1" ]; then
    echo "usage: FACETS.app/bProcess.sh pipelineOutputDir"
    exit
fi

SDIR="$( cd "$( dirname "$0" )" && pwd )"

PIPELINEDIR=$1
projectNo=$(echo $PIPELINEDIR | perl -ne 'm|/Proj_([^/\s]*)|; print $1')
PROJECTDIR=$(ls -d /ifs/projects/BIC/* | fgrep $projectNo)
BAMDIR=$PIPELINEDIR/alignments

echo $PROJECTDIR
echo $PIPELINEDIR
echo $PROJECTDIR/*_sample_pairing.txt
echo $projectNo
echo $BAMDIR

ls $BAMDIR/*bam >bams_$$

cat $PROJECTDIR/*_sample_pairing.txt \
    | fgrep -vw "na" \
    | xargs -n 2  $SDIR/findPairs.sh bams_$$ \
    | xargs -n 2 $SDIR/run.sh
