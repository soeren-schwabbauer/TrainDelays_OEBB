################################################################################
# Project: TrainDelays OEBB
#
# Date: 08.02.2024
#
# Purpose: Edit Raw delay data
################################################################################

# load libraries
library(magrittr)
library(dplyr)
library(tidyr)

raw_delays_list <- readRDS(paste0(getwd(), "/DATA/raw_delays_2024-02-07.RData"))


# define function --------------------------------------------------------------
edit_delaytimes_list <- function(delay){
  
  delay %<>% 
    
    rename(time = Ankunft, 
           train_id = Zugnr.,
           prev_station = "von (Abfahrt)",
           station = Ankunftsbhf.,
           date = Datum) %>%
    
    # get delay and dummy for intime/cancelled
    separate(time, into = c("time", "delay"), sep = " ") %>%
    mutate(delay = gsub("\\(|\\)", "", delay),
           delay = case_when(is.na(delay) ~ "0", .default = delay),
           delay = as.numeric(delay)) %>%
    
    mutate(intime     = case_when(delay > 0 ~ 0, delay <= 0 ~ 1),
           delaymax5  = case_when(delay > 5 ~ 0, delay <= 5 ~ 1),
           delaymax10 = case_when(delay > 10 ~ 0, delay <= 10 ~ 1)) %>%
    mutate(cancelled = case_when(is.na(intime) ~ 1, .default = 0)) %>%
    
    # get hour interval
    mutate(time_hh = gsub(":.*", "", time))
  
  return(delay)
}


test <- lapply(raw_delays_list, edit_delaytimes_list)
