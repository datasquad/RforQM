# File for first QM Computer Lab
# February 2021

setwd("P:/My Documents/Rcode")

library(tidyverse)    # for almost all data handling tasks
library(readxl)       # to import Excel data
library(ggplot2)      # to produce nice graphiscs
library(stargazer)    # to produce nice results tables

CKdata<- read_xlsx("CK_public.xlsx",na = ".")
