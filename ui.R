library(shiny)
library(rgdal)
library(raster)
library(dplyr)
library(leaflet)
library(RColorBrewer)
library(sp)
library(shinydashboard)

############################################################



shinyUI(
  dashboardPage( skin = "blue", 
    dashboardHeader(title = "Satellite and UK AIR data (England and Wales)"),
    
    dashboardSidebar(sidebarMenu(
      menuItem("Dashboard", tabName = "Pollutants", icon = icon("dashboard")
      ),
      menuItem("Gridded/Aggregated", tabName = "type", icon = icon("th"),
                selectInput("type", " ",                  # "Gridded/Aggregated",
                            c("Local Authorities Means" = "OGR", "Gridded (10km/1km)" = "raster"))       
               )
    )),
    
  
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "Pollutants",
              fluidRow(
                box(height = 80, width = 8,
#                      selectInput("type", "Gridded/Aggregated",
#                                  c("Local Authorities Means" = "OGR", "raster")),
                     
                     conditionalPanel(
                       condition = "input.type == 'OGR'",
                       selectInput("variable_OGR", "Data Output", c("PM2.5 satellite MODIS" = "pm25_mean",
                                                                     "PM2.5 UK-AIR" = "pm25_mean_UK_AIR",
                                                                     "PM2.5 GWR Donkelaar et al." = "pm25_mean_AVG_GWR",
                                                                     "PM2.5 modeled data (pcm)" = "pm25_mean_pcm",
                                                                    "PM2.5 CTM cmaq model" = "pm25_mean_cmaq"))),


                     
                     conditionalPanel(
                       condition = "input.type == 'raster'",
                       selectInput("variable_raster", "Data Output", c("PM2.5 satellite MODIS (10km)" = "PM25_SAT_tif",
                                                                        "PM2.5 UK-AIR" = "PM25_UK_AIR_tif",
                                                                        "PM2.5 GWR 1km (MODIS)" = "PM25_GWR_tif",
                                                                        "PM2.5 modeled data (pcm)" = "PM25_pcm_tif")))
                ),
                
# "PM2.5 CTM cmaq model" = "PM25_cmaq_tif"
                
                
                # Show leaflet map with a text div reporting the selected date and extents 
                mainPanel(
                  leafletOutput('myMap', height = 750, width = 1000)
                )
      
              )
      ),
    
    
    # Second tab content
    tabItem(tabName = "type",
            h2("Widgets tab content"))
  ))
))

############################################################
# shiny page with no dashboard

# shinyUI(fluidPage(
#   
#   # Title
#   titlePanel("Satellite and UK AIR data (England and Wales)"),
#   
#   sidebarLayout(
#     
#     sidebarPanel(
#       selectInput("type", "Chose layer type",
#                   c("Local Authorities Means" = "OGR", "raster")),
# 
#     conditionalPanel(
#       condition = "input.type == 'OGR'",
#           selectInput("variable_OGR", "Choose layer", c("PM2.5 satellite MODIS" = "pm25_mean",
#                                                      "PM2.5 UK-AIR" = "pm25_mean_UK_AIR",
#                                                      "PM2.5 GWR Donkelaar et al." = "pm25_mean_AVG_GWR",
#                                                      "PM2.5 modeled data (pcm)" = "pm25_mean_pcm",
#                                                      "PM2.5 CTM cmaq model" = "pm25_mean_cmaq"))),
#     
#      conditionalPanel(
#        condition = "input.type == 'raster'",
#         selectInput("variable_raster", "Choose layer", c("PM2.5 satellite MODIS (10km)" = "PM25_SAT_tif",
#                                                          "PM2.5 UK-AIR" = "PM25_UK_AIR_tif",
#                                                          "PM2.5 GWR 1km (MODIS)" = "PM25_GWR_tif",
#                                                          "PM2.5 modeled data (pcm)" = "PM25_pcm_tif",
#                                                          "PM2.5 CTM cmaq model" = "PM25_cmaq_tif")))
#         ),
#    
#     # Show leaflet map with a text div reporting the selected date and extents 
#     mainPanel(
#       leafletOutput('myMap', height = 500, width = 800)
#     )
#     
#   )
# ))
# 



