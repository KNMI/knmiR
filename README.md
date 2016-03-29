# knmiR

A package to access KNMI data from within R.

## Homogenized precipitation data
To use this data please cite [Buishand et al. (2013): Homogeneity of precipitation series in the Netherlands and their trends in the past century](http://onlinelibrary.wiley.com/doi/10.1002/joc.3471/abstract)

`HomogenizedPrecipitation(550)` obtains the homogenized preciptiation data for the station with stationId 550. The available stations are reported in the data.frame stationMetaData. From this we can see that stationId 550 belongs to De Bilt. 
