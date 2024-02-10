################################################################################
# Project: TrainDelays OEBB
#
# Date: 08.02.2024
#
# Purpose: Edit Raw delay data, which is not yet edited.
# NOTE: If structure is changed, delete data in TEMP & run file
################################################################################

# load libraries
library(magrittr)
library(tidyr)
library(chron)
library(lubridate)
library(stringr)

library(dplyr)

# define INPUT, OUTPUT, TEMP
INPUT  <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/INPUT/"
OUTPUT <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/TEMP/"


# find dates which are not edited ----------------------------------------------
dates_raw    <- list.files(path = INPUT,  pattern = "^raw_delays") %>%
  gsub("raw_delays_", "", .) %>% 
  gsub(".RData", "", .)

dates_edited <- list.files(path = OUTPUT, pattern = "^delays") %>%
  gsub("delays_", "", .) %>%
  gsub(".rda", "", .)

dates <- dates_raw[!dates_raw %in% dates_edited]


# edit & create variables ------------------------------------------------------

for(date in dates){
  
  # load list 
  raw_delays_list <- readRDS(paste0(INPUT, "raw_delays_", date, ".RData"))

  
  delay <- bind_rows(raw_delays_list) %>% 
      
    # rename variables
    rename(arrival = Ankunft, 
           train_id = Zugnr.,
           station_origdeparture = "von (Abfahrt)",
           station = Ankunftsbhf.,
           date_arrival = Datum) %>%
      
    
    # get time of arrival & delay
    separate(arrival, into = c("time_arrival", "delay"), sep = " ") %>%
    mutate(time_arrival = hm(time_arrival),
           date_arrival = ymd(date_arrival),
           hour_arrival = hour(time_arrival),
           wday_arrival = wday(date_arrival, week_start = 1)) %>%
    
    # delay as number  
    mutate(delay = gsub("\\(|\\)", "", delay),
           delay = case_when(is.na(delay) ~ "0", .default = delay),
           delay = as.numeric(delay)) %>%
    
    # delay dummies
    mutate(intime     = case_when(delay != 0 ~ 0, delay == 0 ~ 1),
           delaymax5  = case_when(delay > 5 ~ 0, delay <= 5 ~ 1),
           delaymax10 = case_when(delay > 10 ~ 0, delay <= 10 ~ 1)) %>%
    mutate(cancelled  = case_when(is.na(intime) ~ 1, .default = 0)) %>%
    
    
    # edit orig_station & original departure
    separate(station_origdeparture, into = c("station_origdeparture", "time_origdeparture"), sep = ' \\(ab ') %>%
    mutate(time_origdeparture = gsub(")", "", time_origdeparture),
           time_origdeparture = hm(time_origdeparture),
           date_origdeparture = case_when(time_origdeparture > time_arrival ~ date_arrival - 1,
                                          .default = date_arrival)) %>%
    
    # unify variables
    mutate_at(vars(station, station_origdeparture), 
              ~str_replace_all(., c("St. " = "St."))) %>%
    
    # time traveled
    mutate(time_travelled = case_when(time_arrival > time_origdeparture ~ as.double(time_arrival - time_origdeparture, units = "mins"),
                                      time_arrival < time_origdeparture ~ as.double(time_arrival - time_origdeparture, units = "mins") + 60 *24)) %>%
    
    # nightjet
    mutate(nightjet = case_when(grepl("NJ", train_id) ~ 1,
                                .default = 0)) %>%
    
    # international route
    
    
    # adjust order
    select(date_arrival, train_id, station,time_arrival, delay, date_origdeparture, 
           time_origdeparture, station_origdeparture, everything())

  


  # save data --------------------------------------------------------------------
  df_date <- delay$date_arrival %>% unique() %>% as.character()
  
  
  save(delay, file = paste0(OUTPUT, "delays_", df_date, ".rda"))
  
}

