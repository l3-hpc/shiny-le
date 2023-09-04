#Lake Erie: Modeled vs Measured
#for EPA ORD, Center for Computational Toxicology & Exposure (CCTE), 
#             Great Lakes Toxicology & Ecology Division
#R Shiny App: L.L. Lowe, 2023
#Model outputs from FVCOM Lake Erie, TP and LEEM
#Measured data from [Wilson]

#ui.R is User Interface
#Libraries:
#The dashboard version of Shiny
library(shinydashboard)
#For colormap
library(RColorBrewer)
#To filter dataframes
library(dplyr)

#Change labels to remove run dependent information
source("labels.R")

#River icons are green with white anchor symbol
Riv <- makeAwesomeIcon(
  icon = "anchor",
  iconColor = "green",
  markerColor = "white",
  library = "fa"
)

#Sets output based on input from ui
function(input, output, session) {
  
  #---Initializations-----
  
    #Start an empty plot window with 'click me'
    #First plot, Var1
    output$plotVar1 <- renderPlot({
      plot(1,type="n",xlab="",ylab="",xaxt="n",yaxt="n")
      mtext(title_v1,side=3,line=-4,cex=1.5,col="black")
      mtext("Zoom in, then click a circle to start a plot.",side=3,line=-12,cex=1.5,col="#006CD1")
     })
    #Second plot, Var2
    output$plotVar2 <- renderPlot({
      plot(1,type="n",xlab="",ylab="",xaxt="n",yaxt="n")
      mtext(title_v2,side=3,line=-4,cex=1.5,col="black")
      mtext("Zoom in, then click a circle to start a plot.",side=3,line=-12,cex=1.5,col="#006CD1")
     })
  
    #Initialize Leaflet map
    output$map <- renderLeaflet({
                    leaflet() %>%
                    addTiles() %>%
                    setView(lng = -81.2, lat = 42.2, zoom = 8) 
      })

  #---Observations----
  
  #Watch for changes in Variable and Color By and redraw the map
  observe({
    #Define plot variables based on Var1 or Var2  
    if(input$var == "Var1"){ 
       #-Start with grid dataframe
       df <- grid 
       #Get mean values for surface or bottom, add to dataframe
       if(input$colorby == "Surface") df$mean <- df$v1meansurf
       if(input$colorby == "Bottom") df$mean <- df$v1meanbot
       #Maps data values to colors using Purples and Blues colormap, define Min/Max
       pal <- colorNumeric(palette = "PuBu",domain = c(0.005,0.25))
       #legend title, groupname is for layer control
       legendtitle <- "TP"
       groupname <- paste("Mean",input$colorby,"TP")
     }else if(input$var == "Var2"){
       #-Start with grid dataframe
       df <- grid 
       #Get mean values for surface or bottom, add to dataframe
        if(input$colorby == "Surface") df$mean <- df$v2meansurf
        if(input$colorby == "Bottom") df$mean <- df$v2meanbot
        #Maps data values to colors using Purples and Blues colormap, define Min/Max
        pal <- colorNumeric(palette = "PuBu",domain = c(0.005,0.25))
        #legend title, groupname is for layer control
        legendtitle <- "TP"
        groupname <- paste("Mean",input$colorby,"TP")
      }
    #Define strings with html tags to make river and station labels stand out 
    riverText <- paste0("<h4><strong>River</strong></h4><h4>",river$name,"</h4>")
    stationText <- paste0("<h4><strong>",st_loc$name,"</strong></h4>")
    #Add river popups to leaflet
    leafletProxy("map",data=river) %>%
      addMarkers(~lon, ~lat, label=lapply(riverText,htmltools::HTML),
                 layerId=~gid, group="Rivers",
                 popup = ~paste0("<img src='",image,"' height='400'></img>"))
    #Add station popups to leaflet
    leafletProxy("map",data=st_loc) %>%
      addAwesomeMarkers(~lon, ~lat, icon=Riv,label=lapply(stationText,htmltools::HTML),
                        layerId=~gid, group="Stations",
                        popup = lapply(stationText,htmltools::HTML))
        
    #Redraw the map
    leafletProxy("map", data = df) %>%
      clearShapes() %>%
      clearControls() %>%
      addCircles(~lon, ~lat, radius=400, layerId=~gid,label=~gid,
                  stroke=FALSE, fillOpacity=.8, 
                  fillColor=~pal(mean),group="Model")                %>%   
      addLegend("bottomright", pal = pal, values = ~mean,
                    title = legendtitle,group=groupname,opacity = 1)    %>%
      addLayersControl(overlayGroups = c("Model",groupname,"Rivers","Stations"),
                  options = layersControlOptions(collapsed = FALSE))
  })#End observe 

  
  #Observe the map, start a plot when a gridpoint is clicked
  observe({
    #Event id is a index that defines data and station name
    event <- input$map_shape_click
    #If nothing is clicked, do nothing.
    if (is.null(event)) return()
    #Event id is a index that defines data and station name
    isolate({
      #The event id is equal to the station ID
      GetPlotVar1(event$id) 
      GetPlotVar2(event$id) 
      })
  })
#--End observe map for plotting

#--Function - Get lat/lon and X/Y to display on dashboard  
  GetIndices <- function(id) { 
      whichlon <- grid$lon[id]
      whichlat <- grid$lat[id]
      X <- grid$X[id]*1000
      Y <- grid$Y[id]*1000
      which <- list("lon"=whichlon,"lat"=whichlat,"X"=X,"Y"=Y)
      return(which)
  }
#--End function to get indices
  
#--This observes when the circle markers (model points) are clicked  
  observe({
    event <- input$map_shape_click
    
    isolate({
      #map returns layerid, which is the node.  GetIndices returns lat/lon
      gid <- GetIndices(event$id)
      # When map is clicked, show the Lat/Lon coordinates in the Model Data panel
      content_latlon <- as.character(HTML(sprintf("Lat = %01.2f Lon = %01.2f",gid$lat,gid$lon)))
      content_xy<- as.character(HTML(sprintf("X = %01.2f Y = %01.2f",gid$X,gid$Y)))
    })
    
    if (is.null(event))
      content <- "None Selected"
    output$plotlatlon <- renderUI({HTML(content_latlon)})
    output$plotxy <- renderUI({HTML(content_xy)})
    return()
    
    isolate({
      #This makes and empty plot with text, so the app doesn't start with
      #  a totally blank plot screen
      output$plotVar1 <- renderUI({
        HTML(content)
      })
    })
  })
#--End observing when the circle markers (model points) are clicked  
  
 
#--Function to plots TP   
  GetPlotVar1 <- function(inode) { 
     
    #The Plot!
    output$plotVar1 <- renderPlot({
 
      #Event click returns global index, gid
      depth <- grid$h[inode]
      station <- filter(st_data,gid==inode)
      #Filter based on time slider
      ind_1 <- which(time == input$timeRange[1])
      ind_2 <- which(time == input$timeRange[2])
      time <- time[ind_1:ind_2]
      Surf <- model[[inode]]$v1surf[ind_1:ind_2]
      Bot <- model[[inode]]$v1bot[ind_1:ind_2]
      
      mainlabel=paste0(title_v1,"\n column depth ",round(depth,1),"m")
      ylabel = "TP mg/L"
      msurf = "Surface mean"
      mbot = "Bottom mean"
     
      #Hex codes for surface and bottom lines and text
      colsurf <- "#006CD1"    #Blue
      colbot <- "#994F00"     #Brown
      
      #Find and Format
      #-Surface 
      #-- min,max,mean
      is_min <- format(min(Surf),digits=3)
      is_max <- format(max(Surf),digits=3)
      is_mean <- format(mean(Surf),digits=3)
      #-- label
      surf_label <- paste("Surface: min=",is_min,
                          "max=",is_max)
      #-Bottom 
      #-- min,max,mean
      ib_min <- format(min(Bot),digits=3)
      ib_max <- format(max(Bot),digits=3)
      ib_mean <- format(mean(Bot),digits=3)
      #-- label
      bot_label <- paste("Bottom:  min=",ib_min,
                         "max=",ib_max)
      #Ylimits for plot
      if(input$radio == "2"){  
        #choose range based on model values
        ymi <- min(min(Surf),min(Bot))
        yma <- max(max(Surf),max(Bot))
      }else if(input$radio == "1") {
        #Ylimits based on both models
        Surf2 <- model[[inode]]$v2surf[ind_1:ind_2]
        Bot2 <- model[[inode]]$v2bot[ind_1:ind_2]
        y1mi <- min(min(Surf),min(Bot))
        y1ma <- max(max(Surf),max(Bot))
        y2mi <- min(min(Surf2),min(Bot2))
        y2ma <- max(max(Surf2),max(Bot2))
        ymi <- min(y1mi,y2mi)
        yma <- max(y1ma,y2ma)
      }
      
      msurf = paste(msurf,is_mean)
      mbot = paste(mbot,ib_mean)
      
      plot(time,Surf,main=mainlabel,ylab=ylabel,cex=0.3,type="l",
           col=colsurf,bg=colsurf,ylim = c(ymi,yma),xlabel="")
      lines(time,Bot,pch=20,cex=0.3,type="l",col=colbot,bg=colbot)
      axis.Date(1, time,format="%b %d")
      mtext(msurf, side=3, line=1, col=colsurf, cex=1, adj=0)
      mtext(mbot, side=3, line=1, col=colbot, cex=1, adj=1)
      mtext(surf_label, side=1, line=3, col=colsurf, cex=1, adj=0)
      mtext(bot_label, side=1, line=3, col=colbot, cex=1, adj=1)
      
      if(input$checkbox){
        points(station$date,station$TP,pch=23,col="black",bg="#D9CA4B",cex=2)
      }
      
     
    })
    
  }
  
  #This plots the second variable
  GetPlotVar2 <- function(inode) { 
    
    #The Plot!
    output$plotVar2 <- renderPlot({
      
      #Event click returns global index, gid
      depth <- grid$h[inode]
      station <- filter(st_data,gid==inode)
      #Filter based on time slider
      ind_1 <- which(time == input$timeRange[1])
      ind_2 <- which(time == input$timeRange[2])
      time <- time[ind_1:ind_2]
      Surf <- model[[inode]]$v2surf[ind_1:ind_2]
      Bot <- model[[inode]]$v2bot[ind_1:ind_2]
      
      mainlabel=paste0(title_v2,"\n column depth ",round(depth,1),"m")
      ylabel = "TP mg/L"
      msurf = "Surface mean"
      mbot = "Bottom mean"
      
      #Hex codes for surface and bottom lines and text
      colsurf <- "#006CD1"    #Blue
      colbot <- "#994F00"     #Brown
      
      #Find and Format
      #-Surface 
      #-- min,max,mean
      is_min <- format(min(Surf),digits=3)
      is_max <- format(max(Surf),digits=3)
      is_mean <- format(mean(Surf),digits=3)
      #-- label
      surf_label <- paste("Surface: min=",is_min,
                          "max=",is_max)
      #-Bottom 
      #-- min,max,mean
      ib_min <- format(min(Bot),digits=3)
      ib_max <- format(max(Bot),digits=3)
      ib_mean <- format(mean(Bot),digits=3)
      #-- label
      bot_label <- paste("Bottom:  min=",ib_min,
                         "max=",ib_max)
      #Ylimits for plot
      if(input$radio == "2"){  
        #choose range based on model values
        ymi <- min(min(Surf),min(Bot))
        yma <- max(max(Surf),max(Bot))
      }else if(input$radio == "1") {
        #Ylimits based on both models
        Surf2 <- model[[inode]]$v1surf[ind_1:ind_2]
        Bot2 <- model[[inode]]$v1bot[ind_1:ind_2]
        y1mi <- min(min(Surf),min(Bot))
        y1ma <- max(max(Surf),max(Bot))
        y2mi <- min(min(Surf2),min(Bot2))
        y2ma <- max(max(Surf2),max(Bot2))
        ymi <- min(y1mi,y2mi)
        yma <- max(y1ma,y2ma)
      }
      
      msurf = paste(msurf,is_mean)
      mbot = paste(mbot,ib_mean)
      
      plot(time,Surf,main=mainlabel,ylab=ylabel,cex=0.3,type="l",
           col=colsurf,bg=colsurf,ylim = c(ymi,yma),xlabel="")
      lines(time,Bot,pch=20,cex=0.3,type="l",col=colbot,bg=colbot)
      axis.Date(1, time,format="%b %d")
      mtext(msurf, side=3, line=1, col=colsurf, cex=1, adj=0)
      mtext(mbot, side=3, line=1, col=colbot, cex=1, adj=1)
      mtext(surf_label, side=1, line=3, col=colsurf, cex=1, adj=0)
      mtext(bot_label, side=1, line=3, col=colbot, cex=1, adj=1)
      
      if(input$checkbox){
        points(station$date,station$TP,pch=23,col="black",bg="#D9CA4B",cex=2)
      }
      
      
    })
    
  }
  
  
  
 
  
  
}
