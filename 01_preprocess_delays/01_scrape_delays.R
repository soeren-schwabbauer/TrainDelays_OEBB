################################################################################
# Project: TrainDelays OEBB
#
# Date: 08.02.2024
#
# Purpose: Scrape Delays of previous day
################################################################################

# load libraries
library(rvest)
library(dplyr)
library(xml2)
library(magrittr)

# define INPUT, OUTPUT, TEMP
INPUT  <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/INPUT/"
OUTPUT <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/INPUT/"


# load information on cities ---------------------------------------------------
load(paste0(INPUT, "at_stations.rda"))
stations <- at_stations %>% pull(Bahnhof) 

# scrape yesterdays departures into list ---------------------------------------
date <- Sys.Date()-1
delaytimes_list <- list()
error_stations <- list()

for(station in stations){
  
  tryCatch({ #introduces error loop
    wp <- paste0("https://www.zugfinder.net/de/bahnhofstafel-", station)
    
    #stationsinfo <- read_html(wp) %>% html_node('#hero') 
    delays <- read_html(wp) %>% html_node('#zugdaten') %>% html_table
  
    # add date & station
    delays %<>% mutate(Datum = date)
    
    delaytimes_list[[station]] <- delays
    }, error = function(e) {
    cat("Error occurred for station:", station, "\n")
      }
  )
}

# save data --------------------------------------------------------------------

saveRDS(delaytimes_list, file = paste0(OUTPUT, "raw_delays_", date, ".RData"))


# document errors --------------------------------------------------------------
#error_delays <- read.csv(paste0(getwd(), "/DATA/error_delays.csv"))

#error_stations <- data.frame(date = (Sys.Date()-1),
#                             n_errors = length(error_stations),
#                             station_errors = arrange(error_stations))

#error_stations <- bind_rows(error_delays, error_stations)
#
#write.csv(error_stations, paste0(getwd(), "/DATA/error_delays.csv"))