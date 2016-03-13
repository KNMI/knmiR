library(knmiR)

context("Test obtained data")

test_that("Input queries", {
  expect_error(HomogenizedPrecipitation(10, 1923), "periodStart should be 1910 or 1951")
  expect_error(HomogenizedPrecipitation(09, 1910), "not available")
  expect_error(HomogenizedPrecipitation(09, 1951), "not available")
  expect_error(HomogenizedPrecipitation(17, 1910), "not available for periodStart 1910")
})

test_that("Output is the same", {
  expect_equal_to_reference(HomogenizedPrecipitation(10)[1 : 10,], file = "./referenceOutput/outputHollum.rds")
  expect_equal_to_reference(HomogenizedPrecipitation(550)[1 : 10,], file = "./referenceOutput/outputDeBilt.rds")
  expect_equal_to_reference(HomogenizedPrecipitation(17, 1951)[1 : 10,], file = "./referenceOutput/outputDenBurg.rds")
})
