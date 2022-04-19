# Juicer
dir=JuicerResults_20210517

echo -en "Sample\t" > stats.txt
parseJuicerstats.pl -h $dir/Control_1/aligned/inter.txt >> stats.txt

for cell in `cut -f1 samplelist.txt`
do
    echo $cell
    echo -en "$cell\t" >> stats.txt
    echo -en "`parseJuicerstats.pl $dir/$cell/aligned/inter.txt`\t" >> stats.txt
    echo -en "`grep -w $cell Dropbox/QCscores/qc.genomewide.txt | cut -f2`\t" >> stats.txt
    echo -en "`wc -l $dir/$cell/TAD/VC_SQRT/25000_blocks.bed | cut -d" " -f1`\t" >> stats.txt
    wc -l $dir/$cell/loops/VC_SQRT/merged_loops.simple.bedpe | cut -d" " -f1 >> stats.txt
done



exit
# 4DN

echo -en "Sample\t" > stats.txt
parse4DN.pl -h Results4dn/CTCFKD_1/CTCFKD_1_report/CTCFKD_1.summary.out >> stats.txt

for dir in `ls -d Results4dn/*`
do
    cell=`basename $dir`
    echo -en "$cell\t" >> stats.txt
    parse4DN.pl $dir/${cell}_report/$cell.summary.out >> stats.txt
done
