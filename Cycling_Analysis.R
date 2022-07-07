# Installing Rstudio environment 
library(tidyverse)
library(dplyr)
library(data.table)
# Importing Data into work space to be cleaned and prepared for analysis 
# Set Directory to folder with Monthyly Trip data from April 2020 - February 2022

          setwd("E:/R/Directory/Trip_data")

##########################################################################
Apr_20 <- read.csv("202004-divvy-tripdata.csv")
May_20 <- read.csv("202005-divvy-tripdata.csv")
Jun_20 <- read.csv("202006-divvy-tripdata.csv")
Jul_20 <- read.csv("202007-divvy-tripdata.csv")
Aug_20 <- read.csv("202008-divvy-tripdata.csv")
Sep_20 <- read.csv("202009-divvy-tripdata.csv")
Oct_20 <- read.csv("202010-divvy-tripdata.csv")
Nov_20 <- read.csv("202011-divvy-tripdata.csv")

 # Below are the 12 Most Recent Months Whihc will be used for the analysis 


Jan_21 <- read.csv("202101-divvy-tripdata.csv")
Apr_21 <- read.csv("202104-divvy-tripdata.csv")
May_21 <- read.csv("202105-divvy-tripdata.csv")
Jul_21 <- read.csv("202107-divvy-tripdata.csv")
Aug_21 <- read.csv("202108-divvy-tripdata.csv")
Sep_21 <- read.csv("202109-divvy-tripdata.csv")
Oct_21 <- read.csv("202110-divvy-tripdata.csv")
Dec_21 <- read.csv("202112-divvy-tripdata.csv")
Feb_22 <- read.csv("202202-divvy-tripdata.csv")
Mar_22 <- read.csv("202203-divvy-tripdata.csv")
Apr_22 <- read.csv("202204-divvy-tripdata.csv")
May_22 <- read.csv("202205-divvy-tripdata.csv")

#After importing the data the data was viewed as string files to cheak the data strucute 

str(Jan_21)
str(Apr_21)
str(May_21)
str(Jul_21)
str(Aug_21)
str(Sep_21)
str(Oct_21)
str(Dec_21)
str(Feb_22)
str(Mar_22)
str(Apr_22)
str(May_22)

# After viwing the stinrg data of each data frame we learn that all the column names among the data frames are the same data type  
# Here we double chaek to make sure that naming is consital acrossthe data frames before merging them into all_trips 
colnames(Jan_21)
colnames(Apr_21)
colnames(May_21)
colnames(Jul_21)
colnames(Aug_21)
colnames(Sep_21)
colnames(Oct_21)
colnames(Dec_21)
colnames(Feb_22)
colnames(Mar_22)
colnames(Apr_22)
colnames(May_22)

##########################################################################################
# After verifying data consistency and data integrity we merge all the trip data into one 

all_trips <- bind_rows(Jan_21, Apr_21 , May_21, Jul_21, Aug_21, Sep_21, Oct_21, Dec_21, Feb_22, Mar_22, Apr_22, May_22)


str(all_trips)

#Once all the column type sare layed out we begin to change the started at and ended at columns from chr to Date type 


all_trips$started_at <- as.POSIXct(
    all_trips$started_at, 
    format = "%Y-%m-%d %H:%M:%S"
)

all_trips$ended_at <- as.POSIXct(
  all_trips$ended_at, 
  format = "%Y-%m-%d %H:%M:%S"
)

#Once converted to dat we now order by date. 

all_trips <- all_trips %>%
    arrange(started_at)

#Now we calculate the length of each trip into seconds 

all_trips$ride_length <- difftime(
  all_trips$ended_at, 
  all_trips$started_at,
  units = "secs"
) 

# Following this we must make sure that the ride length variable is numerica rather than a character 

all_trips$ride_length <- as.numeric(
  as.character(all_trips$ride_length)
)

# Once the data was organized and compiled into one large dataset we now begin to 
# seperate the trips by" year, month, week, day and the day of week.

# Seperating the year 
all_trips$year <- format(
  all_trips$started_at, 
  "%Y"
)

# Seperating the month 
all_trips$month <- format(
  all_trips$started_at, 
  "%m"
)

# Seperating the week 
all_trips$week <- format(
  all_trips$started_at,
  "%W"
)

# Seperating the day
all_trips$day <- format(
  all_trips$started_at, 
  "%d"
)

# Seperating the day of week 
all_trips$day_of_week <- format(
  all_trips$started_at, 
  "%A"
)

# Date, YYYY-MM-DD
all_trips$YMD <- format(
  all_trips$started_at, 
  "%Y-%m-%d"
)

# Time of Day, HH:MM:SS
all_trips$ToD <- format(
  all_trips$started_at, 
  "%H:%M:%S"
)

view(all_trips)


#########################################################
all_trips <- all_trips %>%
  arrange(ride_length)
# once we arrange the ride legnths we ntoice that there are many lenghts at 0 or velow so these are removed with the following line 

all_trips_cleaned <- all_trips %>%
  filter(!(ride_length < 0))

#As we contineu to inspect the data we notice mant blank fields in the start and end stations 

all_trips_cleaned <- all_trips_cleaned %>%
  filter(
    !(is.na(start_station_name) |
        start_station_name == "")
  ) %>% 
  
  filter(
    !(is.na(end_station_name) |
        end_station_name == "")
  )

fwrite(all_trips,"E:\\R\\Directory\\Trip_data\\all_trips_cleaned.csv")

