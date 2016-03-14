SpecifyUrlForHomogenPrecipZipped <- function(stationId, periodStart) {
  CheckStationId(stationId, periodStart)
  url <- "http://climexp.knmi.nl/KNMIData/precip"
  if (stationId < 100) stationIdString <- paste(0, stationId, "_hom_", sep="")
  else stationIdString <- paste(stationId, "_hom_", sep="")
  url <- paste(url, stationIdString, sep="")
  if (periodStart == 1910) url <- paste(url, '1910-now.dat.gz', sep="")
  else if (periodStart == 1951) url <- paste(url, '1951-now.dat.gz', sep="")
  else stop("periodStart should be 1910 or 1951")
  return(url)
}
