#!/bin/bash

build=hg38
fastq_post="_R"  # "_" or "_R"  before .fastq.gz
enzyme=MboI

gt=/work/Database/UCSC/$build/genome_table
gene=/work/Database/UCSC/$build/refFlat.txt
sing="singularity exec --bind /work,/work2,/work3 /work/SingularityImages/rnakato_juicer.img"

func(){
    cell=$1
    hic=$odir/aligned/inter_30.hic

    echo $cell
    for res in 25000 50000 100000 250000 
    do
        $sing makeEigen.sh Pearson $norm $odir $hic $res $gt $gene
        $sing makeEigen.sh Eigen $norm $odir $hic $res $gt $gene
    done
}

for cell in `ls fastq/* -d | grep -v .sh`
do
    cell=$(basename $cell)
    odir=$(pwd)/JuicerResults_20210517/$cell
    norm=VC_SQRT
    func $cell &
done
