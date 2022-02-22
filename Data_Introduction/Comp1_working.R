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

summary(CKdata$EMPFT)

summary(CKdata[c("EMPPT","EMPPT2")])

summary(CKdata$CHAINf)

table(CKdata$CHAINf)

prop.table(table(CKdata$CHAINf))

prop.table(table(CKdata$CHAINf,CKdata$STATEf,
                 dnn = c("Chain", "State")),margin = 2)


prop.table(table(CKdata$CHAINf,CKdata$CO_OWNED,
                 dnn = c("Chain", "Co-owned")),margin = 2)

hist(CKdata$EMPPT)

ggplot(CKdata,aes(x=EMPPT)) +
  geom_histogram(bins = 12) +
  ggtitle("Number of part-time employees, Feb/Mar 1992")


ggplot(CKdata,aes(x=EMPPT2)) +
  geom_histogram(bins = 12) +
  ggtitle("Number of part-time employees, Dec 1992")

ggplot(CKdata,aes(x=EMPPT, colour = STATEf)) +
  geom_histogram(position="identity",
                 aes(y = ..density..),
                 bins = 10,
                 alpha = 0.2) +
  ggtitle(paste("Number of part-time employees, Feb/Mar 1992"))




table2 <- CKdata %>% group_by(CHAINf) %>%
  summarise(avg.pfries = mean(PFRY,na.rm = TRUE)) %>% print()

table2 <- CKdata %>% group_by(CHAINf) %>%
  summarise(pfry_FEB = mean(PFRY,na.rm = TRUE),
            pfry_DEC = mean(PFRY2,na.rm = TRUE)) %>% print()

table3 <- CKdata %>% group_by(STATEf) %>%
  summarise(pfry_FEB = mean(PFRY,na.rm = TRUE),
            pfry_DEC = mean(PFRY2,na.rm = TRUE)) %>% print()
