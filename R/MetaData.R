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
"stationMetaData"
