# This is the script to CompLab0

setwd("C:/Rcode/RforQM/Data_Introduction")

library(tidyverse)
library(readxl) # to import Excel data
library(ggplot2) # to produce nice graphiscs
library(stargazer)

CKdata <- read_excel("CK_public.xlsx", na = ".")

str(CKdata)

CKdata$STATEf <- as.factor(CKdata$STATE) # translates a variable into a factor variable
levels(CKdata$STATEf) <- c("Pennsylvania","New Jersey") # changes the names of the categories

CKdata$CHAINf <- as.factor(CKdata$CHAIN)
levels(CKdata$CHAINf) <- c("BK","KFC", "Roys", "Wendy's")

