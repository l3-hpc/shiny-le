# shiny-le
Lake Erie R Shiny

See:
- [Lake Erie[(https://lisalenorelowe.shinyapps.io/shiny-le) - 2013 Shiny App on shinyio.

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

Create netCDF with just TP. *(This could probably be improved...)*

Copy:
```
ncks -O LEEM_2013_Calculated_Time0.nc TP_leem.nc
```
ncap2 can't add variables and divide at the same time (or at least, I couldn't figure out how), so make and add three new ZOO variables.  Append to the existing file (a).
```
ncap2 -s"ZOO1=ZOO1/50.;ZOO2=ZOO2/50.;ZOO3=ZOO3/50.;" -v LEEM_2013_Calculated_Time0.nc TP_leem.nc
a
```
Add the TP variable, append to existing file.
```
ncap2 -s"TP=RPOP+LPOP+RDOP+LDOP+PO4T+LPIP+RPIP+ZOO1+ZOO2+ZOO3" -v TP_leem.nc TP_leem.nc
a
```
Make a small version, just TP:
```
ncks -v TP,h,iint,lat,latc,lon,lonc,nprocs,nv,partition,siglay,siglay_shift,siglev,time,x,xc,y,yc,zeta TP_leem.nc TP.nc
```

Use VisIt to test by opening TP.nc and LEEM_2013_Calculated_Time0.nc, with TP defined as:
```
DefineScalarExpression("TPtot", "RPOP + LPOP + RDOP + LDOP + PO4T + LPIP + RPIP + (ZOO1 + ZOO2 + ZOO3)/50.0")
```

They should be exactly the same.

The file LEEM_2013_Calculated_Time0.nc has data every 6 hours.  Crop it, since I did daily outputs on Expanse:
Make a small version, just TP:
```
ncks -d time,0,979,4  TP.nc TP_crop.nc
```

