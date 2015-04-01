# test_Chinook.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Chinook)
#----------------------------------------------------------------------------------------------------
PORT.RANGE = 5124:5134
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
  test_version();
  test_start()
  
} # runTests
#----------------------------------------------------------------------------------------------------
test_version <- function()
{
  print("--- test_serverVersion, OncoDev14")
  scriptDir <- NA_character_

  chinook <- Chinook(portRange=PORT.RANGE, scriptDir=scriptDir)
  version <- version(chinook)
  checkEquals(length(grep("^0.9", version)), 1)   # e.g., "1.4.4"

} # test_version
#----------------------------------------------------------------------------------------------------
test_start <- function()
{
  print("--- test_serverVersion, OncoDev14")
  scriptDir <- NA_character_

  chinook <- Chinook(portRange=PORT.RANGE, scriptDir=scriptDir)
  run(chinook)

} # test_start
#----------------------------------------------------------------------------------------------------
