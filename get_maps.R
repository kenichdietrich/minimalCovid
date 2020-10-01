library(highcharter)
library(tidyverse)

load("geodata_world.RData")
load("covid_data.RData")

lastDate <- as.character(lastDate)

# Pre-made maps

makeMap <- function(data, cases, color=NA, day){
    data <- switch(cases,
                   "Confirmed"=allData %>% select(Key:Date,Confirmed) %>% 
                       spread(key="Date", value="Confirmed"),
                   "Deaths"=allData %>% select(Key:Date,Deaths) %>% 
                       spread(key="Date", value="Deaths"),
                   "Recovered"=allData %>% select(Key:Date,Recovered) %>% 
                       spread(key="Date", value="Recovered"),
                   "DayConfirmed"=allData %>% select(Key:Date,DayConfirmed) %>% 
                       spread(key="Date", value="DayConfirmed"),
                   "DayDeaths"=allData %>% select(Key:Date,DayDeaths) %>% 
                       spread(key="Date", value="DayDeaths"),
                   "DayRecovered"=allData %>% select(Key:Date,DayRecovered) %>% 
                       spread(key="Date", value="DayRecovered")
    )  
    
    map <- highchart(type="map") %>%
        hc_add_series_map(map=geodata, df=data, 
                          name=cases,
                          value=day,
                          joinBy=c("hc-key","Key"),
                          borderColor = "#FAFAFA",
                          borderWidth = 0.2) %>%
        hc_colorAxis(
            minColor="#e6ebf5",
            maxColor=color) %>%
        hc_plotOptions(series = list(allowPointSelect = TRUE, 
                                     events = list(click = htmlwidgets::JS(
                                         "function(event) {
                                                     Shiny.setInputValue(
                                                       'geo_click', 
                                                       event.point.name, 
                                                       {priority: 'event'}
                                                     );
                                                  }"
                                     )))) %>%
        hc_title(text=paste0("<b>",lastDate,"</b>"),
                 verticalAlign="bottom",
                 margin=0,
                 align="left",
                 floating=T,
                 useHTML=T)
    
    return(map)
}

confirmedMap <- makeMap(allData, "Confirmed", "#2196F3", lastDate)
deathsMap <- makeMap(allData, "Deaths", "#B41B1B", lastDate)
recoveredMap <- makeMap(allData, "Recovered", "#27A413", lastDate)
DayconfirmedMap <- makeMap(allData, "DayConfirmed", "#2196F3", lastDate)
DaydeathsMap <- makeMap(allData, "DayDeaths", "#B41B1B", lastDate)
DayrecoveredMap <- makeMap(allData, "DayRecovered", "#27A413", lastDate)

save(list=c("confirmedMap", "deathsMap", "recoveredMap", 
            "DayconfirmedMap", "DaydeathsMap", "DayrecoveredMap"),
     file="maps.RData")

rm(list=ls())



   