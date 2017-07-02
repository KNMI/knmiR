library(data.table)
library(knmiR)

today <- Sys.time()

# context("EOBS - Transition to WCS")
# test_that("WCS gives the same output", {
#   expect_equal_to_reference(EOBS("tg", 1, 2, 3, 4),
#                             file = "./referenceOutput/initialEOBS.rds")
# })

context("Homogenized precipitation data")

test_that("Input queries", {
  expect_error(HomogenizedPrecipitation(10, 1923),
      "periodStart should be 1910 or 1951")
  expect_error(HomogenizedPrecipitation(09, 1910), "not available")
  expect_error(HomogenizedPrecipitation(09, 1951), "not available")
  expect_error(HomogenizedPrecipitation(17, 1910),
      "not available for periodStart 1910")
})


test_that("Station id output", {
  precipDeBilt <- HomogenPrecip(550, "1911/1912", path = NULL)
  expect_equal(precipDeBilt[1, date], as.Date("1911-01-01"))
  expect_equal(precipDeBilt[.N, date], as.Date("1912-12-31"))
  expect_equal_to_reference(precipDeBilt[1 : 10, ],
                            file = "./referenceOutput/outputDeBilt.rds",
                            check.attributes = FALSE)
  expect_equal_to_reference(License(precipDeBilt),
      "./referenceOutput/HomogenizedPrecipitationLicense.rds")
  expect_true(is.call(Call(precipDeBilt)))
  expect_error(HomogenPrecip(10, 1910, 1950),
      "whichSet should be either 1910, 1951, or 'automatic'")
  expect_error(HomogenPrecip(10, "ab", 1951),
      "Period should be either Numeric, timeBased or ISO-8601 style.")
  precipHollum <- HomogenPrecip(10, year(today), path = NULL)
  expect_equal(any(is.na(precipHollum[, stationId])), FALSE)
  expect_warning(HomogenPrecip(10, "1945/1962", 1951, path = NULL),
      "Period is restricted to 1951-01-01/1962-12-31")
  expect_error(HomogenPrecip(09, 1910),
      "Location should be either valid station id or spatial polygon, with non-empty intersection.") # nolint
  expect_error(HomogenPrecip(17, "1945/1962", 1910),
      "not available for periodStart 1910")
  expect_equal_to_reference(HomogenPrecip(17, "1951/1955",
                            path = NULL)[1 : 10, ],
                            file = "./referenceOutput/outputDenBurg.rds",
                            check.attributes = FALSE)
  expect_equal_to_reference(HomogenPrecip(10, "1910/1920",
                            path = NULL)[1 : 10, ],
                            file = "./referenceOutput/outputHollum.rds",
                            check.attributes = FALSE)
})

context("Area results")

test_that("Area output", {
  ValleiEnVeluwe <- readRDS("./inputData/ValleiEnVeluwe.rds")
  ValleiEnVeluweDamaged <- sp::SpatialPolygons(ValleiEnVeluwe@polygons)
  ValleiEnVeluweTransformed <- sp::spTransform(ValleiEnVeluwe,
                                               sp::CRS("+init=epsg:25831"))
  precipVallei <- HomogenPrecip(ValleiEnVeluwe, "1911/1912", path = NULL)
  precipVallei2 <- HomogenPrecip(ValleiEnVeluwe, "1951/1952", path = NULL)
  precipVallei3 <- HomogenPrecip(ValleiEnVeluwe, "1948/1952", path = NULL)
  expect_warning(HomogenPrecip(ValleiEnVeluwe, "1945/1962", 1951, path = NULL),
      "Period is restricted to 1951-01-01/1962-12-31")
  expect_message(HomogenPrecip(ValleiEnVeluwe, "1955/1962", 1910, path = NULL),
      "You could consider more stations for the given period.")
  expect_error(HomogenPrecip(ValleiEnVeluweDamaged, 1910),
      "No transformation possible from NA reference system")
  expect_equal_to_reference(precipVallei[1 : 10, ],
      file = "./referenceOutput/HomogenPrecipValleiEnVeluwe.rds",
      check.attributes = FALSE)
  expect_equal_to_reference(tail(precipVallei),
      file = "./referenceOutput/HomogenPrecipValleiEnVeluweTail.rds",
      check.attributes = FALSE)
  expect_equal(precipVallei[, length(unique(stationId))], 8)
  expect_equal(precipVallei2[, length(unique(stationId))], 21)
  expect_equal(precipVallei3[, length(unique(stationId))], 8)
  expect_equal(precipVallei[1, date], as.Date("1911-01-01"))
  expect_equal(precipVallei[.N, date], as.Date("1912-12-31"))
  expect_equal_to_reference(HomogenPrecip(ValleiEnVeluweTransformed,
      "1911/1912", path = NULL)[1 : 10, ],
      file = "./referenceOutput/HomogenPrecipValleiEnVeluwe.rds",
      check.attributes = FALSE)
})
