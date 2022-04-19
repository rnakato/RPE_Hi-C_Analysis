3DChromatin_ReplicateQC run_all \
      --metadata_samples metadata.samples \
     --bins /work2/Hi-C/Sakata_RPE/3DChromatin_ReplicateQC/data/Bins.w50000.bedGraph.gz \
     --metadata_pairs metadata.pairs \
     --outdir output

#3DChromatin_ReplicateQC concordance \
#    --metadata_pairs   metadata.pairs \
#    --outdir output \
#    --methods HiCRep #GenomeDISCO

#3DChromatin_ReplicateQC summary \
#      --metadata_samples metadata.samples \
#      --metadata_pairs metadata.pairs \
#      --bins /work2/Hi-C/Sakata_RPE/3DChromatin_ReplicateQC/data/Bins.w50000.bedGraph.gz \
#      --outdir output #\
 #     --methods GenomeDISCO,HiCRep,HiC-Spector,QuASAR-Rep,QuASAR-QC
