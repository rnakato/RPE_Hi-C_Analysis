build=hg38
gt=/work/Database/UCSC/$build/genome_table
#gene=/work/Database/Ensembl/GRCh38/release101/gtf_chrUCSC/Homo_sapiens.GRCh38.101.chr.gene.refFlat
gene=/work/Database/Ensembl/GRCh38/release101/gtf_chrUCSC/Homo_sapiens.GRCh38.101.chr.proteincoding.gene.refFlat
ideogram=/work/git/DROMPAplus/data/ideogram/$build.tsv
GC=/work/Database/UCSC/$build/GCcontents/
GD=/work/Database/UCSC/$build/genedensity/

norm=VC_SQRT

ex(){ echo $1; eval $1; }

### Annotation
HiCdir=/home/rnakato/Dropbox/Cohesin/RPE/Hi-C

for sample in Control_merge CTCFKD_merge Rad21KD_merge NIPBLKD_merge
do
    compartment="$compartment --bed12 $HiCdir/Analysis/05_Eigen/$sample/Compartment.$norm.genome.All.bed12,${sample}"
done

Annobdry="--bed12 ~/Dropbox/Cohesin/RPE/Hi-C/Analysis/10_ChromHMM/state/RPE_15_dense.bed,ChromHMM \
          --bed12 $HiCdir/Analysis/07_Boundary_annotation/output_classify_boundaries_all/annotatedboundaries.genome.bed12,interTAD"

SE="--bed ../ChIP-seq_Bando/rose/NIPBLKD_SuperEnhancers.table.bed,SEBando \
    --bed rose/spikein_SuperEnhancers.table.bed,SE"

HistoneTAD="--bed $HiCdir/TAD/Control_merge/VC_SQRT/25000_blocks.TADregions.bed,TADregion"
for sample in spikein.5000.2021_010_H3K36me3 spikein.5000.2021_023_H3K27me3_ab H3K9me3 Ser2; do
    HistoneTAD="$HistoneTAD --bed $HiCdir/Analysis/06_TAD_annotation/TAD/with$sample.peakcoverageover0.4.tsv,${sample}TAD"
done
for sample in  spikein.5000.2021_010_H3K27ac; do
    HistoneTAD="$HistoneTAD --bed $HiCdir/Analysis/06_TAD_annotation/TAD/with$sample.peakcoverageover0.3.tsv,${sample}TAD"
done

### DEGs
for sample in CTCF Rad21_d3 NIPBL7_d3 Rad21_NIPBL Mau2 WAPL PDS5A PDS5B PDS5AB ESCO1 JQ1
do
    DEG="$DEG --bed /home/rnakato/Dropbox/Cohesin/RPE/Sakata_RNA-seq/DESeq2/top1000/Ct-$sample.up.bed,${sample}up \
              --bed /home/rnakato/Dropbox/Cohesin/RPE/Sakata_RNA-seq/DESeq2/top1000/Ct-$sample.down.bed,${sample}down"
done

### loop, TAD
for sample in Control_merge CTCFKD_merge Rad21KD_merge NIPBLKD_merge Mau2KD ESCO1KD_merge NIPBL_Rad21_KD WAPLKD PDS5AKD_72h PDS5BKD JQ1_plus
do
    loop="$loop --inter $HiCdir/Loop/${sample}/$norm/merged_loops.bedpe,$sample"
    boundary="$boundary --bed $HiCdir/TAD/${sample}/$norm/25000_blocks.boundaries.bed,bdryJuicer.$sample"
    bndyInsu100k="$bndyInsu100k --bed $HiCdir/InsulationScore/${sample}/$norm/Boundary.genome.100k.25000.thre0.7.bed,is100k_${sample}"
    bndyInsu1M="$bndyInsu1M --bed $HiCdir/InsulationScore/${sample}/$norm/Boundary.genome.1M.25000.thre0.7.bed,is1M_${sample}"
done

### DFR
peakdir=Dropbox/drompa_spikein
mkdir -p $peakdir

param="--gt $gt -g $gene --lpp 1 $HistoneTAD $Annobdry $compartment $SE $DEG $loop $TAD $boundary $bndyInsu100k $bndyInsu1M"
for sample in  Rad21KD NIPBLKD NIPBL_Rad21_KD Mau2KD CTCFKD ESCO1KD PDS5ABKD PDS5AKD_72h PDS5BKD WAPLKD JQ1_plus
do
    DFR="$DFR -i ~/Dropbox/Cohesin/RPE/Hi-C/DFR/DFR.$sample.VC_SQRT.genome.25000.bedGraph,,$sample,,,0.7"
