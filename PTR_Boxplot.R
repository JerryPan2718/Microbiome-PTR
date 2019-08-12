# Import library
library(lattice)
library(ggplot2)
library(dplyr)
library(ggpubr)
library(psych)

# Import data and create data frame for multiple samples
Vcit_A4 <- c(2.171264785,
             2.69135983006078,
             2.47633138882580,
             2.673061107,
             2.38076833,
             3.540950033,
             6.06739003971486,
             8.17424009207489,
             9.01533671183520)

Vcit_B2 <- c(2.31529909497751,
             2.51965728959938,
             2.795724934,
             2.98005921128034,
             3.14631685558302,
             2.359737304,
             2.12974187030272,
             3.586396237,
             NA)

Vcit_B3 <- c(1.96193141114091,
             1.949653336,
             2.34622080927689,
             2.49209763109859,
             2.345002784,
             2.286628922,
             2.405100608,
             4.416242419,
             2.674456232)

Vcit_C1 <- c(1.74359465530860,
             1.62644197582948,
             1.99708237420936,
             1.92850883508316,
             2.010754517,
             1.73957014715524,
             2.115862038,
             2.776065561,
             2.737149887)

Vcit_C4 <- c(1.83262638095996,
             2.155558408,
             2.250922616,
             2.11152846585928,
             1.967144572,
             2.05959959284133,
             3.427870143,
             4.489279366,
             5.130410573)

Vcit_D3 <- c(1.760522189,
             1.84904212909439,
             1.893717701,
             2.20780060631265,
             2.32844577581071,
             2.12172796108776,
             4.710124258,
             2.387765796,
             3.63798204640010)

Vcit_B3C4 <- c(Vcit_B3, Vcit_C4)
Vcit_C1D3 <- c(Vcit_C1, Vcit_D3)
Vcit_A4 <- c(Vcit_A4,rep(NA,9))
Vcit_B2 <- c(Vcit_B2,rep(NA,9))
Vcit_B3 <- c(Vcit_B3,rep(NA,9))
Vcit_C1 <- c(Vcit_C1,rep(NA,9))
Vcit_C4 <- c(Vcit_C4,rep(NA,9))
Vcit_D3 <- c(Vcit_D3,rep(NA,9))


Sample <- c("Vcit_A4", "Vcit_B2", "Vcit_B3", "Vcit_C1",
            "Vcit_C4", "Vcit_D3", "Vcit_B3C4", "Vcit_C1D3")
  
PTR_df <- data.frame(Vcit_A4, Vcit_B2, Vcit_B3, Vcit_C1,
                     Vcit_C4, Vcit_D3, Vcit_B3C4, Vcit_C1D3)
row.names(PTR_df) <- c("1","2","3","4","5","6","7","8","10","1.0","2.0","3.0","4.0","5.0",
                       "6.0","7.0","8.0","10.0")

# Box plot
boxplot(PTR_df$Vcit_A4, PTR_df$Vcit_B2, PTR_df$Vcit_B3, PTR_df$Vcit_C1, 
        PTR_df$Vcit_C4, PTR_df$Vcit_D3, PTR_df$Vcit_B3C4, PTR_df$Vcit_C1D3,
        add.points = TRUE,
        ylab = "PTR",
        main = "Citrobacter Rodentium Metagenomics Samples",
        names = c("A4", "B2", "B3", "C1",
                  "C4", "D3","B3C4","C1D3"))
stripchart(PTR_df, vertical = TRUE, add = TRUE, method = "stack", col = 'red', pch = 1)

for (i in 1:(length(PTR_df)-1)){
  for (j in (i+1):length(PTR_df)){
    print(paste(toString(colnames(PTR_df[i])), "VS", toString(colnames(PTR_df[j]))))
    print(wilcox.test(t(na.omit(PTR_df[i])), t(na.omit(PTR_df[j])), correct = FALSE))
  }
}

