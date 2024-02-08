################################################################################
# Project: TrainDelays OEBB
#
# Date: 08.02.2024
#
# Purpose: Scrape Delays of previous day
################################################################################

# load libraries ---------------------------------------------------------------
library(rvest)
library(dplyr)
library(xml2)
library(magrittr)
library(tidyr)


# load information on cities ---------------------------------------------------
load(paste0(getwd(), "/DATA/at_stations.rda"))
stations <- at_stations %>% pull(Bahnhof) 


# scrape yesterdays departures into list ---------------------------------------
delaytimes_list <- list()

for(station in stations){
  
  tryCatch({ #introduces error loop
    wp <- paste0("https://www.zugfinder.net/de/bahnhofstafel-", station)
    
    #stationsinfo <- read_html(wp) %>% html_node('#hero') 
    delays <- read_html(wp) %>% html_node('#zugdaten') %>% html_table
  
    # add date & station
    delays %<>% mutate(Datum = Sys.Date()-1)
    
    delaytimes_list[[station]] <- delays
    }, error = function(e) {
    cat("Error occurred for station:", station, "\n")
  })
}

# save data --------------------------------------------------------------------
formatted_date <- format(Sys.Date() - 1, "%Y-%m-%d")

assign(paste0("departures_", formatted_date), delaytimes_list) %>%
  
  saveRDS(file = paste0(getwd(), "/DATA/raw_delays_", formatted_date, ".RData"))