done
#ex "drompa+ PC_SHARP $param $DFR --ls 8000 -o $peakdir/DFR.8M --showchr --shownegative"

#### pdf
dir=parse2wigdir+
post=-bowtie2-$build-raw-GR
peakdir=Dropbox/drompa_spikein
mkdir -p $peakdir
binsize=5000
#binsize=100000

IFS="$(echo -e '\t')"
while read LINE
do
    LINE=($LINE)
    chip=${LINE[0]}
    input=${LINE[1]}
    label=${LINE[2]}
    s="$s -i $dir/$chip$post.$binsize.bw,parse2wigdir+/$input$post.$binsize.bw,$label"
done < samples/samplelist.Ctonly.txt

H3K9me3="-i ../GSM4977021_LaminB1_Hetero/parse2wigdir+/RPE_ChIP_H3K9me3_Rep1$post.$binsize.bw,../GSM4977021_LaminB1_Hetero//parse2wigdir+/RPE_ChIP_Input$post.$binsize.bw,H3K9me3"

dirBan="../ChIP-seq_Bando/parse2wigdir+"
Pol2_Bando="-i $dirBan/NIPBLKD_Pol2_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Input_Cont$post.$binsize.bw,Pol2_Cont \
            -i $dirBan/NIPBLKD_Ser2_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Input_Cont$post.$binsize.bw,Ser2_Cont \
            -i $dirBan/NIPBLKD_AFF4_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Input_Cont$post.$binsize.bw,AFF4_Cont \
            -i $dirBan/FBS_Med1_FBS-$post.$binsize.bw,$dirBan/FBS_Input_FBS-$post.$binsize.bw,Med1_Cont \
            -i $dirBan/NIPBLKD_H3K36me3_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Input_Cont$post.$binsize.bw,H3K36me3_Cont"
s="$Pol2_Bando $s $H3K9me3"

param="--gt $gt -g $gene --lpp 1 $HistoneTAD $Annobdry $compartment $SE $DEG $loop $TAD $boundary $bndyInsu100k $bndyInsu1M --scale_tag 200 --ystep 10"
#ex "drompa+ PC_SHARP $s -o $peakdir/Read.Ctonly.$binsize $param --ls 8000 --showchr"
#ex "drompa+ PC_SHARP $s -o $peakdir/Read.Ctonly.newNIPBLgenes.$binsize $param --ls 2000 --genelocifile newNIPBLgenes.txt --len_geneloci 500000" &

## Penrich
param_penrich="--showctag 0 --showpenrich 1 --pthre_enrich 3 --scale_pvalue 3"
#ex "drompa+ PC_SHARP $param_penrich $param $s --ls 8000 -o $peakdir/Penrich.Ctonly.$binsize --showchr" &
#ex "drompa+ PC_SHARP --showctag 0 --showpenrich 1 --pthre_enrich 3 --scale_pvalue 10 $param $s --ls 8000 -o $peakdir/Penrich.Ctonly.high.$binsize --showchr" &
#ex "drompa+ PC_SHARP $param_penrich $param $s --ls 5000 -o $peakdir/Penrich.Ctonly.RUNX1.$binsize -r regionfile/RUNX1.txt"
#ex "drompa+ PC_SHARP $param_penrich $param $s --ls 3000 -o $peakdir/Penrich.Ctonly.PCDH.$binsize -r regionfile/PCDH.txt"
#ex "drompa+ PC_SHARP $param_penrich $param $s --ls 11000 -o $peakdir/Penrich.Ctonly.chr21_24_32.$binsize -r regionfile/chr21_24_32.txt"
#ex "drompa+ PC_SHARP $param_penrich $param $s --ls 2000 -o $peakdir/Penrich.Ctonly.newNIPBLgenes.$binsize --genelocifile newNIPBLgenes.txt --len_geneloci 500000" &

s=""
IFS="$(echo -e '\t')"
while read LINE
do
    LINE=($LINE)
    chip=${LINE[0]}
    input=${LINE[1]}
    label=${LINE[2]}
    s="$s -i $dir/$chip$post.$binsize.bw,parse2wigdir+/$input$post.$binsize.bw,$label"
