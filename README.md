# shiny-le
Lake Erie R Shiny

## Get the repo
```
git clone https://github.com/l3-hpc/shiny-le.git
cd shiny-le
```

## Add the model files
Any directory starting with 'output' is git-ignored.  For the example, I am using:
```
output_sinkout
output_nosinkout
```

## Open in R Studio
I did not test these as batch scripts.

Required libraries:
```
#to read model output netCDF
library(ncdf4)
#for ymd_hms
library(lubridate)
#To append dataframes to list: list.append
library(rlist)
#df operations: arrange, distinct
library(dplyr)
#The dashboard version of Shiny
library(shinydashboard)
#For colormap
library(RColorBrewer)
#Leaflet is for the interactive map
library(leaflet)
```

In R Studio, go to the shiny-le folder(this repo), set as the working directory.  

## Reformat the data
Open ***ReformatModelData_allnodes.R***, set the path for the FVCOM outputs.  They should contain the variable "TP". 
```
#--Model data
var1file <- "output_nosinkout/leem_0001.nc"
var2file <- "output_sinkout/leem_0001.nc"
```

If you don't want to write over the example rds in this repo, set `shiny_dir` to something else.

Click **Source**.  This should make new rds files in you `shiny_dir`, or overwrite the ones already in `data`.

## Modify directory paths and labels.
If you made a different `shiny_dir`, change `data_dir` in ***global.R***.

Open ***labels.R*** and change the variable names and titles to reflect your data.

Open ***global.R***, ***ui.R***, or ***server.R***.  Any of these will have a **Run App** button that the top (instead of **Source**).  Click **Run App** to run R Shiny locally.
