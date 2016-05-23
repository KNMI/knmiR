dataDescription <- list()
dataDescription$Earthquakes <- "Induced Earthquakes"
dataDescription$HomogenPrecip <- "Obtained from <a href='http://climexp.knmi.nl'>KNMI</a>

precip [mm/dy] homogenised precipitation (8-8) (extended with operational data from KNMI 2010-now)"

dataCitation <- list()
dataCitation$Earthquakes <- "Please cite me"
dataCitation$HomogenPrecip <- strwrap("Please cite as Buishand, T.A., G. DeMartino, J.N. Spreeuw en T. Brandsma, Homogeneity of precipitation series in the Netherlands and their trends in the past century")

dataLicense <- list()
dataLicense$Earthquakes <- "Open data"
dataLicense$HomogenPrecip <- strwrap('THESE DATA CAN BE USED FREELY PROVIDED THAT THE FOLLOWING SOURCE IS ACKNOWLEDGED: ROYAL NETHERLANDS METEOROLOGICAL INSTITUTE')

availableDataSets <- c("Earthquakes", "HomogenPrecip")

stationMetaData <- data.table::fread("./inst/MetaDataDefinition/stationMetaData.csv", stringsAsFactors = FALSE)
data.table::setkey(stationMetaData, stationId)

devtools::use_data(dataDescription, dataCitation, dataLicense,
                   availableDataSets, stationMetaData,
                   internal=TRUE, overwrite=TRUE)
