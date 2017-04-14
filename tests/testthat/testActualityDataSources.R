library(data.table)
library(knmiR)

context("Sources should be up to date")

today <- as.Date(Sys.time())

test_that("Actuality", {
  skip_on_travis()
  skip_on_appveyor()
  expect_gt(HomogenPrecip(11, paste0(today-365, "/", today), path = NULL)[, .N], 0)
  recentQuakes <- Earthquakes("induced", NULL, paste0(today-14, "/", today), path=NULL)
  expect_gt(recentQuakes[, .N], 0)
  expect_match(License(recentQuakes), "Open data")
})

