#!/bin/bash

build=hg38
fastq_post="_R"  # "_" or "_R"  before .fastq.gz
enzyme=MboI

gt=/work/Database/UCSC/$build/genome_table
gene=/work/Database/UCSC/$build/refFlat.txt
sing="singularity exec --nv --bind /work,/work2 /work/SingularityImages/rnakato_juicer.img"
motifdir=motif_for_Juicer_RPE

for cell in `ls fastq/* -d | grep -v .sh`
do
    cell=$(basename $cell)
    odir=$(pwd)/JuicerResults_20210517/$cell
    echo $cell

    hic=$odir/aligned/inter_30.hic
    for norm in VC_SQRT
    do
        $sing call_HiCCUPS.sh $norm $odir $hic $build
        $sing juicertools.sh motifs $build $motifdir $odir/loops/$norm/merged_loops.bedpe $motifdir/hg38.motifs.txt
        $sing call_motif.sh $norm $odir $build motif_for_Juicer_RPE/
    done
done
