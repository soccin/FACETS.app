#!/bin/bash

if [ "$#" != "2" ]; then
    echo "usage: doFacets.sh PAIR_FILE ALIGN_DIR"
    exit
fi

SDIR="$( cd "$( dirname "$0" )" && pwd )"
PAIRFILE=$1
BAMDIR=$2

ls $BAMDIR/*bam >bams_$$
cat $PAIRFILE | xargs -n 2  $SDIR/findPairs.sh bams_$$ \
    | xargs -n 2 $SDIR/App.sh
