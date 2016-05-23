#!/bin/bash

DBSNP=/ifs/work/socci/Depot/Pipelines/FACETS/v3/lib/dbsnp_137.b37__RmDupsClean__plusPseudo50__DROP_SORT.vcf.gz
#DBSNP=./test1.vcf.gz

samtools mpileup \
    --min-MQ 20 \
    --min-BQ 13 \
    --positions <(zcat $DBSNP) \
    --bam-list bamList \
    --uncompressed \
    --output-tags DP,AD,ADF,ADR,SP \
    --fasta-ref /ifs/depot/assemblies/H.sapiens/b37/b37.fasta \
    --count-orphans \
    | bcftools call --output-type v --multiallelic-caller --keep-alts \
    | gzip -c - > outSAMTOOLSFull.vcf.gz
