## ----setup, include=FALSE-------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message=FALSE, warning = FALSE)


## -------------------------------------------------------------------------------------------------
#install.packages(c("sets", "forecast", "readxl", "tidyverse", "ggplot2", "utils", "httr"))

library(sets)         # used for some set operations
library(readxl)       # enable the read_excel function
library(tidyverse)    # for almost all data handling tasks
library(ggplot2)      # plotting toolbox
library(utils)        # for reading data into R # for reading data into R 
library(httr)         # for downloading data from a URL 
library(stargazer)    # for nice regression output


## -------------------------------------------------------------------------------------------------
#download the dataset from the ECDC website to a local temporary file (“tf”)
GET("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", 
    authenticate(":", ":", type="ntlm"), 
    write_disk(tf <- tempfile(fileext = ".csv")))
#read the Dataset sheet into “R”. The dataset will be called "data".
data <- read.csv(tf) 


## -------------------------------------------------------------------------------------------------
str(data)


## -------------------------------------------------------------------------------------------------
names(data)[names(data) == "countriesAndTerritories"] <- "country"
names(data)[names(data) == "countryterritoryCode"] <- "countryCode"
names(data)[names(data) == "dateRep"] <- "dates"


## -------------------------------------------------------------------------------------------------
data$dates <- as.Date(as.character(data$dates),format = "%d/%m/%Y")


## -------------------------------------------------------------------------------------------------
g1 <- ggplot(subset(data, country == "China"), aes(x=dates,y=deaths_weekly)) +
      geom_line() + 
      ggtitle("Covid-19 weekly cases")
g1


## -------------------------------------------------------------------------------------------------
sel_countries <- c("China", "South_Korea")
g2 <- ggplot(subset(data, country %in% sel_countries), 
             aes(x=dates,y=cases_weekly, color = country)) +
      geom_line() + 
      ggtitle("Covid-19 daily cases")
g2


## -------------------------------------------------------------------------------------------------
countryInd <- read_csv("Data_Introduction/CountryIndicators.csv",na = "#N/A") 
data<- merge(data,countryInd,,all.x=TRUE)


## ---- echo = TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE----------------

data <- data %>% mutate(popdens = popData2019/Land_Area_sqkm)  # calculate population density


## ---- echo = TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE----------------
table3 <- data %>% group_by(country) %>% # groups by Country
            summarise(Avg_cases = mean(pc_cases,na.rm = TRUE),
                      Avg_deaths = mean(pc_deaths,na.rm = TRUE),
                      PopDen = mean(popdens))    


## ---- echo = TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE----------------
ggplot(table3,aes(PopDen,Avg_deaths)) +
  geom_point() +
  scale_x_log10() +
  ggtitle("Population Density v Per Capita Deaths")


## ---- echo = TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE----------------
cor(table3$PopDen, table3$Avg_deaths,use = "complete.obs")


## ---- echo = TRUE, eval=TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE-----
seldate <- "2021-02-01"   # Set the date you wnat to look at
table4 <- data %>%   filter(dates == seldate) %>% 
              group_by(continentExp) %>% 
              summarise(Avg_cases = mean(pc_cases, na.rm = TRUE),
                        Avg_deaths = mean(pc_deaths, na.rm = TRUE),
                        n = n()) %>% print()


## ---- echo = TRUE, eval=TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE-----
test_data_EU <- data %>% 
  filter(continentExp == "Europe") %>%     # pick European data
  filter(dates == seldate)    # pick the date
mean_EU <- mean(test_data_EU$pc_cases,rm.na = TRUE)

test_data_AM <- data %>% 
  filter(continentExp == "America") %>%     # pick European data
  filter(dates == seldate)    # pick the date
mean_AM <- mean(test_data_AM$pc_cases,rm.na = TRUE)

sample_diff <- mean_EU - mean_AM
paste("mean_EU =", round(mean_EU,1),", mean_A =", round(mean_AM,1))
paste("sample_diff =", round(sample_diff,1))


## ---- echo = TRUE, eval=TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE-----
t.test(test_data_EU$pc_cases,test_data_AM$pc_cases, mu=0)  # testing that mu = 0


## ---- echo = TRUE, eval=TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE-----
test_data_AF <- data %>% 
  filter(continentExp == "Africa") %>%     # pick European data
  filter(dates == "2021-02-01")    # pick the date

test_data_AS <- data %>% 
  filter(continentExp == "Asia") %>%     # pick European data
  filter(dates == "2021-02-01")    # pick the date

t.test(test_data_AF$pc_cases,test_data_AS$pc_cases, mu=0)   # testing that mu = 0


## ---- echo = TRUE, eval=TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE-----
names(table3)


## ---- echo = TRUE, eval=TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE-----
mergecont <- data %>% dplyr::select(country,continentExp, GDPpc, HealthExp) %>%  
                    unique() %>% # this reduces each country to one line
                    drop_na  # this drops all countries which have incomplete information
table3 <- merge(table3,mergecont) # merges in continent information
table3 <- table3 %>% mutate(GDPpc = GDPpc/1000) # convert pc GDP into units of $1,000


## ---- echo = TRUE, eval=TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE,fig.height = 2.0, fig.width = 4.5----
ggplot(table3, aes(x=GDPpc, y=Avg_deaths)) +
    labs(x = "GDPpc", y = "Avg_deaths") +
    geom_point(size = 1.0) +    
    geom_abline(intercept = mod2$coefficients[1], 
                slope = mod2$coefficients[2], col = "blue")+
    ggtitle("GDPpc v Avg_deaths from Covid-19")


## ---- echo = TRUE, eval=TRUE, error = FALSE, message = FALSE, results = TRUE, warning = FALSE-----
mod3 <- lm(Avg_deaths~GDPpc+HealthExp,data=table3)
stargazer(mod3,type = "text")

## Add Obesity and Age distribution measure
# Sources:
# https://en.wikipedia.org/wiki/List_of_countries_by_obesity_rate
# https://data.worldbank.org/indicator/SP.POP.65UP.TO.ZS?name_desc=false
# Thanks to Charlotte!

obesity <- read_csv("Data_Introduction/Obesity.csv")
over65p <- read_excel("Data_Introduction/Over 65s 2.xlsx")

data <- merge(data,obesity)
data <- merge(data,over65p)

healthmerge2 <- data %>% dplyr::select(country,Obese_Pcent,Over_65s,Diabetis) %>%  unique() %>% drop_na()
table3b <- merge(table3,healthmerge2)

mod4 <- lm(Avg_deaths~GDPpc+HealthExp+Obese_Pcent+Over_65s+Diabetis,data=table3b)
stargazer(mod3,mod4,type = "text")
