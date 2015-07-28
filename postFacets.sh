#!/bin/bash

PROJNO=$(ls facets__* | head -1 | perl -ne 'm/facets__(Proj_.*?)__s_/;print $1')
if [ "$PROJNO" == "" ]; then
    PROJNO=$(ls facets__* | head -1 | perl -ne 'm/_bc\d+_(Proj_.*?)_L\d\d\d_/;print $1')
fi

echo $PROJNO
if [ "$PROJNO" == "" ]; then
    echo "ERROR: Can not parse project number"
    echo $(ls facets__* | head -1)
    exit
fi

CVAL=$(ls facets__* | head -1 | perl -ne 'm/cval__(\d+?)_/;print $1')

if [ "$CVAL" == "" ]; then
    echo "ERROR: can not parse CVAL"
    echo $(ls facets__* | head -1)
    exit
fi

echo "CVAL=$CVAL"

ODIR=Cval_${CVAL}
mkdir $ODIR

~/opt/bin/convert facets_*${PROJNO}_*BiSeg.png $ODIR/facets__${PROJNO}__Cval_${CVAL}__BiSeg.pdf
~/opt/bin/convert facets_*${PROJNO}_*CNCF.png $ODIR/facets__${PROJNO}__Cval_${CVAL}__CNCF.pdf

mkdir $ODIR/rdata
Rscript --no-save ~/Code/Pipelines/FACETS/v3/FACETS/facets2igv.R
mv IGV_*.seg $ODIR/facets__${PROJNO}__Cval_${CVAL}__IGV.seg

~/Code/Pipelines/FACETS/v3/FACETS/out2tbl.py *out >$ODIR/facets__${PROJNO}__Cval_${CVAL}__OUT.txt
(cat facets__*cncf.txt | head -1; cat facets__*cncf.txt | egrep -v "^ID")>$ODIR/facets__${PROJNO}__Cval_${CVAL}__CNCF.txt

mv *Rdata $ODIR/rdata
rm facets__*cncf.txt
rm facets__*.out
rm facets_*${PROJNO}_*BiSeg.png
rm facets_*${PROJNO}_*CNCF.png

