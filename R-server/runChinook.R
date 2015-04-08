library(Chinook)
PORT = 11001
browserScript <- system.file(package="Chinook", "js", "minimal", "index.html")
chinook <- Chinook(port=PORT, browserScript, runBrowser=TRUE, quiet=FALSE)
run(chinook)

