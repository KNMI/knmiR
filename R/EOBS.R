#
# # url <- "https://climate4impact.eu/impactportal/adagucserver?source=http%3A%2F%2Fopendap.knmi.nl%2Fknmi%2Fthredds%2FdodsC%2Fe-obs_0.25regular%2Ftg_0.25deg_reg_v13.0.nc&SERVICE=WCS&REQUEST=GetCoverage&COVERAGE=tg&CRS=EPSG%3A4326&FORMAT=netcdf&BBOX=-40.5,25.25,75.5,75.5&RESX=0.25&RESY=0.25&TIME=1982-03-17T00:00:00Z"
#
# #' Imports EOBS data (template for transition to WCS)
# #' @param variable String(s) identifying variable(s)
# #' @param geoIdentifier Either string(s) to identify stations,
# #'  SpatialPoint(s) for closest station/grid box,
# #'  bbox or extending SpatialPolygon for everything inside area
# #' @param period Either numeric, timeBased or ISO-8601 style (see \code{\link[xts]{.subset.xts}})
# #' @param path for file download (if set to NULL data are always downloaded but not saved)
# #' @param ncdfFile String identifying local ncdf file (default NULL corresponds to not locally available)
# #' @param basegrid String identifying the basegrid (if ncdfFile determined by file)
# #' @param regrid Boolean should it be regridded through WCS (if ncdfFile not implemented)
# #' @param resx x-Resolution for regridding (default 0.25)
# #' @param resy y-Resolution for regridding (default 0.25)
# #' @export
# EOBS <- function(variable, geoIdentifier, period, path, ncdfFile = NULL,
#                  basegrid, regrid=FALSE, resx=0.25, resy=0.25) {
#   url <- "https://climate4impact.eu/impactportal/adagucserver?"
#   url <- paste0(url, "source=http%3A%2F%2Fopendap.knmi.nl")
#   url <- paste0(url, "%2Fknmi%2Fthredds%2FdodsC%2F")
#   url <- paste0(url, "e-obs_0.25regular%2Ftg_0.25deg_reg_v13.0.nc&")
#   url <- paste0(url, "SERVICE=WCS&REQUEST=GetCoverage&")
#   url <- paste0(url, "COVERAGE=tg&")
#   url <- paste0(url, "CRS=EPSG%3A4326&")
#   url <- paste0(url, "FORMAT=netcdf&")
#   url <- paste0(url, "BBOX=-40.5,25.25,75.5,75.5&")
#   url <- paste0(url, "RESX=0.25&RESY=0.25&")
#   url <- paste0(url, "TIME=1982-03-17T00:00:00Z")
#   #url <- paste0(url, "TIME=1982-03-17T00:00:00Z/1982-04-17T00:00:00Z")
#
#   filename <- "tmp123.nc"
#
#   download.file(url, filename, quiet = TRUE)
#
#   con <- nc_open(filename)
#   var <- ncvar_get(con, variable)
#   nc_close(con)
#   file.remove(filename)
#   return(var)
# }

#' Imports EOBS data
#' @param variable String from ('tg', 'tn', 'tx, ...)
#' @param period Either numeric, timeBased or ISO-8601 style
#'  (see \code{\link[xts]{.subset.xts}})
#' @param area Either SpatialPolygons or SpatialPolygonsDataFrame object (see
#'  package sp)
#' @param grid String from ('0.25reg', '0.50reg', '0.25rot', '0.50rot')
#' @param na.rm Boolean indicating if rows with NA can be deleted
#' @param download Boolean indicating whether to download
#' @export
EOBS <- function(variable, period, area, grid, na.rm=TRUE,
                       download=TRUE) {
  SanitizeInputEOBS(variable, period, area, grid)
  url  <- specifyURL(variable, grid)
  message(paste("Loading opendapURL", url))
  data <- GetEOBS(url, variable, area, period, na.rm)
  return(data)
}

#' Import EOBS data from local file
#' @note Should be merged with \code{\link{importEOBS}}
#' @inheritParams importEOBS
#' @param filename String containing the path to the ncdf file
#' @export
LocalImportEOBS <- function(variable, filename, period = NULL, area = NULL,
                            na.rm=TRUE) {
  # Local sanitizing
  data <- GetEOBS(filename, variable, area, period, na.rm)
  return(data)
}

GetEOBS <- function(filename, variable, area, period, na.rm) {

  result <- GetEobsBbox(filename, variable, sp::bbox(area), period)
  result <- CreateDataTableMelt(variable, result)

  if ( !is.null(area) & !is.matrix(area)) {
    result <- removeOutsiders(result, area)
  }
  if ( na.rm ) result <- removeNAvalues(result)
  result[, year  := as.numeric(format(time, "%Y"))]
  result[, month := as.numeric(format(time, "%m"))]
  result[, day   := as.numeric(format(time, "%d"))]
  setcolorder(result, c("time", "year", "month", "day", "lat", "lon", variable, "pointID"))
  return(result)
}


# Checks whether the input to importEOBS is valid or not
# @param variable Variable name
# @param period Period
# @param area Area
# @param grid Grid
SanitizeInputEOBS <- function(variable, period, area, grid) {
  if (variable %in% c('tg_stderr', 'tn_stderr', 'tx_stderr', 'pp_stderr',
                      'rr_stderr')) {
    stop("Standard error of variables not yet implemented.")
  }
  else if (!variable %in% c('tg', 'tn', "tx", "pp", 'rr', 'tg_stderr', 'tn_stderr',
                            'tx_stderr', 'pp_stderr', 'rr_stderr')) {
    stop(paste("Variable", variable, "not known."))
  }
  tryCatch(xts::.parseISO8601(period),
           warning = function(e) {stop()},
           error = function(e) {
             stop("Period should be either Numeric, timeBased or ISO-8601 style.")
           })
  if (!class(area) %in% c("SpatialPolygons","SpatialPolygonsDataFrame")) {
    stop("Area should be of class SpatialPolygons or SpatialPolygonsDataFrame.")
  }
  if (!grid %in% c("0.25reg", "0.50reg", "0.25rot", "0.50rot")) {
    stop("Grid should be specified correctly.")
  }
}

