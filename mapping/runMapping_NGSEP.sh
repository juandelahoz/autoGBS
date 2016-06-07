p=$1
i5=$2
i3=$3
exp_het=$4
REF=$5
STRs=$6
BOWTIE2=$7
PICARD=$8
NGSEP=$9

f=../reads/${p}.fastq.gz

 # map the reads and sort the alignment
mkdir ${p}_tmpdir
${BOWTIE2} --rg-id ${p} --rg SM:${p} --rg PL:ILLUMINA -t -x ${REF} -U ${f} 2> ${p}_bowtie2.log | java -Xmx4g -jar ${PICARD} SortSam MAX_RECORDS_IN_RAM=1000000 SO=coordinate CREATE_INDEX=true TMP_DIR=${p}_tmpdir I=/dev/stdin O=${p}_bowtie2_sorted.bam >& ${p}_bowtie2_sort.log
rm -rf ${p}_tmpdir

 # calculate statistics from the alignments file
java -Xmx3g -jar ${NGSEP} QualStats ${REF} ${p}_bowtie2_sorted.bam >& ${p}_bowtie2_readpos.stats &
java -Xmx3g -jar ${NGSEP} CoverageStats ${p}_bowtie2_sorted.bam ${p}_bowtie2_coverage.stats >& ${p}_bowtie2_coverage.log &

 # find variants
java -Xmx6g -jar ${NGSEP} FindVariants -h ${exp_het} -maxBaseQS 30 -minQuality 40 -noRep -noRD -noRP -maxAlnsPerStartPos 100 -ignore5 ${i5} -ignore3 ${i3} -sampleId ${p} -knownSTRs ${STRs} ${REF} ${p}_bowtie2_sorted.bam ${p}_bowtie2_NGSEP >& ${p}_bowtie2_NGSEP.log

