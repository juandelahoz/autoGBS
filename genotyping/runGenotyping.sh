p=$1;
pop=$2;
REF=/data/references/bean/Pvulgaris218_phytozome.fa;
NGSEP=/data/software/internal/NGSToolsApp_2.1.5.jar;

java -Xmx4g -jar ${NGSEP} FindVariants -knownVariants ${pop}_variants.vcf -h 0.0001 -maxBaseQS 30 -noRep -noRD -noRP -maxAlnsPerStartPos 100 -ignore5 1 -ignore3 4 -sampleId ${p} ${REF} ../mapping/${p}_bowtie2_sorted.bam ${p}_bowtie2_NGSEP_gt >& ${p}_bowtie2_NGSEP_gt.log