# Specifies the url based on the variableName and the grid
# @param variableName Variable name
# @param grid Grid
specifyURL <- function(variableName, grid) {
  url <- 'http://opendap.knmi.nl/knmi/thredds/dodsC/e-obs_'
  if (grid=="0.50reg") {
    url <- paste(url, '0.50regular/', sep="")
    ending <- '_0.50deg_reg_v14.0.nc'
  }
  if (grid=="0.25reg") {
    url <- paste(url, '0.25regular/', sep="")
    ending <- '_0.25deg_reg_v14.0.nc'
  }
  url <- paste(url, variableName, ending, sep="")
  return(url)
}

# Get the EOBS netcdf dimensions
GetEobsDimensions <- function(ncdfConnection) {
  values <- list()
  values$lat         <- ncdf4::ncvar_get(ncdfConnection, varid = 'latitude')
  values$lon         <- ncdf4::ncvar_get(ncdfConnection, varid = 'longitude')
  values$time        <- ncdf4::ncvar_get(ncdfConnection, varid = 'time')
  return(values)
}

# Accesses the OPeNDAB server
# @param filename String either url or local file
# @param variableName String which variable to get
# @param bbox Bounding box of spatial object
# @param period Time period
# @note This function is based on the script by Maarten Plieger
# https://publicwiki.deltares.nl/display/OET/OPeNDAP+subsetting+with+R
GetEobsBbox = function(filename, variableName, bbox, period){

  # Open the dataset
  dataset = ncdf4::nc_open(filename)

  # Get lon and lat variables, which are the dimensions of depth.
  values <- GetEobsDimensions(dataset)

  # Determine the valid range of the dimensions based on the period and
  # the bounding box
  validRange <- list()
  validRange$time <- which(findInterval(values$time,
                                        periodBoundaries(values$time, period))==1)
  validRange$lat  <- which(findInterval(values$lat, bbox[2,])==1)
  validRange$lon  <- which(findInterval(values$lon, bbox[1,])==1)

  # Make a selection of indices which fall in our subsetting window
  # E.g. translate degrees to indices of arrays.
  determineCount <- function(x) {return(c(x[1], tail(x,1) - x[1] + 1))}
  count <- rbind(determineCount(validRange$lon),
                 determineCount(validRange$lat),
                 determineCount(validRange$time))


  # Prepare a list with the valued values of the dimensions and the variable
  validValues <- list()
  validValues$lat             <- values$lat[validRange$lat]
  validValues$lon             <- values$lon[validRange$lon]
  validValues$time            <- as.Date(values$time[validRange$time],
                                         origin="1950-01-01")
  validValues[[variableName]] <- ncdf4::ncvar_get(dataset, variableName,
                                                  start=count[, 1],
                                                  count=count[, 2])

  # Close the data set and return data.table created from the valid values
  ncdf4::nc_close(dataset)
  return(validValues)
}

CreateDataTableMelt <- function(variable, validValues) {
  if (length(validValues$time) > 1) {
    meltedValues <- reshape2::melt(validValues[[variable]],
                                   varnames=c("lon", "lat", "time"))
    result <- as.data.table(meltedValues)
  } else {
    meltedValues <- reshape2::melt(validValues[[variable]],
                                   varnames=c("lon", "lat"))
    result <- as.data.table(meltedValues)
    result[, time := 1]
  }
  setkey(result, lon, lat)
  result[, pointID:=.GRP, by = key(result)]
  setkey(result, pointID)
  index <- result[, !all(is.na(value)), by = pointID][V1==TRUE, pointID]
  result <- result[pointID %in% index, ]
  result[, pointID := NULL]
  result[, lon := validValues$lon[lon]]
  result[, lat := validValues$lat[lat]]
  result[, time := validValues$time[time]]
  setnames(result, "value", paste(variable))
  return(result)
}

# Removes points outside of the SpatialPolygons
# Not for external use
# @param data Data.table
# @param area Valid area
removeOutsiders <- function(data, area) {
  setkey(data, lon, lat)
  data[, pointID:=.GRP, by=key(data)]
  coords <- data[, .(lon = unique(lon),
                     lat = unique(lat)), by = pointID][, .(lon, lat)]
  points <- sp::SpatialPoints(coords, area@proj4string)
  index  <- data[, unique(pointID)][which(!is.na(sp::over(points,
                                                          as(area, 'SpatialPolygons'))))]
  data <- data[pointID %in% index]
  setkey(data, lon, lat)
  return(data[, pointID:=.GRP, by=key(data)])
}

# Removes all rows with NAs
# Not for external use
# @param data data.table
removeNAvalues <- function(data) {
  # We don't check if time is NA (it should not) but date * 0 is not defined
  data <- data[complete.cases(data[,!"time", with=FALSE]*0)]
  setkey(data, lon, lat)
  data[, pointID:=.GRP, by=key(data)]
}

# To define the valid range
# @param time Time
# @param period Period
periodBoundaries <- function(time, period) {
  xts <- xts::xts(time, as.Date(time, origin="1950-01-01"))
  interval <- range(as.numeric(xts[period]))
  interval[2] <- interval[2] + 1
  return(interval)
}
