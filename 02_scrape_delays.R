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


# load information on cities ---------------------------------------------------
load(paste0(getwd(), "/DATA/at_stations.rda"))
stations <- at_stations %>% pull(Bahnhof) 


# scrape yesterdays departures into list ---------------------------------------
departuretimes_list <- list()

for(station in stations){
  
  tryCatch({ #introduces error loop
    wp <- paste0("https://www.zugfinder.net/de/bahnhofstafel-", station)
    
    #stationsinfo <- read_html(wp) %>% html_node('#hero') 
    departures <- read_html(wp) %>% html_node('#zugdaten') %>% html_table
  
    # add date & station
    departures %<>% mutate(date = Sys.Date()-1,
                           stadt = station)
    
    departuretimes_list[[station]] <- departures
    }, error = function(e) {
    cat("Error occurred for station:", station, "\n")
  })
}


# save data --------------------------------------------------------------------
formatted_date <- format(Sys.Date() - 1, "%Y-%m-%d")
departuretimes_df <- bind_rows(departuretimes)

assign(paste0("departures_", formatted_date), departuretimes_df) %>%
  
  save(file = paste0(getwd(), "/DATA/departures_", formatted_date, ".rda"))
