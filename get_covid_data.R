############################################
## Script to get and clean the covid data ##
############################################

library(tidyverse)

# Data URLs. The data is downloaded from the GitHub repository created by
# the Johns Hopkins University

root <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/"
confirmed.URL <- paste0(root,"time_series_covid19_confirmed_global.csv")
deaths.URL <- paste0(root,"time_series_covid19_deaths_global.csv")
recovered.URL <- paste0(root,"time_series_covid19_recovered_global.csv")

# Read data
confirmed <- read.csv(confirmed.URL)
deaths <- read.csv(deaths.URL)
recovered <- read.csv(recovered.URL)

# Info from geodata
geoinfo <- read.csv("geoinfo.csv")
# Keys to link data and geospatial elements
keys <- geoinfo %>% select(hc.key, name) %>% rename(Key="hc.key", Keyname="name")

## Functions to clean and arrange covid data
clean.and.gather <- function(data, name){
    spread.cols <- names(data)[5:ncol(data)]
    newdata <- data %>% 
        rename(Country=Country.Region) %>%
        select(-c(Province.State,Lat,Long)) %>%
        group_by(Country) %>% summarise_all(funs(sum)) %>%
        gather_(key="Date", value=name, spread.cols)
    newdata$Date <- as.Date(str_remove(newdata$Date,"X"), format="%m.%d.%y")
    return(newdata)
}
# This one creates daily data from the cumulative ones
daily.clean.and.gather <- function(data, name){
    # Select columns of cumulative cases
    spread.cols <- names(data)[5:ncol(data)]
    # Rename, remove vars and gather country data
    newdata <- data %>% 
        rename(Country=Country.Region) %>%
        select(-c(Province.State,Lat,Long)) %>%
        group_by(Country) %>% summarise_all(funs(sum))
    # Select cumulative data and compute differences to get daily cases
    cum.data <- newdata[spread.cols]
    newdata[, spread.cols] <- cbind(cum.data[,1],t(apply(cum.data,1,diff)))
    # Gather dataframe and coerce date col to Date type
    newdata <- newdata %>% gather_(key="Date", value=name, spread.cols)
    newdata$Date <- as.Date(str_remove(newdata$Date,"X"), format="%m.%d.%y")
    return(newdata)
}

# Code to create a dictionary to link data and keys
countries <- unique(confirmed$Country.Region)

matched.countries <- countries[countries %in% keys$Keyname]
non.matched.countries <- countries[!(countries %in% keys$Keyname)]

good.names <- c("The Bahamas", "Myanmar", "Cape Verde", "Republic of Congo",
                "Democratic Republic of the Congo", "Ivory Coast", "Czech Republic",
                NA, "Swaziland", "Guines Bissau", "Vatican", "South Korea", NA,
                "Macedonia", "Republic of Serbia", "Taiwan", "United Republic of Tanzania",
                "East Timor","United States of America", NA)

matching <- data.frame(Bad.name = c(non.matched.countries, matched.countries),
                       Keyname = c(good.names, matched.countries))
matching <- matching[!is.na(matching$Keyname),] # matching is our dictionary
# Remove no longer useful data
rm(list=c("countries", "matched.countries", "non.matched.countries", "good.names"))

# Gather all (and new) data in a tidy dataframe. There are confirmed, deaths
# and recovered cases available, we compute active cases from these and get
# new data concerning daily cases
allData <- clean.and.gather(confirmed, "Confirmed") %>% 
    left_join(clean.and.gather(deaths, "Deaths"), 
              by=c("Country","Date")) %>% 
    left_join(clean.and.gather(recovered, "Recovered"), 
              by=c("Country","Date")) %>% 
    mutate(Active=Confirmed-Deaths-Recovered) %>% 
    left_join(daily.clean.and.gather(confirmed, "DayConfirmed"), 
              by=c("Country","Date")) %>%
    left_join(daily.clean.and.gather(deaths, "DayDeaths"), 
              by=c("Country","Date")) %>%
    left_join(daily.clean.and.gather(recovered, "DayRecovered"), 
              by=c("Country","Date")) %>% 
    left_join(matching, by=c("Country"="Bad.name")) %>%
    relocate(Keyname, .after=Country)

allData <- keys %>% left_join(allData, by="Keyname")

# Save the date of the last data
lastDate <- max(allData$Date,na.rm=T)

# Save data in a .RData file
save(list=c("allData","lastDate"), file="covid_data.RData")

rm(list=ls())


