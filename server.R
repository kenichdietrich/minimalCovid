library(shiny)
library(shinythemes)
library(shinyjs)
library(highcharter)
library(shinycssloaders)
library(tidyverse)

load("geodata_world.RData")
load("covid_data.RData")
load("maps.RData")

colors <- list("Confirmed"=c("#2196F3"), "Deaths"=c("#B41B1B"), 
               "Recovered"=c("#27A413"),
               "DayConfirmed"=c("#2196F3"), "DayDeaths"=c("#B41B1B"), 
               "DayRecovered"=c("#27A413"))

# Check if the data are updated. If not, it runs the required scripts to
# get data and maps. Unfortunately, one of the visitors will have to wait
# the data processing :(

#if (as.numeric(Sys.Date() - lastDate) > 1){
#    source("get_covid_data.R")
#    source("get_maps.R")
#    load("geodata_world.RData")
#    load("covid_data.RData")
#}

server <- function(input, output, session){
    
    output$map <- renderHighchart(
        switch(input$selectType,
               "Confirmed"=confirmedMap,
               "Deaths"=deathsMap,
               "Recovered"=recoveredMap)
    )
    output$dailymap <- renderHighchart(
        switch(input$selectType,
               "Confirmed"=DayconfirmedMap,
               "Deaths"=DaydeathsMap,
               "Recovered"=DayrecoveredMap)
    )
    
    observe({
        shinyjs::hide("timeseries")
        
        if(!is.null(input$geo_click)){
            shinyjs::hide("click_note")
            shinyjs::show("timeseries")
        }
    })
    
    observeEvent(input$selectType,{
        shinyjs::hide("timeseries")
        shinyjs::show("click_note")
    })
    
    observeEvent(input$tabs,{
        shinyjs::hide("timeseries")
        shinyjs::show("click_note")
    })
    
    whichData <- reactive({c(ifelse(input$tabs=="ABSOLUTE",
                                    input$selectType,
                                    paste0("Day",input$selectType)),
                             ifelse(input$tabs=="ABSOLUTE",
                                    input$selectType,
                                    paste0("Daily ",input$selectType))
    )
    })
    countryData <- reactive({
        allData %>% filter(Keyname==input$geo_click) %>%
            select(x="Date", y=whichData()[1])
    })
    observeEvent(input$geo_click,{print(whichData())})
    
    output$timeseries <- renderHighchart({
        
        hchart(countryData(), "area", hcaes(x=x, y=y), 
               color=colors[[whichData()[1]]], name=whichData()[1]) %>%
            hc_yAxis(
                title = list(text=""),
                gridLineWidth = 0
            ) %>%
            hc_xAxis(
                title = NULL,
                gridLineWidth = 0
            ) %>%
            hc_title(
                text = paste0(whichData()[2], " in ", input$geo_click)
            )
    }
    )
}