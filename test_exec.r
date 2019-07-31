#!/usr/bin/env Rscript
library(argparser)

process_arguments <- function(){
  p <- arg_parser(paste("Test"))
  
  # Positional arguments
  p <- add_argument(p, "input",
                    help = paste("This is the input"),
                    type = "integer")
  
  # Optional arguments
  p <- add_argument(p, "--output",
                     help = paste("This is the output"),
                     type = "character",
                     default = "output.png")
                     
  # Read arguments
  cat("Processing arguments...\n")
  args <- parse_args(p)
  
  # Process arguments
  
  return(args)
}


args <- process_arguments()

cat("Printing plot\n")
png(args$output)
plot(1:args$input,1:args$input)
dev.off()