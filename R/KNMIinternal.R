InternalOnly <- function() {
  node <- Sys.info()["nodename"]
  if (!grepl("knmi.nl", node)) {
    errMsg <- "This function works only inside KNMI"
    flog.error(errMsg)
    stop(errMsg)
  }
}
