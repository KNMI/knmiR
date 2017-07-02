#' Extract data from KIS
#' @param var Variable to extract for now 'TG' and 'MOR_10' are allowed (plural?)
#' @param geoIdentifier Station identifier (, spatial point, spatial area ..., plural?)
#' @param period Either numeric, timeBased or ISO-8601 style (see \code{\link[xts]{.subset.xts}})
#' @return data.table
#' @export
#' @examples
#' \dontrun{
#'  KIS('TG', '260_H', '2016')
#'  KIS('MOR_10', '260_A_a', '2016-02-01')
#' }
KIS <- function(var, geoIdentifier, period) {
  InternalOnly()
  flog.debug("Started downloading data from KIS")
  flog.debug("var={%s}", paste(var))
  flog.debug("geoIdentifier has name={%s} and class={%s}",
             paste(substitute(geoIdentifier)),
             paste(class(geoIdentifier)[1]))
  flog.debug("period={%s}", paste(period))
  assertChoice(var, c("TG", "MOR_10"))
  if (var == "TG") {
    assertChoice(geoIdentifier, c("260_H", "310_H"))
  }
  if (var == "MOR_10") {
    assertChoice(geoIdentifier, c("260_A_a", "290_A_a"))
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

  # FIXME: Ensure that the recipe file is deleted
  recipeName <- "KIStable.txt"

  if (var == "TG") {
    dataSeries <- "REH1"
    unit       <- "graad C"
  } else if (var == "MOR_10") {
    dataSeries <- "TOA"
    unit       <- "m"
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
  destFile <- "KIStable.csv"

  flog.info("Start data download.")
  download.file(url, destFile, method = "wget", quiet = T,
                extra = c('--header="Content-Type:application/x-www-form-urlencoded"',
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
