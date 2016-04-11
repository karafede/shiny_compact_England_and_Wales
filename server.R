library(shiny)
library(rgdal)
library(raster)
library(dplyr)
library(leaflet)
library(RColorBrewer)
library(sp)

setwd("C:/RICARDO-AEA/Donkelaar_1Km/Donkelaar_10km_Europe/shiny_compact")
# save GeoJSON file into RDS
# saveRDS(PM25_sat, "England_GWR_Local_Authorities.rds")
 PM25_sat <- readRDS("England_GWR_Local_Authorities.rds")

# qpal_SAT <- colorQuantile("Reds", PM25_sat$pm25_mean, n = 7)
# qpal_UK_AIR <- colorQuantile("Reds", PM25_sat$pm25_mean_UK_AIR, n = 7)
# qpal_GWR <- colorQuantile("Reds", PM25_sat$pm25_mean_AVG_GWR, n = 7)
# qpal_pcm <- colorQuantile("Reds", PM25_sat$pm25_mean_pcm, n = 7)
# qpal_cmaq <- colorQuantile("Reds", PM25_sat$pm25_mean_cmaq, n = 7)
# 
# ### color palettes for legends for Joined data by Local Authorities ##############
# 
# # pal_SAT <- colorNumeric(
# #   palette = "Reds",
# #   domain = PM25_sat$pm25_mean)
# 
# pal_UK_AIR <- colorNumeric(
#   palette = "Reds",
#   domain = PM25_sat$pm25_mean_UK_AIR)
# 
# pal_GWR <- colorNumeric(
#   palette = "Reds",
#   domain = PM25_sat$pm25_mean_AVG_GWR)
# 
# pal_pcm <- colorNumeric(
#   palette = "Reds",
#   domain = PM25_sat$pm25_mean_pcm)
# 
# pal_cmaq <- colorNumeric(
#   palette = "Reds",
#   domain = PM25_sat$pm25_mean_cmaq)

### Popouts for Local Authorities values 

# popup_PM25_sat <- paste0("<strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>", 
#                          PM25_sat$pm25_mean)

# popup_PM25_UK_AIR <- paste0("<strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>", 
#                             PM25_sat$pm25_mean_UK_AIR)
# 
# popup_GWR <- paste0("<strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>", 
#                     PM25_sat$pm25_mean_AVG_GWR)
# 
# popup_pcm <- paste0("<strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>", 
#                     PM25_sat$pm25_mean_pcm)
# 
# popup_cmaq <- paste0("<strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>", 
#                      PM25_sat$pm25_mean_cmaq)

#### Load rasters (only tif files format)

URB_Cover_tif <- raster::raster("URB_cover.tif")
PM25_SAT_tif <- raster::raster("PM25_EN_SAT.tif")
PM25_UK_AIR_tif <- raster::raster("PM25_UK_AIR.tif")
PM25_GWR_tif <- raster::raster("GWR_Donkelaar.tif")
PM25_pcm_tif <- raster::raster("PM25_pcm.tif")
PM25_cmaq_tif <- raster::raster("PM25_cmaq_1km.tif")

### colors for raster URB land cover (England region)
# pal_URB <- colorNumeric(c("#FFFFCC", "#41B6C4","#0C2C84"), getValues(URB_Cover_tif),
#                         na.color = "transparent")
# 
# ### colors for raster PM25_sat
# pal_PM25_SAT <- colorNumeric(c("#9999FF", "#9999FF", "#9999FF","#FFFF00", "#FF0000", "#b30000"),
#                              getValues(PM25_SAT_tif),na.color = "transparent")
# 
# ### colors for raster PM25 UK-AIR
# pal_PM25_UK_AIR <- colorNumeric(c("#9999FF", "#9999FF", "#9999FF","#FFFF00", "#FF0000", "#b30000"),
#                                 getValues(PM25_UK_AIR_tif),na.color = "transparent")
# 
# ### colors for raster GWR_1km new data 2009_2016 Donkelaar (2016)
# pal_PM25_GWR <- colorNumeric(c("#9999FF", "#9999FF", "#9999FF","#FFFF00", "#FF0000", "#b30000"),
#                                      getValues(PM25_GWR_tif),na.color = "transparent")
# 
# ### colors for raster pcm_PM25
# pal_PM25_pcm <- colorNumeric(c("#9999FF", "#9999FF", "#9999FF","#FFFF00", "#FF0000", "#b30000"),
#                                   getValues(PM25_pcm_tif),na.color = "transparent")
# 
# ### colors for raster cmaq_PM25 10km
# pal_PM25_cmaq <- colorNumeric(c("#0000FF", "#FFFF00","#FF0000"),
#                                         getValues(PM25_cmaq_tif),na.color = "transparent")
# 

