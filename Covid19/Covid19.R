## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message=FALSE, warning = FALSE)


## ------------------------------------------------------------------------
library(tidyverse)    # for almost all data handling tasks
library(ggplot2)      # to produce nice graphiscs
library(stargazer)    # to produce nice results tables
library(AER)          # access to HS robust standard errors
library(readxl)       # enable the read_excel function
library(ggplot2)      # plotting toolbox


## ------------------------------------------------------------------------
#these libraries need to be loaded
library(utils)
library(httr)

#download the dataset from the ECDC website to a local temporary file
GET("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", authenticate(":", ":", type="ntlm"), write_disk(tf <- tempfile(fileext = ".csv")))

#read the Dataset sheet into “R”. The dataset will be called "data".
data <- read.csv(tf)


## ------------------------------------------------------------------------
str(data)


## ------------------------------------------------------------------------
names(data)[names(data) == "countriesAndTerritories"] <- "country"
names(data)[names(data) == "countryterritoryCode"] <- "countryCode"
names(data)[names(data) == "dateRep"] <- "dates"


## ------------------------------------------------------------------------
data$dates <- as.Date(as.character(data$dates),format = "%d/%m/%Y")


## ------------------------------------------------------------------------
data_china <- data %>%  filter(country == "China")
plot(data_china$dates,data_china$deaths)  # specifies variable for x and y axis


## ------------------------------------------------------------------------
test <- c(0,0,2,4,9,2)
cumsum(test)


## ------------------------------------------------------------------------
data <- data %>% group_by(country) %>% 
          arrange(dates) %>% 
          mutate(c_cases = cumsum(cases), c_deaths = cumsum(deaths)) %>% 
          ungroup()


## ------------------------------------------------------------------------
g1 <- ggplot(subset(data, country == "China"), aes(x=dates,y=cases)) +
      geom_line() + 
      ggtitle("Covid-19 daily cases")
g1


## ------------------------------------------------------------------------
sel_countries <- c("China", "South_Korea")
g2 <- ggplot(subset(data, country %in% sel_countries), 
             aes(x=dates,y=cases, color = country)) +
      geom_line() + 
      ggtitle("Covid-19 daily cases")
g2


## ------------------------------------------------------------------------
sel_countries <- c("Spain", "France", "United_Kingdom")
g3 <- ggplot(subset(data, country %in% sel_countries), 
             aes(x=dates,y=cases, color = country)) +
      geom_line(size = 1) +   # size controls the line thickness
      ggtitle("Covid-19 daily cases")
g3


## ------------------------------------------------------------------------
sel_countries <- c("France")
g4 <- ggplot(subset(data, country %in% sel_countries), 
             aes(x=dates,y=cases, color = country)) +
      geom_line(size = 1) +   # size controls the line thickness
      geom_smooth(method = "loess", span = 0.1) + # smoothed data
      ggtitle("Covid-19 daily cases")
g4


## ------------------------------------------------------------------------
sel_countries <- c("Spain", "France", "United_Kingdom")
g5 <- ggplot(subset(data, country %in% sel_countries), 
             aes(x=dates,y=cases, color = country)) +
      geom_smooth(method = "loess", span = 0.1) + # smoothed data
      ggtitle("Covid-19 daily cases")
g5


## ------------------------------------------------------------------------
sel_countries <- c("Germany", "France", "United_Kingdom")
g6 <- ggplot(subset(data, country %in% sel_countries), 
             aes(x=dates,y=c_cases, color = country)) +
      geom_line(size = 1) + 
      ggtitle("Covid-19 cumulative cases")
g6


## ------------------------------------------------------------------------
sel_countries <- c("Germany", "France", "United_Kingdom")
g7 <- ggplot(subset(data, country %in% sel_countries), 
             aes(x=dates,y=c_cases, color = country)) +
      geom_line(size = 1) + 
      scale_y_continuous(trans='log2') +
      ggtitle("Covid-19 cumulative cases")
g7


## ------------------------------------------------------------------------
library(sf)
library(raster)
library(dplyr)
library(spData)
library(tmap)


## ------------------------------------------------------------------------
# Add fill and border layers to world shape
tm_shape(world) + tm_polygons(col = "lifeExp") 


## ------------------------------------------------------------------------
m2 <- tm_shape(world) 
str(m2)


## ------------------------------------------------------------------------
temp <- m2$tm_shape$shp
names(temp)




## ---- eval = FALSE-------------------------------------------------------
## Error in (function (classes, fdef, mtable)  :
##   unable to find an inherited method for function ‘select’ for signature ‘"tbl_df"’


## ------------------------------------------------------------------------
temp_mergein <- data %>% filter(dates == "2020-04-04") %>% 
                          dplyr::select(geoId, cases, c_cases, deaths, c_deaths)


## ------------------------------------------------------------------------
temp_mergein$geoId <- as.character(temp_mergein$geoId)
temp_mergein$geoId[temp_mergein$geoId == "UK"] <- "GB" 


## ------------------------------------------------------------------------
temp <- merge(temp, temp_mergein, by.x = "iso_a2", by.y = "geoId", all.x = TRUE)


## ------------------------------------------------------------------------
m2$tm_shape$shp <- temp


## ------------------------------------------------------------------------
# Add polygons layer to world shape
m2 + tm_polygons(col = "deaths", n=10)  # n = 10 controls the number of categories



## ------------------------------------------------------------------------
m2 + tm_polygons(col = "deaths", n=10) +  # n = 10 controls the number of categories
      tm_style("col_blind")


## ------------------------------------------------------------------------
m3 <- tm_shape(world) # create a new shape file from scratch
temp3 <- m3$tm_shape$shp

# prepare the data from data
date_sel <- seq(as.Date("2020-01-01"), as.Date("2020-04-04"), 7)
temp_mergein <- data %>% filter(dates %in% date_sel) %>% 
                  dplyr::select(geoId, dates, cases, c_cases, deaths, c_deaths) %>% 
                  arrange(geoId,dates)
temp_mergein$geoId <- as.character(temp_mergein$geoId)
temp_mergein$geoId[temp_mergein$geoId == "UK"] <- "GB" 


## ------------------------------------------------------------------------
temp3 <- merge(temp3, temp_mergein, by.x = "iso_a2", by.y = "geoId", all.x = TRUE)
temp3$dates <- as.character(temp3$dates)
temp3 <- temp3 %>%  filter(!is.na(dates)) %>%   # Remove countries with no dates
                    arrange(iso_a2,dates)
m3$tm_shape$shp <- temp3


## ------------------------------------------------------------------------
covid_anim <- m3 + tm_polygons(col = "cases",  
                               style = "fixed",
                               breaks = c(0,50,100,250,500,1000,5000,25000)) + 
  tm_layout(legend.outside = TRUE) +
  tm_facets(along = "dates")


## ------------------------------------------------------------------------
tmap_animation(covid_anim, filename = "covid_anim.gif", delay = 200, width = 1200, height = 800)

