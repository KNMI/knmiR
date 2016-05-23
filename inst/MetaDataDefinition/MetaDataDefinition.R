dataDescription <- list()
dataDescription$Earthquakes <- "Induced Earthquakes"

dataCitation <- list()
dataCitation$Earthquakes <- "Please cite me"

dataLicense <- list()
dataLicense$Earthquakes <- "Open data"

availableDataSets <- "Earthquakes"

devtools::use_data(stationMetaData, dataDescription, dataCitation, dataLicense,
                   availableDataSets,
                   internal=TRUE, overwrite=TRUE)
