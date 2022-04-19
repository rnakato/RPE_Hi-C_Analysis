build=hg38
gt=/work/Database/UCSC/$build/genome_table

norm=VC_SQRT

ex(){ echo $1; eval $1; }


post=-bowtie2-$build-raw-GR

peakdir=Dropbox/drompa+peak
mkdir -p $peakdir

for binsize in 100 5000
do
    IFS="$(echo -e '\t')"
    s=""
    dir=parse2wigdir+
    while read LINE
    do
        LINE=($LINE)
        chip=${LINE[0]}
        input=${LINE[1]}
        s="$s -i $dir/$chip$post.$binsize.bw,parse2wigdir+/$input$post.$binsize.bw,$chip"
    done < samples/samplelist.nonspikein.txt

#    ex "drompa+ PC_SHARP --gt $gt $s -o $peakdir/nonspikein.$binsize $param --ls 8000 --callpeak --showchr --showpenrich 1 --showpinter 1 --scale_pvalue 3 >& log/peakcall_nonspikein.$binsize" &

    s=""
    dir=parse2wigdir+_spikein
    while read LINE; do
        LINE=($LINE)
        chip=${LINE[0]}
        input=${LINE[1]}
        s="$s -i $dir/$chip$post.$binsize.bw,parse2wigdir+/$input$post.$binsize.bw,$chip"
    done < samples/samplelist.spikein.txt
    ex "drompa+ PC_SHARP --gt $gt $s -o $peakdir/spikein.$binsize $param --ls 8000 --callpeak --showchr --showpenrich 1 --showpinter 1 --scale_pvalue 3 >& log/peakcall_spikein.$binsize" &
done
