#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$#" -lt "2" ]; then
	echo
	echo "Too few arguments"
	echo
	echo "    usage:: FACETS/App.sh NORMALBAM TUMORBAM"
	echo
	exit
fi

NORMALBAM=$1; shift
TUMORBAM=$1; shift
TAG=$1; shift
### remaining arguments go to doFacets.R

NBASE=$(basename $NORMALBAM | sed 's/.bam//')
TBASE=$(basename $TUMORBAM | sed 's/.bam//')

## TAG=${TBASE}____${NBASE}
ODIR=scratch/$TAG
mkdir -p $ODIR

should_wait="FALSE"

### make normal counts only if both countsMerged and normal counts files are absent
if [[ ! -s $ODIR/countsMerged____${TAG}.dat.gz && ! -s $ODIR/${NBASE}.dat.gz ]]; then
    echo make normal counts
    bsub -We 59 -o LSF/ -e Err/ -J f_COUNT_$$_N -R "rusage[mem=40]" \
	 $SDIR/getBaseCountsZZAutoWithName.sh $ODIR/${NBASE}.dat $NORMALBAM
    should_wait=true
fi

### make tumor counts only if both countsMerged and tumor counts files are absent
if [[ ! -s $ODIR/countsMerged____${TAG}.dat.gz && ! -s $ODIR/${TBASE}.dat.gz ]]; then
    echo make tumor counts
    bsub -We 59 -o LSF/ -e Err/ -J f_COUNT_$$_T -R "rusage[mem=40]" \
	 $SDIR/getBaseCountsZZAutoWithName.sh $ODIR/${TBASE}.dat $TUMORBAM
    should_wait=true
fi

if [[ ! -s $ODIR/countsMerged____${TAG}.dat.gz ]]; then
    echo -n "merge counts ... "
    if [[ $should_wait = true ]]; then
	echo waiting
	bsub -We 59 -o LSF/ -e Err/ -n 2 -R "rusage[mem=60]" -J f_JOIN_$$ -w "post_done(f_COUNT_$$_*)" \
	     "$SDIR/mergeTN.R $ODIR/${TBASE}.dat.gz $ODIR/${NBASE}.dat.gz | gzip -9 -c - >$ODIR/countsMerged____${TAG}.dat.gz"
    else
	echo not waiting
	bsub -We 59 -o LSF/ -e Err/ -n 2 -R "rusage[mem=60]" -J f_JOIN_$$ \
	     "$SDIR/mergeTN.R $ODIR/${TBASE}.dat.gz $ODIR/${NBASE}.dat.gz | gzip -9 -c - >$ODIR/countsMerged____${TAG}.dat.gz"
    fi
    should_wait=true
fi
    
if [[ $should_wait = true ]]; then
    bsub -We 59 -o LSF/ -e Err/ -J f_FACETS_$$ -w "post_done(f_JOIN_$$)" \
	 $SDIR/doFacets.R $* $ODIR/countsMerged____${TAG}.dat.gz
else
    bsub -We 59 -o LSF/ -e Err/ -J f_FACETS_$$ \
	 $SDIR/doFacets.R $* $ODIR/countsMerged____${TAG}.dat.gz
fi
