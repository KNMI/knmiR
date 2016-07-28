recipe = 'recipe={"datasetserieselements":[{"datasetseries":"TOA","element":"MOR_10","unit":"m"}],"datasetseriesnames":["TOA"],"datasourcecodes":["260_A_a"],"intervalids":[],"elementgroupnames":[],"unitsettings":[{"unit":"m","scale":"true","conversionfunction":"NONE"}],"starttime":"20160722_000000_000000","endtime":"20160728_000000_000000","maxresults":100,"countsettings":{"count":false,"period":"DAY","countconditionbyelement":[{"element":"MOR_10","condition":"AMOUNT","value":null}]},"displaysettings":{"showMetaData":false,"sort":"DateStationTime"}}'

KIS <- function(variable, geoLoc, period) {
  recipeFileName <- paste0("tmp", timeStamp, ".in")
  localFileName  <- paste0("tmp", timeStamp, ".csv")
  on.exit(file.remove(c(localFileName, recipeFileName)))

  recipe    <- 'recipe={"datasetserieselements":[{"datasetseries":"TOA","element":"MOR_10","unit":"m"}],"datasetseriesnames":["TOA"],"datasourcecodes":["260_A_a"],"intervalids":[],"elementgroupnames":[],"unitsettings":[{"unit":"m","scale":"true","conversionfunction":"NONE"}],"starttime":"20160722_000000_000000","endtime":"20160728_000000_000000","maxresults":100,"countsettings":{"count":false,"period":"DAY","countconditionbyelement":[{"element":"MOR_10","condition":"AMOUNT","value":null}]},"displaysettings":{"showMetaData":false,"sort":"DateStationTime"}}'
  timeStamp <- timestamp(stamp=format(Sys.time(), "%Y%m%d_%H%M%S"),
                         prefix="-", suffix="", quiet=TRUE)
  write(recipe, recipeFileName)
  download.file("http://kisapp.knmi.nl:8080/servlet/download/table/20100703_000001/20100703_240000/CSV",
                localFileName,
                method = "wget",
                extra = paste0("--header=Content-Type:application/x-www-form-urlencoded",
                               " --post-file=", recipeFileName))
  fread(localFileName)
}

