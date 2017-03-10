context("EOBS")

library(knmiR)
adm0 <- raster::getData('GADM', country='NL', level=0)
context("Input testing:")

expect_error(EOBS("foo"), "Variable foo not known.")
expect_error(EOBS('tg', 'A', "foo"), "Period should be either Numeric, timeBased or ISO-8601 style.")
expect_error(EOBS('tg', '2014', "foo"), "Area should be of class SpatialPolygons or SpatialPolygonsDataFrame.")
expect_error(EOBS('tg', '2014', adm0, "foo"), "Grid should be specified correctly.")

context("Output testing:")
expect_equal_to_reference(EOBS('tg', '2014', adm0, '0.50reg'), file="EOBSreference/output.rds")
expect_equal_to_reference(EOBS('rr', '2014', adm0, '0.50reg'), file="EOBSreference/output_rr.rds")
expect_equal_to_reference(EOBS("tg", "2015-06-01", adm0, grid = "0.50reg"),
                          file = "EOBSreference/output_one_timestep.rds")
expect_equal_to_reference(EOBSLocal("tg", "tg_0.50deg_reg_v12.0_plus_2015_ANN_avg.nc",
                                          "2000/2015", adm0),
                          file = "EOBSreference/output_local.rds")
