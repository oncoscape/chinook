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
Chinook = function(portRange, scriptDir, runBrowser=FALSE, quiet=FALSE)
{
   actualPort <- portRange[1]

   if(is.na(scriptDir))
      browserFile <- system.file(package="Chinook", "js", "minimal", "index.html")
   else
      browserFile <- system.file(package="Chinook", "js", scriptDir, "index.html")

   if(!quiet)
      message(sprintf("Chinook ctor, browserFile: %s", browserFile))
   
   if(!file.exists(browserFile)){
      msg <- sprintf("Chinook constructor error: cannot find browserFile.");
      msg <- paste(msg, sprintf("  looked for '%s'", browserFile));
      stop(msg);
      }

  host <- "localhost"
  uri <- sprintf("http://%s:%s", host, actualPort)

  if(runBrowser){
     if(!quiet)
        message(sprintf("summoning default browser to get %s", uri))
     browseURL(uri)
     }

  wsCon <- new.env(parent=emptyenv())
  wsCon <- .setupWebSocketHandlers(wsCon, browserFile)

  obj <- .Chinook(websocketConnection=wsCon, port=as.integer(actualPort))

  obj@websocketConnection <- wsCon
   
  obj

} # ctor
#---------------------------------------------------------------------------------------------------
setMethod("show", "Chinook",

  function(obj) {
    s <- sprintf("Chinook server running on port %d", port)
    cat(s)
    })

#---------------------------------------------------------------------------------------------------
.startServerOnFirstAvailableLocalHostPort <- function(portRange, wsCon)
{
   done <- FALSE

   port <- portRange[1]
   wsID <- NULL
   
   while(!done){
     if(port > max(portRange))
        done <- TRUE
     else
        printf("Chinook trying port %d", port)
        wsID <- tryCatch(startServer("0.0.0.0", port, wsCon),
                         error=function(m){sprintf("port not available: %d", port)})
     if(.validWebSocketID(wsID))
        done <- TRUE
     else
        port <- port + 1;
     } # while

   actualPort <- NULL
   
   if(.validWebSocketID(wsID))
      actualPort <- port

   list(wsID=wsID, port=actualPort)

} # .startServerOnFirstAvailableLocalHostPort
#----------------------------------------------------------------------------------------------------
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
.setupWebSocketHandlers <- function(wsCon, browserFile)
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
       body = c(file=browserFile))
       }

      # called whenever a websocket connection is opened
   wsCon$onWSOpen = function(ws) {   
      printf("---- chinook wsCon$onWSOpen");
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
         printf("Chinook:onMessage, raw ");
         print(rawMessage)
         printf("Chinook:onMessage, cooked ");
         print(message)
         dispatchMessage(ws, message);
         }) # onMessage
       wsCon$open <- TRUE
       } # onWSOpen

   wsCon

} # .setupWebSocketHandlers
#--------------------------------------------------------------------------------
.version <- function()
{
   sessionInfo()$otherPkgs$OncoDev14$Version

} # .version
#--------------------------------------------------------------------------------
dispatchMessage <- function(WS, msg)
{
  errorFunction <- function(cond){
    return.msg <- list()
    return.msg$cmd <- msg$callback
    return.msg$callback <- ""
    package.version <- .version()
    printf("Chinook.R %s dispatchMessage detected error", package.version);
    return.msg$status <- "error";
    error.msg <- sprintf("Chinook (version %s) exception!  %s", package.version, cond);
    msg.as.text <- paste(as.character(msg), collapse=";  ")
    msg.full <- sprintf("%s. incoming msg: %s", error.msg, msg.as.text)
    printf("--- msg.full: %s", msg.full);
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
   printf("OncoDev14 addRMessageHandler: '%s'", key);
   dispatchMap[[key]] <- function.name
    
} # addServerMessageHandler
#---------------------------------------------------------------------------------------------------
getServerStatus <- function(ws, msg)
{
   print("=== Chinook, getServerStatus")

   payload <- list(currentTime=Sys.time(),
                   serverVersion=sessionInfo()$otherPkgs$Chinook$Version,
                   registeredHandlers=length(dispatchMap))
   
   return.msg <- list(cmd=msg$callback, status="success", callback="", payload=payload)
   print(return.msg)
   ws$send(toJSON(return.msg))

} # getServerStatus
#---------------------------------------------------------------------------------------------------
addServerMessageHandler("getServerStatus", "getServerStatus");
