install.packages("qqman")
library("qqman")
vignette("qqman")

str(gwasResults)
head(gwasResults)
tail(gwasResults)
as.data.frame(table(gwasResults$CHR))
# Basic Manhattan Plot
manhattan(gwasResults)
gwasResults
manhattan(gwasResults, main = "Manhattan Plot", ylim = c(0, 10), cex = 0.6, 
          cex.axis = 0.9, col = c("blue4", "orange3"), suggestiveline = F, genomewideline = F, 
          chrlabs = c(1:20, "P", "Q"))
manhattan(subset(gwasResults, CHR == 1))
str(snpsOfInterest)
manhattan(gwasResults, highlight = snpsOfInterest)

# Combine highlighting and limiting to a single chromosome, 
# And use the xlim graphical parameter to zoom in on a region of interest (between position 200-500)
manhattan(subset(gwasResults, CHR == 3), highlight = snpsOfInterest, xlim = c(200,500), main = "Chr 3")
# Annotate SNPs based on their p-value. 
# By default, this only annotates the top SNP per chromosome that exceeds the annotatePval threshold.
manhattan(gwasResults, annotatePval = 0.01)
manhattan(gwasResults, annotatePval = 0.005, annotateTop = FALSE)
# Add test statistics
gwasResults <- transform(gwasResults, zscore = qnorm(P/2, lower.tail = FALSE))
head(gwasResults)
# Make the new plot
manhattan(gwasResults, p = "zscore", logp = FALSE, ylab = "Z-score", genomewideline = FALSE, 
          suggestiveline = FALSE, main = "Manhattan plot of Z-scores")
