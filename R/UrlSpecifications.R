SpecifyUrlForHomogenPrecipZipped <- function(stationId, periodStart) {
  CheckStationId(stationId, periodStart)
  url <- "http://climexp.knmi.nl/KNMIData/precip"
  if (stationId < 100) stationIdString <- paste(0, stationId, "hom", sep = "")
  else stationIdString <- paste(stationId, "hom", sep = "")
  url <- paste(url, stationIdString, sep = "")
  if (periodStart == 1910) url <- paste(url, "1910.dat.gz", sep = "")
  else if (periodStart == 1951) url <- paste(url, "1951.dat.gz", sep = "")
  else stop("periodStart should be 1910 or 1951")
  return(url)
}

SpecifyUrlEarthquakes <- function(type) {
  if (type == "induced") {
    URL <- "http://cdn.knmi.nl/knmi/map/page/seismologie/all_induced.json"
  } else if (type == "tectonic") {
    URL <- "http://cdn.knmi.nl/knmi/map/page/seismologie/all_tectonic.json"
  } else stop("Catalogue type not known.")
  return(URL)
}
