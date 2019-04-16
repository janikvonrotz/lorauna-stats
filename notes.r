library('mongolite')
library('magrittr')
library('dplyr')
library('readr')

# load config
readRenviron(".env")

# setup connection
connection <- mongo(collection = "visitor", db = "lorauna", url = Sys.getenv("MONGO_URL"))

# read and filter visitors data
visitors <- connection$find(
  query = '{
    "created": { "$gte" : { "$date" : "2019-01-01T00:00:00Z" }},
    "created": { "$lte" : { "$date" : "2019-01-15T00:00:00Z" }}
  }'
)

# add date column
visitors$date <- as.Date(visitors$created)

# add day column
visitors$day <- format(visitors$date, '%d')

# add week day column
visitors$weekday <- weekdays(as.Date(visitors$date))

# add month column
visitors$month <- months(as.Date(visitors$date))

# filter weekdays
visitors <- visitors %>% filter(weekday %in% c('Monday', 'Tuesday', 'Friday', 'Saturday', 'Sunday'))

# filter incoming visitors
visitors_in <- visitors %>% filter(value == 1)

# aggregate by weekday or day
aggregate(visitors_in['value'], by=visitors_in['weekday'], sum)
aggregate(visitors_in['value'], by=visitors_in['day'], sum)

# read all visitors and export to json file
visitors_all <- connection$find()
visitors_all %>% toJSON() %>% write_lines('visitors.json')

# read json
visitors <- fromJSON(file='visitors.json')