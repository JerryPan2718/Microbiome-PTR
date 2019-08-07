# import packages
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()
BiocManager::install(c("seqinr","Rsamtools"))
install.packages("random")
install.packages("reshape2")
install.packages("tidyverse")
install.packages("dplyr")
install.packages("qqman")
install.packages("lattice")
install.packages("tictoc")
install.packages("mgcv")
library("seqinr", "Rsamtools")
library("random")
library("tidyverse")
library("dplyr")
library("reshape2")
library("qqman")
library("lattice")
library("ggplot2")
library("tictoc")
library("mgcv")

#######################################################################################################################
# read and reshape the bam file
bam_file <- scanBam("/Users/jerrypan/Desktop/GRIPS/Analysis/20190725-bowtie2/GCF_000027085.1_ASM2708v1_genomic.bam", param = ScanBamParam(what=scanBamWhat()))
filtered_file <- data.frame(bam_file[[1]]$rname,bam_file[[1]]$pos)
filtered_bam <- na.omit(filtered_file)
bam_rname <- filtered_bam$bam_file.rname
bam_pos <- filtered_bam$bam_file.pos
sorted_bam_file <- filtered_bam[order(filtered_bam$bam_file..1...rname),]
uni_rname <- unique(sorted_bam_file$bam_file..1...rname)
#######################################################################################################################


#######################################################################################################################
# # organize data for "Result" and for Manhattan Plot
# window_size <- 10000
# sliding_size <- 100
# # SNP: rs1 ... rs(n)
# SNP_result <- matrix(nrow = length(bam_rname), ncol = 1)
# SNP_result <- sprintf("rs%d",seq(1:length(bam_rname)))
# # CHR: the cardinal number of rname
# CHR_result <- matrix(nrow = length(bam_rname), ncol = 1)
# for (i in length(uni_rname)) {
#   repla_rname <- which(sorted_bam_file$bam_file.rname == uni_rname[i])
#   for (j in repla_rname){
#     CHR_result[j] <- i
#   }
# }
# # BP: directly use rname
# BP_result <- sorted_bam_file$bam_file.rname
# # P: coverage
#######################################################################################################################


#######################################################################################################################
# bam_start_pos
# count <- as.data.frame(table(bam_start_pos))
# start_pos <- as.numeric(as.character(count$bam_start_pos))
# freq <- count$Freq
# plot(start_pos, freq, main = "Genome Mapping" , xlab = "Genomic Location (Mbp)", ylab = "Coverage (# reads) ", pch = ".")
#######################################################################################################################


#########################################################################################################################
# # plot genome mapping
# max_pos <- max(filtered_start_pos)
# window_size <- 10000
# sliding_size <- 100
# sliding_time <- max_pos - window_size + 1
# reads_in_a_row <- matrix(nrow = step_size + 1, ncol = 2)
# for (i in seq(1,step_size,100)){
#   reads <- sum(between(filtered_start_pos, i, i + window_size))
#   reads_in_a_row[i,1] <- i
#   reads_in_a_row[i,2] <- reads
# }
# plot(reads_in_a_row[,1], reads_in_a_row[,2], main = "Genome Mapping GCF_000027085.1_ASM2708v1", 
#      xlab = "Genomic Location (Mbp)", ylab = "Coverage (# reads) ", pch = ".")
#######################################################################################################################


#######################################################################################################################
# Plot discrete genome mapping using "ggplot2"
sorted_bam_file
window_size <- 10000
sliding_size <- 100

# group with unique variables
group <- sorted_bam_file$bam_file..1...rname
uni_group <- unique(group)

# position in terms of "max_pos" in "sorted_bam_file"
max_pos <- matrix(nrow = length(uni_group), ncol = 1)

for (i in 1:length(uni_group)){
  match_rname = which(sorted_bam_file$bam_file..1...rname == uni_group[i])
  max_pos[i] = max(sorted_bam_file$bam_file..1...pos[match_rname])
}
column_num <- sum(max_pos)
# result = matrix(nrow = sum(max_pos), ncol = 3)
# result is the final format of the matrix for xyplot
result = matrix(nrow = 0, ncol = 3)
# tic("total time")
for (i in 1:length(max_pos)){
  # tic(paste("For loop",i))
  index_temp_reads_pos <- which(sorted_bam_file$bam_file..1...rname == sorted_bam_file$bam_file..1...rname[i])
  temp_reads_pos <- sorted_bam_file$bam_file..1...pos[index_temp_reads_pos]
  if (max_pos[i] - window_size + 1 > 0){
    temp <- matrix(nrow = max_pos[i] - window_size + 1, ncol = 3)
    temp[,1] <- uni_group[i]
    temp[,2] <- (1:(max_pos[i] - window_size + 1))
    for (j in seq(1,(max_pos[i] - window_size + 1),sliding_size)){                           # Without Sliding_size
      temp[j,3] <- sum(between(sorted_bam_file$bam_file..1...pos,j,j + window_size))
    }
  }
  else{
    next
  }
  result <- rbind(result,temp)
  # toc()
}
# toc()
result <- na.omit(result)
result
#######################################################################################################################


#######################################################################################################################
# dat <- data.frame(group = rep(letters[1:5], each = 50),
#                   pos = rep(1:50, times = 5),
#                   value = rnorm(250))
# head(dat)
# xyplot(value ~ pos | group, data = dat)
# 
# p1 <- ggplot(dat , aes(x = pos, y = value)) +
#   facet_grid(~ group) +
#   geom_point()
# p1
#######################################################################################################################


#######################################################################################################################
result.df <- as.data.frame(result)
colnames(result.df)[1] <- "RNAME"
colnames(result.df)[2] <- "Position"
colnames(result.df)[3] <- "Reads"
RNAME <- uni_rname[result.df$RNAME]
Position <- result.df$Position
Reads <- result.df$Reads

xyplot(Reads ~ Position | RNAME, data = result.df, pch = ".", main = "Genomic Mapping for GCF_000027085.1_ASM2708v1")

# p1 <- ggplot(result.df, aes(x = Position, y = Reads), pch = ".") +
#   facet_grid(~ RNAME, space = "free_x", scales = "free_x") + 
#   ggtitle("Genomic Mapping for GCF_000027085.1_ASM2708v1") +
#   geom_point(shape = 19, color = "blue", size = 0.01)
# ggsave("~/Desktop/test.png", p1, width = 12, height = 3)
#######################################################################################################################


#######################################################################################################################

