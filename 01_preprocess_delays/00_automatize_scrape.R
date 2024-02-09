#

# Install and load taskscheduleR package
library(taskscheduleR)

scrape_delays <- paste0(getwd(), "/01_preprocess_delays/02_scrape_delays.R")

myscript <- system.file("helloworld.R", package = "taskscheduleR")

taskscheduler_create(taskname = "AutoScrapeDelay", 
                     rscript= "C:/Users/soere/Dropbox/TrainDelays_OEBB/01_preprocess_delays/02_scrape_delays.R",
                     schedule = "MINUTE", 
                     starttime = format(Sys.time() + 62, "%H:%M"),
                     startdate = format(Sys.Date(), "%d/%m/%Y")) 

t <- taskscheduler_ls()
taskscheduler_delete(taskname = "AutoScrapeDelay")


library(cronR)
f   <- "C:/Users/soere/Dropbox/TrainDelays_OEBB/01_preprocess_delays/02_scrape_delays.R"
cmd <- cron_rscript(f)
cmd
