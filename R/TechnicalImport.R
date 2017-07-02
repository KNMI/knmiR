ReadZippedFile <- function(url, colNames) {
  con <- gzcon(url(url))
  raw <- textConnection(readLines(con))
  close(con)
  data <- read.table(raw, col.names = colNames)
  close(raw)
  return(data)
}

UpdateJsonTable <- function(jsonTable) {
  depth <- lat <- lon <- mag <- NULL
  tmp <- as.data.table(jsonTable) # nolint
  tmp[, date  := as.Date(date, tz = "CET")]
  tmp[, depth := as.numeric(depth)]
  tmp[, lat   := as.numeric(lat)]
  tmp[, lon   := as.numeric(lon)]
  tmp[, mag   := as.numeric(mag)]
  setcolorder(tmp, c("date", "time", "place", "type",
                     "evaluationMode", "lat", "lon", "depth", "mag"))
  tmp
}
