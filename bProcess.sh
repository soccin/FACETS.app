#!/bin/bash

if [ $# -lt 1 ]; then
    echo "usage: FACETS.app/bProcess.sh pipelineOutputDir [PROJECTDIR]"
    exit
fi

SDIR="$( cd "$( dirname "$0" )" && pwd )"

PIPELINEDIR=$1
projectNo=$(echo $PIPELINEDIR | perl -ne 'm|/Proj_([^/\s]*)|; print $1')


if [ $# -eq 1 ]; then

	NUMDIRS=$(find /ifs/projects/BIC /ifs/projects/CMO -type d | egrep -v "(drafts|archive)" | egrep "Proj_$projectNo$" | wc -l)
	PROJECTDIR=$(find /ifs/projects/BIC /ifs/projects/CMO -type d | egrep -v "(drafts|archive)" | egrep "Proj_$projectNo$")

	SCRIPT=$(basename $0)
	if [ "$NUMDIRS" != "1" ]; then
	    echo $SCRIPT :: Problem finding project files for Proj_$projectNo
	    echo $SCRIPT NUMDIRS=$NUMDIRS
	    echo
	    exit
	fi

else 

	PROJECTDIR=$2

fi

echo $SCRIPT PROJECTDIR=\"$PROJECTDIR\"

BAMDIR=$PIPELINEDIR/alignments

echo $SCRIPT
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
    | xargs -n 2 $SDIR/findPairs.sh bams_$$ \
    | xargs -n 2 $SDIR/run.sh
