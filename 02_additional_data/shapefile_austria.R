################################################################################
# Project: TrainDelays OEBB
#
# Date: 10.02.2024
#
# Purpose: Prepare Shapefile Info for Austria
# Data Source: https://public.opendatasoft.com/explore/?sort=modified
################################################################################


shapefile_austria <- st_read(paste0(INPUT, "/world-administrative-boundaries/world-administrative-boundaries.shp")) %>%
  
  filter(name == "Austria")