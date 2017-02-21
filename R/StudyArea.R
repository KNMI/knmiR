#' Create study area sp from coordinates
#'
#' @param coords coordinate matrix row point, first col lon, second col lat
#' @param bbox boolean specifying wether a SpatialPolygon representing the bbox
#'   of the coordinates should be returned
#' @return SpatialPolygons object
#' @export
StudyArea <- function(coords, bbox = FALSE) {

  if (bbox) {

    xmin <- min(coords[, 1])
    xmax <- max(coords[, 1])
    ymin <- min(coords[, 2])
    ymax <- max(coords[, 2])

    coords <- rbind(c(xmin, ymin),
                    c(xmin, ymax),
                    c(xmax, ymax),
                    c(xmax, ymin))
  }


  boundingBoxC <- Polygon(coords)
  boundingBoxC <- list(boundingBoxC)
  boundingBoxC <- Polygons(boundingBoxC, "B")
  boundingBoxC <- list(boundingBoxC)
  SpatialPolygons(boundingBoxC, proj4string = CRS("+proj=longlat +datum=WGS84"))
}

