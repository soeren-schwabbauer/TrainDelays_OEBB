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

library(dplyr)

# define INPUT, OUTPUT, TEMP
INPUT  <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/INPUT/"
OUTPUT <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/TEMP/"


# find dates which are not edited
dates_raw    <- list.files(path = INPUT,  pattern = "^raw_delays") %>%
  gsub("raw_delays_", "", .) %>% 
  gsub(".RData", "", .)

dates_edited <- list.files(path = OUTPUT, pattern = "^delays") %>%
  gsub("delays_", "", .) %>%
  gsub(".rda", "", .)

# define function for departure related variables ------------------------------
dates <- dates_raw[!dates_raw %in% dates_edited]


for(date in dates){
  
  raw_delays_list <- readRDS(paste0(INPUT, "raw_delays_", date, ".RData"))

  
  edit_delaytimes_list <- function(delay){
    
    delay %<>% 
      
      rename(info_arrived = Ankunft, 
             train_id = Zugnr.,
             orig_station = "von (Abfahrt)",
             station = Ankunftsbhf.,
             date = Datum) %>%
      
      # edit original station
      separate(orig_station, into = c("orig_station", "orig_departure"), sep = ' \\(ab ') %>%
      mutate(orig_departure = gsub(")", "", orig_departure),
             orig_departure = times(paste0(orig_departure, ":00"))) %>%
      
      # get delay and dummy for intime/cancelled
      separate(info_arrived, into = c("time_arrived", "delay"), sep = " ") %>%
      
      mutate(delay = gsub("\\(|\\)", "", delay),
             delay = case_when(is.na(delay) ~ "0", .default = delay)) %>%
      mutate(delay = as.numeric(delay)) %>%
      
      mutate(intime     = case_when(delay != 0 ~ 0, delay == 0 ~ 1),
             delaymax5  = case_when(delay > 5 ~ 0, delay <= 5 ~ 1),
             delaymax10 = case_when(delay > 10 ~ 0, delay <= 10 ~ 1)) %>%
      mutate(cancelled  = case_when(is.na(intime) ~ 1, .default = 0)) %>%
      
      # get hour interval
      mutate(hour_arrived = gsub(":.*", "", time_arrived)) %>%
  
      #date variable
      mutate(date = as.POSIXct(date, format = "%d-%m-%y"),
             time_arrived = times(paste0(time_arrived, ":00")))
    
    return(delay)
  }

  
  delaytimes <- lapply(raw_delays_list, edit_delaytimes_list) %>% bind_rows()
  
  
  # add dayrelated variables -----------------------------------------------------
  
  # add inland dummy
  inland <- delaytimes %>% pull(station)
  delaytimes %<>% mutate(orig_at = case_when((orig_station %in% inland) ~ 1, .default = 0))
    
  # format date
  delaytimes %<>% mutate(date = as.Date(date))
  
  
  # save data --------------------------------------------------------------------
  df_date <- delaytimes$date %>% unique() %>% as.character()
  
  
  save(delaytimes, file = paste0(OUTPUT, "delays_", df_date, ".rda"))
  
}
