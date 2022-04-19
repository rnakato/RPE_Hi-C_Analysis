#!/bin/bash

build=hg38
fastq_post="_R"  # "_" or "_R"  before .fastq.gz
enzyme=MboI

gt=/work/Database/UCSC/$build/genome_table
gene=/work/Database/UCSC/$build/refFlat.txt
sing="singularity exec --bind /work,/work2,/work3 /work/SingularityImages/rnakato_juicer.img"

for sample in  Control ESCO1KD Rad21KD NIPBLKD CTCFKD
do
    odir=$sample/mega
    hic=$odir/aligned/inter_30.hic
    norm=VC_SQRT
    for res in 100000 50000 10000 25000
    do
        $sing makeMatrix_intra.sh $norm $odir $hic $res $gt
    done
done
