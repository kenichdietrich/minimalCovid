################################################################
## Script to generate the geodata from highcharts repository: ##
## https://code.highcharts.com/mapdata/                       ##
################################################################

library(highcharter)
library(jsonlite)
library(geojsonio)

# We download a high-resolution Miller-proj world map
geodata <- download_map_data("custom/world-highres")

# The object stored in geodata is a list, i.e., an R representation of
# the geojson file. We can coerce this object to a json class

geodata.json <- as.json(geodata)

# And save it to a json/geojson file
write(geodata.json, "geodata_world.json")

# To load data into R, we simply read this file by using fromJSON
# function (jsonlite library) taking care that simplifyVector is
# set to FALSE

# In addition, we can also save the geodata object directly in a 
# .RData file
save(geodata, file="geodata_world.RData")

# This is even more suitable, because the .RData file takes less
# memory than the saved geojson file

# Finally, we save the geodata info in a csv file
geoinfo <- get_data_from_map(geodata)
write.csv(geoinfo, file="geoinfo.csv", row.names=F)
