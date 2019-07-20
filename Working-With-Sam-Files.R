if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
#BiocManager::install(c("RNAseqData.HNRNPC.bam.chr14","GenomicAlignments","Rsamtools"))
library(RNAseqData.HNRNPC.bam.chr14)
library(GenomicAlignments)
library(Rsamtools)

#README_file <- system.file("scripts", "README.TXT",
#                           package="RNAseqData.HNRNPC.bam.chr14")

bamfile <- RNAseqData.HNRNPC.bam.chr14_BAMFILES[1]
gal <- readGAlignments(bamfile)
gal
head(gal)
?GAlignments


length(gal)
strand(gal)
table(strand(gal))
#browseVignettes("IRanges")

?ScanBamParam
scanBamWhat()
ranges(gal)[1:5]
gr <- GRanges(seqnames = "chr14", ranges = ranges(gal)[1:5])
gr
seq_gal <- readGAlignments(bamfile, ScanBamParam(which = gr, what = c("seq","qual")))
seq_gal

scanBamWhat()
pos_gal <- readGAlignments(bamfile, param = ScanBamParam(which = gr,what = "seq",
                           flag = scanBamFlag(isMinusStrand = FALSE)))
pos_gal
