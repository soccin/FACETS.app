#!/bin/bash

SDIR="$( cd "$( dirname "$0" )" && pwd )"

if [ $# -ne "2" ]; then
    echo "usage:: getBaseCountsZZAuto.sh OFILE BAM"
    exit
fi

OFILE=$1
BAM=$2

CHR1TAG=$(samtools view -H $BAM | fgrep "@SQ" | head -1 | awk '{print $2"::"$3}')

if [ "$CHR1TAG" == "SN:chr1::LN:197195432" ]; then
	GENOME=/ifs/work/bio/assemblies/M.musculus/mm9/mm9.fasta
	#SNPS=$SDIR/lib/ucsc_mm9_dbsnp128_NoDups.vcf.gz
	SNPS=$SDIR/lib/ucsc_mm9_dbsnp128_NoDups___plusPseudo50__DROP_SORT.vcf.gz
elif [ "$CHR1TAG" == "SN:chr1::LN:249250621" ]; then
	GENOME=/ifs/work/bio/assemblies/H.sapiens/hg19/hg19.fasta
	SNPS=$SDIR/lib/dbsnp_137.hg19__RmDupsClean__plusPseudo50__DROP_SORT.vcf.gz
elif [ "$CHR1TAG" == "SN:1::LN:249250621" ]; then
	GENOME=/ifs/work/socci/Depot/Genomes/H.sapiens/b37/Homo_sapiens_assembly19.fasta
	SNPS=$SDIR/lib/dbsnp_137.b37__RmDupsClean__plusPseudo50__DROP_SORT.vcf.gz
elif [ "$CHR1TAG" == "SN:chr1::LN:195471971" ]; then
    GENOME=/ifs/depot/assemblies/M.musculus/mm10/mm10.fasta
    SNPS=$SDIR/lib/mouse_MM10_dbSNP_NCBI_20150625___noChrM__plusPseudo50__DROP_SORT.vcf.gz
else
	echo "INVALID GENOME"
	echo $CHR1TAG
	exit
fi

echo $GENOME
echo $SNPS

MINCOV=0
BASEQ=20
MAPQ=15

$SDIR/bin/GetBaseCounts \
    --filter_improper_pair \
    --sort_output \
    --fasta $GENOME \
    --vcf $SNPS \
    --maq $MAPQ --baq $BASEQ --cov $MINCOV \
    --bam $BAM \
    --out $OFILE

gzip -9 $OFILE

