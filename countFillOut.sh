#!/bin/bash

DBSNP=/ifs/work/socci/Depot/Pipelines/FACETS/v3/lib/dbsnp_137.b37__RmDupsClean__plusPseudo50__DROP_SORT.vcf.gz

./FillOut/bin/GetBaseCountsMultiSample \
    --fasta /ifs/depot/assemblies/H.sapiens/b37/b37.fasta \
    --vcf <(zcat testChr1.vcf.gz) \
    --filter_improper_pair 0 \
    --output outGBC2.vcf \
    --baq 13 \
    --maq 20 \
    --bam P_0004260_T02_IM5_N:/ifs/res/seq/soccin/donoghum/Proj_UTest03/r_003/alignments/Proj_UTest03_indelRealigned_recal_s_P_0004260_T02_IM5_N.bam \
    --bam P_0004260_T02_IM5:/ifs/res/seq/soccin/donoghum/Proj_UTest03/r_003/alignments/Proj_UTest03_indelRealigned_recal_s_P_0004260_T02_IM5.bam


#    --bam H_MV-3B-A9HL-10A-01D-A38A-09:/ifs/assets/socci/Cache/SingerTCGA/SARC_WXS/WXS/3c2d9f1e-89c6-4940-92e9-2bbd1b1ca247/c24446e1d0a4123ae50bcf3f69a4ebe6.bam \
#    --bam H_MV-3B-A9HL-01A-11D-A387-09:/ifs/assets/socci/Cache/SingerTCGA/SARC_WXS/WXS/6e140e4a-d34b-47b3-babd-2b8521f2a98b/4e7a0ad1e471579888e8c1ac820f4a51.bam
