library('mongolite')
library('magrittr')
library('dplyr')

# load config
readRenviron(".env")

# setup connection
connection <- mongo(collection = "visitor", db = "lorauna", url = Sys.getenv("MONGO_URL"))

# read abd filter data
visitors <- connection$find(
  query = '{
    "created": { "$gte" : { "$date" : "2019-01-01T00:00:00Z" }},
    "created": { "$lte" : { "$date" : "2019-01-15T00:00:00Z" }}
  }'
)

# add date column
visitors$date <- as.Date(visitors$created)

# add day
visitors$day <- format(visitors$date, '%d')

# add week day
visitors$weekday <- weekdays(as.Date(visitors$date))

# add month
visitors$month <- months(as.Date(visitors$date))

# filter weekdays
visitors <- visitors %>% filter(weekday %in% c('Monday', 'Tuesday', 'Friday', 'Saturday', 'Sunday'))

# create data frame from list
visitors_in <- visitors %>% filter(value == 1)

# count positive values per day
aggregate(visitors_in['value'], by=visitors_in['weekday'], sum)

aggregate(visitors_in['value'], by=visitors_in['day'], sum)

# make a report for each month

# sum count of visitors

# show average frequency by weekday

# 

