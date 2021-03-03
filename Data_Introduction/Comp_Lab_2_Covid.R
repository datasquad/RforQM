# Computer Lab 2

## -------------------------------------------------------------------------------------------
library(sets)         # used for some set operations
library(readxl)       # enable the read_excel function
library(tidyverse)    # for almost all data handling tasks
library(ggplot2)      # plotting toolbox
library(utils)        # for reading data into R # for reading data into R 
library(httr)         # for downloading data from a URL 
library(stargazer)    # for nice regression output


## ---- eval= FALSE---------------------------------------------------------------------------
## setwd("YOUR WORKING DORECTORY")
## data <- read.csv(XXXX,na="XXXX")
## str(data)
## 


## ---- echo = FALSE--------------------------------------------------------------------------
setwd("C:/Rcode/RforQM/Data_Introduction")
# ,na.strings="#N/A", stringsAsFactors = TRUE
data <- read.csv("StaticECDCdata_8Feb21.csv",na.strings="#N/A", stringsAsFactors = TRUE)
str(data)



## -------------------------------------------------------------------------------------------
names(data)[names(data) == "countriesAndTerritories"] <- "country"
names(data)[names(data) == "countryterritoryCode"] <- "countryCode"
names(data)[names(data) == "dateRep"] <- "dates"

data$dates <- as.Date(as.character(data$dates),format = "%d/%m/%Y")


## -------------------------------------------------------------------------------------------
data <- data %>%  
          mutate(pc_cases = (cases_weekly/popData2019)*100000, 
                 pc_deaths = (deaths_weekly/popData2019)*100000)


## ---- eval = FALSE--------------------------------------------------------------------------
## g1 <- XXXX(subset(XXXX, XXXX == "Brazil"), aes(x=dates,y=deaths_weekly)) +
##       geom_XXXX() +
##       ggtitle("Covid-19 weekly cases, Brazil")
## g1


## ---- echo = FALSE--------------------------------------------------------------------------
g1 <- ggplot(subset(data, country == "Brazil"), aes(x=dates,y=deaths_weekly)) +
      geom_line(size=1) + 
      ggtitle("Covid-19 weekly deaths, Brazil")
g1


## -------------------------------------------------------------------------------------------
temp <- data %>% select(country,popData2019) %>%  
          unique() %>% 
          arrange(desc(popData2019)) 
head(temp,14)

## ---- eval = FALSE--------------------------------------------------------------------------
sel_countries <- c("Brazil", "Pakistan", "Nigeria")
g2 <- ggplot(subset(data, country %in% sel_countries),
             aes(x=dates,y=deaths_weekly, color = country)) +
      geom_line(size=1) +
      ggtitle("Covid-19 weekly cases")
g2



## ---- echo = TRUE---------------------------------------------------------------------------
countryInd <- read_csv("CountryIndicators.csv",na = "#N/A") 
countryInd <- countryInd %>% select(-country)
# by.x and by.y specify the matching variables of x (data) and y (countryInd)
data<- merge(data,countryInd,by.x="geoId", by.y="geoID",all.x=TRUE)

obesity <- read_csv("Obesity.csv")   # Adds obesity and diabetis country
obesity <- obesity %>% select(-country)
data <- merge(data,obesity,by.x="geoId", by.y="geoID",all.x=TRUE)


## ---- echo = TRUE---------------------------------------------------------------------------
over65p <- read_excel("Over 65s 2.xlsx")
data <- merge(data,over65p,all.x=TRUE)


## -------------------------------------------------------------------------------------------
view(data)
str(data)
summary(data)
names(data)


## ---- eval=FALSE----------------------------------------------------------------------------
## # calculate population density
## data <- data %>% XXXX(popdens = XXXX/XXXX)


## ---- echo=FALSE----------------------------------------------------------------------------
# calculate population density
data <- data %>% mutate(popdens = popData2019/Land_Area_sqkm)  


## ---- echo=FALSE----------------------------------------------------------------------------
summary(data$popdens)


