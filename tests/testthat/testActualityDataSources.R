library(data.table)
library(knmiR)

context("Sources should be up to date")

today <- as.Date(Sys.time())

test_that("Actuality", {
  expect_gt(HomogenPrecip(10, paste0(today-45, "/", today), path = NULL)[, .N], 0)
  recentQuakes <- Earthquakes("induced", NULL, paste0(today-14, "/", today), path=NULL)
  expect_gt(recentQuakes[, .N], 0)
  expect_match(License(recentQuakes), "Open data")
})

