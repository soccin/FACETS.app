#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$#" -ne "2" ]; then
	echo
	echo "Too few arguments"
	echo
	echo "    usage:: FACETS/App.sh NORMALBAM TUMORBAM"
	echo
	exit
fi

NORMALBAM=$1
TUMORBAM=$2

NBASE=$(basename $NORMALBAM | sed 's/.bam//')
TBASE=$(basename $TUMORBAM | sed 's/.bam//')

TAG=${TBASE}____${NBASE}
ODIR=scratch/$TAG
mkdir -p $ODIR

bsub -We 59 -o LSF/ -e Err/ -J f_COUNT_$$_N -R "rusage[mem=40]" \
    $SDIR/getBaseCountsZZAutoWithName.sh $ODIR/${NBASE}.dat $NORMALBAM
bsub -We 59 -o LSF/ -e Err/ -J f_COUNT_$$_T -R "rusage[mem=40]" \
    $SDIR/getBaseCountsZZAutoWithName.sh $ODIR/${TBASE}.dat $TUMORBAM

bsub -We 59 -o LSF/ -e Err/ -n 2 -R "rusage[mem=60]" -J f_JOIN_$$ -w "post_done(f_COUNT_$$_*)" \
    "$SDIR/mergeTN.py $ODIR/${TBASE}.dat.gz $ODIR/${NBASE}.dat.gz | gzip -9 -c - >$ODIR/countsMerged____${TAG}.dat.gz"

bsub -We 59 -o LSF/ -e Err/ -J f_FACETS_$$ -w "post_done(f_JOIN_$$)" \
    $SDIR/doFacets.R $ODIR/countsMerged____${TAG}.dat.gz
