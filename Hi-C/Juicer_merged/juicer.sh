sing="singularity exec --bind /work,/work2,/run /work/SingularityImages/rnakato_juicer.img"
build=hg38
gt=/work/Database/UCSC/$build/genome_table
gene=/work/Database/UCSC/$build/refFlat.txt
motifdir=../motif_for_Juicer_RPE

for sample in Control ESCO1KD Rad21KD NIPBLKD CTCFKD
do
    odir=$sample/mega
    hic=$odir/aligned/inter_30.hic
    norm=VC_SQRT
    for res in 100000 50000 10000 25000
    do
        $sing makeMatrix_intra.sh $norm $odir $hic $res $gt
    done

    $sing juicer_callTAD.sh $norm $hic $odir $gt &
    continue

     for res in 25000 50000 100000
     do
         $sing makeEigen.sh Eigen $norm $odir $hic $res $gt $gene &
     done
     $sing juicer_insulationscore.sh $norm $odir $gt &
done