## ---- eval = FALSE--------------------------------------------------------------------------
## table3 <- data %>% group_by(country) %>% # groups by Country
##             summarise(Avg_cases = mean(pc_cases,na.rm = TRUE),
##                       Avg_deaths = mean(pc_deaths,na.rm = TRUE),
##                       PopDen = mean(popdens))


## ---- eval = FALSE--------------------------------------------------------------------------
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
                      Continent = first(continentExp))



head(table3)


## -------------------------------------------------------------------------------------------
ggplot(table3,aes(PopDen,Avg_deaths)) +
  geom_point() +
  scale_x_log10() +
  ggtitle("Population Density v Per Capita Deaths")


## ---- echo=FALSE----------------------------------------------------------------------------
ggplot(table3,aes(Obese,Avg_deaths)) +
  geom_point() +
  ggtitle("Percentage of Obese v Per Capita Deaths")


## ---- echo=FALSE----------------------------------------------------------------------------
ggplot(table3,aes(Diabetis,Avg_deaths)) +
  geom_point() +
  ggtitle("Prevalence of Diabetis v Per Capita Deaths")


## ---- echo=TRUE-----------------------------------------------------------------------------
ggplot(table3,aes(Over_65s,Avg_deaths)) +
  geom_point() +
  facet_wrap(~ Continent) +  # this is where the magic happens!
  theme_bw() +
  ggtitle("Percentage of over 65 v Per Capita Deaths")


## -------------------------------------------------------------------------------------------
table4 <- table3 %>%   
              group_by(Continent) %>% 
              summarise(CAvg_cases = mean(Avg_cases, na.rm = TRUE),
                        CAvg_deaths = mean(Avg_deaths, na.rm = TRUE),
                        n = n()) %>% print()


## -------------------------------------------------------------------------------------------
test_data_AS <- table3 %>% 
  filter(Continent == "Asia")      # pick Asian data

test_data_AM <- table3 %>% 
  filter(Continent == "America")      # pick American data

t.test(test_data_AS$Avg_deaths,test_data_AM$Avg_deaths, mu=0)  # testing that mu = 0


## -------------------------------------------------------------------------------------------
test_data_EU <- table3 %>% 
  filter(Continent == "Europe")      # pick European data

test_data_AM <- table3 %>% 
  filter(Continent == "America")      # pick American data

t.test(test_data_EU$Avg_cases,test_data_AM$Avg_cases, mu=50, alternative = "greater") 


## ---- eval = FALSE--------------------------------------------------------------------------
## t.test(test_data_XXXX$Avg_cases,test_data_XXXX$Avg_cases, mu=XXXX, alternative = XXXX)


## ---- echo = FALSE--------------------------------------------------------------------------
t.test(test_data_EU$Avg_cases,test_data_AS$Avg_cases, mu=100, alternative = "greater") 


## -------------------------------------------------------------------------------------------
library(car)


## -------------------------------------------------------------------------------------------
mod3 <- lm(Avg_deaths~GDPpc+HealthExp,data=table3)
stargazer(mod3,type = "text")


## ---- eval = FALSE--------------------------------------------------------------------------
mod4 <- lm(Avg_deaths~GDPpc+HealthExp+Obese+Diabetis+Over_65s,data=table3)
stargazer(mod3,mod4,type = "text")


## ---- echo = FALSE--------------------------------------------------------------------------
mod4 <- lm(Avg_deaths~GDPpc+HealthExp+Obese+Over_65s+Diabetis,data=table3)
stargazer(mod3,mod4,type = "text")


## -------------------------------------------------------------------------------------------
lht(mod4,"Obese=0")


## ---- echo = FALSE--------------------------------------------------------------------------
lht(mod4,"HealthExp=0")


## -------------------------------------------------------------------------------------------
lht(mod4,"Over_65s=0.1")


## ---- echo = FALSE--------------------------------------------------------------------------
lht(mod4,c("Obese=0","Diabetis=0","Over_65s=0"))

