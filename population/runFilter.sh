pop=$1
mI=$2
reps=/data/projects/bean/WGSParentals/population/Pvulgaris218_repMasked.txt
NGSEP=/data/software/internal/NGSToolsApp_2.1.5.jar
quality="20 30 40"
parents="1012-29-3-3A,PR1146-138"

 # filter by quality, keep only SNPs, remove positions that are highly heterozygous, with very low MAF or with few samples genotyped, impute and compress.

for q in ${quality};
do
{ java -Xmx3g -jar ${NGSEP} FilterVCF      -frs   ${reps} -q ${q} ${pop}_annotated.vcf 1>${pop}_annotated_repMasked_q${q}.vcf ;
  java -Xmx2g -jar ${NGSEP} SummaryStats   -m 1   ${pop}_annotated_repMasked_q${q}.vcf 1>${pop}_annotated_repMasked_q${q}_summary.stats ;
  java -Xmx1g -jar ${NGSEP} DiversityStats        ${pop}_annotated_repMasked_q${q}.vcf 1>${pop}_annotated_repMasked_q${q}.div ;
  awk 'BEGIN{FS=":"}{if($3>=0.06)print $1"\t"$3}' ${pop}_annotated_repMasked_q${q}.div 1>${pop}_annotated_repMasked_q${q}.hets ;
  java -Xmx3g -jar ${NGSEP} FilterVCF -s -minMAF 0.05 -frs ${pop}_annotated_repMasked_q${q}.hets -minI ${mI} ${pop}_annotated_repMasked_q${q}.vcf 1>${pop}_annotated_repMasked_q${q}_s_maf0.05_hets6pct_minI${mI}.vcf ;
  java -Xmx1g -jar ${NGSEP} SummaryStats -m ${mI} ${pop}_annotated_repMasked_q${q}_s_maf0.05_hets6pct_minI${mI}.vcf 1>${pop}_annotated_repMasked_q${q}_s_maf0.05_hets6pct_minI${mI}_summary.stats ;
  java -Xmx16g -jar ${NGSEP} ImputeVCF -p ${parents} -k 2 -c 0.003 -t ${pop}_annotated_repMasked_q${q}_s_maf0.05_hets6pct_minI${mI}.vcf ${pop}_annotated_repMasked_q${q}_s_maf0.05_hets6pct_minI${mI}_k2_c0.003_t >& ${pop}_annotated_repMasked_q${q}_s_maf0.05_hets6pct_minI${mI}_k2_c0.003_t_imputed.log ;
  bgzip -i ${pop}_annotated_repMasked_q${q}.vcf ;
  tabix -p vcf ${pop}_annotated_repMasked_q${q}.vcf.gz ;
 } 2>q${q}.err &
done
wait

bgzip -i ${pop}_annotated.vcf
tabix -p vcf ${pop}_annotated.vcf.gz

