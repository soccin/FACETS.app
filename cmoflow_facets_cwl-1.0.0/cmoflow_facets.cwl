#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  facets_vcf:
    type: File
    secondaryFiles:
      - .gz

  bam_normal:
    type: File

  bam_tumor:
    type: File
 
  # snp-pileup parameters
  pseudo_snps:
    type: int

  count_orphans:
    type: boolean

  gzip:
    type: boolean

  ignore_overlaps:
    type: boolean

  max_depth:
    type: int

  min_base_quality:
    type: int

  min_map_quality:
    type: int

  min_read_counts:
    type: int

  snp_pileup_output_file_name:
    type: string

  # doFacets parameters
  cval:
    type: int

  snp_nbhd:
    type: int

  ndepth:
    type: int 

  min_nhet:
    type: int

  purity_cval:
    type: int

  purity_snp_nbhd:
    type: int

  purity_ndepth:
    type: int

  purity_min_nhet:
    type: int

  genome:
    type: string 

  directory:
   type: string

  R_lib: 
    type: string

  single_chrom: 
    type: string

  ggplot2: 
    type: string

  seed:
    type: int

  tumor_id:
    type: string

  facets_output_prefix:
    type: string

  dipLogR:
    type: float?

outputs:

  snp_pileup_out:
    type: File
    outputSource: do_snp_pileup/output_file

  facets_png: 
    type: File[]?
    outputSource: do_facets/png_files

  facets_txt_purity:
    type: File?
    outputSource: do_facets/txt_files_purity

  facets_txt_hisens:
    type: File?
    outputSource: do_facets/txt_files_hisens

  facets_out_files:
    type: File[]?
    outputSource: do_facets/out_files

  facets_rdata:
    type: File[]?
    outputSource: do_facets/rdata_files

  facets_seg:
    type: File[]?
    outputSource: do_facets/seg_files

steps:

  do_snp_pileup:
    run: ./htstools_0.1.1/snp-pileup.cwl
    in:
        vcf_file: facets_vcf
        bam_normal: bam_normal
        bam_tumor: bam_tumor
        pseudo_snps: pseudo_snps
        count_orphans: count_orphans
        gzip: gzip
        ignore_overlaps: ignore_overlaps
        max_depth: max_depth
        min_base_quality: min_base_quality
        min_read_counts: min_read_counts
        min_map_quality: min_map_quality
        output_file: snp_pileup_output_file_name
    out: [ output_file ]

  do_facets:
    run: ./facets_1.5.6/facets.doFacets-1.5.6.cwl
    in:
      genome: genome
      counts_file: do_snp_pileup/output_file
      TAG: facets_output_prefix
      tumor_id: tumor_id
      directory: directory
      cval: cval
      snp_nbhd: snp_nbhd
      ndepth: ndepth
      min_nhet: min_nhet
      purity_cval: purity_cval
      purity_snp_nbhd: purity_snp_nbhd
      purity_ndepth: purity_ndepth
      purity_min_nhet: purity_min_nhet
      genome: genome
      directory: directory
      R_lib: R_lib
      single_chrom: single_chrom
      ggplot2: ggplot2
      seed: seed
      dipLogR: dipLogR
    out: [ png_files, txt_files_purity, txt_files_hisens, out_files, rdata_files, seg_files ]
