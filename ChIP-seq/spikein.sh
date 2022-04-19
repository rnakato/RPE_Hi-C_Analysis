gt=/work/Database/UCSC/hg38/genome_table

func(){
    prefix=$1
    input=$2
    binsize=$3
    numH=`parsebowtielog2.pl log/bowtie2-$prefix-bowtie2-hg38 | cut -f8 | tail -n1`
    numM=`parsebowtielog2.pl log/bowtie2-$prefix-bowtie2-mm10 | cut -f8 | tail -n1`
    numHInput=`parsebowtielog2.pl log/bowtie2-$input-bowtie2-hg38 | cut -f8 | tail -n1`
    numMInput=`parsebowtielog2.pl log/bowtie2-$input-bowtie2-mm10 | cut -f8 | tail -n1`

    rInput=`echo $numMInput $numHInput | awk '{printf ("%f",$1/$2)}'`
    rIP=`echo $numH $numM | awk '{printf ("%f",$1/$2)}'`
    nNormed=`echo 20000000 $rInput $rIP | awk '{printf ("%d",$1*$2*$3)}'`
    echo -e "$prefix\t$numH\t$numM\t$rInput\t$rIP\t$nNormed"

    parse2wig+ --odir parse2wigdir+_spikein --gt $gt \
               -i cram/$prefix-bowtie2-hg38.sort.cram \
               -o $prefix-bowtie2-hg38-raw-GR \
               -n GR --nrpm $nNormed \
               --binsize $binsize -p 4 \
               > log/parse2wig+_spikein_$prefix
}

showscalingfactor(){
    prefix=$1
    input=$2
    numH=`parsebowtielog2.pl log/bowtie2-$prefix-bowtie2-hg38 | cut -f8 | tail -n1`
    numM=`parsebowtielog2.pl log/bowtie2-$prefix-bowtie2-mm10 | cut -f8 | tail -n1`
    numHInput=`parsebowtielog2.pl log/bowtie2-$input-bowtie2-hg38 | cut -f8 | tail -n1`
    numMInput=`parsebowtielog2.pl log/bowtie2-$input-bowtie2-mm10 | cut -f8 | tail -n1`

    rInput=`echo $numMInput $numHInput | awk '{printf ("%f",$1/$2)}'`
    rIP=`echo $numH $numM | awk '{printf ("%f",$1/$2)}'`
    nNormed=`echo $rInput $rIP | awk '{printf ("%f",$1*$2)}'`
    echo -e "$prefix\t$nNormed"
}

IFS="$(echo -e '\t')"
while read LINE
do
    LINE=($LINE)
    chip=${LINE[0]}
    input=${LINE[1]}

    if test "$input" != ""; then
        echo $chip $input
        func $chip $input 100
        func $chip $input 100000
        func $chip $input 5000
       showscalingfactor $chip $input
    fi
done < samples/samplelist.txt
