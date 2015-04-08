library(ModelMPG)
PORT = 11002
browserScript <- system.file(package="ModelMPG", "js", "twoTabsSelfContained", "index.html")
modelMPG <- ModelMPG(port=PORT, browserScript, runBrowser=TRUE, quiet=FALSE)
run(modelMPG)

