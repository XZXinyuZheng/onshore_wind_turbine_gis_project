
# setup -------------------------------------------------------------------

library(sf)
library(tmap)
library(tidyverse)

tmap_mode('plot')

source('scripts/spatial_data_wrangling_Xinyu_Zheng.R')

# turbine capacity and wind speed -----------------------------------------

# Map the static wind speed and turbines

wind %>% 
  tm_shape() +
  tm_raster(
    title = 'Wind Speed (Mwh)',
    style = 'cont',
    palette = 'Blues') +
  
  # Wind turbines
  
  sf$site %>% 
  tm_shape() +
  tm_dots() +
  
  # Set the map layout
  
  tm_layout(
    legend.outside = TRUE,
    main.title = 'Although wind turbines cluster in places with higher wind speeds or known \nas wind potential, it is unclear whether the distribution of wind turbines \nmaximizes the wind potential',
    main.title.size = 0.7,
    frame = FALSE)

# Create the project table without geometry: project capacity and geometry

project <- 
  sf$site %>% 
  as_tibble() %>% 
  group_by(p_name) %>% 
  summarise(
    p_cap = 
      sum(t_cap)) %>% 
  mutate(
    p_wind_speed = 
      .$p_name %>% 
      
      # create the polygon geometry or point geometry for each project and extract average wind speed for them
      
      map_dbl(
        ~ if (filter(sf$site, p_name == .x) %>% 
              count() %>% 
              pull(n) > 1) {
          filter(sf$site, p_name == .x) %>% 
            st_coordinates() %>%
            as_tibble() %>% 
            bind_rows(
              slice(., 1)) %>% 
            as.matrix() %>%
            list() %>% 
            st_polygon() %>% 
            st_geometry() %>% 
            st_set_crs(
              st_crs(wind)) %>% 
            terra::vect() %>% 
            terra::extract(
              wind,
              .,
              mean,
              na.rm = TRUE) %>% 
            pull()
        } else {
          filter(sf$site, p_name == .x) %>% 
            terra::vect() %>% 
            terra::extract(
              wind,
              .) %>% 
            pull()
        }))

# Plot the relationship between wind speed and capacity of project

project %>% 
  ggplot(
    aes(
      x = p_wind_speed,
      y = p_cap / 1000000)) + 
  geom_point(
    alpha = 0.5,
    color = '#084081') +
  geom_smooth(
    color = '#feb24c',
    method = 'lm') +
  scale_y_continuous(
      expand = c(0, 0)) +
  theme_minimal() +
  labs(
    title = 'The capacity of wind turbines is positively related to the wind speed at the project level',
    x = 'Wind speed by project (Mwh)',
    y = 'Total capacity of wind turbines by project (Mw)')

# Plot the relationship between wind speed and capacity of turbines at the tract level

data_by_tract %>% 
  ggplot(
    aes(
      x = wind_speed,
      y = cap_tract / 1000000)) +
  geom_point(
    alpha = 0.5,
    color = '#084081') +
  geom_smooth(
    color = '#feb24c',
    method = 'lm') +
  scale_y_continuous(
      expand = c(0, 0)) +
  theme_minimal() +
  labs(
    title = 'The capacity of wind turbines is positively related to the wind speed at the tract level',
    x = 'Wind speed by tract (Mwh)',
    y = 'Total capacity of wind turbines by tract (Mw)')

# residual and median househould income -----------------------------------

# Plot the relationship between residuals and median household income

data_by_tract_resid %>%
  ggplot(
    aes(
      x = median_household_income,
      y = resid)) +
  geom_point() +
  geom_smooth()

# The graph above suggests:
# 1. Different relationships between residuals and income at different income level
# 2. The impact of extreme high income is huge

# Plot the relationship by two level of income excluding 1% of outlines

data_by_tract_resid %>%
  filter(
    median_household_income <= 
      quantile(data_by_tract_resid$median_household_income,
               prob = 0.99)) %>% 
  mutate(
    income_level =
      if_else(
        median_household_income < median(median_household_income),
        'Low Income',
        'High Income') %>% 
      fct_relevel(
        c(
          'Low Income',
          'High Income'))) %>% 
  ggplot(
    aes(
      x = median_household_income / 1000,
      y = resid)) +
  geom_point(
    alpha = 0.5,
    color = '#084081') +
  geom_smooth(
    color = '#feb24c') +
  scale_y_continuous(
    expand = c(0, 0)) +
  facet_grid(
    ~ income_level,
    scales = 'free_x') +
  theme_minimal() +
  labs(
    title = 'Residuals Are Negatively Correlated With Meidan Household Income',
    x = 'Median Household Income (1000 Dollars)',
    y = 'Residual')
