library(data.table)
library(knmiR)

context("Sources should be up to date")

today <- as.Date(Sys.time())

test_that("Acutality", {
  expect_gt(HomogenPrecip(10, paste0(today-45, "/", today))[, .N], 0)
  expect_gt(Earthquakes("induced", NULL, paste0(today-14, "/", today))[, .N], 0)
})
