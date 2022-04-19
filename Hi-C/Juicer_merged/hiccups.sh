sing="singularity exec --nv --bind /work,/work2 /work/SingularityImages/rnakato_juicer.img"
build=hg38
gt=/work/Database/UCSC/$build/genome_table
motifdir=../motif_for_Juicer_RPE

for sample in Control CTCFKD NIPBLKD ESCO1KD Rad21KD
do
    odir=$sample/mega
    hic=$odir/aligned/inter_30.hic
    for norm in KR VC_SQRT
    do
        $sing call_HiCCUPS.sh $norm $odir $hic $build
        $sing juicertools.sh motifs $build $motifdir $odir/loops/$norm/merged_loops.bedpe $motifdir//hg38.motifs.txt
    done
done
