#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

usage() {

    echo
    echo "    usage:: FACETS.app/run.sh [--tag TAG] [-o | --outdir ODIR] TUMORBAM [NORMALBAM]"
    echo
    exit

}

ODIR="."

while [[ $1 =~ ^- ]]; do
  case $1 in
    --tag)
      TAG="$2"
      shift 2
      ;;
    -o|--outdir)
      ODIR="$2"
      shift 2
      ;;
    -*|--*)
      echo "Unknown option $1"
      usage
      ;;
  esac
done

if [[ "$#" -lt 1 ]]; then
    usage
fi

TUMORBAM=$1; shift
NORMALBAM=$1; shift

echo "TAG=\"$TAG\""
echo "TUMORBAM="$TUMORBAM
echo "NORMALBAM=\"$NORMALBAM\""
echo "ODIR=\"$ODIR\""

# NBASE=$(basename $NORMALBAM | sed 's/.bam//')
# TBASE=$(basename $TUMORBAM | sed 's/.bam//')

# mkdir -p $ODIR