#After viewinv the data we noticed a few station ids with capital letters, these were then filtered out and inpsected 
capitalized_station_name_check <- all_trips_cleaned %>%
  
  filter(
    str_detect(start_station_name, "[:upper:]")
    & !str_detect(start_station_name,"[:lower:]")
  ) %>%
  
  group_by(
    start_station_name
  ) %>%
  
  count(
    start_station_name
  )
#We found that there are 2 station names that were capitalized: DIVVY CASSETTE REPAIR MOBILE STATION & WEST CHI-WATSON

which(all_trips_cleaned$start_station_name == "DIVVY CASSETTE REPAIR MOBILE STATION")

view(all_trips_cleaned %>%
       +     filter(start_station_name == "WEST CHI-WATSON")) 
#Both of these station are test stations or repair stations used by the company so they will be removed so we can focus on customer use.

all_trips_cleaned <- all_trips_cleaned %>%
  filter(
    !(str_detect(start_station_name, "[:upper:]")
      & !str_detect(start_station_name, "[:lower:]"))
  )

#Following the removal of noncustomer usage we also want to verify that there is no duplciate data.
ride_id_check <- all_trips_cleaned %>%
  count(ride_id) %>%
  filter(n > 1)
# The return of 0 shows that we have no duplicate users. 


#We now check the station names 

station_name <- all_trips_cleaned %>%
  group_by(start_station_name) %>%
  count(start_station_name)
view(station_name)

#We create a montly breakdown of what stations were used each month 

#January 2021 dataframe that lists the unique stations used 

Jan_21_filter <- all_trips_cleaned %>%
  filter(
      month == "01" & year == "2021"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )
  
  
# April 2021 filter 

Apr_21_filter <- all_trips_cleaned %>%
  filter(
    month == "04" & year == "2021"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#May 2021 Filter 

May_21_filter <- all_trips_cleaned %>%
  filter(
    month == "05" & year == "2021"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#July 2021 filter
 

Jul_21_filter <- all_trips_cleaned %>%
  filter(
    month == "07" & year == "2021"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#August 2021 filter 

Aug_21_filter <- all_trips_cleaned %>%
  filter(
    month == "08" & year == "2021"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#September 2021 filter

Sep_21_filter <- all_trips_cleaned %>%
  filter(
    month == "09" & year == "2021"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#October 2021 Filter 

Oct_21_filter <- all_trips_cleaned %>%
  filter(
    month == "10" & year == "2021"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )
#December 2021 filter 

Dec_21_filter <- all_trips_cleaned %>%
  filter(
    month == "12" & year == "2021"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )
#february 2022 Filter 

Feb_22_filter <- all_trips_cleaned %>%
  filter(
    month == "02" & year == "2022"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#March 2022 filter 

Mar_22_filter <- all_trips_cleaned %>%
  filter(
    month == "03" & year == "2022"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#April 2022 filter 

Apr_22_filter <- all_trips_cleaned %>%
  filter(
    month == "04" & year == "2022"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#May 2022 filter 

May_22_filter <- all_trips_cleaned %>%
  filter(
    month == "05" & year == "2022"
  )  %>%
  group_by(
    start_station_name
  ) %>%
  count(
    start_station_name
  )

#Confirm that unqie station names can be tested against the monthly filter data frames to observe
# which station was used in each month. 


station_name$Jan_21 <- as.integer(station_name$start_station_name 
                                  %in% Jan_21_filter$start_station_name)

station_name$Apr_21 <- as.integer(station_name$start_station_name
                              %in% Apr_21_filter$start_station_name)

station_name$May_21 <- as.integer(station_name$start_station_name
                                  %in% May_21_filter$start_station_name)

station_name$Jul_21 <- as.integer(station_name$start_station_name
                                  %in% Jul_21_filter$start_station_name)

station_name$Aug_21 <- as.integer(station_name$start_station_name
                                  %in% Aug_21_filter$start_station_name)

station_name$Sep_21 <- as.integer(station_name$start_station_name
                                  %in% Sep_21_filter$start_station_name)

station_name$Oct_21 <- as.integer(station_name$start_station_name
                                  %in% Oct_21_filter$start_station_name)

station_name$Dec_21 <- as.integer(station_name$start_station_name
                                  %in% Dec_21_filter$start_station_name)

station_name$Feb_22 <- as.integer(station_name$start_station_name
                                  %in% Feb_22_filter$start_station_name)

station_name$Mar_22 <- as.integer(station_name$start_station_name
                                  %in% Mar_22_filter$start_station_name)

station_name$Apr_22 <- as.integer(station_name$start_station_name
                                  %in% Apr_22_filter$start_station_name)

station_name$May_22 <- as.integer(station_name$start_station_name
                                  %in% May_22_filter$start_station_name)

station_name$count <- rowSums(station_name[,3:14])

# We filter to see if there were any stations that were not used year around 
view(station_name %>%
       filter(count < 12))
#############################################################################

# Check A 
station_name_check_A <- station_name %>%
  filter(
    Apr_22<1 & Oct_21<1
  )

# Check B
station_name_check_B <- station_name %>%
  filter(
    Jul_21<1 & Aug_21<1
  )

###################################################################
# Saving the data for analysis 

fwrite(all_trips,"E:\\R\\Directory\\Trip_data\\all_trips.csv")
fwrite(all_trips_cleaned,"E:\\R\\Directory\\Trip_data\\all_trips_cleaned.csv")
fwrite(rideable_type_check,"E:\\R\\Directory\\Trip_data\\rideable_type_check.csv")
fwrite(station_name,"E:\\R\\Directory\\Trip_data\\station_name_check.csv")
