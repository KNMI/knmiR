library(knmiR)

context("File handling")

test_that("Correct reading", {
  quakes <- Earthquakes("induced", period = "2015", path = "./inputData/")
  expect_equal_to_reference(MetaData(quakes),
                            file = "./referenceOutput/correctReadingQuakes.rds")
  precipDeBilt <- HomogenPrecip(550, "1911/1912", path = "./inputData/")
  expect_equal_to_reference(MetaData(precipDeBilt),
                            file = "./referenceOutput/correctReadingPrecip.rds")
})
