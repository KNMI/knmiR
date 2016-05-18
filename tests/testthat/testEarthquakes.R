library(knmiR)
context("Earthquake data")

test_that("Corrected input", {
  expect_error(Earthquakes("ind"), "Catalogue type not known.")
})


test_that("Earthquakes catalogue gives the same results", {
  quakes <- Earthquakes("induced", NULL, "1980/2015-11-15", path = NULL)
  tectonicQuakes <- Earthquakes('tectonic', path = NULL)
  expect_match(class(quakes)[1],"data.table")
  expect_true(nrow(quakes)>1210)
  expect_true(nrow(tectonicQuakes)>=1339)
  expect_equal_to_reference(quakes, file = "./referenceOutput/outputQuakes.rds", check.attributes=FALSE)
  expect_equal_to_reference(ClipQuakes(quakes, Groningen), file = "./referenceOutput/outputQuakesGroningen.rds")
})

