################################################################################
# Project: TrainDelays OEBB
#
# Date: 10.02.2024
#
# Purpose: Create Map to Visualize Delays & Intensity
################################################################################


INPUT <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/OUTPUT/"

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
intensity <- delays %>% group_by(station) %>%
    summarise(n_trains = n(),
              mean_delay = mean(delay, na.rm = TRUE)) %>%
    left_join(shapefile_stations, by = "station")

intensity_map <- ggplot() +
    geom_sf(data = shapefile_austria$geometry, fill = "grey") +
    geom_sf(data = intensity$geometry, aes(size = intensity$n_trains, color = -intensity$mean_delay)) +
    labs(title = "Mean Train Delays & Trains/Day by Station", size = "Trains/Day", color = "Mean Delay (min)",
         subtitle = "long-distance trains only") +
    theme_minimal() +
    scale_color_viridis_c(option = "C") 
  