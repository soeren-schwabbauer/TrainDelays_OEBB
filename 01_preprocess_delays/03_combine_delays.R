################################################################################
# Project: TrainDelays OEBB
#
# Date: 08.02.2024
#
# Purpose: Combine Delay Data
################################################################################

# load libraries
library(dplyr)

# define INPUT, OUTPUT, TEMP
INPUT  <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/TEMP/"
OUTPUT <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/OUTPUT/"


# edited data in loop ----------------------------------------------------------
files <- list.files(path = INPUT, pattern = "^delays")
files_list <- list()

for(file in files){
  
  load(paste0(INPUT, file))
  
  files_list[[file]] <- delay
}
  
# combine data  
delays <- bind_rows(files_list) %>% 
  
  arrange(date_arrival, time_arrival)
  

# inland dummy
inland <- delay %>% pull(station) %>% unique()
inland <- c(inland, "Wien Hbf (Autoreisezug)", "Klagenfurt Hbf (Busbahnhof)", "Wien Hbf (Autoreisezuganlage)")
delays %<>% mutate(orig_abroad = case_when(station_origdeparture %in% inland ~ 0,
                                          .default = 1))




# save data in single df
save(delays, file = paste0(OUTPUT, "delays.rda"))
