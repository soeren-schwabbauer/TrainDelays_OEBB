################################################################################
# Project: TrainDelays_OEBB
#
# Date: 08.02.2024
#
# Purpose: Scrape Names of Austrian Trainstations
################################################################################

# load libraries
library(rvest)
library(magrittr)
library(dplyr)

# define INPUT, OUTPUT, TEMP
OUTPUT <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/INPUT/"


# scrape data ------------------------------------------------------------------
table_nodes <- seq(4,20, by = 2) %>% as.character()
at_stations <- list()

for(table_node in table_nodes){
  
  at_stations[[table_node]] <- read_html("https://de.wikipedia.org/wiki/Liste_der_Fernverkehrsbahnh%C3%B6fe_in_%C3%96sterreich") %>%
  
  html_node(paste0("table.wikitable:nth-child(", table_node, ") > tbody:nth-child(1)")) %>%
  
  html_table() 

}

# bind & edit data -------------------------------------------------------------
at_stations %<>% bind_rows() %>% rename(Bahnhof = Betriebsstelle)

at_stations %<>% mutate(Bahnhof = gsub(" ", "_", Bahnhof),
                        Bahnhof = gsub("_an.*", "", Bahnhof),
                        Bahnhof = gsub("_am.*", "", Bahnhof),
                        Bahnhof = gsub("_in.*", "", Bahnhof),
                        Bahnhof = gsub("_im.*", "", Bahnhof)) %>%
  
  mutate(Bahnhof = case_when(Bahnhof == "Wien_Westbf" ~ "Wien_West",
                             Bahnhof == "Flughafen_Wien_(VIE)" ~ "Flughafen_wien",
                             Bahnhof == "Baden" ~ "Baden_B.wien",
                             Bahnhof == "Langen" ~ "Langen_am_Arlberg",
                             .default = Bahnhof))


# save file --------------------------------------------------------------------
save(at_stations, file = paste0(OUTPUT, "at_stations.rda"))

