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

    rm -rf $odir
    mkdir -p $odir
    if test ! -e $odir/fastq; then ln -s $(pwd)/fastq/$cell/ $odir/fastq; fi

   $sing juicer_map.sh $odir $build $enzyme $fastq_post

    if test ! -e $odir/distance; then $sing plot_distance_count.sh $cell $odir; fi

    hic=$odir/aligned/inter_30.hic
    norm=VC_SQRT
    if test ! -e $odir/Matrix; then
        $sing juicer_makematrix.sh $norm $hic $odir $gt
    fi


    if test ! -e $odir/TAD; then
        $sing juicer_callTAD.sh $norm $hic $odir $gt
    fi

    for res in 25000 50000 100000
    do
	    $sing makeEigen.sh Pearson $norm $odir $hic $res $gt $gene &
	    $sing makeEigen.sh Eigen $norm $odir $hic $res $gt $gene
    done
    if test ! -e $odir/InsulationScore; then $sing juicer_insulationscore.sh $norm $odir $gt &
    fi
done
