# Mark Rowe 6-16-2015
# Define projection functions that can be called by habtracker R scripts

require(sp)
require(rgdal)

# use the GLCFS Lambert conformal projection for plots
#prj_new <- CRS("+proj=lcc +lat_1=41.763515 +lat_2=42.524841 +lat_0=0.0 +lon_0=-81.164597 +x_0=+194292.1
#+y_0=-4994940.0 +ellps=WGS84 +datum=NAD83 +units=m")

prj_new = CRS("+proj=utm +north +zone=16")#UTM

# define a function to project coordinates
projLcc <- function(nodes, prj_new){
  if(nrow(nodes) > 0){
    #     require(sp)
    #     require(rgdal)
    # "nodes" is a data frame with columns "lat" and "lon"
    #project lat lon coords 
    llCRS <- CRS("+proj=longlat +ellps=WGS84")
    #project coordinates 
    temp_pts = data.frame(nodes[,c("lon","lat")])
    # this version will tolerate NA values in the lat lon 
    nro <- nrow(temp_pts)
    temp_pts$ind <- seq(1:nro)
    temp_pts <- temp_pts[is.na(temp_pts$lat+temp_pts$lon)==FALSE,]
    ind <- temp_pts$ind
    temp_pts = SpatialPoints(temp_pts[,c("lon","lat")])
    proj4string(temp_pts) <- llCRS 
    temp_proj = spTransform(temp_pts, prj_new)
    nodes[ind,"X"] <- temp_proj@coords[,1]/1000
    nodes[ind,"Y"] <- temp_proj@coords[,2]/1000
  }
  return(nodes)
} # end function

projLatLon <- function(nodes, prj_new){
  if(nrow(nodes) > 0){
    #     require(sp)
    #     require(rgdal)
    
    #project lat lon coords for the FVCOM grid to plot it over the raster
    # to make sure raster is aligned correctly with lat lon coords
    llCRS <- CRS("+proj=longlat +ellps=WGS84")
    #project  coordinates 
    temp_pts = data.frame(nodes[,c("X","Y")])
    temp_pts <- temp_pts
    # this version will tolerate NA values in the lat lon 
    nro <- nrow(temp_pts)
    temp_pts$ind <- seq(1:nro)
    temp_pts <- temp_pts[is.na(temp_pts$X+temp_pts$Y)==FALSE,]
    ind <- temp_pts$ind
    temp_pts = SpatialPoints(temp_pts[,c("X","Y")]*1000)
    proj4string(temp_pts) <- prj_new 
    temp_proj = spTransform(temp_pts, llCRS)
    nodes[ind,"lon"] <- temp_proj@coords[,1]
    nodes[ind,"lat"] <- temp_proj@coords[,2]
  }
  return(nodes)
} # end function

# function to project to lat lon
projxy <- function(nodes, prj_new){
  if(nrow(nodes) > 0){
    
    #project lat lon coords for the FVCOM grid to plot it over the raster
    # to make sure raster is aligned correctly with lat lon coords
    llCRS <- CRS("+proj=longlat +ellps=WGS84")
    #project  coordinates 
    temp_pts = data.frame(nodes[,c("lon","lat")])
    temp_pts <- temp_pts
    # this version will tolerate NA values in the lat lon 
    nro <- nrow(temp_pts)
    temp_pts$ind <- seq(1:nro)
    temp_pts <- temp_pts[is.na(temp_pts$lon+temp_pts$lat)==FALSE,]
    ind <- temp_pts$ind
    temp_pts = SpatialPoints(temp_pts[,c("lon","lat")])
    proj4string(temp_pts) <- CRS("+proj=longlat +ellps=WGS84")
    temp_proj = spTransform(temp_pts, prj_new)
    nodes[ind,"X"] <- temp_proj@coords[,1]
    nodes[ind,"Y"] <- temp_proj@coords[,2]
    
    #     plotPolys(shorelineLL, xlim=c(-83.5,-82), ylim=c(41.4, 42.3))
    #     points(nodes$lon, nodes$lat, pch=3, cex=0.5)
  }
  return(nodes)
} # end function