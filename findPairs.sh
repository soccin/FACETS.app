#!/bin/bash

if [ "$#" == "0" ]; then
    echo "Usage: findPairs.sh BAM_LIST_FILE NORMAL TUMOR"
    exit
fi

SDIR="$( cd "$( dirname "$0" )" && pwd )"

BAMS=$1
NORMAL=$2
TUMOR=$3

# Delegate to python function so we can get this correct
# for all cases

$SDIR/findPairs.py $BAMS $NORMAL $TUMOR
