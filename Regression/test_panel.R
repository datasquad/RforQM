setwd("C:/Rcode/RforQM/Regression")
library(tidyverse) # for almost all data handling tasks
library(ggplot2) # to produce nice graphiscs
library(stargazer) # to produce nice results tables
library(haven) # to import stata file
library(AER) # access to HS robust standard errors
source("stargazer_HC.r") # includes the robust regression display
library(plm)

data_USoc <- read_dta("20222_USoc_extract.dta")
data_USoc <- as.data.frame(data_USoc) # ensure data frame structure
names(data_USoc)

data_USoc$region <- as_factor(data_USoc$region)
data_USoc$male <- as_factor(data_USoc$male)
data_USoc$degree <- as_factor(data_USoc$degree)
data_USoc$race <- as_factor(data_USoc$race)

data_USoc <- data_USoc %>%
  mutate(hrpay = paygu/(jbhrs*4)/(cpi/100)) %>%
  mutate(lnhrpay = log(hrpay))

data_USoc <- data_USoc %>%
  mutate(lnurate=log(urate))

data_USoc %>% filter(pidp == 272395767) %>%
  select(c("pidp","male","wave","year","paygu","age","educ")) %>%
  print()

data_USoc <- data_USoc %>%
  filter(wave != 2) %>%
  filter(!is.na(lnhrpay))

data_USoc <- data_USoc %>%
  group_by(pidp) %>%
  mutate(n_wave = n())

pdata_USoc <- pdata.frame(data_USoc, index = c("pidp","wave")) # defines the panel dimensions

table(pdata_USoc$n_wave,pdata_USoc$wave, dnn = c("n_waves","waves"))

Dlnhrpay <- pdata_USoc$lnhrpay-lag(pdata_USoc$lnhrpay,k=2)
Dlnurate <- pdata_USoc$lnurate-lag(pdata_USoc$lnurate,k=2)
#Dregion <- ifelse(pdata_USoc$region==lag(pdata_USoc$region,k=2),"no move","move")
pdata_USoc$Dlnhrpay <- Dlnhrpay # add the new series to the dataframe
pdata_USoc$Dlnurate <- Dlnurate

temp <- pdata_USoc # create a temporary dataframe
temp <- temp %>% filter(n_wave == 2) %>% # only keep individuals with two waves
  group_by(pidp) %>% # group data by individual
  mutate(move = ifelse(length(unique(region))==1,"no move","move")) %>% 
  select(pidp,wave,move)

# the move variable will take the value 1 if both regions are identical (no move)
# and 2 if there are two different regions (move)
temp$move <- as_factor(temp$move) # convert to factor variable
temp2 <- temp %>% select(pidp,move)

# the following merges the new variable into the p
pdata_USoc <- merge(pdata_USoc,temp,all.x = TRUE)
