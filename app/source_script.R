
# setup -------------------------------------------------------------------

library(sf)
library(tmap)
library(tidyverse)

# spatial data preprocess -------------------------------------------------

# Read in wind potential and land cover raster

raster <-
  list.files(
    'data',
    'tif') %>% 
  file.path(
    'data',
    .) %>% 
  map(
    ~ terra::rast(.x)) %>% 
  set_names(
    'land',
    'wind_100',
    'wind_60',
    'wind_80')

# Read in turbine site, project, income data and state boundary

sf <- 
  list.files(
    'data',
    'geojson') %>% 
  file.path(
    'data',
    .) %>% 
  map(
    ~  st_read(.x)) %>%   
  set_names(
    'grid',
    'demography',
    'state',
    'project',
    'site')

# prepare data for running model ------------------------------------------

# Join site capacity, wind speed and income data by census tract

# sf$data_by_county <- 
#   sf$site %>% 
#   as_tibble() %>% 
#   group_by(t_fips) %>% 
#   summarise(
#     cap_county = 
#       sum(t_cap)) %>% 
#   left_join(
#     sf$income,
#     .,
#     by = c('geoid' = 't_fips')) %>% 
#   mutate(
#     cap_county = 
#       if_else(
#         is.na(cap_county),
#         0,
#         cap_county),
#     wind_speed = 
#       sf$income %>% 
#       terra::vect() %>% 
#       terra::extract(
#         wind, 
#         .,
#         mean,
#         na.rm = TRUE) %>% 
#       pull())
# 
# # calculate residual ------------------------------------------------------
# 
# # Create a table with calculated residuals
# 
# sf$data_by_county_resid <- 
#   sf$data_by_county %>% 
#   mutate(
#     resid = 
#       lm(wind_speed ~ cap_county, sf$data_by_county) %>% 
#       resid())
