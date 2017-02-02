library(futile.logger)
flog.threshold(DEBUG)
flog.appender(appender.file('DutchClimate.log'))

context("KIS data extraction")

node <- Sys.info()["nodename"]

test_that("Obtain temperature", {
  skip_on_travis()
  skip_if_not(grepl("knmi.nl", node))
  expect_match(WriteKISRecipe('TG', '260_H', '2016'), 'KIStable.txt')
  expect_error(KIS('rr', '260_H', '2016'), "Must be element of set {'TG','MOR_10'}.", fixed = TRUE)
  result <- KIS('TG', '260_H', '2016-08/2016-09')
  expect_equal_to_reference(result, file = "testOutput/temperatureDeBilt.rds")
  result <- KIS('TG', '310_H', '2016-08/2016-09')
  expect_equal_to_reference(result, file = "testOutput/temperatureVlissingen.rds")
})

test_that("Obtain MOR_10", {
  skip_on_travis()
  skip_if_not(grepl("knmi.nl", node))
  result <- KIS('MOR_10', '260_A_a', '2016-11-10')
  expect_equal_to_reference(result, file = "testOutput/MOR_10_DeBilt.rds")
})

test_that("Get error outside", {
  skip_if_not(!grepl("knmi.nl", node))
  expect_error(KIS('TG', '260_H', '2016'), "function works only inside KNMI", fixed = TRUE)
})
