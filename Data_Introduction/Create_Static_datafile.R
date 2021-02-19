# This is to create a static data file which works with the old Data_Intro_2_Covid code


library(sets)         # used for some set operations
library(readxl)       # enable the read_excel function
library(tidyverse)    # for almost all data handling tasks
library(ggplot2)      # plotting toolbox
library(utils)        # for reading data into R # for reading data into R 
library(httr)         # for downloading data from a URL 
library(stargazer)    # for nice regression output

#download the dataset from the ECDC website to a local temporary file (“tf”)
GET("https://opendata.ecdc.europa.eu/covid19/nationalcasedeath/csv", 
    authenticate(":", ":", type="ntlm"), 
    write_disk(tf <- tempfile(fileext = ".csv")))
#read the Dataset sheet into “R”. The dataset will be called "data".
data2 <- read.csv(tf) 
