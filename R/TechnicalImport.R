ReadZippedFile <- function(url, colNames) {
  con <- gzcon(url(url))
  raw <- textConnection(readLines(con))
  close(con)
  data <- read.table(raw, col.names = colNames)
  close(raw)
  return(data)
}
