pop=$1		# population name
smpl=$2		# file with the list of samples (only their name)
s=$3		# samples per thread
t=`seq $4` 	# number of threads
mI=$5		# min num of inds genotyped (for the filtering)
REF=/data/references/bean/Pvulgaris218_phytozome.fa
seqnames=/data/references/bean/Pvulgaris218_phytozome_sequenceNames.txt
genes=/data/references/bean/genes/Pvulgaris_218_gene.gff3
NGSEP=/data/software/internal/NGSToolsApp_2.1.5.jar

cd mapping

for i in ${t};
do
 awk '{if(NR>(('${i}'-1)*'${s}')&&NR<=('${i}'*'${s}'))print "./runMapping_NGSEP.sh "$1}' ../${smpl} > runSamples_${i}
 chmod 744 runSamples_${i}; ./runSamples_${i} &
done
wait ; rm runSamples*

cd ../genotyping

java -jar ${NGSEP} MergeVariants ${seqnames} ${pop}_variants.vcf ../mapping/*NGSEP.vcf >& ${pop}_variants.log

for i in ${t};
do
 awk '{if(NR>(('${i}'-1)*'${s}')&&NR<=('${i}'*'${s}'))print "./runGenotyping.sh "$1,"'${pop}'"}' ../${smpl} > runSamples_${i}
 chmod 744 runSamples_${i}; ./runSamples_${i} &
done
wait ; rm runSamples*

cd ../population

java -jar ${NGSEP} MergeVCF ${seqnames} ../genotyping/*NGSEP_gt.vcf 1>${pop}.vcf 2>${pop}.log
java -jar ${NGSEP} Annotate ${pop}.vcf ${genes} ${REF} 1>${pop}_annotated.vcf
java -Xmx3g -jar ${NGSEP} SummaryStats -m 1 ${pop}_annotated.vcf 1>${pop}_annotated_summary.stats &

./runFilter.sh ${pop} ${mI}
