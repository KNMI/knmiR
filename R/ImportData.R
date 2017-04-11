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
#' @param path for file download (if set to NULL data are always downloaded but not saved)
#' @return data.table with date, stationId and precipitation values
#' @import sp
#' @import foreach
#' @import rgdal
#' @export
HomogenPrecip <- function(location, period, whichSet = "automatic", path="") {
  cl <- match.call()
  SanitizeInput(type = "HomogenPrecip", location, period, whichSet)
  if (is.null(path)) tmp <- PrecipitationDownload(location, period, whichSet, cl)
  else {
    fileName <- SpecifyFileName("HomogenPrecip", path, location, period)
    if (!file.exists(fileName)) {
      tmp <- PrecipitationDownload(location, period, whichSet, cl)
      saveRDS(tmp, file = fileName)
    } else {
      tmp <- readRDS(fileName)
    }
  }
  return(tmp)
}

PrecipitationDownload <- function(location, period, whichSet, call) {
  longRecord <- lon <- lat <- inArea <- i <- stationId <- NULL
  DownloadMessage("HomogenPrecip")
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
  tmp <- tmp[date %in% HomogenPrecipDates(period),]
  setkey(tmp, stationId, date)
  KnmiData(tmp, call, "HomogenPrecip")
}

DownloadMessage <- function(name) {
  message(paste0("Downloading data from ", DownloadMessageContent(name)))
}

DownloadMessageContent <- function(name) {
  switch(name,
         "Earthquakes" = return("www.knmi.nl/kennis-en-datacentrum/dataset/aardbevingscatalogus"),
         "HomogenPrecip" = return("www.climexp.knmi.nl")
  )
}

#' @importFrom xts .subset.xts
#' @importFrom xts .parseISO8601
HomogenPrecipDates <- function(period) {
  tmp <- xts::.parseISO8601(period, tz="GEZ")
  return(seq.Date(as.Date(tmp$first.time), as.Date(tmp$last.time), by = "day"))
}

#' Loads the KNMI earthquake catalogue
#' @param type Type of catalogue c('induced', 'tectonic')
#' @param area Inheriting from spatial polygon
#' @param period Either numeric, timeBased or ISO-8601 style (see \code{\link[xts]{.subset.xts}})
#' @param path for saving data (if set to NULL data are always downloaded but not saved)
#' @return data.table with rows being the single events
#' @export
#' @examples
#' data <- Earthquakes("induced", Groningen, "1990/2016")
#' Description(data)
#' Citation(data)
#' License(data)
#'
Earthquakes <- function(type="induced", area = NULL, period = NULL, path = "") {
  cl <- match.call()
  if (is.null(path)) tmp <- EarthquakesDownload(type, area, period, cl)
  else {
    fileName <- SpecifyFileNameEarthquakes(type, path, area, period)
    if (!file.exists(fileName)) {
      tmp <- EarthquakesDownload(type, area, period, cl)
      saveRDS(tmp, file=fileName)
    } else {
      tmp <- readRDS(fileName)
    }
  }
  return(tmp)
}

EarthquakesDownload <- function(type, area, period, call) {
  DownloadMessage("Earthquakes")
  URL       <- SpecifyUrlEarthquakes(type)
  jsonTable <- jsonlite::fromJSON(URL)$events
  tmp       <- UpdateJsonTable(jsonTable)
  if (!is.null(area))   tmp <- ClipQuakes(tmp, area)
  if (!is.null(period)) tmp <- tmp[date %in% HomogenPrecipDates(period),]
  KnmiData(tmp, call, "Earthquakes")
}

EarthquakesDownload2 <- function(type, area, period, call) {
  # DownloadMessage("Earthquakes")
  queryUrl <- "http://rdsa.knmi.nl/fdsnws/event/1/query?"
  queryUrl <- paste0(queryUrl, "starttime=2016-01-14T00%3A00%3A00&")
  queryUrl <- paste0(queryUrl, "endtime=2017-04-13T00%3A00%3A00&")
  queryUrl <- paste0(queryUrl, "minlatitude=40&maxlatitude=80&minlongitude=-5&maxlongitude=9&")
  queryUrl <- paste0(queryUrl, "format=text&nodata=404&minmagnitude=0.5&limit=99999999")
  tmp <- read.delim(queryUrl, sep = "|", stringsAsFactors = FALSE)
  tmp <- as.data.table(tmp)
  tmp[, Author := NULL]
  tmp[, Catalog := NULL]
  tmp[, Contributor := NULL]
  tmp[, ContributorID := NULL]
  tmp[, MagAuthor := NULL]
  # oldDigits <- options(digits.secs = 2)
  # tmp[, datetime := as.POSIXct(Time, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")+0.01]
  # options(digits.secs = oldDigits)
  setnames(tmp, c("Latitude", "Longitude", "Depth.km",
                  "Magnitude", "EventLocationName"),
           c("lat", "lon", "depth", "mag", "place"))
  tmp
}

#' Select earthquake sover area
#'
#' @param quakes data.table with earthquakes
#' @param area SpatialPolygons
#' @export
ClipQuakes <- function(quakes, area) {
  lat <- lon <- NULL
  points <- as.data.frame(quakes[, list(lon, lat)])
  points <- sp::SpatialPoints(points, CRS("+proj=longlat +datum=WGS84"))
  points <- sp::spTransform(points, area@proj4string)
  index <- which(!is.na(sp::over(points, area)))
  return(quakes[index, ])
}





