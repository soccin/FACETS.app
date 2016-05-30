#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$#" -lt "2" ]; then
	echo
	echo "Too few arguments"
	echo
	echo "    usage:: FACETS.app/run.sh NORMALBAM TUMORBAM"
	echo "       or:: FACETS.app/run.sh NORMALBAM TUMORBAM TAG -c 50"
	echo
	echo "Arguments after TAG are passed to doFacets.R"
	exit
fi

NORMALBAM=$1; shift
TUMORBAM=$1; shift

NBASE=$(basename $NORMALBAM | sed 's/.bam//')
TBASE=$(basename $TUMORBAM | sed 's/.bam//')

if [ "$#" -lt "1" ]; then
    TAG=${TBASE}____${NBASE}
else
    TAG=$1; shift
fi
FTAG=$($SDIR/prettyTags.py $TAG)

echo " "TAG=$TAG
echo FTAG=$FTAG

### remaining arguments go to doFacets.R

pwd
ODIR=scratch/$TAG
mkdir -p $ODIR

should_wait="FALSE"

### if there are fewer than 10 lines in the countsMerged file, then overwrite it
nlines=$(gunzip --stdout $ODIR/countsMerged____${TAG}.dat.gz 2> /dev/null | head | wc -l)
if [[ $nlines == 10 ]]
then countsMerged_exists=true
else countsMerged_exists=false
fi


