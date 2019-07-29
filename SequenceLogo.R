#install if necessary
source("http://bioconductor.org/biocLite.R")
biocLite("seqLogo")

library(seqLogo)
#using the frequencies above, create four vectors
a <- c(1,6,9,4,13,16,16,14,15,9)
c <- c(5,8,3,3,1,0,0,0,1,2)
g <- c(8,2,4,1,0,0,0,2,0,2)
t <- c(2,0,0,8,2,0,0,0,0,3)

#create data frame using the four vectors
df <- data.frame(a,c,g,t)
#df
#a c g t
#1   1 5 8 2
#2   6 8 2 0
# 3   9 3 4 0
# 4   4 3 1 8
# 5  13 1 0 2
# 6  16 0 0 0
# 7  16 0 0 0
# 8  14 0 2 0
# 9  15 1 0 0
# 10  9 2 2 3

#define function that divides the frequency by the row sum i.e. proportions
proportion <- function(x){
  rs <- sum(x);
  return(x / rs);
}

#create position weight matrix
pwm <- apply(df, 1, proportion)
pwm <- makePWM(pwm)
postscript("hunchback.eps")
seqLogo(pwm)
dev.off()
