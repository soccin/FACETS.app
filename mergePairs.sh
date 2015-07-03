#!/bin/bash
NORMAL=$1
TUMOR=$2
NORMALCOUNT=$(find counts -name "*.gz" | egrep $TUMOR | egrep "_____"$NORMAL)
TUMORCOUNT=$(find counts -name "*.gz" | egrep $NORMAL | egrep "_____"$TUMOR)
echo $NORMALCOUNT "<=>" $TUMORCOUNT
./FACETS/mergeTN.py $TUMORCOUNT $NORMALCOUNT | gzip -9 -c - >${TUMORCOUNT}______MERGE.dat.gz
