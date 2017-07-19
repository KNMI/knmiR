#' Extract data from KIS
#' @param var Variable to extract for now 'TG' and 'MOR_10' are allowed (plural?)
#' @param geoIdentifier Station identifier (, spatial point, spatial area ..., plural?)
#' @param period Either numeric, timeBased or ISO-8601 style (see \code{\link[xts]{.subset.xts}})
#' @return data.table
#' @import uuid
#' @export
#' @examples
#' \dontrun{
#'  KIS('TG', '260_H', '2016')
#'  KIS('MOR_10', '260_A_a', '2016-02-01')
#' }
KIS <- function(var, geoIdentifier, period) {
  InternalOnly()
  morStations <- c("260_A_a", "290_A_a", "348_A_a", "280_A_23t",
                   "380_A_22t", "344_A_24t", "240_A_18Ct")
  groundTempStations <- c("260_T_a", "290_T_a", "348_T_a", "280_T_23t",
                   "380_T_22t", "344_T_24t", "240_T_18Ct")
  windStations <- c("260_W_a", "290_W_a", "348_W_a", "280_W_23t",
                          "380_W_22t", "344_W_24t", "240_W_18Ct")
  flog.debug("Started downloading data from KIS")
  flog.debug("var={%s}", paste(var))
  flog.debug("geoIdentifier has name={%s} and class={%s}",
             paste(substitute(geoIdentifier)),
             paste(class(geoIdentifier)[1]))
  flog.debug("period={%s}", paste(period))
  assertChoice(var, c("TG", "MOR_10", "FF_10M_10", "T_DRYB_10",
                      "U_10", "T_DEWP_10"))
  if (var == "TG") {
    assertChoice(geoIdentifier, c("260_H", "310_H"))
  }
  if (var == "T_DRYB_10") {
    assertChoice(geoIdentifier, groundTempStations)
  }
  if (var == "T_DEWP_10") {
    assertChoice(geoIdentifier, groundTempStations)
  }
  if (var == "U_10") {
    assertChoice(geoIdentifier, groundTempStations)
  }
  if (var == "MOR_10") {
    assertChoice(geoIdentifier, morStations)
  }
  if (var == "FF_10M_10") {
    assertChoice(geoIdentifier, windStations)
  }
  tryCatch(xts::.parseISO8601(period),
           warning = function(cond) {
             stop("period does not seem to be suitable")
           },
           error = function(cond) {
             stop("period does not seem to be suitable")
           })
  locationID <- geoIdentifier
  recipeName <- WriteKISRecipe(var, locationID, period)
  result <- ExecuteKISRecipe(recipeName, period)
  SetRightColumnClass(result)
  return(result) #FIX: Timezone is 240000 this day or the next?
}

SetRightColumnClass <- function(dt) {
  # So far only the class of the measurement col is changed to numeric
  colName <- as.name(names(dt)[3])
  dt[, c(3) := as.numeric(eval(as.name(colName)))]
}

WriteKISRecipe <- function(var, locationID, period) {
  # period is not yet used in the recipe
  # max results does not seem to have any effect

  uuid2 <- UUIDgenerate()

  # FIXME: Ensure that the recipe file is deleted
  recipeName <- paste0("KIStable", uuid2, ".txt")

  if (var == "TG") {
    dataSeries <- "REH1"
    unit       <- "graad C"
  } else if (var == "MOR_10") {
    dataSeries <- "TOA"
    unit       <- "m"
  } else if (var == "FF_10M_10") {
    dataSeries <- "TOW"
    unit       <- "m/s"
  } else if (var == "U_10") {
    dataSeries <- "TOT"
    unit       <- "%"
  } else if (var == "T_DEWP_10") {
    dataSeries <- "TOT"
    unit       <- "graad C"
  } else if (var == "T_DRYB_10") {
    dataSeries <- "TOT"
    unit       <- "graad C"
  } else {
    stop(paste0("Variable ", var, " not defined."))
  }

  # nolint start
  recipe <- 'recipe=' %>%
    paste0('{"datasetserieselements":[{"datasetseries":"', dataSeries, '",') %>%
    paste0('"element":"', var, '","unit":"', unit, '"}],') %>%
    paste0('"datasetseriesnames":["', dataSeries, '"],') %>%
    paste0('"datasourcecodes":["', locationID, '"],') %>%
    paste0('"intervalids":[],') %>%
    paste0('"elementgroupnames":[],') %>%
    paste0('"unitsettings":[{"unit":"', unit, '",') %>%
    paste0('"scale":"true","conversionfunction":"NONE"}],') %>%
    paste0('"starttime":"20160115_000000_000000",') %>%   # hard coded because does not effect result
    paste0('"endtime":"20160916_000000_000000",') %>%     #
    paste0('"maxresults":1000,') %>%
    paste0('"countsettings":{"count":false,"period":"DAY",') %>%
    paste0('"countconditionbyelement":[{"element":"', var, '",') %>%
    paste0('"condition":"AMOUNT","value":null}]},') %>%
    paste0('"displaysettings":{"showMetaData":false,"sort":"DateStationTime"}}') %>%
    str_replace_all('%', '%25')
  # nolint end

  writeLines(recipe, recipeName)
  return(recipeName)
}

CorrectDataFormat <- function(xtsObject) {
  format(xtsObject, "%Y%m%d_%H%M%S")
}

ExecuteKISRecipe <- function(recipeName, period) {
  parsedPeriod <- .parseISO8601(period)
  url <- "http://kisapp.knmi.nl:8080/servlet/download/table/"
  url <- paste0(url, CorrectDataFormat(parsedPeriod$first.time + 1),
                "/", CorrectDataFormat(parsedPeriod$last.time + 1),
                "/", "CSV")
  uuid <- UUIDgenerate()
  destFile <- paste0("KIStable", uuid, ".csv")

  flog.info("Start data download.")
  download.file(url, destFile, method = "wget", quiet = T,
                extra = c('--header="Content-Type:application/x-www-form-urlencoded"', # nolint
                          paste0('--post-file="', recipeName, '"')))
  flog.info("Download finished.")

  result <- tryCatch(fread(destFile),
                     warning = function(cond) {
                       message("URL caused a warning")
                       return(NULL)
                     },
                     error = function(cond) {
                       message("Download failed")
                       return(NULL)
                     },
                     finally = {
                       file.remove(recipeName)
                       file.remove(destFile)
                     })
  return(result)
}
