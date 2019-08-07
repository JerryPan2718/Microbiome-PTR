#!/usr/bin/env Rscript
# install.packages("argparser")

tictoc::tic("Total Time")
library("argparser")
library("Rsamtools")
library("random")
library("tidyverse")
library("dplyr")
library("reshape2")
library("qqman")
library("lattice")
library("ggplot2")
library("tictoc")
library("mgcv")

process_arguments <- function(){
  p <- arg_parser(paste("Calculate PTR and the graph of coverage with bam file"))
  
  # Positional arguments
  p <- add_argument(p, "input",
                    help = paste("This is the input"),
                    type = "character")
  
  # Optional arguments
  p <- add_argument(p, "--window_size",
                    help = paste("This is the window_size"),
                    type = "Integer",
                    default = 10000)
  
  # Optional arguments
  p <- add_argument(p, "--step_size",
                    help = paste("This is the step_size"),
                    type = "Integer",
                    default = 100)
  
  # Optional arguments
  p <- add_argument(p, "--output",
                    help = paste("This is the output"),
                    type = "character",
                    default = "Coverage_Graph.jpg")
  p <- add_argument(p,  "--name",
                    help = "name of original file",
                    type = "character")
  
  
  # Read arguments
  cat("Processing arguments...\n")
  args <- parse_args(p)
  
  # Process arguments
  return(args)
}

bam_into_PTR_and_graph <- function(root_path, w_size = 10000,
                                   s_size = 100,
                                   output = "/Users/jerrypan/Desktop/Coverage_Graph.jpg",
                                   name = ""){
  bam_file <- scanBam(root_path, param = ScanBamParam(what=scanBamWhat()))
  filtered_file <- data.frame(bam_file[[1]]$rname,bam_file[[1]]$pos)
  filtered_bam <- na.omit(filtered_file)
  sorted_bam_file <- filtered_bam[order(filtered_bam$bam_file..1...rname),]
  
  # Set variables
  window_size <- w_size
  step_size <- s_size
  
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
  
  # result is the final format of the matrix for xyplot
  result = matrix(nrow = 0, ncol = 3)
  
  for (i in 1:length(max_pos)){
    index_temp_reads_pos <- which(sorted_bam_file$bam_file..1...rname == sorted_bam_file$bam_file..1...rname[i])
    temp_reads_pos <- sorted_bam_file$bam_file..1...pos[index_temp_reads_pos]
    if (max_pos[i] - window_size + 1 > 0){
      temp <- matrix(nrow = max_pos[i] - window_size + 1, ncol = 3)
      temp[,1] <- uni_group[i]
      temp[,2] <- (1:(max_pos[i] - window_size + 1))
      for (j in seq(1,(max_pos[i] - window_size + 1),step_size)){                           
        temp[j,3] <- sum(between(sorted_bam_file$bam_file..1...pos,j,j + window_size))
      }
    }
    else{
      next
    }
    result <- rbind(result,temp)
  }
  result <- na.omit(result)
  
  test <- data.frame(result[,2:3])
  fitness_span <- 0.1
  x <- test[,1]
  y <- test[,2]
  l <- loess(formula = y ~ x, data = test, span = fitness_span)
  deri <- diff(l$fitted) / diff(x)
  
  # Find absolute extrema
  extrema <- matrix(ncol = 3)
  colnames(extrema) <- c("x", "y", "multi_deri")
  for (i in seq(1:length(x)-1)[2:length(x)-2]){
    if (deri[i] * deri[i + 1] < -10 ** -21){
      temp <- matrix(nrow = 1, ncol = 3)
      temp[1,1] <- x[i]
      temp[1,2] <- l$fitted[i]
      temp[1,3] <- deri[i] * deri[i + 1]
      extrema <- rbind(extrema, temp)
    }
  }
  extrema <- na.omit(extrema)
  Peak <- max(as.vector(extrema[,2]))
  Trough <- min(as.vector(extrema[,2]))
  PTR <- Peak / Trough
  
  
  # Highlight the peak and trough
  x_peak <- extrema[which(as.vector(extrema[,2]) == Peak), 1]
  x_trough <- extrema[which(as.vector(extrema[,2]) == Trough), 1]
  
  
  
  # Output
  name = output
  new_name <- sub(pattern = "[.]fastq$", replacement = "", x = basename(name))
  
  # bam_file <- scanBam("/Users/jerrypan/Desktop/test.bam", param = ScanBamParam(what=scanBamWhat()))
  # str(bam_file)
  qname <- bam_file[[1]]$qname[1]
  qname <- sub(pattern = "[.][0-9]+$", replacement = "", x = qname)
  filename <- paste0(output, qname, ".txt")
  write.table(PTR, file = filename)
  # write.table(PTR, file = paste("/Users/jerrypan/Desktop/", basename(root_path),"PTR.txt"))
  tiff(file = paste(output, qname, "_", "Graph.tiff"))
  plot(y ~ x, pch = ".")
  lines(l$fitted[10000:length(l$fitted)-10000] ~ x[10000:length(l$fitted)-10000], col = "red")
  abline(h = Peak, v = x_peak, col = "blue")
  abline(h = Trough, v = x_trough, col = "blue")
  dev.off()
}

args <- process_arguments()
bam_into_PTR_and_graph(args$input, args$window_size, args$step_size, args$output)
toc()

# Test the function with default input
# bam_into_PTR_and_graph("/Users/jerrypan/Desktop/GRIPS/Microbiota_Project/work/a8/eb222ddad29da04eaf8d1219dceb1b/bam", 10000, 100, "/Users/jerrypan/Desktop/Coverage_reads1.jpg")
# bam_into_PTR_and_graph("/Users/jerrypan/Desktop/test.bam", 10000, 100, "/Users/jerrypan/Desktop/Coverage_reads2.jpg")

# root_path = "/home/jerrypan/Data/Data_Citrobacter_Rodentium/"
# output = "/home/jerrypan/Analysis/20190807-overall/"
# name = output
# new_name <- sub(pattern = "[.]fastq$", replacement = "", x = basename(name))
# 
# bam_file <- scanBam("/Users/jerrypan/Desktop/test.bam", param = ScanBamParam(what=scanBamWhat()))
# str(bam_file)
# qname <- bam_file[[1]]$qname[1]
# qname <- sub(pattern = "[.][0-9]+$", replacement = "", x = qname)
# 
# filename <- paste0(output, qname, ".txt")
# write.table(PTR, file = filename)

# bam_into_PTR_and_graph("/Users/jerrypan/Desktop/test.bam", 10000, 100,
#                        "/Users/jerrypan/Desktop/Coverage_reads2.jpg",
#                        "/Users/jerry/Desktop/GRIPS/Data/ERR930224_1.fastq")


