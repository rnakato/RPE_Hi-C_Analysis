build=hg38
gt=/work/Database/UCSC/$build/genome_table
mpbl=/work/Database/UCSC/$build/mappability_Mosaics_50mer/map_fragL150

for cram in cram/2022_*$build*.cram
  do
      prefix=`basename $cram -bowtie2-$build.sort.cram`
      echo $prefix
#      parse2wig+.sh -b 5000 $pens $cram $prefix-bowtie2-hg38 $build
      parse2wig+ --gt $gt \
                 -i cram/$prefix-bowtie2-hg38.sort.cram \
                 -o $prefix-bowtie2-hg38-raw-GR \
                 -n GR --binsize 5000 -p 4 \
                 > log/parse2wig+_$prefix &
done