###############################################################

shinyServer(function(input, output) {
  
  finalMap <- reactive({
    # Local authorites joined data
    PM25_OGR <- input$variable_OGR
    variable <- input$variable_OGR

     qpal <- colorQuantile("Reds", PM25_sat@data$PM25_OGR, n = 7)

     pal_OGR <- colorNumeric(
        palette = "Reds",
        domain = PM25_sat@data$PM25_OGR)
     
    # Raster data
    PM25_raster <- input$variable_raster
     rast_pal <- colorNumeric(c("#9999FF", "#9999FF", "#9999FF","#FFFF00", "#FF0000", "#b30000"), 
                             getValues(get(PM25_raster)),
                     na.color = "transparent")
  
    
    TYPE <- input$type
    
    # Create base map
    map <- leaflet() %>% 
      addTiles() %>% 
      setView(-2, 52.5, 6)
    
  if (TYPE == "OGR" & PM25_OGR == input$variable_OGR) {
  
      map <- map %>% 
        
        addPolygons(data = PM25_sat,
                    stroke = FALSE, smoothFactor = 0.2, 
                    fillOpacity = 0.5, 
                    color = ~ qpal(get(PM25_OGR)),
                    popup = ~ paste("<strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>",
                                   get(PM25_OGR))) 
      # %>%
        
#           addLegend("bottomright", pal = pal_OGR, values = PM25_sat$pm25_mean,
#                     title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>",
#                     labFormat = labelFormat(prefix = ""), opacity = 1)
      
  }  
    
#    values = PM25_sat()[[variable_OGR]]
  
    
    
#     if (TYPE == "OGR" & PM25_OGR == "pm25_mean_UK_AIR") {  
#       
#       map <- map %>% 
#         addPolygons(data = PM25_sat,
#                     stroke = FALSE, smoothFactor = 0.2, 
#                     fillOpacity = 0.5, 
#                     color = ~ qpal(get(PM25_OGR)),
#                     popup = popup_PM25_UK_AIR) %>%
#         addLegend("bottomright", pal = pal_OGR, values = PM25_sat$pm25_mean_UK_AIR,
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) UK-AIR : </strong>",
#                   labFormat = labelFormat(prefix = ""), opacity = 1)
#       
#     } 
#     
#     
#     if (TYPE == "OGR" & PM25_OGR == "pm25_mean_AVG_GWR") {
#       
#       map <- map %>% 
#         addPolygons(data = PM25_sat,
#                     stroke = FALSE, smoothFactor = 0.2, 
#                     fillOpacity = 0.5, 
#                     color = ~ qpal_GWR(pm25_mean_AVG_GWR),
#                     popup = popup_GWR) %>%
#         addLegend("bottomright", pal = pal_GWR , values = PM25_sat$pm25_mean_AVG_GWR,
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) GWR : </strong>",
#                   labFormat = labelFormat(prefix = ""), opacity = 1)
#       
#     }
#     
#     
#     if (TYPE == "OGR" & PM25_OGR == "pm25_mean_pcm") {
#       
#       map <- map %>% 
#         addPolygons(data = PM25_sat,
#                     stroke = FALSE, smoothFactor = 0.2, 
#                     fillOpacity = 0.5, 
#                     color = ~ qpal_pcm(pm25_mean_pcm),
#                     popup = popup_pcm) %>%
#         addLegend("bottomright", pal = pal_pcm , values = PM25_sat$pm25_mean_pcm,
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) PMC : </strong>",
#                   labFormat = labelFormat(prefix = ""), opacity = 1)
#       
#     }
#     
#     if (TYPE == "OGR" & PM25_OGR == "pm25_mean_cmaq") {
#       
#       map <- map %>% 
#         addPolygons(data = PM25_sat,
#                     stroke = FALSE, smoothFactor = 0.2, 
#                     fillOpacity = 0.5, 
#                     color = ~ qpal_cmaq(pm25_mean_cmaq),
#                     popup = popup_cmaq) %>%
#         addLegend("bottomright", pal = pal_cmaq , values = PM25_sat$pm25_mean_cmaq,
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) CMAQ : </strong>",
#                   labFormat = labelFormat(prefix = ""), opacity = 1)
#       
#     }
    
    
    if (TYPE == "raster" & PM25_raster == input$variable_raster) {
      
      map <- map %>% 
        addRasterImage(get(PM25_raster), 
                       colors = rast_pal, 
                       opacity = 0.6) %>%
        addLegend("bottomright", pal = rast_pal, values = getValues(get(PM25_raster)),
                  title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>",
                  labFormat = labelFormat(prefix = ""),
                  opacity = 0.6)
      
    }
    
