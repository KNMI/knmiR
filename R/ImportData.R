#' Obtains Brandsma series for specified station and period
#'
#' The data are downloaded from the Climate Explorer.
#' @param stationId Integer specifying the KNMI station number
#' @param periodStart Either 1910 or 1951
#' @return data.table with date and precipitation values
#' @import data.table
HomogenizedPrecipitation <- function(stationId, periodStart=1910) {
  url <- SpecifyUrlForHomogenPrecipZipped(stationId, periodStart)
  precip <- data.table(ReadZippedFile(url, c("date", "pr")))
  precip[, stationId := stationId]
  precip[, date := as.Date(paste(date), '%Y%m%d')]
  setcolorder(precip, c("date", "stationId", "pr"))
  return(precip)
}

#' Obtains homogenized precipitation data
#' @description  8-8 daily precipitation measurements
#' @param location Either inheriting from spatial polygon or station number
#' @param period Either numeric, timeBased or ISO-8601 style (see \code{\link[xts]{.subset.xts}})
#' @param whichSet Which set should be used c(1910, 1951, "automatic")?
#' @return data.table with date, stationId and precipitation values
#' @import sp
#' @import foreach
#' @import rgdal
#' @export
HomogenPrecip <- function(location, period, whichSet = "automatic") {
  SanitizeInput(type = "HomogenPrecip", location, period, whichSet)
  longRecord <- lon <- lat <- inArea <- i <- stationId <- NULL
  periodStart <- HomogenPrecipPeriodStart(period)
  if (is.numeric(location)) {
    tmpStart <- ifelse(stationMetaData[list(location), longRecord] & whichSet != 1951, 1910, 1951)
    tmp <- HomogenizedPrecipitation(location, tmpStart)
  } else {
    standardCRSstring <- "+proj=longlat +ellps=WGS84"
    if (location@proj4string@projargs != standardCRSstring) {
      location <- sp::spTransform(location, CRS(standardCRSstring))
    }
    tmpMetaData <- stationMetaData
    if(periodStart==1910 | whichSet==1910) {
      tmpMetaData <- tmpMetaData[longRecord==TRUE, ]
    }
    stationLocations <- sp::SpatialPoints(tmpMetaData[, list(lon, lat)], CRS(standardCRSstring))
    tmpMetaData[, inArea := sp::over(stationLocations, as(location, 'SpatialPolygons'))]
    tmpMetaData <- na.omit(tmpMetaData)
    tmp <- foreach(i = 1 : tmpMetaData[, .N], .combine = "rbind") %do% {
      tmpStart <- ifelse(tmpMetaData[i, longRecord] & whichSet != 1951, 1910, 1951)
      HomogenizedPrecipitation(tmpMetaData[i, stationId], tmpStart)
    }
  }
  setkey(tmp, date)
  tmp <- tmp[list(HomogenPrecipDates(period)),]
  setkey(tmp, stationId, date)
  setattr(tmp, "MetaData", HomogenizedPrecipitationMetaData())
  setattr(tmp, "DownloadMetaData", DownloadMetaData())
  return(tmp)
}


#' @importFrom xts .subset.xts
#' @importFrom xts .parseISO8601
HomogenPrecipDates <- function(period) {
  tmp <- xts::.parseISO8601(period, tz="GEZ")
  return(seq.Date(as.Date(tmp$first.time), as.Date(tmp$last.time), by = "day"))
}
