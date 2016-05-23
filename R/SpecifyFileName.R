SpecifyFileName <- function(name, path, area, period) {
  periodString <- GetFullySpecifiedPeriod(name, period)
  areaString <- GetFullySpecifiedArea(name, area)
  fileName <- paste0(path, name, "_", periodString, "_", areaString,
                     "_knmiR_", utils::packageVersion("knmiR"), ".rds")
  return(fileName)
}

SpecifyFileNameEarthquakes <- function(type, path, area, period) {
  if (type == "induced") {
    fileName <- SpecifyFileName("InducedQuakes", path, area, period)
  } else if (type == "tectonic") {
    fileName <- SpecifyFileName("TectonicQuakes", path, area, period)
  } else stop("Catalogue type not known.")
  return(fileName)
}

GetFullySpecifiedPeriod <- function(name, period = NULL) {
  startDate <- GetStartDate(name)
  endDate <- Sys.Date()
  if (is.null(period)) {
    return(paste0(startDate, "_", endDate))
  } else {
    parsedPeriod <- lapply(xts::.parseISO8601(period, tz="GEZ"), as.Date)
    return(paste0(max(startDate, parsedPeriod$first.time), "_",
                  min(endDate, parsedPeriod$last.time)))
  }
}

GetStartDate <- function(name) {
  switch (name,
    "HomogenPrecip" = return(as.Date("1910-01-01")),
    "InducedQuakes" = return(as.Date("1986-01-01")),
    "TectonicQuakes" = return(as.Date("1911-01-01")),
    stop("Name not defined"))
}

GetFullySpecifiedArea <- function(name, area = NULL) {
  if (is.null(area)) area <- GetMaxDomain(name)
  if (extends(class(area), "SpatialPolygons")) {
    return(paste0("AreaHash_", digest::digest(area)))
  } else if (class(area) == "matrix") {
    return(paste0("bbox_", round(area[1,1], 2), "_", round(area[1,2], 2),
                  "_", round(area[2,1], 2), "_", round(area[2,2], 2)))
  } else if (class(area) == "numeric") {
    return(paste0("StationId_", area))
  } else stop("Area is not set correctly")
}

GetMaxDomain <- function(name) {
  lon <- lat <- NULL
  switch (name,
    "HomogenPrecip" = return(sp::bbox(sp::SpatialPoints(stationMetaData[, cbind(lon, lat)]))),
    "InducedQuakes" = return(EarthquakesBoundaryBox),
    "TectonicQuakes" = return(EarthquakesBoundaryBox))
}
