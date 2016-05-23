#' Generate a KNMI data object
#'
#' @description The creation of the same data should be facilitated by the
#'  storage of call, knmiR package version and timeStamp
#'
#' @param data The raw data (can be different objects)
#' @param call Call object describing the creation of the data
#' @param type String describing what kind of data set
#'
#' @return An augmentated data object
#'
#' @export
KnmiData <- function(data, call, type) {
  stopifnot(type %in% availableDataSets)
  structure(data,
            call        = call,
            description = dataDescription[[type]],
            license     = dataLicense[[type]],
            citation    = dataCitation[[type]],
            version     = utils::packageVersion("knmiR"),
            timeStamp   = utils::timestamp(format(Sys.time(),
                                                  "%Y-%m-%d %H:%M:%S"),
                                           quiet=TRUE),
            class       = append("KnmiData", class(data)))
}

KnmiDataInformation <- function(x, attribute, objectName) {
  if (!is.null(attr(x, attribute))) {
    attr(x, attribute)
  } else {
    warning(paste(objectName, "was modified before. No", attribute,
                  "available."))
  }
}

KnmiDataDefault <- function(x, method) {
  warning(paste(method, "not defined for class", class(x)[1]))
}

#' Information about KnmiData object
#' @name getInformation
#' @param x KnmiData object
#' @param ... Additional parameters (deprecated)
#' @examples
#' data <- Earthquakes("induced", NULL, "2016-04-01/2016-05-18", path = NULL)
#' Call(data)
#' Description(data)
#' License(data)
#' Citation(data)
#' MetaData(data)
NULL

#' @rdname getInformation
#' @export
Call <- function(x, ...) {
  UseMethod("Call")
}

#' @export
Call.KnmiData <- function(x, ...) {
  KnmiDataInformation(x, "call", deparse(substitute(x)))
}

#' @rdname getInformation
#' @export
Call.default <- function(x, ...) KnmiDataDefault(x, "Call")

#' @rdname getInformation
#' @export
Description <- function(x, ...) {
  UseMethod("Description")
}

#' @export
Description.KnmiData <- function(x, ...) {
  KnmiDataInformation(x, "description", deparse(substitute(x)))
}

#' @export
Description.default <- function(x, ...) KnmiDataDefault(x, "Description")

#' @rdname getInformation
#' @export
License <- function(x, ...) {
  UseMethod("License")
}

#' @export
License.KnmiData <- function(x, ...) {
  KnmiDataInformation(x, "license", deparse(substitute(x)))
}

#' @export
License.default <- function(x, ...) KnmiDataDefault(x, "License")

#' @rdname getInformation
#' @export
Citation <- function(x, ...) {
  UseMethod("Citation")
}

#' @export
Citation.KnmiData <- function(x, ...) {
  KnmiDataInformation(x, "citation", deparse(substitute(x)))
}

#' @export
Citation.default <- function(x, ...) KnmiDataDefault(x, "Citation")

#' @rdname getInformation
#' @export
MetaData <- function(x, ...) {
  UseMethod("MetaData")
}

#' @export
MetaData.KnmiData <- function(x, ...) {
  if (!is.null(attr(x, "version"))) {
    paste0("Downloaded via knmiR package version: ",
                      attr(x, "version"), " on\n",
                      attr(x, "timeStamp"))
  } else {
    warning(paste(deparse(substitute(x)),
                  "was modified before. No metadata available."))
  }
}

#' @export
MetaData.default <- function(x, ...) KnmiDataDefault(x, "MetaData")
