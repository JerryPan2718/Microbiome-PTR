#!/usr/bin/env Rscript
# install.packages("argparser")
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
  p <- add_argument(p, "--sliding_size",
                    help = paste("This is the sliding_size"),
                    type = "Integer",
                    default = 100)
  
  # Optional arguments
  p <- add_argument(p, "--output",
                    help = paste("This is the output"),
                    type = "character",
                    default = "Coverage_Graph.jpg", "PTR.txt")
  
  
  # Read arguments
  cat("Processing arguments...\n")
  args <- parse_args(p)
  
  # Process arguments
  return(args)
}

bam_into_PTR_and_graph <- function(root_path, w_size = 10000, s_size = 100, output = "/Users/jerrypan/Desktop/Coverage_Graph.jpg"){
  bam_file <- scanBam(root_path, param = ScanBamParam(what=scanBamWhat()))
  filtered_file <- data.frame(bam_file[[1]]$rname,bam_file[[1]]$pos)
  filtered_bam <- na.omit(filtered_file)
  # bam_rname <- filtered_bam$bam_file.rname
  # bam_pos <- filtered_bam$bam_file.pos
  sorted_bam_file <- filtered_bam[order(filtered_bam$bam_file..1...rname),]
  
  # Set variables
  window_size <- w_size
  sliding_size <- s_size
  
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
      for (j in seq(1,(max_pos[i] - window_size + 1),sliding_size)){                           
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
  x_peak <- extrema[which(as.vector(extrema[,2]) == Peak),1]
  x_trough <- extrema[which(as.vector(extrema[,2]) == Trough),1]
  
  
  
  # Output
  write.table(PTR, file = "/Users/jerrypan/Desktop/PTR.txt")
  jpeg(file = "/Users/jerrypan/Desktop/Coverage_Graph.jpg")
  plot(y ~ x, pch = ".")
  lines(l$fitted ~ x, col = "red")
  abline(h = Peak, v = x_peak, col="blue")
  abline(h = Trough, v = x_trough, col="blue")
  dev.off()
}


# ## Test the function
# tictoc::tic("function")
# bam_into_PTR_and_graph("/Users/jerrypan/Desktop/GRIPS/Analysis/20190725-bowtie2/GCF_000027085.1_ASM2708v1_genomic.bam", 10000, 100)
# tictoc::toc()


args <- process_arguments()

bam_into_PTR_and_graph(args$input, args$window_size, args$sliding_size, args$output)
