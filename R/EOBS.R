
# url <- "https://climate4impact.eu/impactportal/adagucserver?source=http%3A%2F%2Fopendap.knmi.nl%2Fknmi%2Fthredds%2FdodsC%2Fe-obs_0.25regular%2Ftg_0.25deg_reg_v13.0.nc&SERVICE=WCS&REQUEST=GetCoverage&COVERAGE=tg&CRS=EPSG%3A4326&FORMAT=netcdf&BBOX=-40.5,25.25,75.5,75.5&RESX=0.25&RESY=0.25&TIME=1982-03-17T00:00:00Z"

#' Imports EOBS data (template for transition to WCS)
#' @param variable String(s) identifying variable(s)
#' @param geoIdentifier Either string(s) to identify stations,
#'  SpatialPoint(s) for closest station/grid box,
#'  bbox or extending SpatialPolygon for everything inside area
#' @param period Either numeric, timeBased or ISO-8601 style (see \code{\link[xts]{.subset.xts}})
#' @param path for file download (if set to NULL data are always downloaded but not saved)
#' @param basegrid String identifying the basegrid
#' @param regrid Boolean should it be regridded through WCS
#' @param resx x-Resolution for regridding (default 0.25)
#' @param resy y-Resolution for regridding (default 0.25)
#' @export
EOBS <- function(variable, geoIdentifier, period, path,
                 basegrid, regrid=FALSE, resx=0.25, resy=0.25) {
  url <- "https://climate4impact.eu/impactportal/adagucserver?"
  url <- paste0(url, "source=http%3A%2F%2Fopendap.knmi.nl")
  url <- paste0(url, "%2Fknmi%2Fthredds%2FdodsC%2F")
  url <- paste0(url, "e-obs_0.25regular%2Ftg_0.25deg_reg_v13.0.nc&")
  url <- paste0(url, "SERVICE=WCS&REQUEST=GetCoverage&")
  url <- paste0(url, "COVERAGE=tg&")
  url <- paste0(url, "CRS=EPSG%3A4326&")
  url <- paste0(url, "FORMAT=netcdf&")
  url <- paste0(url, "BBOX=-40.5,25.25,75.5,75.5&")
  url <- paste0(url, "RESX=0.25&RESY=0.25&")
  url <- paste0(url, "TIME=1982-03-17T00:00:00Z")
  #url <- paste0(url, "TIME=1982-03-17T00:00:00Z/1982-04-17T00:00:00Z")

  filename <- "tmp123.nc"

  download.file(url, filename, quiet = TRUE)

  con <- nc_open(filename)
  var <- ncvar_get(con, variable)
  nc_close(con)
  file.remove(filename)
  return(var)
}