done < samples/samplelist.readpdf.txt

H3K9me3="-i ../GSM4977021_LaminB1_Hetero/parse2wigdir+/RPE_ChIP_H3K9me3_Rep1$post.$binsize.bw,../GSM4977021_LaminB1_Hetero/parse2wigdir+/RPE_ChIP_Input$post.$binsize.bw,H3K9me3"

dirBan="../ChIP-seq_Bando/parse2wigdir+"
Pol2_Bando="-i $dirBan/NIPBLKD_Pol2_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Input_Cont$post.$binsize.bw,Pol2_Cont \
            -i $dirBan/NIPBLKD_Pol2_7$post.$binsize.bw,$dirBan/NIPBLKD_Input_7$post.$binsize.bw,Pol2_7 \
            -i $dirBan/NIPBLKD_Ser2_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Input_Cont$post.$binsize.bw,Ser2_Cont \
            -i $dirBan/NIPBLKD_Ser2_7$post.$binsize.bw,$dirBan/NIPBLKD_Input_7$post.$binsize.bw,Ser2_7 \
            -i $dirBan/NIPBLKD_AFF4_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Input_Cont$post.$binsize.bw,AFF4_Cont \
            -i $dirBan/NIPBLKD_AFF4_7$post.$binsize.bw,$dirBan/NIPBLKD_Input_7$post.$binsize.bw,AFF4_7 \
            -i $dirBan/FBS_Med1_FBS-$post.$binsize.bw,$dirBan/FBS_Input_FBS-$post.$binsize.bw,Med1_Cont \
            -i $dirBan/NIPBLKD_H3K36me3_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Input_Cont$post.$binsize.bw,H3K36me3_Cont \
            -i $dirBan/NIPBLKD_H3K36me3_7$post.$binsize.bw,$dirBan/NIPBLKD_Input_7$post.$binsize.bw,H3K36me3_7"

s="$Pol2_Bando $s $H3K9me3"

### GV
#ex "drompa+ GV  $s -o $peakdir/GV --gt $gt --ideogram $ideogram --GC $GC --gcsize 500000 --GD $GD --gdsize 500000"

### Read
param="--gt $gt -g $gene --lpp 1 $HistoneTAD $Annobdry $compartment $SE $DEG $loop $TAD $boundary $bndyInsu100k $bndyInsu1M --scale_tag 200 --ystep 10"
#ex "drompa+ PC_SHARP $s -o $peakdir/Read.$binsize $param --ls 8000 --showchr" &
#ex "drompa+ PC_SHARP $s -o $peakdir/Read.$binsize.MAP3K7CL $param --ls 2000 -r MAP3K7CL.txt"

## Penrich
param_penrich="--showctag 0 --showpenrich 1 --pthre_enrich 3 --scale_pvalue 3"
ex "drompa+ PC_SHARP $param_penrich $param $s --ls 8000 -o $peakdir/Penrich.$binsize --showchr >& log/drompa+_spikein.Penrich" &
ex "drompa+ PC_SHARP $param_penrich $param $s --ls 5000 -o $peakdir/Penrich.RUNX1.$binsize -r regionfile/RUNX1.txt" &
ex "drompa+ PC_SHARP $param_penrich $param $s --ls 3000 -o $peakdir/Penrich.PCDH.$binsize -r regionfile/PCDH.txt" &
ex "drompa+ PC_SHARP $param_penrich $param $s --ls 11000 -o $peakdir/Penrich.chr21_24_32.$binsize -r regionfile/chr21_24_32.txt" &
ex "drompa+ PC_SHARP $param_penrich $param $s --ls 2000 -o $peakdir/Penrich.newNIPBL.$binsize -r /home/rnakato/Dropbox/Cohesin/RPE/Hi-C/Analysis/07_Boundary_annotation/output_new_boundaries_NIPBL/Newboundaries.merged.extend500k.bed --bed /home/rnakato/Dropbox/Cohesin/RPE/Hi-C/Analysis/07_Boundary_annotation/output_new_boundaries_NIPBL/Newboundaries.merged.bed,newNIPBL" &


#### UPDOWN
binsize=5000
#binsize=100000
dir=parse2wigdir+_spikein

