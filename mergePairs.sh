#!/bin/bash
SDIR="$( cd "$( dirname "$0" )" && pwd )"
NORMAL=$1
TUMOR=$2
NORMALCOUNT=$(find counts -name "*.gz" | egrep $TUMOR | egrep "_____"$NORMAL)
TUMORCOUNT=$(find counts -name "*.gz" | egrep $NORMAL | egrep "_____"$TUMOR)
echo $NORMALCOUNT "<=>" $TUMORCOUNT
$SDIR/mergeTN.R $TUMORCOUNT $NORMALCOUNT | gzip -9 -c - >${TUMORCOUNT}______MERGE.dat.gz
