#!/bin/bash

PROJNO=$(ls facets__* | head -1 | perl -ne 'm/facets__(Proj_.*?)__s_/;print $1')
echo $PROJNO

~/opt/bin/convert facets__${PROJNO}__*BiSeg.png facets__${PROJNO}__BiSeg.pdf 
~/opt/bin/convert facets__${PROJNO}__*CNCF.png facets__${PROJNO}__CNCF.pdf
rm facets__${PROJNO}__*BiSeg.png facets__${PROJNO}__*CNCF.png
mkdir rdata
Rscript --no-save ~/Code/Pipelines/FACETS/v3/FACETS/facets2igv.R
mv *Rdata rdata
mv IGV_*.seg facets__${PROJNO}__IGV.seg
~/Code/Pipelines/FACETS/v3/FACETS/out2tbl.py *out >facets__${PROJNO}__OUT.txt
(cat facets__*cncf.txt | head -1; cat facets__*cncf.txt | egrep -v "^ID")>facets__${PROJNO}__CNCF.txt
rm facets__*cncf.txt
rm facets__*.out

