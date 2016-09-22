library(shiny)
library(rgdal)
library(raster)
library(dplyr)
library(leaflet)
library(RColorBrewer)
library(sp)
library(shinydashboard)

############################################################


jscode <- "shinyjs.refresh = function() { history.go(0); }"
    
    ui <- dashboardPage(skin = "blue",
                        dashboardHeader (title = "Satellite and UK AIR data (England and Wales)"),
                      
                        dashboardSidebar(
                          width = 290,
                          paste("Time:",Sys.time()),
                          sidebarMenu(

                            
               selectInput("type", "Aggregates/Gridded ",                  
                           c("Aggregated data" = "OGR", "Gridded data" = "raster")),
               conditionalPanel(
                 condition = "input.type == 'OGR'",
                 selectInput("variable_OGR", "Choose layer", c("PM2.5 satellite MODIS" = "pm25_mean",
                                                               "PM2.5 UK-AIR" = "pm25_mean_UK_AIR",
                                                               "PM2.5 GWR Donkelaar et al." = "pm25_mean_AVG_GWR",
                                                               "PM2.5 modeled data (pcm)" = "pm25_mean_pcm",
                                                               "PM2.5 CTM cmaq model" = "pm25_mean_cmaq"))),
               
               conditionalPanel(
                 condition = "input.type == 'raster'",
                 selectInput("variable_raster", "Choose layer", c("PM2.5 satellite MODIS (10km)" = "PM25_SAT_tif",
                                                                  "PM2.5 UK-AIR" = "PM25_UK_AIR_tif",
                                                                  "PM2.5 GWR 1km (MODIS)" = "PM25_GWR_tif",
                                                                  "PM2.5 modeled data (pcm)" = "PM25_pcm_tif",
                                                                  "PM2.5 CTM cmaq model" = "PM25_cmaq_tif"))),
    
      
      menuItem("Map", tabName = "MAP", icon = icon("th"))
    
    )),
    
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
      # First tab content
      tabItem(tabName = "MAP",
              fluidRow(
                tabBox(
                  height = 750, width = 950, selected = tags$b("Interactive map"),
                  tabPanel(
                    tags$b("Interactive map"),leafletOutput('myMap', height = 650, width = 750)
                  )
                )
              ))
      
    

  ))
)

