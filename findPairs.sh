#!/bin/bash

if [ "$#" == "0" ]; then
    echo "Usage: findPairs.py BAM_LIST_FILE NORMAL TUMOR"
    exit
fi

BAMS=$1
NORMAL=$2
TUMOR=$3

NORMALBAM=$(cat $BAMS | egrep "_"$NORMAL".bam")
TUMORBAM=$(cat $BAMS | egrep "_"$TUMOR".bam")

echo $NORMALBAM $TUMORBAM

