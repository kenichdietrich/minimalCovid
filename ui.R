library(shiny)
library(shinythemes)
library(shinyjs)
library(highcharter)
library(shinycssloaders)
library(tidyverse)

ui <- fluidPage(
    useShinyjs(),
    theme = shinytheme("paper"),
    title = titlePanel("COVID-19 minimal dashboard"),
    tags$style(HTML("
        .tabbable > .nav > li > a {width: 40vw; align-content: center;}
        
        .nav-pills {
            display: flex !important;
            justify-content: center !important;
            width: 0%;
        }
        ")),
    fluidRow(
        column(2,
               img(src='minimalCovid.png',width="100%"),
               br(),
               br(),
               br(),
               radioButtons("selectType",
                            HTML("<b>CASES</b>"),
                            choices=c("Confirmed","Deaths","Recovered"),
                            selected="Confirmed"),
               br(),
               actionButton("github_button", 
                            label="GitHub", 
                            icon=icon("github"),
                            onclick="window.open('https://github.com/kenichdietrich/minimalCovid',
                            '_blank')")
        ),
        column(10,
               wellPanel(
                   tabsetPanel(id="tabs", type="pills",
                               tabPanel("ABSOLUTE",
                                        highchartOutput("map") %>% withSpinner(type=8, color="#2196F3")
                               ),
                               tabPanel("DAILY",
                                        highchartOutput("dailymap") %>% withSpinner(type=8, color="#2196F3")
                               )
                   ),
                   style="background:white; border-radius: 20px;"
               ),
               align="center", class="flex-center"
        )
    ),
    fluidRow(column(2),
             column(10,
                    wellPanel(name="series_panel",
                              h2("Click on a country to show its time evolution",
                                 style="color:#E8E8E8", id="click_note"),
                              highchartOutput("timeseries", height="200px"),
                              style="background:white; border-radius: 20px;"
                    ), align="center"
             )
    )
)