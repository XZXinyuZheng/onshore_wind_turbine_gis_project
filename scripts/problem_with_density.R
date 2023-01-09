
# setup -------------------------------------------------------------------

library(sf)
library(tmap)
library(tidyverse)

source('scripts/spatial_data_wrangling_Xinyu_Zheng.R')

# density -----------------------------------------------------------------

site_density <-
  sf$site %>%
  st_transform(4326) %>% 
  st_coordinates() %>%
  spatstat.geom::ppp(
    x = .[, 1],
    y = .[, 2],
    window = spatstat.geom::as.owin(sf$income)) %>%
  stats::density(bw = 'nrd') %>%
  stars::st_as_stars() %>%
  st_set_crs(
    st_crs(wind))
