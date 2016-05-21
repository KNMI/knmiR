library(data.table)
library(knmiR)

context("Sources should be up to date")

test_that("License", {
  expect_match(DataLicense("test"), "This is license for data set.")
})

today <- as.Date(Sys.time())

test_that("Actuality", {
  expect_gt(HomogenPrecip(10, paste0(today-45, "/", today), path = NULL)[, .N], 0)
  expect_gt(Earthquakes("induced", NULL, paste0(today-14, "/", today), path=NULL)[, .N], 0)
})

test_that("Can the data be correctly read", {
  savedQuakes <- Earthquakes("induced", NULL, "2016-04-01/2016-05-18", path = "./inputData/")
  savedRain   <- HomogenPrecip(10, "2016-04-01/2016-05-18", path = "./inputData/")
  expect_equal(attributes(savedQuakes)$DownloadMetaData, "Downloaded by roth on pc150395.knmi.nl at 2016-05-18 11:40:06")
  expect_equal(attributes(savedRain)$DownloadMetaData, "Downloaded by roth on pc150395.knmi.nl at 2016-05-18 11:40:06")
})
