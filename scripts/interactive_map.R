
# setup -------------------------------------------------------------------

library(spatstat)
library(sf)
library(tmap)
library(tidyverse)

tmap_mode('view')

source('scripts/source_script.R')


# interactive map ---------------------------------------------------------

# Calculate density (The processing time is too long so assign it to the global environment)

site_density <-
  sf$site %>%
  st_coordinates() %>%
  spatstat.geom::ppp(
    x = .[, 1],
    y = .[, 2],
    window = spatstat.geom::as.owin(sf$income)) %>%
  stats::density(bw = 'nrd') %>%
  stars::st_as_stars() %>%
  st_set_crs(
    st_crs(wind))

# Map the wind speed, wind farms, wind turbines and income by tract

wind %>% 
  tm_shape(name = 'Wind Speed') +
  tm_raster(
    title = 'Wind Speed (Mwh)',
    style = 'cont',
    palette = 'Blues') +
  
  # Map the turbine site density to better compare with continuous wind speed
  
  # site_density %>% 
  # tm_shape(name = 'Density of turbine sites') +
  # tm_raster(
  #   title = 'Density of turbine sites',
  #   style = 'kmeans',
  #   n = 20,
  #   alpha = 0.6,
  #   palette = 'Purples',
  #   legend.show = FALSE) + 
  
  # Median houshold income by tract
  
  sf$income %>% 
  tm_shape(name = 'Median Household Income') +
  tm_polygons(
    col = 'median_household_income',
    title = 'Median Household Income ($)',
    alpha = 0.7,
    border.col = 'white',
    border.alpha = 0.7) +
  
  # Wind project
  
  sf$project %>% 
  filter(
    st_geometry_type(geometry) == 'POLYGON') %>% 
  tm_shape('Wind Farms') +
  tm_polygons(
    col = 'p_cap',
    title = 'Wind Farms (Mw)') +
  
  # Wind turbines
  
  sf$site %>% 
  tm_shape('Wind Turbine Sites') +
  tm_dots(
    clustering = TRUE)