sratio=""
sratioread=""
while read LINE; do
    LINE=($LINE)
    chip=${LINE[0]}
    input=${LINE[1]}
    label=${LINE[2]}
    sratio="$sratio -i $dir/${LINE[1]}$post.$binsize.bw,$dir/${LINE[0]}$post.$binsize.bw,${label}_down"
    sratioread="$sratioread -i $dir/${LINE[1]}$post.$binsize.bw,,${LINE[1]} -i $dir/${LINE[0]}$post.$binsize.bw,,${LINE[0]}"
done < samples/samplelist.spikein.ratio.txt

Pol2_Bando="-i $dirBan/NIPBLKD_Pol2_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Pol2_7$post.$binsize.bw,Pol2_down \
            -i $dirBan/NIPBLKD_Ser2_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Ser2_7$post.$binsize.bw,Ser2_down \
            -i $dirBan/NIPBLKD_AFF4_Cont$post.$binsize.bw,$dirBan/NIPBLKD_AFF4_7$post.$binsize.bw,AFF4_down"

sratio="$Pol2_Bando $sratio"
sratio="$sratio -i parse2wigdir+/2017_034B_si7_input$post.$binsize.bw,parse2wigdir+/2017_034B_Ct_input$post.$binsize.bw,Input_down"
#sratio="$sratio -i $dir/2017_034B_si621_Rad21$post.$binsize.bw,$dir/2017_034B_si7_Rad21$post.$binsize.bw,621_7_Rad21_down \
#                -i $dir/2021_010_H3K27ac_IP_RAD21KD$post.$binsize.bw,$dir/2021_010_H3K27ac_IP_NIPBLKD$post.$binsize.bw,621_7_H3K27ac_down \
#                -i parse2wigdir+/2017_034B_si7_input$post.$binsize.bw,parse2wigdir+/2017_034B_Ct_input$post.$binsize.bw,Input_down"

## Penrich
param_penrich="--showctag 0 --showpenrich 1 --pthre_enrich 3 --scale_pvalue 3"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 8000 -o $peakdir/DOWN.Penrich.8MB.$binsize --showchr"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 5000 -o $peakdir/DOWN.Penrich.RUNX1.$binsize -r regionfile/RUNX1.txt"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 3000 -o $peakdir/DOWN.Penrich.PCDH.$binsize -r regionfile/PCDH.txt"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 11000 -o $peakdir/DOWN.Penrich.chr21_24_32.$binsize -r regionfile/chr21_24_32.txt"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 2000 -o $peakdir/DOWN.Penrich.newNIPBL.$binsize -r /home/rnakato/Dropbox/Cohesin/RPE/Hi-C/Analysis/07_Boundary_annotation/output_new_boundaries_NIPBL/Newboundaries.merged.extend500k.bed --bed /home/rnakato/Dropbox/Cohesin/RPE/Hi-C/Analysis/07_Boundary_annotation/output_new_boundaries_NIPBL/Newboundaries.merged.bed,newNIPBL" &
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 2000 -o $peakdir/DOWN.Penrich.newNIPBLgenes.$binsize --genelocifile newNIPBLgenes.txt --len_geneloci 500000"

sratio=""
sratioread=""
while read LINE; do
    LINE=($LINE)
    chip=${LINE[0]}
    input=${LINE[1]}
    label=${LINE[2]}
    sratio="$sratio -i $dir/${LINE[0]}$post.$binsize.bw,$dir/${LINE[1]}$post.$binsize.bw,${label}_up \
                   -i $dir/${LINE[1]}$post.$binsize.bw,$dir/${LINE[0]}$post.$binsize.bw,${label}_down"
   sratioread="$sratioread -i $dir/${LINE[1]}$post.$binsize.bw,,${LINE[1]} -i $dir/${LINE[0]}$post.$binsize.bw,,${LINE[0]}"
done < samples/samplelist.spikein.ratio.txt

Pol2_Bando="-i $dirBan/NIPBLKD_Pol2_7$post.$binsize.bw,$dirBan/NIPBLKD_Pol2_Cont$post.$binsize.bw,Pol2_up \
            -i $dirBan/NIPBLKD_Pol2_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Pol2_7$post.$binsize.bw,Pol2_down \
            -i $dirBan/NIPBLKD_Ser2_7$post.$binsize.bw,$dirBan/NIPBLKD_Ser2_Cont$post.$binsize.bw,Ser2_up \
            -i $dirBan/NIPBLKD_Ser2_Cont$post.$binsize.bw,$dirBan/NIPBLKD_Ser2_7$post.$binsize.bw,Ser2_down \
            -i $dirBan/NIPBLKD_AFF4_7$post.$binsize.bw,$dirBan/NIPBLKD_AFF4_Cont$post.$binsize.bw,AFF4_up \
            -i $dirBan/NIPBLKD_AFF4_Cont$post.$binsize.bw,$dirBan/NIPBLKD_AFF4_7$post.$binsize.bw,AFF4_down"

