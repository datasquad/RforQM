# This is my first R script

library(tidyverse)    # for almost all data handling tasks
library(readxl)       # to import Excel data
library(ggplot2)      # to produce nice graphiscs
library(stargazer)    # to produce nice results tables

setwd("C:/Rcode/RforQM/Data_Introduction")
RRData <- read_excel("RRdata.xlsx")
