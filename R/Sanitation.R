CheckStationId <- function(stationId, periodStart) {
  if (!stationId %in% stationMetaData$stationId) stop("stationId not available")
  else if (periodStart == 1910 &
           !stationId %in% stationMetaData[longRecord==TRUE, stationId]) {
    stop("stationId not available for periodStart 1910")
  }
}
