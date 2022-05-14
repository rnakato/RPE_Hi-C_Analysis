# Context-dependent 3D genome regulation by cohesin and related factors

## Authors

Ryuichiro Nakato1,§, Toyonori Sakata2,§, Jiankang Wang1, Luis Augusto Eijy Nagai1,
Gina Miku Oba1, Masashige Bando2 and Katsuhiko Shirahige2

- 1 Laboratory of Computational Genomics, Institute for Quantitative Biosciences, University of Tokyo, 1-1-1 Yayoi, Bunkyo-Ku, Tokyo 113-0032, Japan.
- 2 Laboratory of Genome Structure and Function, Institute for Quantitative Biosciences, University of Tokyo, 1-1-1 Yayoi, Bunkyo-Ku, Tokyo 113-0032, Japan.
- § These authors contributed equally to this work.
- Corresponding authors: Ryuichiro Nakato and Katsuhiko Shirahige

## Summary
Cohesin plays vital roles in chromatin folding and gene expression regulation, cooperating with such factors as cohesin loaders, unloaders, and the insulation factor CTCF. Although models of regulation have been proposed (e.g., loop extrusion), how cohesin and related factors collectively or individually regulate the hierarchical chromatin structure and gene expression remains unclear. We have depleted cohesin and related factors and then conducted a comprehensive evaluation of the resulting 3D genome, transcriptome and epigenome data. We observed substantial variation in depletion effects among factors at topologically associating domain (TAD) boundaries and on interTAD interactions, which were related to epigenomic status. Gene expression changes were highly correlated with direct cohesin binding and gain of TAD boundaries than with the loss of boundaries. Moreover, cohesin was broadly enriched in active compartment A chromosomes, which were retained after CTCF depletion. Our results demonstrate context-specific roles of cohesin for gene expression and chromatin folding.

## Data

The raw sequencing data and processed files of Hi-C, RNA-seq and ChIP-seq data are available at the Gene Expression Omnibus (GEO).

- GSE196450: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE196450

## Hi-C analysis

### Prerequisites

- 3DChromatin_ReplicateQC: https://github.com/kundajelab/3DChromatin_ReplicateQC
- docker_juicer (version >= 1.5.7): https://github.com/rnakato/docker_juicer
- Singularity (version >= 3.6.4): https://sylabs.io/singularity

The paper used the Docker image `docker_juicer` version 1.5.7. To make the singularity image, type:

    singularity build rnakato_juicer.1.5.7.sif docker://rnakato/juicer:1.5.7

### Scripts and data

- 3DChromatin_ReplicateQC/ ... script and data for quality assessment using
- 4dn.cooler.sh ... script for Cooler (using [4dn-hic docker image](https://hub.docker.com/r/duplexa/4dn-hic/))
- Juicer/ ... Scripts for applying Juicer to each sample (see [docker_juicer](https://github.com/rnakato/docker_juicer) for details)
- Juicer_merged/ ... Scripts for applying Juicer to merged samples (see [docker_juicer](https://github.com/rnakato/docker_juicer) for details)
- Notebook/ ... Jupyter notebooks for generating Figures for the manuscript

## Spike-in ChIP-seq analysis

- We used [bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/index.shtml) for mapping reads and converted the output to [the CRAM format](https://www.ga4gh.org/cram/).
- The CRAM files were converted to bigWig files by parse2wig+ (included in DROMPAplus) with spike-in normalization.

### Prerequisites

- DROMPAplus (version >= 1.12.1): https://github.com/rnakato/DROMPAplus
- SAMtools (version >= 1.15): http://www.htslib.org/

### Scripts and data

- spike-in.sh ... calculate scaling factor for spike-in normalization
- scalingfactor.txt ... obtained scaling factors by `spike-in.sh`
- log/bowtie2* ... bowtie2 output (used in `spike-in.sh`)
- log/drompa+\*, log/peakcall\* ... log of DROMPAplus
- count_pval_enrich.sh ... script for Figure S7A
- parse2wig.sh ... script for generagin bigWig files (each sample, input for DROMPAplus)
- makewig.sh, makewig.pval.sh ... scripts for generagin bigWig files (pvalue of ChIP/Input)
- peak.sh ... script for peak calling by DROMPAplus
- samples/ ... ChIP/Input pair list
- pdf.sh ... script for makeing pdf files by DROMPAplus
- regionfile/ ... region file for `pdf.sh`
- peak_SIMA/ ... input peak files for SIMA analysis
- ChromHMM_15_dense.bed ... The output of the extended ChromHMM

## RNA-seq analysis

- We used [STAR](https://github.com/alexdobin/STAR) for read mapping and [RSEM](https://github.com/deweylab/RSEM) to estimate gene expression values.
- We used [DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html) for the differential analysis.

### Prerequisites
- ClusterProfiler (version >= 4.0.5): https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html

### Scripts and data

- GOanalysis/ ... scripts for GO analysis using ClusterProfiler

## Referece

in preparation.
