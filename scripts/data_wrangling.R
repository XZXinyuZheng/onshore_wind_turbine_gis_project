
# setup -------------------------------------------------------------------

library(tidyverse)
library(sf)
library(tidycensus)
library(tmap)

tmap_mode('view')

state <- 
  st_read('data/raw/shapefile/states.shp') %>%
  select(GEOID:NAME)

st_write(state, 'data/processed/state.geojson')

us <- 
  state %>% 
  st_union() %>% 
  st_sf()

texas <- 
  state %>%
  filter(NAME == 'Texas')

# wind potential ----------------------------------------------------------

wind <- 
  list.files(
    'data/raw/raster',
    'wtk') %>% 
  file.path(
    'data/raw/raster',
    .) %>% 
  map(
    ~ .x %>% 
      terra::rast())

wind %>% 
  map(
  ~ .x %>%
    terra::crop(
      st_transform(texas, st_crs(.x))) %>% 
    terra::mask(
      st_transform(texas, st_crs(.x))) %>% 
    terra::writeRaster(
      paste0('data/processed/', names(.x), '.tif')))

tm_shape(wind_us) +
  tm_raster(alpha = 0.6,
            palette = 'Blues')

# turbine -----------------------------------------------------------------

turbine_origin <- 
  st_read('data/raw/shapefile/uswtdb_v5_2_20221012.shp') %>% 
  st_filter(us)

# Tidy turbine data

turbine <- 
  list(
    
    # Site data    
    
    site = 
      turbine_origin %>% 
      select(
        c(case_id,
          t_county,
          t_fips,
          p_name:p_year,
          t_cap:t_ttlh)) %>% 
      mutate(
        across(
          everything(),
          ~ na_if(.x,
                  -9999)),
        state_geoid = str_sub(t_fips, 1, 2)) %>% 
      left_join(
        state %>% 
          st_drop_geometry(),
        by = c('state_geoid' = 'GEOID')) %>% 
      select(!state_geoid) %>% 
      rename(state = NAME),
    
    # Project data
    
    project = 
      turbine_origin %>% 
      as_tibble() %>% 
      select(
        c(p_name:p_cap)) %>% 
      mutate(
        across(
          everything(),
          ~ na_if(.x,
                  -9999))) %>% 
      group_by(p_name, p_year) %>% 
      summarise(
        p_tnum = sum(p_tnum),
        p_cap = sum(p_cap)))

# Create project geometry

turbine$site_test <- 
  turbine$site %>% 
  mutate(
    p_year = replace_na(p_year, 0))

project_geom <- 
  map2(
    .x = turbine$project$p_name,
    .y = replace_na(turbine$project$p_year, 0),
    ~ {if (filter(turbine$site_test, p_name == .x, p_year == .y) %>% 
           count() %>% 
           pull(n) > 1) {
      filter(turbine$site_test, p_name == .x, p_year == .y) %>% 
        st_coordinates() %>%
        as_tibble() %>% 
        bind_rows(
          slice(., 1)) %>% 
        as.matrix() %>%
        list() %>% 
        st_polygon() %>% 
        st_geometry() %>% 
        st_set_crs(
          st_crs(us)) %>% 
        st_sf()
    } else {
      filter(turbine$site_test, p_name == .x, p_year == .y) %>% 
        select(geometry)
    }}) %>% 
  bind_rows() %>% 
  st_make_valid()

# Create the project data including capacity

turbine$project <- 
  turbine$project %>% 
  bind_cols(
    project_geom,
    .)

# mutate(
#   p_wind_speed = 
#     map_dbl(
#       project_geom$geometry,
#       ~ {if (
#         st_geometry_type(.x) != 'POINT') {
#         terra::vect(.x) %>% 
#           terra::extract(
#             wind_us,
#             .,
#             mean,
#             na.rm = TRUE) %>% 
#           pull()
#       } else {
#         terra::vect(.x) %>% 
#           terra::extract(
#             wind_us,
#             .) %>% 
#           pull()
#       }}))

st_write(turbine$site, 'data/processed/turbine_site.geojson')
st_write(turbine$project, 'data/processed/turbine_project.geojson')

# census ------------------------------------------------------------------

credential <- Sys.getenv("census_api_key")

acs_5y_var <- load_variables(2020, "acs5")

rm(acs_5y_var)

