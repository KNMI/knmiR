library(data.table)
library(knmiR)

today <- Sys.time()

context("Test obtained data")

test_that("Input queries", {
  expect_error(HomogenizedPrecipitation(10, 1923), "periodStart should be 1910 or 1951")
  expect_error(HomogenizedPrecipitation(09, 1910), "not available")
  expect_error(HomogenizedPrecipitation(09, 1951), "not available")
  expect_error(HomogenizedPrecipitation(17, 1910), "not available for periodStart 1910")
})

precipDeBilt <- HomogenizedPrecipitation(550)

context("Test HomogenPercip")

test_that("Station id output", {
  precipDeBilt <- HomogenPrecip(550, "1911/1912")
  expect_equal(precipDeBilt[1, date], as.Date("1911-01-01"))
  expect_equal(precipDeBilt[.N, date], as.Date("1912-12-31"))
  expect_equal_to_reference(precipDeBilt[1 : 10,], file = "./referenceOutput/outputDeBilt.rds")
  expect_equal_to_reference(attributes(precipDeBilt)$MetaData, "./referenceOutput/HomogenizedPrecipitationMetaData.rds")
  expect_error(HomogenPrecip(10, 1910, 1950), "whichSet should be either 1910, 1951, or 'automatic'")
  expect_error(HomogenPrecip(10, "ab", 1951), "Period should be either Numeric, timeBased or ISO-8601 style.")
  precipHollum <- HomogenPrecip(10, year(today))
  expect_equal(any(is.na(precipHollum[, stationId])), FALSE)
  expect_warning(HomogenPrecip(10, "1945/1962", 1951), "Period is restricted to 1951-01-01/1962-12-31")
  expect_error(HomogenPrecip(09, 1910), "Location should be either valid station id or spatial polygon, with non-empty intersection.")
  expect_error(HomogenPrecip(17, "1945/1962", 1910), "not available for periodStart 1910")
  expect_equal_to_reference(HomogenPrecip(17, "1951/1955")[1 : 10,], file = "./referenceOutput/outputDenBurg.rds")
  expect_equal_to_reference(HomogenPrecip(10, "1910/1920")[1 : 10,], file = "./referenceOutput/outputHollum.rds")
})

context("Area results")

test_that("Area output", {
  ValleiEnVeluwe <- readRDS("./inputData/ValleiEnVeluwe.rds")
  ValleiEnVeluweDamaged <- sp::SpatialPolygons(ValleiEnVeluwe@polygons)
  ValleiEnVeluweTransformed <- sp::spTransform(ValleiEnVeluwe, sp::CRS("+init=epsg:25831"))
  precipVallei <- HomogenPrecip(ValleiEnVeluwe, "1911/1912")
  precipVallei2 <- HomogenPrecip(ValleiEnVeluwe, "1951/1952")
  precipVallei3 <- HomogenPrecip(ValleiEnVeluwe, "1948/1952")
  expect_warning(HomogenPrecip(ValleiEnVeluwe, "1945/1962", 1951), "Period is restricted to 1951-01-01/1962-12-31")
  expect_message(HomogenPrecip(ValleiEnVeluwe, "1955/1962", 1910), "You could consider more stations for the given period.")
  expect_error(HomogenPrecip(ValleiEnVeluweDamaged, 1910), "No transformation possible from NA reference system")
  expect_equal_to_reference(precipVallei[1 : 10, ], "./referenceOutput/HomogenPrecipValleiEnVeluwe.rds")
  expect_equal_to_reference(tail(precipVallei), "./referenceOutput/HomogenPrecipValleiEnVeluweTail.rds")
  expect_equal(precipVallei[, length(unique(stationId))], 8)
  expect_equal(precipVallei2[, length(unique(stationId))], 21)
  expect_equal(precipVallei3[, length(unique(stationId))], 8)
  expect_equal(precipVallei[1, date], as.Date("1911-01-01"))
  expect_equal(precipVallei[.N, date], as.Date("1912-12-31"))
  expect_equal_to_reference(HomogenPrecip(ValleiEnVeluweTransformed, "1911/1912")[1 : 10, ], "./referenceOutput/HomogenPrecipValleiEnVeluwe.rds")
})
