p=$1;

 # input files
f=../reads/${p}.fastq.gz;
REF=/data/references/bean/bowtie2/Pvulgaris218_phytozome.fa;
STRs=/data/references/bean/strs/Pvulgaris218_trf_2_7_7_80_10_20_50_filter1.txt;

 # software variables
BOWTIE2=/data/software/bowtie2-2.2.6/bowtie2;
PICARD=/data/software/picard-tools-1.140/picard.jar;
NGSEP=/data/software/internal/NGSToolsApp_2.1.5.jar;

 # map the reads and sort the alignment
mkdir ${p}_tmpdir
${BOWTIE2} --rg-id ${p} --rg SM:${p} --rg PL:ILLUMINA -t -x ${REF} -U ${f} 2> ${p}_bowtie2.log | java -Xmx4g -jar ${PICARD} SortSam MAX_RECORDS_IN_RAM=1000000 SO=coordinate CREATE_INDEX=true TMP_DIR=${p}_tmpdir I=/dev/stdin O=${p}_bowtie2_sorted.bam >& ${p}_bowtie2_sort.log
rm -rf ${p}_tmpdir

 # calculate statistics from the alignments file
java -Xmx3g -jar ${NGSEP} QualStats ${REF} ${p}_bowtie2_sorted.bam >& ${p}_bowtie2_readpos.stats &
java -Xmx3g -jar ${NGSEP} CoverageStats ${p}_bowtie2_sorted.bam ${p}_bowtie2_coverage.stats >& ${p}_bowtie2_coverage.log &

 # find variants
java -Xmx6g -jar ${NGSEP} FindVariants -h 0.0001 -maxBaseQS 30 -minQuality 40 -noRep -noRD -noRP -maxAlnsPerStartPos 100 -ignore5 1 -ignore3 4 -sampleId ${p} -knownSTRs ${STRs} ${REF} ${p}_bowtie2_sorted.bam ${p}_bowtie2_NGSEP >& ${p}_bowtie2_NGSEP.log

