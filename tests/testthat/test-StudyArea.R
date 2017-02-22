context("StudyArea")

test_that("reference ", {
  coords <- structure(c(3.2, 5, 8.45, 9.65, 11.25, 9, 6.75, 6.5, 5.65, 5,
                        4.45, 4.15, 51.2, 55, 55.1, 54.9, 54.5, 52, 51.25,
                        50.75, 50.75, 51.35, 51.35, 51.2),
                      .Dim = c(12L, 2L))
  expect_true(rgeos::gEqualsExact(StudyArea(coords),
                           readRDS("./referenceOutput/StudyArea.rds")))
  expect_true(rgeos::gEqualsExact(StudyArea(coords, bbox = TRUE),
                           readRDS("./referenceOutput/StudyAreaBbox.rds")))
})
