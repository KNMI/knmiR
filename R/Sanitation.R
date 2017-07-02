CheckStationId <- function(stationId, periodStart) {
  longRecord <- NULL
  if (!stationId %in% stationMetaData$stationId) stop("stationId not available")
  else if (periodStart == 1910 &
           !stationId %in% stationMetaData[longRecord==TRUE, stationId]) {
    stop("stationId not available for periodStart 1910")
  }
}

SanitizeInput <- function(type, ...) {
  switch(type,
         "HomogenPrecip" = SanitizeHomogenPrecip(...),
         stop("No data type indicated"))
}

#' @importFrom xts .parseISO8601
SanitizeHomogenPrecip <- function(location, period, whichSet) {
  stationId <- NULL
  if (!whichSet %in% c(1910, 1951, "automatic")) {
    stop("whichSet should be either 1910, 1951, or 'automatic'")
  }
  tryCatch(xts::.parseISO8601(period),
           warning = function(e) {
             stop()
             },
           error = function(e) {
             stop("Period should be either Numeric, timeBased or ISO-8601 style.")
           })
  periodStart <- HomogenPrecipPeriodStart(period)
  isStationId <- FALSE
  if (is.numeric(location)) {
    if (location %in% stationMetaData[, stationId]) isStationId <- TRUE
  }
  isArea      <- extends(class(location), "SpatialPolygons")
  if (isArea) {
    if (is.na(location@proj4string@projargs)) {
      stop("No transformation possible from NA reference system")
    }
  }
  if (!(isStationId | isArea)) {
    stop("Location should be either valid station id or spatial polygon, with non-empty intersection.")
  }
  if (isStationId) CheckStationId(location, periodStart)
  if (whichSet != "automatic") {
    if (periodStart < whichSet) {
      lastDate <- as.Date(xts::.parseISO8601(period)$last.time)
      warning(paste0("Period is restricted to 1951-01-01/", lastDate))
    }
    else if (periodStart > whichSet & isArea) message("You could consider more stations for the given period by choosing whichSelect='automatic'")
  }
}

HomogenPrecipPeriodStart <- function(period) {
  if (period  < "1951-01-01") return(1910)
  else return(1951)
}
