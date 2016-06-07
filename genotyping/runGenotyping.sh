p=$1
pop=$2
i5=$3
i3=$4
exp_het=$5
REF=$6
NGSEP=$7

java -Xmx4g -jar ${NGSEP} FindVariants -knownVariants ${pop}_variants.vcf -h ${exp_het} -maxBaseQS 30 -noRep -noRD -noRP -maxAlnsPerStartPos 100 -ignore5 ${i5} -ignore3 ${i3} -sampleId ${p} ${REF} ../mapping/${p}_bowtie2_sorted.bam ${p}_bowtie2_NGSEP_gt >& ${p}_bowtie2_NGSEP_gt.log

