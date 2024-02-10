################################################################################
# Project: TrainDelays OEBB
#
# Date: 08.02.2024
#
# Purpose: Combine Delay Data
################################################################################

# define INPUT, OUTPUT, TEMP
INPUT  <- "G:/My Drive/R_data/TrainDelays_OEBB/01_preprocess_delays/OUTPUT/"


load(paste0(INPUT, "delays.rda"))

library(dplyr)
library(ggplot2)

# auslastung
auslastung <- delays %>% distinct(train_id, date_arrival, orig_abroad, nightjet) %>% 
  group_by(date_arrival, orig_abroad, nightjet) %>% 
  summarise(n = n())
auslastung

delays %>% ggplot() +
  geom_bar(aes(x = date_arrival, fill = as.character(orig_abroad)))


# Delay
delays %>% ggplot() +
  
  geom_boxplot(aes(y = delay)) +
  coord_cartesian(ylim=c(0,20)) +
  labs(x = "", y = "delay (min)") +
  facet_wrap(~date_arrival) +
  
  theme(axis.text.x=element_blank(),
        axis.ticks.x = element_blank())


# most delayed station / tain
delays %>% group_by(train_id, orig_abroad) %>%
  summarise(mean = mean(delay, na.rm = TRUE),
            median = median(delay, na.rm = TRUE))  %>%
  ungroup() %>%
  slice_max(mean, n = 10) %>%
  ggplot() +
  geom_col(aes(x = reorder(train_id, mean), y = mean, fill = as.character(orig_abroad)))


delays %>% group_by(station) %>%
  summarise(mean = mean(delay, na.rm = TRUE),
            median = median(delay, na.rm = TRUE)) %>%
  ungroup() %>%
  slice_max(mean, n = 10) %>%
  ggplot() +
  geom_col(aes(x = reorder(station, mean), y = mean))




# lm on delays
lm(delay ~ orig_abroad + hour_arrival, data = delays) %>%
  summary()




