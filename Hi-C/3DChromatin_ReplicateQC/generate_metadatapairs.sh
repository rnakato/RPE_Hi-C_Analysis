samples=`ls data/*res50000* | grep -v ESCO2 | grep -v ESCO12 | grep -v SMC| sed -e 's/data\///g' -e 's/.res50000.gz//g'`

for sample1 in $samples
do
for sample2 in $samples
do
    echo -e $sample1"\t"$sample2
done
done
