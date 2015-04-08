library(ModelMPG)
PORT = 5129
browserScript <- system.file(package="ModelMPG", "js", "twoTabsSelfContained", "index.html")
modelMPG <- ModelMPG(port=PORT, browserScript, runBrowser=TRUE, quiet=FALSE)
run(modelMPG)

