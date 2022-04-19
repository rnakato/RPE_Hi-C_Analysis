build=hg38
gt=/home/Database/UCSC/$build/genome_table
mpbl=/home/Database/UCSC/$build/mappability_Mosaics_50mer/map_fragL150

for cram in cram/*$build*.cram
  do
      prefix=`basename $cram -bowtie2-$build.sort.cram`
      echo $prefix
      parse2wig+.sh -b 5000 $pens $cram $prefix-bowtie2-hg38 $build &
done
