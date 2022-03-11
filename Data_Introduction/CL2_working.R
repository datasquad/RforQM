library(readxl) # enable the read_excel function
library(tidyverse) # for almost all data handling tasks
library(ggplot2) # plotting toolbox
library(utils) # for reading data into R # for reading data into R
library(httr) # for downloading data from a URL
library(stargazer) # for nice regression output
library(ISOweek) # Weeks are provided in the ISO weeks format
library(countrycode) # to translate country codes
library(car)

setwd("C:/Rcode/RforQM/Data_Introduction")
data <- read.csv("StaticECDCdata_18Feb22.csv",na="NA", 
                 stringsAsFactors = TRUE)
str(data)

# remove continent data
data <- data %>% filter(!is.na(country_code))

data <- data %>%
  mutate(pc_cases = (cases_weekly/popData2019)*100000,
         pc_deaths = (deaths_weekly/popData2019)*100000)


data <- data %>%
  separate(dates, c("year", "week"), "-") %>%
  mutate(dates = ISOweek2date(paste0(year,"-W",week,"-4")))


g1 <- ggplot(subset(data, country == "Brazil"), 
             aes(x=dates,y=deaths_weekly)) +
  geom_line(size=2) +
  ggtitle("Covid-19 weekly cases, Brazil")
g1

temp <- data %>% select(country,popData2019) %>%
  unique() %>%
  arrange(desc(popData2019))

head(temp,14)

sel_countries <- c("Brazil", "Pakistan", "Nigeria")
g2 <- ggplot(subset(data, country %in% sel_countries),
             aes(x=dates,y=deaths_weekly, color = country)) +
  geom_line(size=2) +
  ggtitle("Covid-19 weekly cases")
g2

countryInd <- read_csv("CountryIndicators.csv",na = "#N/A")
countryInd <- countryInd %>% select(-country)
obesity <- read_csv("Obesity.csv") # Adds obesity and diabetis country
obesity <- obesity %>% select(-country)
over65p <- read_excel("Over 65s 2.xlsx")



data$geoID <- countrycode(data$country_code, 
                          origin = "iso3c", destination = "iso2c")

# by.x and by.y specify the matching variables of x (data) and y (countryInd)

data <- merge(data,countryInd,by.x="geoID", by.y="geoID",all.x=TRUE)

data <- merge(data,obesity,by.x="geoID", by.y="geoID",all.x=TRUE)

data <- merge(data,over65p,by.x="country_code", by.y="countryCode",all.x=TRUE)

summary(data)


data <- data %>% mutate(popdens = popData2019/Land_Area_sqkm)

table3 <- data %>% group_by(country) %>% # groups by Country
  summarise(Avg_cases = mean(pc_cases,na.rm = TRUE),
            Avg_deaths = mean(pc_deaths,na.rm = TRUE),
            PopDen = mean(popdens))

table3 <- data %>% filter(dates>"2020-06-01") %>%
  group_by(country) %>% # groups by Country
  summarise(Avg_cases = mean(pc_cases,na.rm = TRUE),
            Avg_deaths = mean(pc_deaths,na.rm = TRUE),
            PopDen = first(popdens),
            Obese = first(Obese_Pcent),
            Diabetis = first(Diabetis),
            Over_65s = first(Over_65s),
            GDPpc = first(GDPpc)/1000, # calculate GDPpc in $1000s
            HealthExp = first(HealthExp),
            Continent = first(continent))


ggplot(table3,aes(PopDen,Avg_deaths)) +
  geom_point(size=2) +
  scale_x_log10() +
  ggtitle("Population Density v Per Capita Deaths")


ggplot(table3,aes(Over_65s,Avg_deaths)) +
  geom_point() +
  facet_wrap(~ Continent) + # this is where the magic happens!
  theme_bw() +
  ggtitle("Percentage of over 65 v Per Capita Deaths")


table4 <- table3 %>%
  group_by(Continent) %>%
  summarise(CAvg_cases = mean(Avg_cases, na.rm = TRUE),
            CAvg_deaths = mean(Avg_deaths, na.rm = TRUE),
            n = n()) %>% print()


test_data_AS <- table3 %>%
  filter(Continent == "Asia") # pick Asian data
test_data_AM <- table3 %>%
  filter(Continent == "America") # pick European data

t.test(test_data_AS$Avg_deaths,test_data_AM$Avg_deaths, mu=0) # testing that mu = 0



test_data_EU <- table3 %>%
  filter(Continent == "Europe") # pick European data
test_data_AM <- table3 %>%
  filter(Continent == "America") # pick American data

t.test(test_data_EU$Avg_cases,test_data_AM$Avg_cases, mu=100, alternative = "greater")



mod3 <- lm(Avg_deaths~GDPpc+HealthExp,data=table3)
stargazer(mod3,type = "text")

mod4 <- lm(Avg_deaths~GDPpc+HealthExp+Obese+Over_65s,data=table3)
stargazer(mod3,mod4,type = "text")

lht(mod4,"Obese=0")
lht(mod4,"Over_65s=0.1")
