cat data/Bin50000.txt | awk 'OFS="\t" {print $1, $2, $3, $2}' > data/Bins.w50000.bedGraph
pigz data/Bins.w50000.bedGraph
