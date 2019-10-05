#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

module load python/2.7.14
module load singularity/3.3.0

if [ "$#" -lt "2" ]; then
	echo
	echo "Too few arguments"
	echo
	echo "    usage:: FACETS.app/run.sh NORMALBAM TUMORBAM [TAG]"
	echo
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
FTAG=$($SDIR/bin/prettyTags.py $TAG)

uuid=$(echo $FTAG | md5sum - | awk '{print $1}')
D1=$(echo $uuid | perl -ne 'm/^(..)/;print $1')

ODIR=results/$D1/$FTAG

echo ODIR=$ODIR

mkdir -p $ODIR

$SDIR/bin/fillTemplate \
    $SDIR/TEMPLATE.yaml \
    NORMAL=$NORMALBAM \
    TUMOR=$TUMORBAM \
    PREFIX=$FTAG \
    > $ODIR/input.yaml

. $SDIR/venv/bin/activate

cwltool \
    --outdir $ODIR \
    --singularity $SDIR/cmoflow_facets_cwl-1.0.0/cmoflow_facets.cwl \
    $ODIR/input.yaml \
    > $ODIR/log 2>&1

