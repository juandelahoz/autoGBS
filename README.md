# autoGBS
These are the bash scripts used at CIAT to run the NGSEP pipeline for GBS reads.

## Run the pipeline in 6 single steps:
1. Read and understand the scripts
2. Place the reads in their directory:
 ..- one `*.fastq.gz` file per sample, with the ID of the sample in the `*` place.
3. Modify the software and reference file variables in each script.
4. Define the parentals for imputation in `population/runFilter.sh`
5. Type:
``` bash
    ./runPipeline.sh pop_name samples.txt samples_per_thread num_of_threads min_num_of_inds_genotyped &
```
And relax.

Note: Reads should be single-end and should already be demultiplexed (you can use NGSEP to deconvolute reads)
