# shiny-le
Lake Erie R Shiny

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/l3-hpc/shiny-le/HEAD?urlpath=rstudio)

## Environment
These were tested in R Studio.

Required libraries for reformatting
- ncdf4
- lubridate
- rlist
- dplyr

Required libraries for R Shiny App
- shinydashboard
- RColorBrewer
- leaflet
- dplyr

## Get the repo
```
git clone https://github.com/l3-hpc/shiny-le.git
cd shiny-le
```

## Add the model files
Add FVCOM model outputs to a directory named starting with ***output***. (The ***.gitignore*** file ignores everything starting with ***output***.)For the example, I am using:
```
output_sinkout
output_nosinkout
```

## Open in R Studio
I did not test these as batch scripts.

In R Studio, go to the shiny-le folder(this repo), set as the working directory.  

## Reformat the data
Open ***ReformatModelData_allnodes.R***, set the path for the FVCOM outputs.  They should contain the variable "TP". 
```
#--Model data
var1file <- "output_nosinkout/leem_0001.nc"
var2file <- "output_sinkout/leem_0001.nc"
```

If you don't want to write over the example rds in this repo, set `shiny_dir` to something else.  To run these instructions in the github repo without tracking the new data, name the directory with ***data_***.  (The ***.gitignore*** file ignores everything starting with ***data_***.)

Click **Source**.  This should make new rds files in you `shiny_dir`, or overwrite the ones already in `data`.

## Modify directory paths and labels.
If you made a different `shiny_dir`, change `data_dir` in ***global.R***.

Open ***labels.R*** and change the variable names and titles to reflect your data.

Open ***global.R***, ***ui.R***, or ***server.R***.  Any of these will have a **Run App** button that the top (instead of **Source**).  Click **Run App** to run R Shiny locally.

## Additional steps for LEEM data
Using this example...

Make a directory starting with ***output***.  (The ***.gitignore*** file ignores everything starting with ***output***.)  

Try a sample file:
```
mkdir output_leem
cd output_leem
wget https://renc.osn.xsede.org/ees210015-bucket01/LEEM_2013_Calculated_Time0.nc
```

Create netCDF with just TP. *(This is inefficient and slow, but we can fix that later.)*

Make a copy:
```
cp LEEM_2013_Calculated_Time0.nc TP_leem.nc
```
ncap2 can't add variables and divide at the same time (or at least, I couldn't figure out how), so make and add three new ZOO variables.
```
ncap2 -s"ZOO1=ZOO1/50.;ZOO2=ZOO2/50.;ZOO3=ZOO3/50.;" -v LEEM_2013_Calculated_Time0.nc TP_leem.nc
a
```
Add the TP variable
```
ncap2 -s"TP=RPOP+LPOP+RDOP+LDOP+PO4T+LPIP+RPIP+ZOO1+ZOO2+ZOO3" -v TP_leem.nc TP_leem.nc
a
```
Get rid of the other variables, rename.
```
ncks -x -v CHL,PHYT1,PHYT2,PHYT3,PHYT4,PHYT5,RPOP,LPOP,RDOP,LDOP,PO4T,RPON,LPON,RDON,LDON,NH4T,NO23,BSI,SIT,RPOC,LPOC,RDOC,LDOC,EXDOC,REPOC,REDOC,O2EQ,DO,ZOO1,ZOO2,ZOO3,BALG,DYE,LPIP,RPIP,IPOP,IPON,IPOC,Hyp2_Area TP_leem.nc TP2_leem.nc
mv TP2_leem.nc TP_leem.nc
```
