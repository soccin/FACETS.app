#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

usage() {

    echo
    echo "    usage:: FACETS.app/run.sh TUMORBAM NORMALBAM"
    echo
    exit

}



# NORMALBAM=$1; shift
# TUMORBAM=$1; shift

# NBASE=$(basename $NORMALBAM | sed 's/.bam//')
# TBASE=$(basename $TUMORBAM | sed 's/.bam//')

# mkdir -p $ODIR



