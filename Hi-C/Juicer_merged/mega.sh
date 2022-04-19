sing="singularity exec --bind /work:/work --bind /work2:/work2 /work/SingularityImages/rnakato_juicer.img"
build=hg38
gt=/work/Database/UCSC/$build/genome_table

for sample in Control ESCO1KD Rad21KD NIPBLKD CTCFKD
do
    cd $sample
    $sing mega.sh -g $gt -s /work/Database/HiC-restriction_sites/MboI_resfrag_$build.bed
    cd ..
done
