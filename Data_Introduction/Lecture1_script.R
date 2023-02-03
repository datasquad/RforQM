# Lecture 1

library(tidyverse)    # for almost all data handling tasks
library(readxl)       # to import Excel data
library(ggplot2)      # to produce nice graphiscs
library(stargazer)    # to produce nice results tables


# Data import
CKdata<- read_xlsx("C:/Rcode/RforQM/Data_Introduction/CK_public.xlsx",na = ".")



str(CKdata)  # prints some basic info on variables

CKdata[32:35,1:4] 

str(CKdata[c("STATE","CHAIN")])  # prints some basic info on variables

# change the data type
CKdata$STATEf <- as.factor(CKdata$STATE)  
levels(CKdata$STATEf) <- c("Pennsylvania","New Jersey") 

CKdata$CHAINf <- as.factor(CKdata$CHAIN)  
levels(CKdata$CHAINf) <- c("Burger King","KFC", "Roy Rogers", "Wendy's")

str(CKdata[c("STATEf","CHAINf")])  # prints some basic info on variables

levels(CKdata$CHAINf)

summary(CKdata[c("WAGE_ST","EMPFT")])

Tab1 <- CKdata %>% group_by(STATEf) %>% 
  summarise(n = n()) %>% 
  print()

prop.table(table(CKdata$CHAINf,CKdata$STATEf,dnn = c("Chain", "State")),margin = 2)

p1 <- ggplot(CKdata,aes(WAGE_ST,EMPFT)) +
  geom_point(size=0.5) +    # this produces the scatter plot
  geom_smooth(method = "lm", se = FALSE)  # adds the line 
p1


mod1 <- lm(EMPFT~WAGE_ST, data= CKdata)
summary(mod1)

stargazer(mod1,type="text")

hist(CKdata$WAGE_ST[CKdata$STATEf == "Pennsylvania"])
hist(CKdata$WAGE_ST[CKdata$STATEf == "New Jersey"])

ggplot(CKdata,aes(WAGE_ST, colour = STATEf), colour = STATEf) + 
  geom_histogram(position="identity", 
                 aes(y = ..density..),
                 bins = 10,
                 alpha = 0.2) +
  ggtitle(paste("Starting wage distribution, Feb/Mar 1992"))

Tab1 <- CKdata %>% group_by(STATEf) %>% 
  summarise(wage_FEB = mean(WAGE_ST,na.rm = TRUE), 
            wage_DEC = mean(WAGE_ST2,na.rm = TRUE)) %>% 
  print()

ggplot(CKdata,aes(WAGE_ST2, colour = STATEf), colour = STATEf) + 
  geom_histogram(position="identity", 
                 aes(y = ..density..),
                 bins = 10,
                 alpha = 0.2) +
  ggtitle(paste("Starting wage distribution, Nov/Dec 1992"))


CKdata$FTE <- CKdata$EMPFT + CKdata$NMGRS + 0.5*CKdata$EMPPT
CKdata <- CKdata %>%  mutate(FTE2 = EMPFT2 + NMGRS2 + 0.5*EMPPT2)

TabDiD <- CKdata %>% group_by(STATEf) %>% 
  summarise(meanFTE_FEB = mean(FTE,na.rm = TRUE), 
            meanFTE_DEC = mean(FTE2,na.rm = TRUE)) %>% 
  print()

ggplot(CKdata, aes(1992,FTE, colour = STATEf)) +
  geom_point(alpha = 0.2) +
  geom_point(aes(1993,FTE2),alpha = 0.2) +
  labs(x = "Time") +
  ggtitle(paste("Employment, FTE"))

ggplot(CKdata, aes(1992,FTE, colour = STATEf)) +
  geom_jitter(alpha = 0.2) +
  geom_jitter(aes(1993,FTE2),alpha = 0.2) +
  labs(x = "Time") +
  ggtitle(paste("Employment, FTE"))

ggplot(TabDiD, aes(1992,meanFTE_FEB, colour = STATEf)) +
  geom_point(size = 3) +
  geom_point(aes(1993,meanFTE_DEC),size=3) +
  ylim(17, 24) +
  labs(x = "Time") +
  ggtitle(paste("Employment, mean FTE"))

