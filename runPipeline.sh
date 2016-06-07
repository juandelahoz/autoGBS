### MANUALLY EDIT THESE VARIABLES ###
 # population parameters
pop="beans"			# population name
parents="P01,P02,P03,P04"       # for imputation
quality="20 30 40 60"           # genotype quality filter
t=5                             # number of threads
i5=1				# trim read on the 5' end
i3=4				# trim read on the 3' end
exp_het=0.0001			# expected heterozygosity
cm_x_kb=0.003			# centimorgans per Kbp

 # reference files
REF=/path/to/indexed_reference.fa
seqnames=/path/to/reference_sequenceNames.txt
genes=/path/to/reference_annotations.gff3
STRs=/path/to/reference_short_tandem_repeats.gff
reps=/path/to/reference_repeats_to_mask.txt

 # software variables
BOWTIE2=/path/to/software/bowtie2-2.2.X/bowtie2
PICARD=/path/to/software/picard.jar
NGSEP=/path/to/software/NGSEP.jar
##################################################

ls -1 reads/*.fastq.gz | awk '{print substr($1,7,index($1,".fastq.gz")-7)}' >samples.txt
numsampl=`wc -l samples.txt | awk '{print $1}'`
s=`expr $numsampl / $t`
s=`expr $s + 1`			# samples per thread
mI=`expr $numsampl / 2`		# min num of inds genotyped ~50%

 # pipeline

cd mapping

for i in `seq ${t}`;
do
 awk '{if(NR>(('${i}'-1)*'${s}')&&NR<=('${i}'*'${s}'))print "./runMapping_NGSEP.sh "$1" '$i5' '$i3' '$exp_het' '$REF' '$STRs' '$BOWTIE2' '$PICARD' '$NGSEP'"}' ../samples.txt > runSamples_${i}
 chmod 744 runSamples_${i}; ./runSamples_${i} &
done
wait ; rm runSamples*

cd ../genotyping

java -jar ${NGSEP} MergeVariants ${seqnames} ${pop}_variants.vcf ../mapping/*NGSEP.vcf >& ${pop}_variants.log

for i in `seq ${t}`;
do
 awk '{if(NR>(('${i}'-1)*'${s}')&&NR<=('${i}'*'${s}'))print "./runGenotyping.sh "$1" '$pop' '$i5' '$i3' '$exp_het' '$REF' '$NGSEP'"}' ../samples.txt > runSamples_${i}
 chmod 744 runSamples_${i}; ./runSamples_${i} &
done
wait ; rm runSamples*

cd ../population

java -jar ${NGSEP} MergeVCF ${seqnames} ../genotyping/*NGSEP_gt.vcf 1>${pop}.vcf 2>${pop}.log
java -jar ${NGSEP} Annotate ${pop}.vcf ${genes} ${REF} 1>${pop}_annotated.vcf
java -Xmx3g -jar ${NGSEP} SummaryStats -m 1 ${pop}_annotated.vcf 1>${pop}_annotated_summary.stats &

./runFilter.sh $pop $mI $quality $parents $cm_x_kb $reps $NGSEP
