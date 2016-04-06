#' Homogenized precipitation station meta data
#'
#' A dataset containing the station meta data for the stations
#' used in Buishand et al. (2013)
#' @format A data.table with 240 rows and 4 variables:
#' \describe{
#'   \item{stationId}{KNMI station id},
#'   \item{lat}{Latitude},
#'   \item{lon}{Longitude},
#'   \item{elev}{Elevation in meters}
#'   \item{stationName}{Name of the Station}
#'   \item{longRecord}{TRUE if record starts in 1910}}
#' @source T. Brandsma \url{brandsma@knmi.nl}
#' @export
"stationMetaData"

DownloadMetaData <- function() {
  host <- system('uname -n',intern=T)
  user <- system('whoami',intern=T)
  time <- Sys.time()
  return(paste("Downloaded by", user, "on", host, "at", time))
}

HomogenizedPrecipitationMetaData <- function() {
  return(strwrap('# extended with operational data from KNMI 2010-now

  # THESE DATA CAN BE USED FREELY PROVIDED THAT THE FOLLOWING SOURCE IS ACKNOWLEDGED: ROYAL NETHERLANDS METEOROLOGICAL INSTITUTE

  # precip [mm/dy] homogenised precipitation (8-8)

  # Buishand, T.A., G. De Martino, J.N. Spreeuw en T. Brandsma, Homogeneity of precipitation series in the Netherlands and their trends in the past century <a href="http://www.knmi.nl/publicaties/showAbstract.php?id=8714">more</a>

  # source: <a href="http://climexp.knmi.nl">KNMI</a>'))
}


#' Groningen reservoir boundaries
#'
#' @format SpatialPolygons
#'
#' @source KNMI
"Groningen"


#' Earthquakes maximal domain
#' @format bbox i.e. 2*2 matrix
#'
EarthquakesBoundaryBox <- matrix(c(2, 50, 9, 55), nrow=2)
