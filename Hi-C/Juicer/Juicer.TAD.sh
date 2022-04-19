#!/bin/bash

build=hg38
fastq_post="_R"  # "_" or "_R"  before .fastq.gz
enzyme=MboI

gt=/work/Database/UCSC/$build/genome_table
gene=/work/Database/UCSC/$build/refFlat.txt
sing="singularity exec --bind /work,/work2,/work3 /work/SingularityImages/rnakato_juicer.img"

for cell in `ls fastq/* -d | grep -v .sh`
do
    cell=$(basename $cell)
    odir=$(pwd)/JuicerResults_20210517/$cell
    echo $cell

    hic=$odir/aligned/inter_30.hic
    norm=VC_SQRT
    $sing juicer_callTAD.sh $norm $hic $odir $gt
done
