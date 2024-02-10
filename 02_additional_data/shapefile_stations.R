################################################################################
# Project: TrainDelays OEBB
#
# Date: 10.02.2024
#
# Purpose: Prepare Shapefile Data for Trainstations
# Data Source: https://data.oebb.at/de/datensaetze~geo-netz~
################################################################################

# load libraries
library(sf)
library(ggplot2)
library(stringr)
library(magrittr)

library(dplyr)

# Define Input, OUTPUT
INPUT  <- "G:/My Drive/R_data/TrainDelays_OEBB/02_additional_data/INPUT/"


# Replace specific values in the station column
shapefile_stations <- st_read(paste0(INPUT, "OEBB_GeoNetz_12-2023_SHP/RailwayJunction_2024.shp")) %>%
  
  rename(station = NAME_SNNB) %>%
  
  mutate(station = gsub("^\\s+|\\s+$", "", station)) %>%
  mutate(station = str_replace(station, "St. ", "St.")) %>%
  mutate(station = case_when(station == "Amstetten" ~ "Amstetten NÖ",
                             station == "Wien Hauptbahnhof" ~ "Wien Hbf",
                             station == "Traun" ~ "Traun OÖ",
                             station == "Krumpendorf" ~ "Krumpendorf/Wörthersee",
                             station == "Pörtschach am Wörthersee" ~ "Pörtschach am Wörther See",
                             station == "St.Michael" ~ "St.Michael in Obersteiermark",
                             station == "Micheldorf" ~ "Micheldorf in OÖ",
                             station == "Velden am Wörthersee" ~ "Velden am Wörther See",
                             station == "Neuhofen a.d.Krems" ~ "Neuhofen/Krems",
                             station == "Kirchdorf a.d.Krems" ~ "Kirchdorf/Krems", 
                             station == "St.Veit a.d.Glan" ~ "St.Veit/Glan",
                             station == "Bruck a.d.Mur" ~ "Bruck/Mur",
                             station == "Feldbach" ~ "Feldbach/Raab",
                             station == "Friesach" ~ "Friesach in Kärnten",
                             station == "Lienz" ~ "Lienz in Osttirol",
                             station == "Baden" ~ "Baden b.Wien",
                             station == "Micheldorf-Hirt" ~ "Micheldorf",
                             station == "Riedenburg" ~ "Bregenz Riedenburg",
                             station == "Graz Liebenau-Murpark" ~ "Graz Liebenau Murpark",
                             station == "Graz Ostbf-Messe" ~ "Graz Ostbahnhof-Messe",
                             
                             .default = station)) %>%
  
  select(station, geometry)


# check, which stations are in the delays df -----------------------------------
#PATH_DELAYS <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/OUTPUT/"
#delays <- readRDS(paste0(PATH_DELAYS, "delays.rds"))

#sf_stations <- shapefile_stations %>% pull(station)
#wrongstationname <- delays %>% mutate(wrongstationname = case_when(station %in% sf_stations ~ 0, .default = 1)) %>% 
#  filter(wrongstationname == 1) %>%
#  distinct(station)

#wrongstationname
# no more missing (every station can be matched) 