build=hg38
gt=/work/Database/UCSC/$build/genome_table

binsize=5000
post=-bowtie2-hg38-raw-GR
odir=bedGraph_pval
mkdir -p $odir

dir=parse2wigdir+_spikein
func(){
    chip=$1
    input=$2
    label=$3
    drompa+ GENWIG --outputvalue 2 --outputformat 2 --gt $gt -i $dir/$chip$post.$binsize.bw,$dir/$input$post.$binsize.bw,${label} -o $odir/pval
}

while read LINE
do
    LINE=($LINE)
    chip=${LINE[0]}
    input=${LINE[1]}
    drompa+ GENWIG --outputvalue 2 --outputformat 2 --gt $gt -i $dir/$chip$post.$binsize.bw,parse2wigdir+/$input$post.$binsize.bw,${label} -o $odir/pval
done < samples/samplelist.spikein.txt

exit

while read LINE; do
    LINE=($LINE)
    func ${LINE[0]} ${LINE[1]} ${LINE[2]}_up
    func ${LINE[1]} ${LINE[0]} ${LINE[2]}_down
done < samples/samplelist.spikein.ratio.txt
