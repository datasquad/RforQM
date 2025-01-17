library(tidyverse)
library(ggplot2)
library(stargazer)
library(haven)
library(AER)
source("stargazer_HC.r")
data_USoc <- read_dta("20222_USoc_extract.dta")
data_USoc <- as.data.frame(data_USoc)
data_USoc$region <- as_factor(data_USoc$region)
names(data_USoc)
unique(data_USoc$region)
