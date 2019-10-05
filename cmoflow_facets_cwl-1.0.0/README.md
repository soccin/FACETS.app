# cmoflow_facets_cwl
CWL to mimic the logic in cmoflow_facets

# Usage

Prerequisite: You can run this CWL as-is using `cwltool` (if you have Docker) or `cwltool --singularity` (assuming you have `singularity` installed), but they will run locally. If you want to submit jobs to the JUNO cluster, we recommend using `cwltoil`; go to https://github.com/mskcc/cwl_run_scripts_juno - and follow the installation steps.

1. Clone this repo and all its submodules to your working directory.

```
git clone --recursive https://github.com/mskcc/cmoflow_facets_cwl
```

2. Edit the `inputs.yaml` file by providing the necessary information for inputs:

```
bam_normal: { class: File, path: /bam/here }
bam_tumor: { class: File, path: /bam/here }
facets_output_prefix: "my_tumor_id"
tumor_id: "my_tumor_id"
snp_pileup_output_file_name: "my_snp_pileup_output_file_name.dat.gz"
```

You can also edit specific parameters for `snp-pileup` and `doFacets` in the YAML.

3. Once complete, submit to a CWL executor.

# Examples of CWL executors

#### `cwltool --singularity` for local runs:
```
cwltool --singularity <path to the CWL> <path to input yaml file>
```

#### `cwltoil` (cluster jobs), if you have it installed:
```
mkdir work/ job-stores/ ## Required cwltoil directories for execution

PIPELINE_NAME=<path to the CWL>
YAML_FILE=<path to the input yaml file>
OUTPUT_NAME=<output directory name> # not absolute path; created in current working directory

cwltoil --singularity --logFile toil_log.log \
    --retryCount 3 \
    --batchSystem lsf \
    --stats \
    --debug  \
    --disableCaching  \
    --preserve-environment PATH TMPDIR TOIL_LSF_ARGS PWD \
    --defaultMemory 8G  \
    --maxCores 16  \
    --maxDisk 128G  \
    --maxMemory 256G  \
    --not-strict  \
    --realTimeLogging  \
    --jobStore job-stores/$OUTPUT_NAME \
    --workDir work/ \
    --outdir $OUTPUT_NAME \
    $PIPELINE_NAME $YAML_FILE
```

#### Alternatively, The `cwltoil` process is simplified in `run_script_lsf.sh`, which can be installed from [this repo](https://github.com/mskcc/cwl_run_scripts_juno).:

```
mkdir work/ job-stores/ ## Required cwltoil directories for execution

PIPELINE_NAME=<path to the CWL>
YAML_FILE=<path to the input yaml file>
OUTPUT_NAME=<output directory name> # not absolute path; created in current working directory

## output directory name is relative to current working directory
bash run_script_lsf.sh $PIPELINE_NAME $YAML_FILE $OUTPUT_NAME 
```
