context("Earthquake data")

test_that("Corrected input", {
  expect_error(Earthquakes("ind"), "Catalogue type not known.")
})


quakes <- Earthquakes("induced", NULL, "1980/2015-11-15")
#quakes <- quakes[ date <= "2015-11-15"]
tectonicQuakes <- Earthquakes('tectonic')


test_that("Output type of LoadKnmiEarthquakeCatalogue is data.table:", {
  expect_match(class(quakes)[1],"data.table")
})

test_that("Catalogues have at least the same number of entries as on 2015-11-13:", {
  expect_true(nrow(quakes)>1210)
  expect_true(nrow(tectonicQuakes)>=1339)
})

test_that("Catalogue output", {
  expect_equal_to_reference(quakes, file = "./referenceOutput/outputQuakes.rds")
  expect_equal_to_reference(ClipQuakes(quakes, Groningen), file = "./referenceOutput/outputQuakesGroningen.rds")
})
