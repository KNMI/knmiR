ReadZippedFile <- function(url, colNames) {
  con <- gzcon(url(url))
  raw <- textConnection(readLines(con))
  close(con)
  data <- read.table(raw, col.names = colNames)
  close(raw)
  return(data)
}

GetJsonValues <- function(entry) {
  date           <- as.Date(entry["date"], tz="CET")
  time           <- as.character(entry["time"])
 # datetime       <- as.POSIXlt(paste0(date, " ", time))
  type           <- as.character(entry["type"])
  depth          <- as.numeric(entry["depth"])
  evaluationMode <- as.character(entry["evaluationMode"])
  lat            <- as.numeric(entry["lat"])
  lon            <- as.numeric(entry["lon"])
  mag            <- as.numeric(entry["mag"])
  place          <- as.character(entry["place"])
  return(data.frame(date, time,
                    place, type,
                    evaluationMode, lat, lon, depth, mag,
                    stringsAsFactors = FALSE))
}
