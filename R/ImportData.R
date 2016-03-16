#' Obtains Brandsma series for specified station and period
#'
#' The data are downloaded from the Climate Explorer.
#' @param stationId Integer specifying the KNMI station number
#' @param periodStart Either 1910 or 1951
#' @return data.table with date and precipitation values
#' @import data.table
#' @export
HomogenizedPrecipitation <- function(stationId, periodStart=1910) {
  url <- SpecifyUrlForHomogenPrecipZipped(stationId, periodStart)
  precip <- data.table(ReadZippedFile(url, c("date", "pr")))
  precip[, stationId := stationId]
  precip[, date := as.Date(paste(date), '%Y%m%d')]
  setcolorder(precip, c("date", "stationId", "pr"))
  setattr(precip, "MetaData", HomogenizedPrecipitationMetaData())
  setattr(precip, "DownloadMetaData", DownloadMetaData())
  return(precip)
}
