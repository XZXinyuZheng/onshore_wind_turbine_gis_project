# distance ----------------------------------------------------------------

wind %>% 
  terra::global(
    quantile,
    na.rm = TRUE)

# Filter out pixels with high wind speed

wind_q4 <- 
  {tribble(
    ~ from, ~ to,  ~ become,
    1.36,   7.39,  NA_real_,
    7.39,   14.21, 1) %>%
      as.matrix() %>% 
      terra::classify(
        wind,
        rcl = .,
        include.lowest = TRUE,
        right = FALSE) * wind}

sf$site %>% 
  st_union() %>% 
  terra::vect() %>% 
  terra::distance(
    wind_q4,
    .) %>% 
  terra::extract(sf$site)
