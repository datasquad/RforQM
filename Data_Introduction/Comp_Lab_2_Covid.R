# Computer Lab 2

## -------------------------------------------------------------------------------------------
library(readxl)       # enable the read_excel function
library(tidyverse)    # for almost all data handling tasks
library(ggplot2)      # plotting toolbox
library(utils)        # for reading data into R # for reading data into R 
library(httr)         # for downloading data from a URL 
library(stargazer)    # for nice regression output
library(ISOweek) # Weeks are provided in the ISO weeks format
library(countrycode) # to translate country codes

## ---- eval= FALSE---------------------------------------------------------------------------
## setwd("YOUR WORKING DORECTORY")
## data <- read.csv(XXXX,na="XXXX")
## str(data)
## 


## ---- echo = FALSE--------------------------------------------------------------------------
setwd("C:/Rcode/RforQM/Data_Introduction")
# ,na.strings="#N/A", stringsAsFactors = TRUE
data <- read.csv("StaticECDCdata_18Feb22.csv",na.strings="#N/A", stringsAsFactors = TRUE)
str(data)


# remove continent data
data <- data %>% filter(!is.na(country_code))

data <- data %>%
  mutate(pc_cases = (cases_weekly/popData2019)*100000,
         pc_deaths = (deaths_weekly/popData2019)*100000)

data <- data %>%
  separate(dates, c("year", "week"), "-") %>%
  mutate(dates = ISOweek2date(paste0(year,"-W",week,"-4")))

countryInd <- read_csv("CountryIndicators.csv",na = "#N/A")
countryInd <- countryInd %>% select(-country)
obesity <- read_csv("Obesity.csv") # Adds obesity and diabetis country
obesity <- obesity %>% select(-country)
over65p <- read_excel("Over 65s 2.xlsx")

data$geoID <- countrycode(data$country_code, origin = "iso3c", destination = "iso2c")

# by.x and by.y specify the matching variables of x (data) and y (countryInd)
data<- merge(data,countryInd,by.x="geoID", by.y="geoID",all.x=TRUE)
data <- merge(data,obesity,by.x="geoID", by.y="geoID",all.x=TRUE)

data <- merge(data,over65p,by.x="country_code", by.y="countryCode",all.x=TRUE)
names(data)

# calculate population density
data <- data %>% mutate(popdens = popData2019/Land_Area_sqkm) 

summary(data$popdens)

table3 <- data %>% group_by(country) %>% # groups by Country
  summarise(Avg_cases = mean(pc_cases,na.rm = TRUE),
            Avg_deaths = mean(pc_deaths,na.rm = TRUE),
            PopDen = mean(popdens))

table3 <- data %>% filter(dates >= "2020-06-01") %>% 
  group_by(country) %>% # groups by Country
  summarise(Avg_cases = mean(pc_cases,na.rm = TRUE),
            Avg_deaths = mean(pc_deaths,na.rm = TRUE),
            PopDen = first(popdens),
            Obese = first(Obese_Pcent),
            Diabetis = first(Diabetis),
            Over_65s = first(Over_65s),
            GDPpc = first(GDPpc)/1000,  # calculate GDPpc in $1000s
            HealthExp = first(HealthExp),
            Continent = first(continent))    

head(table3)

















# Regression

library(car)

mod3 <- lm(Avg_deaths~GDPpc+HealthExp,data=table3)


stargazer(mod3,type = "text")

mod4 <- lm(Avg_deaths~GDPpc+HealthExp+Diabetis+Obese+Over_65s,data=table3)

stargazer(mod3,mod4,type = "text")

lht(mod4,"Obese=0")


lht(mod4,"HealthExp=0")

lht(mod4,c("Obese=0","Over_65s=0","Diabetis=0"))


