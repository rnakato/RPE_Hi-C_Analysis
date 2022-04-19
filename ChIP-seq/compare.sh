gt=/work/Database/UCSC/hg38/genome_table
#gene=/work/Database/UCSC/hg38/refFlat.txt
#gene=/work/Database/Ensembl/GRCh38/release101/gtf_chrUCSC/Homo_sapiens.GRCh38.101.chr.proteincoding.gene.refFlat
gene=/work/Database/Ensembl/GRCh38/release103/gtf_chrUCSC/Homo_sapiens.GRCh38.proteincoding.103.chr.transcript.refFlat

mkdir -p compare
for str in Ct si7 si621 si628
do
    bed=drompa+peak/spikein.100.2017_034B_${str}_Rad21.peak.bed
    compare_bed2tss -g $gene -r -b $bed --gt $gt -m 2 -i > compare/spikein.100.2017_034B_${str}_Rad21.compare.m2.bed &
done

bed=drompa+peak/spikein.100.2018_014A_si11_Rad21.peak.bed
compare_bed2tss -g $gene -r -b $bed --gt $gt -m 2 -i > compare/spikein.100.2018_014A_si11_Rad21.compare.m2.bed

for str in 2017_034B_Ct 2017_034B_si628 2018_014A_015B_si11
do
    bed=drompa+peak/spikein.100.${str}_CTCF.peak.bed
    compare_bed2tss -g $gene -r -b $bed --gt $gt -m 2 -i > compare/spikein.100.${str}_CTCF.compare.m2.bed &
done

bed=drompa+peak/nonspikein.100.2019_004B_SMC3ac_IP.peak.bed
compare_bed2tss -g $gene -r -b $bed --gt $gt -m 2 -i > compare/spikein.100.2019_004B_SMC3ac.compare.m2.bed
