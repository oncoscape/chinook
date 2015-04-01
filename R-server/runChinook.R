library(Chinook)
PORT.RANGE = 5129:5134
scriptDir <- "minimal"
chinook <- Chinook(portRange=PORT.RANGE, scriptDir=scriptDir, runBrowser=TRUE, quiet=FALSE)
run(chinook)

