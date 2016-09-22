library(shiny)
library(rgdal)
library(raster)
library(dplyr)
library(leaflet)
library(RColorBrewer)
library(sp)

# setwd("C:/RICARDO-AEA/Donkelaar_1Km/Donkelaar_10km_Europe/shiny_compact")
# save GeoJSON file into RDS
# PM25_sat <- readOGR(dsn = "Copia.geojson",layer = "OGRGeoJSON")
# read GeoJSON file
# PM25_sat <- readOGR(dsn = "Copia.ENGLAND_geojson_PM25_1km_Sat_2009_2011",
#                       layer = "OGRGeoJSON")

# save GeoJSON file into RDS
# saveRDS(PM25_sat, "England_GWR_Local_Authorities.rds")
 PM25_sat <- readRDS("England_GWR_Local_Authorities.rds")


#### Load rasters (only tif files format)

URB_Cover_tif <- raster::raster("URB_cover.tif")
PM25_SAT_tif <- raster::raster("PM25_EN_SAT.tif")
PM25_UK_AIR_tif <- raster::raster("PM25_UK_AIR.tif")
PM25_GWR_tif <- raster::raster("GWR_Donkelaar.tif")
PM25_pcm_tif <- raster::raster("PM25_pcm.tif")
PM25_cmaq_tif <- raster::raster("PM25_cmaq_1km.tif")


###############################################################

shinyServer(function(input, output) {
  
  finalMap <- reactive({
  
    # Local authorites joined data
    PM25_OGR <- input$variable_OGR
    variable <- input$variable_OGR

    withProgress(message = "processing.....",  detail = 'this may take a while...', value = 0.25, { background= "yellow"  
    # Number of times we'll go through the loop
    for(i in 1:2) {
    
     qpal <- colorQuantile("Reds", PM25_sat@data$PM25_OGR, n = 7)

     pal_OGR <- colorNumeric(
        palette = "Reds",
        domain = PM25_sat@data$PM25_OGR)
     
    # Raster data
    PM25_raster <- input$variable_raster
     rast_pal <- colorNumeric(c("#9999FF", "#9999FF","#9999FF", "#FFFF00", "#FF0000", "#b30000"), 
                             getValues(get(PM25_raster)),
                     na.color = "transparent")
  
     
    TYPE <- input$type
    
    # Create base map
    map <- leaflet() %>% 
      addTiles() %>% 
      addTiles(group = "OSM (default)") %>%
      addProviderTiles("OpenStreetMap.Mapnik", group = "Road map") %>%
      addProviderTiles("Thunderforest.Landscape", group = "Topographical") %>%
      addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
      addProviderTiles("Stamen.TonerLite", group = "Toner Lite") %>%
      setView(-2, 52.5, 6)
    
  if (TYPE == "OGR" & PM25_OGR == input$variable_OGR) {
  
      map <- map %>% 
        
        addPolygons(data = PM25_sat,
                    stroke = FALSE, smoothFactor = 0.2, 
                    fillOpacity = 0.5, 
                    color = ~ qpal(get(PM25_OGR)),
                    popup = ~ paste("<strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>",
                                   get(PM25_OGR)), group = PM25_OGR)  %>%
        
           addLegend("bottomright", pal = pal_OGR,  values = PM25_sat[[PM25_OGR]],      # values = PM25_sat$pm25_mean,
                     title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>",
                     labFormat = labelFormat(prefix = ""), opacity = 1) %>%
        addLayersControl(
          baseGroups = c("Road map", "Topographical", "Satellite", "Toner Lite"),
          overlayGroups = PM25_OGR,
          options = layersControlOptions(collapsed = TRUE))
      
  }  
    

    if (TYPE == "raster" & PM25_raster == input$variable_raster) {
      
      map <- map %>% 
        addRasterImage(get(PM25_raster), 
                       colors = rast_pal, 
                       opacity = 0.6, group = PM25_raster) %>%
        addLegend("bottomright", pal = rast_pal, values = getValues(get(PM25_raster)),
                  title = "<br><strong>PM<sub>2.5</sub> (<font face=symbol>m</font>g/m<sup>3</sup>): </strong>",
                  labFormat = labelFormat(prefix = ""),
                  opacity = 0.6) %>%
        addLayersControl(
          baseGroups = c("Road map", "Topographical", "Satellite", "Toner Lite"),
          overlayGroups = PM25_raster,
          options = layersControlOptions(collapsed = TRUE))
      
    }
    
    
    # Increment the progress bar, and update the detail text.
    setProgress(message = 'message = "processing.....',
                detail = 'this may take a while...',
                value=i)
    print(i)
    Sys.sleep(0.1)
    # Pause for 0.5 seconds to simulate a long computation.
    }
    
    })

    # Return
    map
    
  })
  

  # Return to client
  output$myMap = renderLeaflet(finalMap())
  
})

