sing="singularity exec --bind /work,/work2 /work/SingularityImages/rnakato_juicer.img"

resolution=50000
norm=VC_SQRT
for cell in ../JuicerResults_20210517/*
do
    cell=`basename $cell`
    echo $cell
    for chr in 21 22
    do
        $sing juicertools.sh dump observed $norm ../JuicerResults_20210517/$cell/aligned/inter_30.hic $chr $chr BP $resolution data/$cell.$chr.txt
        cat data/$cell.$chr.txt | awk -v chr=$chr 'OFS="\t" {printf("%s\t%d\t%s\t%d\t%d\n", chr, $1, chr, $2, $3)}' | grep -v NaN > data/$cell.$chr.temp
        mv data/$cell.$chr.temp data/$cell.$chr.txt
    done
    cat data/$cell.21.txt data/$cell.22.txt > data/$cell.res$resolution
    pigz data/$cell.res$resolution
    rm data/$cell.21.txt data/$cell.22.txt
done
