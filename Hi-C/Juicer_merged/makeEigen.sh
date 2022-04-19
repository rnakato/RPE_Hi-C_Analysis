#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <command> <norm> <matrixdir> <hic file> <binsize> <genometable> <refFlat>" 1>&2
}

if [ $# -ne 7 ]; then
  usage
  exit 1
fi

command=$1
norm=$2
matrixdir=$3
hic=$4
binsize=$5
gt=$6
gene=$7

pwd=$(cd $(dirname $0) && pwd)
juicertool="juicertools.sh"
chrlist=$(getchr_from_genometable.sh $gt)

dir=$matrixdir/Eigen/$binsize
mkdir -p $dir

ex(){ echo $1; eval $1; }

getPearson(){
    $juicertool pearsons -p $norm $hic chr$chr BP $binsize $dir/pearson.$norm.chr$chr.matrix
    if test -s $dir/pearson.$norm.chr$chr.matrix; then
	    gzip -f $dir/pearson.$norm.chr$chr.matrix
    fi
}

getEigen(){
    $juicertool eigenvector -p $norm $hic chr$chr BP $binsize $dir/eigen.$norm.chr$chr.txt
    fixEigendir.py $dir/eigen.$norm.chr$chr.txt \
			            $dir/eigen.$norm.chr$chr.txt.temp \
			            $gene \
			            chr$chr \
			            $binsize
    mv $dir/eigen.$norm.chr$chr.txt.temp $dir/eigen.$norm.chr$chr.txt
    gzip -f $dir/eigen.$norm.chr$chr.txt
}

toBed12(){
    prefix=$1
    cat $prefix.StrongA.bed | awk -v 'OFS=\t' '{print $1, $2, $3, "StrongA\t0\t+", $2, $3, "255,0,50"}' > $prefix.StrongA.bed12
    cat $prefix.WeakA.bed   | awk -v 'OFS=\t' '{print $1, $2, $3, "WeakA\t0\t+", $2, $3, "255,255,50"}' > $prefix.WeakA.bed12
    cat $prefix.WeakB.bed   | awk -v 'OFS=\t' '{print $1, $2, $3, "WeakB\t0\t+", $2, $3, "50,150,50"}' > $prefix.WeakB.bed12
    cat $prefix.StrongB.bed | awk -v 'OFS=\t' '{print $1, $2, $3, "StrongB\t0\t+", $2, $3, "50,50,255"}' > $prefix.StrongB.bed12

    cat $prefix.StrongA.bed12 \
        $prefix.WeakA.bed12 \
        | sort -k1,1 -k2,2n \
        > $prefix.A.bed12
    cat $prefix.WeakB.bed12 \
        $prefix.StrongB.bed12 \
        | sort -k1,1 -k2,2n \
        > $prefix.B.bed12
    cat $prefix.StrongA.bed12 \
        $prefix.WeakA.bed12 \
        $prefix.WeakB.bed12 \
        $prefix.StrongB.bed12 \
        | sort -k1,1 -k2,2n \
        > $prefix.All.bed12
}

for str in A B All StrongA WeakA WeakB StrongB
do
    cat $dir/Compartment.$norm.chr*.$str.bed   > $dir/Compartment.$norm.genome.$str.bed
    cat $dir/Compartment.$norm.chr*.$str.bed12 > $dir/Compartment.$norm.genome.$str.bed12
done
