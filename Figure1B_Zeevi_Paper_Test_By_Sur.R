bam_file <- scanBam("/Users/jerrypan/Desktop/GRIPS/Analysis/20190725-bowtie2/GCF_000027085.1_ASM2708v1_genomic.bam", param = ScanBamParam(what=scanBamWhat()))
filtered_file <- data.frame(bam_file[[1]]$rname,bam_file[[1]]$pos)
filtered_bam <- na.omit(filtered_file)
bam_rname <- filtered_bam$bam_file.rname
bam_pos <- filtered_bam$bam_file.pos
dat <- filtered_bam[order(filtered_bam$bam_file..1...rname),]

dat <- dat %>%
  split(.$bam_file..1...rname) %>%
  map_dfr(~arrange(., bam_file..1...pos))

w_size <- 10000
s_size <- 100

Res <-  NULL
for(g in unique(dat$bam_file..1...rname)){
  tic(paste("For loop", g))
  # g <- dat$bam_file..1...rname[1]
  
  temp <- subset(dat, bam_file..1...rname == g)
  max_pos <- max(temp[,2])
  if ((max_pos - w_size + 1) > 0){
    for(i in seq(from = 1, to = max_pos - w_size + 1, by = s_size)){
      tic(paste("For loop", i))
      w_cov <- sum(between(temp[,2], i, i + w_size))
      res <- data.frame(bam_file..1...rname = g, w_start = i, w_end = i + w_size, w_cov = w_cov)
      Res <- rbind(Res, res)
      toc()
    }
  }
  else{
    next
  } 
  
  toc()
}

# 
# for (i in 1:length(max_pos)){
#   tic(paste("For loop",i))
#   index_temp_reads_pos <- which(sorted_bam_file$bam_file..1...rname == sorted_bam_file$bam_file..1...rname[i])
#   temp_reads_pos <- sorted_bam_file$bam_file..1...pos[index_temp_reads_pos]
#   if (max_pos[i]-window_size+1 > 0){
#     temp <- matrix(nrow = max_pos[i]-window_size+1, ncol = 3)
#     temp[,1] <- uni_group[i]
#     temp[,2] <- (1:(max_pos[i]-window_size+1))
#     #for (j in seq(1,(max_pos[i]-window_size+1),sliding_size)){                          # Slide_size
#     for (j in seq(1,(max_pos[i]-window_size+1),sliding_size)){                           # Without Sliding_size
#       temp[j,3] <- sum(between(sorted_bam_file$bam_file..1...pos,j,j+window_size))
#     }
#   }
#   else{
#     next
#   }
#   result <- rbind(result,temp)
#   toc()
# }

Res$midpoint <- (Res$w_start + Res$w_end) / 2
Res

xyplot(w_cov ~ w_start | Res$bam_file..1...rname, data = Res, pch = ".", main = "Genomic Mapping")