median_income <- get_acs(
  geography = 'county',
  variables = c(
    'B19013_001', 
    'B15003_022', 
    'B23025_004', 
    'B01003_001'),
  year = 2020,
  key = credential,
  output = 'wide') %>% 
  select(
    !c(B19013_001M, 
       B15003_022M, 
       B23025_004M, 
       B01003_001M)) %>% 
  separate(
    col = NAME,
    into = c('county', 'state'),
    sep = ', ') %>% 
  rename(
    'geoid' = 'GEOID',
    'median_household_income' = 'B19013_001E',
    'bachelor' = 'B15003_022E', 
    'employed' = 'B23025_004E', 
    'total_pop' = 'B01003_001E') %>% 
  left_join(
    tigris::counties(
      cb = TRUE, 
      year = 2020) %>% 
      select(GEOID),
    .,
    by = c('GEOID' = 'geoid')) %>% 
  st_filter(us) %>% 
  rename('geoid' = 'GEOID') %>% 
  mutate(
    # income_cat =
    #   .$median_household_income %>%
    #   cut(
    #     breaks = 
    #       quantile(.,
    #                prob = 
    #                  seq(0, 1, 0.1)),
    #     labels = c(
    #       '<10%',
    #       '10-20%',
    #       '20-30%',
    #       '30-40%',
    #       '40-50%',
    #       '50-60%',
    #       '60-70%',
    #       '70-80%',
    #       '80-90%',
    #       '>90%'),
    #     include.lowest = TRUE,
    #     right = TRUE),
    bachelor_rate = 
      bachelor / total_pop,
    employment_rate = 
      employed / total_pop) %>% 
  rmapshaper::ms_simplify(keep = 0.001)

st_write(median_income, 'data/processed/median_income.geojson')

median_income_texas <- 
  median_income %>% 
  filter(state == 'Texas') %>% 
  select(!state)

st_write(median_income_texas, 'data/processed/median_income_texas.geojson')

# power grid --------------------------------------------------------------

grid <- 
  st_read('data/raw/shapefile/Electric__Power_Transmission_Lines.geojson') %>% 
  st_transform(
    st_crs(us)) %>% 
  st_filter(us) %>% 
  rmapshaper::ms_simplify(keep = 0.001)

st_write(grid, 'data/processed/grid.geojson')

grid_texas <- 
  grid %>% 
  st_filter(texas)

st_write(grid_texas, 'data/processed/grid_texas.geojson')

grid %>%
  tm_shape() +
  tm_lines() +
  turbine$site %>%
  st_filter(
    filter(state, NAME == "Texas")) %>% 
  tm_shape() +
  tm_dots(clustering = TRUE)

# land cover --------------------------------------------------------------

land <- 
  terra::rast('data/raw/raster/nlcd_2019_land_cover/nlcd_2019_land_cover_l48_20210604.img')

texas <- 
  tigris::states(year = 2020) %>% 
  filter(NAME == 'Texas') %>% 
  st_transform(
    st_crs(land))

land_texas <- 
  land %>% 
  terra::crop(texas) %>% 
  terra::mask(texas) %>% 
  terra::aggregate(10, fun = 'modal')

rm(land)

land_texas %>% 
  tm_shape() +
  tm_raster(
    style = 'cat',
    palette = '-Spectral'
  )

terra::writeRaster(land_texas, 'data/processed/land_cover_texas.tif')

land_texas_layers <- 
  land_texas %>% 
  terra::catalyze()

land_texas_layer1 <- 
  tribble(
    ~ is, ~ to,
    17, 0,
    14,  11,
    15, 12,
    8, 21,
    6, 22,
    7, 23,
    5, 24,
    2, 31,
    4, 41,
    10, 42,
    13, 43,
    16, 52,
    12, 71,
    11, 81,
    3, 82,
    18, 90,
    9, 95) %>% 
  as.matrix() %>% 
  terra::classify(
    land_texas_layers[[1]],
    rcl = .)

terra::writeRaster(land_texas_layer1, 'data/processed/land_cover_texas_layer1.tif')

# mutate(
#   to = 
#     to %>% 
#     fct_recode(
#       `Unclassfied` = '0',
#       `Open Water` = '11',
#       `Perennial Snow/Ice` = '12',
#       `Developed, Open Space` = '21',
#       `Developed, Low Intensity` = '22',
#       `Developed, Medium Intensit` = '23',
#       `Developed, High Intensity` = '24',
#       `Barren Land`= '31',
#       `Deciduous Forest` = '41',
#       `Evergreen Fores` = '42',
#       `Mixed Forest` = '43',
#       `Shrub/Scrub` = '52',
#       `Herbaceous` = '71',
#       `Hay/Pasture` = '81',
#       `Cultivated Crops` = '82',
#       `Woody Wetlands` = '90',
#       `Emergent Herbaceous Wetlands` = '95'))
