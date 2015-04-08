# Chinook.R: a server for 4-field JSON messages over websockets
#---------------------------------------------------------------------------------------------------
.Chinook <- setClass("Chinook",
                      representation(websocketConnection="environment",
                                     port="integer"))

#----------------------------------------------------------------------------------------------------
setGeneric("run",                signature="obj", function(obj, startBrowser=FALSE) standardGeneric("run"))
setGeneric("show",               signature="obj", function(obj) standardGeneric("show"))
setGeneric("port",               signature="obj", function(obj) standardGeneric("port"))
setGeneric('closeWebSocket',     signature="obj", function(obj) standardGeneric("closeWebSocket"))
setGeneric("version",            signature="obj", function(obj) standardGeneric("version"))
#---------------------------------------------------------------------------------------------------
printf <- function(...) print(noquote(sprintf(...)))
dispatchMap <- new.env(parent=emptyenv())
#---------------------------------------------------------------------------------------------------
# class constructor
Chinook = function(port, browserScript, runBrowser=FALSE, quiet=FALSE)
{
   if(is.na(browserScript))
      browserScript <- system.file(package="Chinook", "js", "empty", "index.html")

   if(!quiet)
      message(sprintf("Chinook ctor, browserScript: %s", browserScript))
   
   if(!file.exists(browserScript)){
      msg <- sprintf("Chinook constructor error: cannot find browserScript.");
      msg <- paste(msg, sprintf("  looked for '%s'", browserScript));
      stop(msg);
      }

  host <- "localhost"
  uri <- sprintf("http://%s:%s", host, port)

  if(runBrowser){
     if(!quiet)
        message(sprintf("summoning default browser to get %s", uri))
     browseURL(uri)
     }

  wsCon <- new.env(parent=emptyenv())
  wsCon <- .setupWebSocketHandlers(wsCon, browserScript)

  #browser()
  #obj <- .Chinook(websocketConnection=wsCon, port=as.integer(actualPort))
  obj <- .Chinook(websocketConnection=wsCon, port=as.integer(port))

  obj@websocketConnection <- wsCon
   
  obj

} # ctor
#---------------------------------------------------------------------------------------------------
setMethod("show", "Chinook",

  function(obj) {
    s <- sprintf("Chinook server running on port %d", port(obj))
    cat(paste(s, "\n", sep=""))
    })

#---------------------------------------------------------------------------------------------------
.validWebSocketID <- function(candidate)
{
   if(length(grep("not available", candidate)) == 1)
      return (FALSE)

   return (TRUE)

} # .validWebSocketID
#----------------------------------------------------------------------------------------------------
# the semanitcs of toJSON changed between RJSONIO and jsonlite: in the latter, scalars are
# promoted to arrays of length 1.  rather than change our javascript code, and since such
# promotion -- while sensible in the context of R -- strikes me as gratuitous, I follow
# jeroen ooms suggestion, creating this wrapper
toJSON <- function(..., auto_unbox = TRUE)
{
  jsonlite::toJSON(..., auto_unbox = auto_unbox)
}
#----------------------------------------------------------------------------------------------------
.setupWebSocketHandlers <- function(wsCon, browserScript)
{
   wsCon$open <- FALSE
   wsCon$ws <- NULL
   wsCon$result <- NULL
     # process http requests
   wsCon$call = function(req) {
      wsUrl = paste(sep='', '"', "ws://",
                   ifelse(is.null(req$HTTP_HOST), req$SERVER_NAME, req$HTTP_HOST),
                   '"')
     list(
       status = 200L,
       headers = list('Content-Type' = 'text/html'),
       body = c(file=browserScript))
       }

      # called whenever a websocket connection is opened
   wsCon$onWSOpen = function(ws) {   
      wsCon$ws <- ws
      ws$onMessage(function(binary, rawMessage) {
         message <- as.list(fromJSON(rawMessage))
         #loginfo(message);
         wsCon$lastMessage <- message
         if(!is(message, "list")){
            message("message: new websocket message is not a list");
            return;
            }
         if (! "cmd" %in% names(message)){
            message("error: new websocket messages has no 'cmd' field");
            return;
            }
         cmd <- message$cmd
         dispatchMessage(ws, message);
         }) # onMessage
       wsCon$open <- TRUE
       } # onWSOpen

   wsCon

} # .setupWebSocketHandlers
#--------------------------------------------------------------------------------
.version <- function()
{
   sessionInfo()$otherPkgs$Chinook$Version

} # .version
#--------------------------------------------------------------------------------
dispatchMessage <- function(WS, msg)
{
  errorFunction <- function(cond){
    return.msg <- list()
    return.msg$cmd <- msg$callback
    return.msg$callback <- ""
    package.version <- .version()
    return.msg$status <- "error";
    error.msg <- sprintf("Chinook (version %s) exception!  %s", package.version, cond);
    msg.as.text <- paste(as.character(msg), collapse=";  ")
    msg.full <- sprintf("%s. incoming msg: %s", error.msg, msg.as.text)
    return.msg$payload <- msg.full
    WS$send(toJSON(return.msg))
    }

  tryCatch({
    stopifnot(msg$cmd %in% ls(dispatchMap));
    function.name <- dispatchMap[[msg$cmd]]
    success <- TRUE   
    stopifnot(!is.null(function.name))
    func <- get(function.name)
    stopifnot(!is.null(func))
    do.call(func, list(WS, msg))
    }, error=errorFunction)

} # dispatchMessage
#---------------------------------------------------------------------------------------------------
setMethod("run", "Chinook",

  function(obj, startBrowser=FALSE) {
     wsID <- startServer("0.0.0.0", port(obj),  obj@websocketConnection)
     obj@websocketConnection$wsID <- wsID

     print(noquote(sprintf("Chinook::run, starting service loop on port %d", port(obj))))
     if(startBrowser){
        browseURL(sprintf("http://localhost:%d", port(obj)));
        }
     while (TRUE) {
       service()
       Sys.sleep(0.001)
       }
     }) # run

#---------------------------------------------------------------------------------------------------
setMethod("version", "Chinook",

  function(obj){
     sessionInfo()$otherPkgs$Chinook$Version;
  }) # version

#---------------------------------------------------------------------------------------------------
setMethod('closeWebSocket', 'Chinook',

  function (obj) {
     if(!obj@websocketConnection$open){
        warning("websocket server is not open, cannot close");
        return()
        }
     obj@websocketConnection$open <- FALSE
     stopServer(obj@websocketConnection$wsID)
     obj@websocketConnection$ws <- NULL
     obj@websocketConnection$ws <- -1
     invisible(obj)
     })

#----------------------------------------------------------------------------------------------------
setMethod("port", "Chinook",

  function(obj) {
    obj@port
    })

#---------------------------------------------------------------------------------------------------
addServerMessageHandler <- function(key, function.name)
{
   dispatchMap[[key]] <- function.name
    
} # addServerMessageHandler
#---------------------------------------------------------------------------------------------------
getServerStatus <- function(ws, msg)
{
   payload <- list(currentTime=Sys.time(),
                   serverVersion=sessionInfo()$otherPkgs$Chinook$Version,
                   registeredHandlers=length(dispatchMap))
   
   return.msg <- list(cmd=msg$callback, status="success", callback="", payload=payload)
   ws$send(toJSON(return.msg))

} # getServerStatus
#---------------------------------------------------------------------------------------------------
addServerMessageHandler("getServerStatus", "getServerStatus");
