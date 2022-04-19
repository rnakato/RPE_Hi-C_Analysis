#!/bin/bash
### https://github.com/4dn-dcic/docker-4dn-hic/blob/v43/HiCPipeline.md

ex(){ echo $1; eval $1; }

build=hg38
gt=/work/Database/UCSC/$build/genome_table
bwa_index=/work/Database/bwa-indexes/UCSC-$build
enzyme=MboI
enzymelen=4
max_distance=8.4

restrictionsite=/work/Database/HiC-restriction_sites/${enzyme}_resfrag_$build.bed
sing="singularity exec --bind /work,/work2 /work/SingularityImages/rnakato_4dn.img"
ncore=32

bwa_mapping(){
    cell=$1
    fq1s=""
    fq2s=""
    for id in $(ls fastq/$cell/*_R1.fastq.gz)
    do
        id=${id%%_R1.fastq.gz}
        fq1s="$fq1s ${id}_R1.fastq.gz"
        fq2s="$fq2s ${id}_R2.fastq.gz"
    done

    ex "mkdir -p $odir/aligned/ $odir/log"
    ex "bwa mem -t $ncore -SP5M $bwa_index <(zcat $fq1s) <(zcat $fq2s) | samtools view -Shb - > $odir/aligned/$cell.bam" >& $odir/log/bwa_mapping_$cell
}

pairsam-parse-sort(){
    cell=$1
    BAM=$odir/aligned/$cell.bam
    OUTDIR=$odir/pairsam-parse-sort
    OUTPREFIX=$cell
    SORTED_PAIRS_PATH=${OUTDIR}/${OUTPREFIX}.sam.pairs.gz

    mkdir -p $OUTDIR
    samtools view -h $BAM | {
        # Classify Hi-C molecules as unmapped/single-sided/multimapped/chimeric/etc
        # and output one line per read, containing the following, separated by \\v:
        #  * triu-flipped pairs
        #  * read id
        #  * type of a Hi-C molecule
        #  * corresponding sam entries
        $sing pairtools parse -c $gt --add-columns mapq
    } | {
        # Block-sort pairs together with SAM entries
        $sing pairtools sort --nproc $ncore \
              --tmpdir ${OUTDIR} \
              --output ${SORTED_PAIRS_PATH}
    }
}

pairsam-merge(){
run-pairsam-merge.sh out 'out.sam.pairs.gz out.sam.pairs.gz'
}

pairsam-markdup(){
    cell=$1
    OUTDIR=$odir/pairsam-parse-sort
    OUTPREFIX=$cell
    PAIRSAM=${OUTDIR}/${OUTPREFIX}.sam.pairs.gz
    MARKED_PAIRSAM=$OUTDIR/${OUTPREFIX}.marked.sam.pairs.gz

    $sing pairtools dedup --mark-dups --output-dups - --output-unmapped - --output ${MARKED_PAIRSAM} ${PAIRSAM}
    $sing pairix ${MARKED_PAIRSAM}  # sanity check
}

pairsam-filter(){
    cell=$1
    OUTDIR=$odir/pairsam-parse-sort
    OUTPREFIX=$cell

    PAIRSAM=${OUTDIR}/${OUTPREFIX}.sam.pairs.gz
    UNMAPPED_SAMPAIRS=$OUTDIR/${OUTPREFIX}.unmapped.sam.pairs.gz
    DEDUP_PAIRS=$OUTDIR/${OUTPREFIX}.dedup.pairs.gz
    LOSSLESS_BAM=$OUTDIR/${OUTPREFIX}.lossless.bam
    TEMPFILE=$OUTDIR/temp.gz
    TEMPFILE1=$OUTDIR/temp1.gz

    ## Generate lossless bam
    $sing pairtools split --output-sam ${LOSSLESS_BAM} ${PAIRSAM}

    # Select UU, UR, RU reads
    $sing pairtools select '(pair_type == "UU") or (pair_type == "UR") or (pair_type == "RU")' \
                 --output-rest ${UNMAPPED_SAMPAIRS} \
                 --output ${TEMPFILE} \
                ${PAIRSAM}
    $sing pairtools split --output-pairs ${TEMPFILE1} ${TEMPFILE}
    $sing pairtools select 'True' --chrom-subset $gt -o ${DEDUP_PAIRS} ${TEMPFILE1}
    $sing pairix ${DEDUP_PAIRS}  # sanity check & indexing
    rm ${TEMPFILE} ${TEMPFILE1}
}

pairsqc-single(){
    cell=$1
    OUTDIR=$odir/pairsam-parse-sort
    OUTPREFIX=$cell
    input_pairs=${OUTDIR}/${OUTPREFIX}.marked.sam.pairs.gz
    sample_name=$cell

    scriptdir=/usr/local/bin/pairsqc/
    ex "$sing python3 $scriptdir/pairsqc.py -p $input_pairs -c $gt -tP -s $sample_name -O $odir/$sample_name -M $max_distance"
    ex "$sing Rscript $scriptdir/plot.r $enzymelen $odir/$sample_name\_report"
}

addfrag2pairs(){
    scriptdir=/usr/local/bin
    cell=$1
    OUTDIR=$odir/pairsam-parse-sort
    OUTPREFIX=$cell
    input_pairs=${OUTDIR}/${OUTPREFIX}.marked.sam.pairs.gz
    # use fragment_4dnpairs.pl in pairix/util instead of juicer/CPU/common
    gunzip -c $input_pairs \
        | $sing $scriptdir/pairix/util/fragment_4dnpairs.pl -a - ${OUTDIR}/${OUTPREFIX}.ff.pairs $restrictionsite
    $sing bgzip  -f ${OUTDIR}/${OUTPREFIX}.ff.pairs
    $sing pairix -f ${OUTDIR}/${OUTPREFIX}.ff.pairs.gz
}

run-cooler(){
    cell=$1
    OUTDIR=$odir/coolfile
    OUTPREFIX=$cell
    pairs_file=$odir/pairsam-parse-sort/${OUTPREFIX}.ff.pairs.gz
    out_prefix=${OUTDIR}/${OUTPREFIX}
    max_split=2
    binsizes="5000,10000,25000,50000,100000,500000,1000000,2500000,5000000,10000000"
    binsize_min=5000
    pwd=`pwd`

    mkdir -p $OUTDIR
    ex "$sing cooler cload pairix -p $ncore -s $max_split $gt:$binsize_min $pairs_file $out_prefix.cool " >& $odir/log/run-cooler.$binsize_min
   ### matrix balancing
    ex "$sing cooler balance -p $ncore $out_prefix.cool"
    ex "$sing run-juicebox-pre.sh -i $pairs_file -c $gt -o $odir/$cell -r $binsize_min -u $binsizes"
    ### Generate a multi-resolution cooler file by coarsening
    ex "$sing run-cool2multirescool.sh -i $out_prefix.cool -p $ncore -o $out_prefix -u $binsizes"

    ### Adds a normalization vector from a hic file to an mcool file
    ex "$sing run-add-hicnormvector-to-mcool.sh $pwd/$odir/$cell.hic $pwd/$out_prefix.multires.cool $pwd/$OUTDIR" &


    ### dump matrix files
    for binsize in 5000 25000 50000 100000
    do
        cool=$out_prefix.$binsize.cool
        ex "$sing cooler cload pairix -p $ncore -s $max_split $gt:$binsize $pairs_file $cool" >& $odir/log/cooler-cload.$binsize
        ### matrix balancing
        ex "$sing cooler balance -p $ncore $cool"
        ex "$sing run-cooler-dump.sh $cool $odir $binsize $gt"
    done

    cp $pwd/$out_prefix.multires.cool $out_prefix.hic2cool.cool
    ex "$sing hic2cool extract-norms -e $odir/$cell.hic $out_prefix.hic2cool.cool"
}


for cell in $(ls fastq/* -d | grep -v .sh)
do
    cell=$(basename $cell)
    odir=Results4dn/$cell

    echo $odir
    bwa_mapping $cell

    ### pairtools parse
    ### pairtools sort 
    pairsam-parse-sort $cell

    pairsam-markdup $cell

    ### Filtering (select, split)
    pairsam-filter $cell

    ### QC report generater
    pairsqc-single $cell

    addfrag2pairs $cell
    run-cooler $cell
done
