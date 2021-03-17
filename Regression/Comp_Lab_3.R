
setwd("C:/Rcode/RforQM/Regression")

## --------------------------------------------------------------------------------------------
library(tidyverse)    # for almost all data handling tasks
library(ggplot2)      # to produce nice graphics
library(stargazer)    # to produce nice results tables
library(haven)        # to import stata file
library(AER)          # access to HS robust standard errors


## --------------------------------------------------------------------------------------------
source("stargazer_HC.r")  # includes the robust regression 



data_USoc <- read_dta("20222_USoc_extract.dta")
names(data_USoc)




data_USoc$region <- as_factor(data_USoc$region)
data_USoc$male <- as_factor(data_USoc$male)
data_USoc$degree <- as_factor(data_USoc$degree)
data_USoc$race <- as_factor(data_USoc$race)

data_USoc <- data_USoc  %>% 
              mutate(hrpay = paygu/(jbhrs*4)/(cpi/100)) %>%
              mutate(lnhrpay = log(hrpay))


table1 <- data_USoc %>% group_by(region,year) %>% # groups by region and year
summarise(n = n()) %>% # summarises each group by calculating obs
spread(year,n) %>% # put Waves across columns
print(n=Inf) 


data_USoc <- data_USoc %>% filter(year != 2013)


## lnhrpay regressed on region only 
mod1 <- lm(lnhrpay~region, data = data_USoc)
stargazer_HC(mod1)




## lnhrpay regressed on educ only 
mod2 <- lm(lnhrpay~educ, data = data_USoc)
stargazer_HC(mod2)


## lnhrpay regressed on region and educ
mod3 <- lm(lnhrpay~region+educ, data = data_USoc)
stargazer_HC(mod2,mod1,mod3)


## --------------------------------------------------------------------------------------------
stargazer_HC(mod2,mod1,mod3, omit.stat="f")

