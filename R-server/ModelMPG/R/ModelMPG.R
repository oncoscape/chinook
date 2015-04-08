# ModelMPG.R: a server for 4-field JSON messages over websockets
#---------------------------------------------------------------------------------------------------
.ModelMPG <- setClass("ModelMPG",
                      representation(data="data.frame"),
                      contains="Chinook",
                      prototype = prototype(uri="http://localhost", 9000)
                      )

#----------------------------------------------------------------------------------------------------
setGeneric("version",            signature="obj", function(obj) standardGeneric("version"))
setGeneric("calculateModel",     signature="obj", function(obj, variableNames) standardGeneric("calculateModel"))
#---------------------------------------------------------------------------------------------------
printf <- function(...) print(noquote(sprintf(...)))
#---------------------------------------------------------------------------------------------------
scriptDir <- system.file(package="ModelMPG", "scripts", "modelMPG.html");
#---------------------------------------------------------------------------------------------------
# class constructor
ModelMPG = function(port, browserScript, runBrowser=TRUE, quiet=FALSE)
{
   obj <- .ModelMPG(Chinook(port, browserScript, runBrowser, quiet))

   addServerMessageHandler("calculate", "calculate");
   addServerMessageHandler("getTable", "getTable");

   obj

} # ctor
#---------------------------------------------------------------------------------------------------
setMethod("show", "ModelMPG",

  function(obj) {
    s <- sprintf("ModelMPG server running on port %d", port(obj))
    cat(s)
    })

#---------------------------------------------------------------------------------------------------
setMethod("calculateModel", "ModelMPG",

   function(obj, variableNames){
      printf("ModleMPG::calculateModel");
      })
   
#---------------------------------------------------------------------------------------------------
calculate <- function(ws, msg)
{
   xVariableName <- msg$payload$x;
   yVariableName <- msg$payload$y;
   legalInputs <- all(c(xVariableName, yVariableName) %in% colnames(mtcars))   
   xVals = mtcars[, xVariableName]
   yVals = mtcars[, yVariableName]

   xMin=min(xVals)
   xMax=max(xVals)
   yMin=min(yVals)
   yMax=max(yVals)

   xExtent <- xMax - xMin
   padding <- xExtent/10
   xMin <- xMin - padding
   xMax <- xMax + padding

   yExtent <- yMax - xMin
   padding <- yExtent/10
   yMin <- yMin - padding
   yMax <- yMax + padding

   payload <- list(x=xVals,
                   y=yVals,
                   xMin=xMin,
                   xMax=xMax,
                   yMin=yMin,
                   yMax=yMax,
                   xAxisLabel=xVariableName,
                   yAxisLabel=yVariableName,
                   rownames=rownames(mtcars)
                   )

   return.msg <- list(cmd=msg$callback, status="success", callback="", payload=payload)
   ws$send(toJSON(return.msg))

} # calculate
#---------------------------------------------------------------------------------------------------
# httpuv and Javascript work best togther if we send a data.frame as a matrix of strings
# with rownames and colnames stripped off, and rownames made into the first column of the matrix
# these rather odd transformation is performed here, before the matrix and colnames are
# shipped separately in the payload.
# at present, and for the sake of this demo, only the R builtin data.frame "mtcars" is used, to
# no incoming specifier is needed or examined.

getTable <- function(ws, msg)
{
   dataFrame <- mtcars
   column.titles <- colnames(dataFrame)

   if(length(rownames(dataFrame)) == nrow(dataFrame)){   # crude test for presence of rownames
      dataFrame <- cbind(rownames(dataFrame), dataFrame)
      column.titles <- c(" ", column.titles)
      }

    matrix <- as.matrix(dataFrame)
    colnames(matrix) <- NULL
    payload <- list(cols=column.titles, mtx=matrix)
    return.msg <- list(cmd="displayTable", callback="handleResponse", status="success",
                       payload=payload)

    ws$send(toJSON(return.msg))
 
} # getTable
#----------------------------------------------------------------------------------------------------
