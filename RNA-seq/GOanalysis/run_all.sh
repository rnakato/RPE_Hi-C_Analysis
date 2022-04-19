# Instruction for running smoothly the whole analysis with one command.

#   In this script "run_all.sh". modify the lines 6, 7
#   In the script "run_clusterProfiler_compare.R adapt the line 65.
#   If you use the script "run_clusterProfiler_separated.R" remove "#"
# from the beginning of the line
#   Run the comand > bash run_all.sh
#   Done

indir=DESeq2/
outdir=DESeq2/clusterProfiler

# Create all genes list
Rscript run_create_background_gene_list.R --i $indir

# Run clusterProfiler in each gene set
Rscript run_clusterProfiler_separated.R --i $indir --o $outdir

# Run clusterProfiler for all genes together
Rscript run_clusterProfiler_compare.R --i $indir --o $outdir
