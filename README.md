## An interactive mapping tool about wind farm siting

This repo includes the codes for an interactive mapping tool about wind farm siting, developed by Xinyu Zheng, MPP'23, at McCourt School of Public Policy of Georgetown University.

### Shiny interface

The app presents the deployment and distribution of onshore wind turbines:

![Wind turbines](app/www/shiny_interface_database.png)

The app also examines the determinants of wind farm siting, taking Texas, the home of over 25% of wind energy capacity in the U.S., as an illustrative example:

![Determinants of wind farm siting](app/www/shiny_interface_determinants.png)

Note: The app is too big to be loaded in the rsconnect as a webpage. Please clone or download the repo and run the app on your R terminal.

### Input data

- [The United States Wind Turbine Database (USWTDB)](https://eerscmap.usgs.gov/uswtdb/data/)
- [The monitor-level wind speed data in raster file from the NREL (at 60, 80,100 meters above surface)](https://www.nrel.gov/gis/wind-resource-maps.html)
- [The electric power transmission lines from the Homeland Infrastructure Foundation Level Database (HIFLD)](https://hifld-geoplatform.opendata.arcgis.com/datasets/geoplatform::electric-power-transmission-lines/about)
- [The 2019 National Land Cover Database (NLCD) in raster file from the Multi-Resolution Land Characteristics Consortium](https://www.mrlc.gov/data/nlcd-2019-land-cover-conus)
- [2020 5-year ACS of the Census Bureau](https://www.census.gov/data/developers/data-sets/acs-5year.html)

Note: The raw data used are too big to be included in the repo. Please download the raw data from the links above if you want to replicate the data-cleaning process. But the clean data for running the app is provided.

### Analysis code

Codes to clean data and map interactive and statics maps are in the folder of scripts:
- *data_wrangling.R*: (1) raster files: limit to U.S. continent or Texas; reduce the resolution to speed up the app loading; reclassify the land cover categories (2) the files: limit to U.S. continent or Texas; generate wind turbine project polygons from wind turbine points; load in demographic data through tidycensus; tidy data according to the tidy rules; simplify geometry to speed up the app loading
- *interactive_map.R*: preliminarily plot some interactive maps  
- *static_map.R* - preliminarily plot some static map

Codes to build the app are in the folder of app:
- *source_script.R*: a source script to load clean data into the app
- *shiny_app_renewed.R*: the script to build the Shiny app, including UI and service

* * *

## Author
Xinyu Zheng, Candidate for Master of Public Policy, McCourt School of Public Policy at Georgetown University

## Contact
zheng.xinyu.zx@gmail.com
