#Load rds files

#Notes
# variable name 'v1' and 'v2' are used to make things generic
# Change the labels in labels.R for TP vs TP_leem vs TP_sinkout/nosinkout, etc.
#

#Location of data(rds files), relative to this directory is defined in labels.R
source("labels.R")

#gid=global index
#h=depth
#X,Y=zonal coordinates
#surf=surface, bot=bottom
#image=location of image on OSN
#(to display images in R Shiny, files have to be online and have a URL, hence OSN)

#grid info for location and color of circles
# gid, h, lat, lon, X, Y, 
# v1meansurf, v1meanbot, v2meansurf, v2meanbot
grid <- readRDS(file.path(data_dir,"le_grid.rds"))
#river info: node, name, image, gid, lat, lon
river <- readRDS(file.path(data_dir,"le_rivers.rds"))
#Time array
time <- readRDS(file.path(data_dir,"le_time.rds"))
#model data, list of dataframes with timeseries of
# v1surf, v1bot, v2surf, v2bot
model <- readRDS(file.path(data_dir,"le_data.rds"))
#Measured station data: gid, date, TP
st_data <- readRDS(file.path(data_dir,"le_stations.rds"))
#Station location info for popups: gid, name, lat, lon
st_loc <- readRDS(file.path(data_dir,"le_pop.rds"))

#Resize the circles
#grid$circle <- grid$h**(1/3)
