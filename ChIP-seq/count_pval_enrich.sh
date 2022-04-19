echo -e "sample\tup\tdown"
for sample in H3K4me3 H3K27ac H3K27me3 H3K36me3 H3K9me3
do
    for si in NIPBLKD RAD21KD
    do
        echo -en "${sample}_${si}"
        for str in up down
        do
            n=`cat bedGraph_pval/pval.${sample}_${si}_$str.penrich.5000.bedGraph | awk '{if($4>=4) print}'| wc -l`
            bp=$(($n * 5000))
            echo -en "\t$bp"
        done
        echo ""
    done
done