#     if (TYPE == "raster" & PM25_raster == "PM25_SAT_tif") {
#       
#       map <- map %>% 
#         addRasterImage(PM25_SAT_tif, 
#                        colors = pal_PM25_SAT, 
#                        opacity = 0.6) %>%
#         addLegend("bottomright",pal = pal_PM25_SAT, values = getValues(PM25_SAT_tif),
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) MODIS (10km): </strong>",
#                   labFormat = labelFormat(prefix = ""),
#                   opacity = 0.6)
#       
#     }
#     
#     if (TYPE == "raster" & PM25_raster == "PM25_UK_AIR_tif") {
#       
#       map <- map %>% 
#         addRasterImage(PM25_UK_AIR_tif, 
#                        colors = pal_PM25_UK_AIR, 
#                        opacity = 0.6) %>%
#         addLegend("bottomright",pal = pal_PM25_UK_AIR, values = getValues(PM25_UK_AIR_tif),
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) UK-AIR: </strong>",
#                   labFormat = labelFormat(prefix = ""),
#                   opacity = 0.6)
#       
#     }
#     
#     if (TYPE == "raster" & PM25_raster == "PM25_GWR_tif") {
#       
#       map <- map %>% 
#         addRasterImage(PM25_GWR_tif, 
#                        colors = pal_PM25_GWR, 
#                        opacity = 0.6) %>%
#         addLegend("bottomright",pal = pal_PM25_GWR, values = getValues(PM25_GWR_tif),
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) GWR 1km (MODIS): </strong>",
#                   labFormat = labelFormat(prefix = ""),
#                   opacity = 0.6)
#       
#     }
#     
#     if (TYPE == "raster" & PM25_raster == "PM25_pcm_tif") {
#       
#       map <- map %>% 
#         addRasterImage(PM25_pcm_tif, 
#                        colors = pal_PM25_pcm, 
#                        opacity = 0.6) %>%
#         addLegend("bottomright",pal = pal_PM25_pcm, values = getValues(PM25_pcm_tif),
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) PCM (1km): </strong>",
#                   labFormat = labelFormat(prefix = ""),
#                   opacity = 0.6)
#       
#     }
#     
#     if (TYPE == "raster" & PM25_raster == "PM25_cmaq_tif") {
#       
#       map <- map %>% 
#         addRasterImage(PM25_cmaq_tif, 
#                        colors = pal_PM25_cmaq, 
#                        opacity = 0.6) %>%
#         addLegend("bottomright",pal = pal_PM25_cmaq, values = getValues(PM25_cmaq_tif),
#                   title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>) CMAQ (1km): </strong>",
#                   labFormat = labelFormat(prefix = ""),
#                   opacity = 0.6)
#       
#     }
#     
# 
    
    # Return
    map
    
  })
  

  # Return to client
  output$myMap = renderLeaflet(finalMap())
  
})

