# autoGBS
These are the bash scripts used at CIAT to run the NGSEP pipeline for GBS reads.

### Run the pipeline in 4 single steps:
1. Read and understand the scripts
2. Place the reads in their directory:
..- one `ID.fastq.gz` file per sample, with a different ID for each sample.
3. Modify the population, reference and software variables in `runPipeline.sh`
4. Type:
``` bash
./runPipeline.sh &
```

Note.1: Reads should be single-end and already demultiplexed (use `java -jar NGSEP.jar Deconvolute`)
Note.2: Expected heterozygozity and other population parameters are set for Common Bean
