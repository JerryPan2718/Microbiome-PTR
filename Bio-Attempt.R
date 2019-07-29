if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()
BiocManager::install(c("rnaseqWrapper", "seqinr","DESeq","topGO"))
BiocManager::install(c("argparse"))
?BiocManager
oriloc_1 <- seqinr::oriloc(seq.fasta = "/Users/jerrypan/Desktop/GRIPS/Glimmer3.02/bin/Test.txt",
                           g2.coord = "/Users/jerrypan/Desktop/GRIPS/Glimmer3.02/bin/Blank.predict",
                           glimmer.version = 3,
                           oldoriloc = FALSE, gbk = NULL, clean.tmp.files = TRUE, rot = 0)
oriloc_2 <- seqinr::oriloc(seq.fasta = system.file("sequences/ct.fasta.gz", 
                                                   package = "seqinr"),
                           g2.coord = system.file("sequences/ct.predict", package = "seqinr"),
                           glimmer.version = 3,
                           oldoriloc = FALSE, gbk = NULL, clean.tmp.files = TRUE, rot = 0)
seqinr::draw.oriloc(oriloc_1,main = "Nucleotide skews in chromosomes", 
            xlab = "Genomic Location (Mbp)", ylab = "Coverage (# reads)", 
            las = 1, las.right = 3,
            ta.mtext = "Cumul. T-A skew", ta.col = "pink", ta.lwd = 1,
            cg.mtext = "Cumul. C-G skew", cg.col = "lightblue", cg.lwd = 1,
            cds.mtext = "Cumul. CDS skew", cds.col = "lightgreen", cds.lwd = 1,
            sk.col = "black", sk.lwd = 2,
            add.grid = TRUE)

