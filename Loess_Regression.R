# loess_regression
# Input: n * 2 matrix 
# matrix[,1]: independent variable
# matrix[,2]: dependent variable



#######################################################################################################################
# x <- c(1,3,3,3,5,7,7,9,11,13,15,17,17,19,21,23,25,27,29)
# y <- c(1,4,5,7,6,8,10,13,14,17,19,22,25,26,29,39,38,35,31)
# data <- data.frame(x, y)
# plot(y ~ x)
# l <- loess(formula = y ~ x, data = data, span = 2 / 3)
# l
# str(l)
# lines(l$fitted ~ x, col = "red")
# #lines(loess(formula = y ~ x, data = data, span = 2 / 3), col = "red")
# deri <- diff(l$fitted) / (diff(x) + 0.000001)
# deri
#######################################################################################################################
# Test using "result"
test <- data.frame(result[,2:3])
fitness_span <- 0.1
x <- test[,1]
y <- test[,2]
plot(y ~ x, pch = ".")
l <- loess(formula = y ~ x, data = test, span = fitness_span)
lines(l$fitted ~ x, col = "red")
deri <- diff(l$fitted) / diff(x)
deri

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
PTR

# Highlight the peak and trough
x_peak <- extrema[which(as.vector(extrema[,2]) == Peak),1]
x_trough <- extrema[which(as.vector(extrema[,2]) == Trough),1]
abline(v = x_peak, h = Peak, col="blue")
abline(v = x_trough, h = Trough, col="blue")
