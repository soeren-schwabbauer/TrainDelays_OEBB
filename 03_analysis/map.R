################################################################################
# Project: TrainDelays OEBB
#
# Date: 10.02.2024
#
# Purpose: Create Map to Visualize Delays & Intensity
################################################################################

# load libraries 
library(sf)
library(ggplot2)
library(gganimate)
library(stringr)
library(magrittr)

library(dplyr)


# INPUT
INPUT <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/OUTPUT/"
OUTPUT <- "G:/My Drive/R_data/TrainDelays_OEBB/03_analysis/OUTPUT"

# load data
delays <- readRDS(paste0(INPUT, "delays.rds"))
source(paste0(getwd(), "/02_additional_data/shapefile_stations.R"))
source(paste0(getwd(), "/02_additional_data/shapefile_austria.R"))


# Overall image of coverage ----------------------------------------------------
overall <- shapefile_stations %>% mutate(indelays = case_when(station %in% unique(delays$station) ~ 1,
                                                   .default = 0))
overall_map <- ggplot() +
    geom_sf(data = shapefile_austria$geometry, fill = "grey") +
    geom_sf(data = overall$geometry, aes(color = as.character(overall$indelays))) +
    theme_minimal()


# Intensity --------------------------------------------------------------------
intensity <- delays %>% 
  mutate(delay = case_when(delay < 5 ~ 0,
                           .default = delay)) %>%
  group_by(station, date_arrival) %>%
    summarise(n_trains = n(),
              mean_delay = mean(delay, na.rm = TRUE)) %>%
    left_join(shapefile_stations, by = "station")

# function for plot
intensity_fun <- function(date){
  
  intensity <- intensity %>% filter(date_arrival == date) 
  
  intensity_map <- ggplot() +
      geom_sf(data = shapefile_austria$geometry, fill = "grey") +
      geom_sf(data = intensity$geometry, aes(size = intensity$n_trains, color = intensity$mean_delay)) +
      labs(title = "Mean Train Delays & Trains/Day by Station", size = "Trains/Day", color = "Mean Delay (min)",
           subtitle = paste0("Date: ", as.Date(i)), 
           caption = "Note: Long Distance Trains only; delays <5 min delay are valued as 0 min delay | source: oebb.at") +
  
    #scale_color_viridis_c(option = "C") +
        
    scale_color_continuous(
      type = "viridis", 
      option = 'A', 
      direction = -1, 
      limits = c(0, 20), 
      oob = scales::squish,
      breaks = seq(0, 20, 5), 
      labels = c(seq(0, 15, 5), '>20'),
      guide = guide_coloursteps(
        show.limits = TRUE)) +
    guides(size = guide_legend(order = 1)) +
    
    theme(plot.caption = element_text(size = 6, color = "darkgrey", hjust = 0))
  theme_minimal() 

  return(intensity_map)
  
}

# apply put plot to gif in loop
saveGIF(
  {for(i in dates){print(intensity_fun(i))}},
  movie.name = "delays.gif", 
  interval = 0.2, 
  ani.width = 600, 
  ani.height = 300,
  anires = 300,
  outdir = getwd()
)