sratio="$Pol2_Bando $sratio"
#sratio="$sratio -i $dir/2017_034B_si7_Rad21$post.$binsize.bw,$dir/2017_034B_si621_Rad21$post.$binsize.bw,621_7_Rad21_up \
#                -i $dir/2017_034B_si621_Rad21$post.$binsize.bw,$dir/2017_034B_si7_Rad21$post.$binsize.bw,621_7_Rad21_down \
#                -i $dir/2021_010_H3K27ac_IP_NIPBLKD$post.$binsize.bw,$dir/2021_010_H3K27ac_IP_RAD21KD$post.$binsize.bw,621_7_H3K27ac_up \
#                -i $dir/2021_010_H3K27ac_IP_RAD21KD$post.$binsize.bw,$dir/2021_010_H3K27ac_IP_NIPBLKD$post.$binsize.bw,621_7_H3K27ac_down \
sratio="$sratio -i parse2wigdir+/2017_034B_Ct_input$post.$binsize.bw,parse2wigdir+/2017_034B_si7_input$post.$binsize.bw,Input_up \
                -i parse2wigdir+/2017_034B_si7_input$post.$binsize.bw,parse2wigdir+/2017_034B_Ct_input$post.$binsize.bw,Input_down"

## GV
#ex "drompa+ GV $sratio -o $peakdir/UPDOWN.GV --gt $gt --ideogram $ideogram --GC $GC --gcsize 500000 --GD $GD --gdsize 500000"

## Penrich
param_penrich="--showctag 0 --showpenrich 1 --pthre_enrich 3 --scale_pvalue 3"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 8000 -o $peakdir/UPDOWN.Penrich.8MB.$binsize --showchr >& log/drompa+_spikein"  &
ex "drompa+ PC_SHARP --showctag 0 --showpenrich 1 --pthre_enrich 3 --scale_pvalue 10 $sratio $param --ls 8000 -o $peakdir/UPDOWN.Penrich.high.8MB.$binsize --showchr"  &
ex "drompa+ PC_SHARP --showctag 0 --showpenrich 1 --pthre_enrich 3 --scale_pvalue 10 $sratio $param --ls 20000 -o $peakdir/UPDOWN.Penrich.high.20MB.$binsize --showchr"  &
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 5000 -o $peakdir/UPDOWN.Penrich.RUNX1.$binsize -r regionfile/RUNX1.txt"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 3000 -o $peakdir/UPDOWN.Penrich.PCDH.$binsize -r regionfile/PCDH.txt"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 11000 -o $peakdir/UPDOWN.Penrich.chr21_24_32.$binsize -r regionfile/chr21_24_32.txt"
ex "drompa+ PC_SHARP $param_penrich $sratio $param --ls 2000 -o $peakdir/UPDOWN.Penrich.newNIPBLgenes.$binsize --genelocifile newNIPBLgenes.txt --len_geneloci 500000"

for sample in Pol2 Ser2 AFF4
do
Pol2_Bando_read="$Pol2_Bando_read \
            -i $dirBan/NIPBLKD_${sample}_Cont$post.$binsize.bw,,${sample}_Cont \
            -i $dirBan/NIPBLKD_${sample}_7$post.$binsize.bw,,${sample}_7"

done
sratioread="$Pol2_Bando_read $sratioread"
sratioread="$sratioread -i parse2wigdir+/2017_034B_Ct_input$post.$binsize.bw,,2017_034B_Ct_input \
                        -i parse2wigdir+/2017_034B_si7_input$post.$binsize.bw,,2017_034B_Ct_si7"

## Read
#ex "drompa+ PC_SHARP $sratioread $param --ls  8000 -o $peakdir/UPDOWN.read.8MB.$binsize --showchr" &
#ex "drompa+ PC_SHARP $sratioread $param --ls 20000 -o $peakdir/UPDOWN.read.20MB.$binsize --showchr" &
