library(shiny)
library(rgdal)
library(raster)
library(dplyr)
library(leaflet)
library(RColorBrewer)
library(sp)

############################################################

shinyUI(fluidPage(
  
  # Title
  titlePanel("Satellite and UK AIR data (England and Wales)"),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput("type", "Chose layer type",
                  c("Local Authorities Means" = "OGR", "raster")),

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
                                                         "PM2.5 CTM cmaq model" = "PM25_cmaq_tif")))
        ),
   
    # Show leaflet map with a text div reporting the selected date and extents 
    mainPanel(
      leafletOutput('myMap', height = 500, width = 800)
    )
    
  )
))
