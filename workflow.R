data <- c(1, 2, 3, 4)
result <- sum(data)
cat("Done: ", result, "\n")

more_data <- read.csv2("/data/stuff.csv")
cat("More: ", sum(more_data$values), "\n")
