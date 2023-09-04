#-- RDS_model_output.R: 
# Create rds's of model outputs for shiny,
#  including top and bottom layer timeseries for both models,
#  and yearly mean surface and bottom TP.
#to read model output netCDF
library(ncdf4)
#for ymd_hms
library(lubridate)
#To append dataframes to list: list.append
library(rlist)
#df operations: arrange, distinct
library(dplyr)
        
#--Model data
#var1file <- "output_nosinkout/leem_0001.nc"
var1file <- "output_sinkout/leem_0001.nc"
#var2file <- "output_sinkout/leem_0001.nc"
var2file <- "output_leem/TP_leem_crop.nc"

#--Shiny fixed rds files
fixed_dir <- "data_fixed"
#--Final Shiny rds files
shiny_dir <- "data_sinkout_vs_leem"
#-----END USER MODIFY---

#-------Directory checking-----
#--The inputs should exist
message <- paste("Var 1 file",var1file,"not found, exiting.")
if (!file.exists(var1file)) stop(message)
message <- paste("Var 2 file",var2file,"not found, exiting.")
if (!file.exists(var2file)) stop(message)
# and the grid, river, and station rds file
grid_rds <- file.path(fixed_dir,"le_grid.rds")
riv_rds <- file.path(fixed_dir,"le_rivers.rds")
st_rds <- file.path(fixed_dir,"le_stationdata.rds")
if (!file.exists(grid_rds)) stop("STEP1 output le_grid.rds not found, exiting.")
if (!file.exists(riv_rds)) stop("STEP2 output le_rivers.rds not found, exiting.")
if (!file.exists(st_rds)) stop("STEP3 output le_stationdata.rds not found, exiting.")
# Create a shiny model output directory if it does not exist
if (!dir.exists(shiny_dir)) dir.create(shiny_dir)
#--End Directory checking-----

# Grid df has node,depth,X,Y,lat,lon
df_grid <- readRDS(grid_rds)
# River df has node, name, image
df_riv <- readRDS(riv_rds)
# Station df_st has data
df_st <- readRDS(st_rds)

# Sort each dataframe by node so it is easier to check results
df_grid <- arrange(df_grid,node)
df_riv <- arrange(df_riv,node)
df_st <- arrange(df_st,node)

#Get list of all nodes with stations and rivers
inodes <- append(df_riv$node,df_st$node)
cat("There are",length(inodes),"total nodes.","\n")
#Get list of all unique nodes
uni_nodes <- unique(inodes)
#cat("Extracting data from the",length(uni_nodes),"unique nodes.","\n")

#Keep only the grid points with data
#df_grid <- df_grid[df_grid$node %in% uni_nodes,]
#Nope, in this version we keep ALL the data

#--Open model data
# netCDF files
ncvar1 <- nc_open(var1file)
ncvar2 <- nc_open(var2file)

# Use tp_file because of better metadata (MJD)
time_var1 <- ncvar_get(ncvar1, "time")
origin <- ymd_hms("1858-11-17 00:00:00")
time <- as.POSIXct(time_var1*86400, tz="UTC",origin=origin)
nt <- length(time)

#Create a list of dataframes
the_data <- list()
the_stats <- list()

#Loop through unique nodes
#for (i in uni_nodes) {
#Loop through ALL nodes
for (i in df_grid$node){
  #create a data frame for data
  df_data <- data.frame(matrix(ncol = 4, nrow = nt))
  colnames(df_data) <- c("v1surf","v1bot","v2surf","v2bot")
  #create a data frame for stats
  df_stats <- data.frame(matrix(ncol = 4, nrow = 1))
  colnames(df_stats) <- c("v1meansurf","v1meanbot","v2meansurf","v2meanbot")
  #surface, j=1
  j <- 1
  df_data$v1surf <- ncvar_get(ncvar1, "TP", start=c(i,j,1), count=c(1,1,-1))
  df_stats$v1meansurf <- mean(df_data$v1surf)
  df_data$v2surf <- ncvar_get(ncvar2, "TP", start=c(i,j,1), count=c(1,1,-1))
  df_stats$v2meansurf <- mean(df_data$v2surf)
  #top, j=20
  j <- 20
  df_data$v1bot <- ncvar_get(ncvar1, "TP", start=c(i,j,1), count=c(1,1,-1))
  df_stats$v1meanbot <- mean(df_data$v1bot)
  df_data$v2bot <- ncvar_get(ncvar2, "TP", start=c(i,j,1), count=c(1,1,-1))
  df_stats$v2meanbot <- mean(df_data$v2bot)
  the_data <- list.append(the_data,df_data)
  the_stats <- list.append(the_stats,df_stats)
}

#The node numbers are a subset of all nodes, but the list of dataframes must be
# accessed by index. Create a 'global id' that matches list index to node number.
df_grid$gid <- df_grid$node

#For rivers, add gid, lat, lon
df_riv$gid <- 0
df_riv$lat <- 0
df_riv$lon <- 0
ii <- 1
for (i in df_riv$node){
  #i is a node
  index <- which(df_grid$node == i)
  #find the corresponding gid
  df_riv$gid[ii] <- df_grid$gid[index]
  #and the corresponding lat/lon
  df_riv$lat[ii] <- df_grid$lat[index]
  df_riv$lon[ii] <- df_grid$lon[index]
  ii <- ii + 1
}

#For station data, add gid
df_st$gid <- 0
ii <- 1
for (i in df_st$node){
  #i is a node
  index <- which(df_grid$node == i)
  #find the corresponding gid
  df_st$gid[ii] <- df_grid$gid[index]
  #and the corresponding lat/lon
  df_st$lat[ii] <- df_grid$lat[index]
  df_st$lon[ii] <- df_grid$lon[index]
  ii <- ii + 1
}

#Create a dataframe for station popups
#Keep unique station ids
df_pop <- df_st %>% distinct(id, .keep_all = TRUE)
df_pop <- df_pop %>% select(gid,name,lat,lon)

#Clean up station data
df_st <- df_st %>% select(gid,date,TP)
#And grid
df_grid <- df_grid %>% select(gid,h,lat,lon,X,Y)

#Add the statistics to the dataframe
df_grid$v1meansurf = 0
df_grid$v1meanbot = 0
df_grid$v2meansurf = 0
df_grid$v2meanbot = 0

#For each grid point, each having a gid
for (j in df_grid$gid) {
  df_grid$v1meansurf[j] <- the_stats[[j]]$v1meansurf
  df_grid$v1meanbot[j] <- the_stats[[j]]$v1meanbot
  df_grid$v2meansurf[j] <- the_stats[[j]]$v2meansurf
  df_grid$v2meanbot[j] <- the_stats[[j]]$v2meanbot
}

#Save everything to the data_model directory
saveRDS(df_grid,file=file.path(shiny_dir,"le_grid.rds"))
saveRDS(df_riv,file=file.path(shiny_dir,"le_rivers.rds"))
saveRDS(time,file=file.path(shiny_dir,"le_time.rds"))
saveRDS(the_data,file=file.path(shiny_dir,"le_data.rds"))
saveRDS(df_st,file=file.path(shiny_dir,"le_stations.rds"))
saveRDS(df_pop,file=file.path(shiny_dir,"le_pop.rds"))

#Optional clean up
#rm(list=ls())




  


