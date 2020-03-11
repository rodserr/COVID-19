# sicyng a fork: https://help.github.com/en/enterprise/2.13/user/articles/syncing-a-fork
# Libraries----
library(tidyverse)
library(lubridate)
library(forecast)
library(plotly)
library(janitor)

# Tryouts Reader----
.files <- list.files('csse_covid_19_data/csse_covid_19_daily_reports', full.names = TRUE)

daily_data <- lapply(.files,read_csv) %>% 
  discard(function(x) nrow(x) == 0)

.location_aux <- read_csv('csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv') %>% 
  clean_names() %>% 
  select(province_state, country_region, lat, long)

data <- daily_data %>% 
  map(function(x) x %>% 
        mutate_at(vars(`Last Update`), ~ifelse(is_character(.), mdy_hm(.), .))
      ) %>% 
  bind_rows() %>% 
  janitor::clean_names() %>% 
  left_join(.location_aux, by = c('country_region', 'province_state')) %>% 
  mutate(date = last_update %>% as_datetime() %>% date(),
         province_state = province_state %>% replace_na('missing_state'))

prueba <- data %>% filter(is.na(lat))

# .country_loc <- .dataWna %>% 
#   filter(!is.na(latitude)) %>% 
#   group_by(country_region) %>%
#   summarise(country_lat = mean(latitude),
#             country_lon = mean(longitude))

# data <- .dataWna %>% 
#   left_join(.dataWna %>% 
#               select(province_state, country_region, lat = latitude, long = longitude) %>% 
#               filter(!is.na(lat)) %>% 
#               unique(), by = c('province_state', 'country_region')) %>% 
#   left_join(.country_loc, by = 'country_region') %>% 
#   transmute(province_state, 
#             country_region, 
#             confirmed, 
#             deaths,
#             recovered,
#             latitude = )
  
data %>% 
  select(province_state, country_region, latitude, longitude) %>% 
  filter(!is.na(latitude)) %>% 
  unique()


map_data <- data %>% 
  mutate(confirmed = replace_na(confirmed, 0)) %>% 
  group_by(latitude, longitude) %>% 
  summarise(steps = list(confirmed))


prueba <- data %>% filter(is.na(lat))
prueba <- data %>% filter(country_region == 'US')

# Read-----
data <- read_csv('csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv') %>% 
  clean_names()

map_data <- data %>% 
  mutate_at(vars(starts_with('x')), as.character) %>% 
  unite('sequence', starts_with('x')) %>%
  transmute(lat, 
            long, 
            z = 1548,
            color = colorize(z),
            sequence = sequence %>% str_split('_') %>% map(as.numeric))

hcmap() %>% 
  hc_add_series(data = map_data[1:20,], type = "mapbubble",
                minSize = 0, maxSize = 50) %>% 
  hc_motion(enabled = TRUE, series = 1, autoPlay = F, 
            updateInterval = 1000, magnet = list(step =  1)) %>% 
  hc_plotOptions(series = list(showInLegend = FALSE))

