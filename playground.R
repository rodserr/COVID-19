# sicyng a fork: https://help.github.com/en/enterprise/2.13/user/articles/syncing-a-fork
# Libraries----
library(tidyverse)
library(lubridate)
library(forecast)

# Reader----
.files <- list.files('csse_covid_19_data/csse_covid_19_daily_reports', full.names = TRUE)

pair_list <- lapply(.files,read_csv) %>% 
  discard(function(x) nrow(x) == 0) %>% 
  map(function(x) mutate(x, `Last Update` = ymd_h,`Last Update`))
  bind_rows()

names(pair_list) <- files_name

data <- read_csv('')