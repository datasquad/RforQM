# This is Lecture 2 work

library(tidyverse)    # for almost all data handling tasks
library(readxl)       # to import Excel data
library(ggplot2)      # to produce nice graphiscs
library(stargazer)    # to produce nice results tables

setwd("C:/Rcode/RforQM/Data_Introduction")

load("WBdata.Rdata")
str(wb_data)  # prints some basic info on variables

colnames(wb_data)[colnames(wb_data)=="X025A"] <- "Education"

table1 <- wb_data %>% group_by(S002EVS,S003) %>% # groups by Wave and Country
  summarise(no = n()) %>%               # summarises each group by calculating obs
  spread(S002EVS,no) %>%                # put Waves across columns
  print(n=Inf)                         # n = Inf makes sure that all rows are printed

# Health - Life Satisfaction

table2 <- wb_data %>% group_by(S002EVS,S003) %>% # groups by Wave and Country
  summarise(Avg_LifeSatis = mean(A170),Avg_Health = mean(A009))     # summarises each group by calculating obs

table2

ggplot(table2,aes(Avg_Health,Avg_LifeSatis, colour=S002EVS)) +
  geom_point(size=4) +
  ggtitle("Health v Life Satisfaction")

# Work First - Life Satisfaction

table2 <- wb_data %>% group_by(S002EVS,S003) %>% # groups by Wave and Country
  summarise(Avg_LifeSatis = mean(A170),Avg_WorkFirst = mean(C041))    # summarises each group by calculating obs

ggplot(table2,aes( Avg_WorkFirst, Avg_LifeSatis,colour=S002EVS)) +
  geom_point(size=4) +
  ggtitle("Work First v Life Satisfaction")

# Calculate income Work First correlation inside countries
table3 <- wb_data %>% filter(S002EVS == "2008-2010") %>% 
  group_by(S003) %>% # groups by Country
  summarise(cor_LS_WF = cor(A170,C041,use = "pairwise.complete.obs"),
            med_income = median(X047D)) %>%    # correlation, remove missing data
  arrange(cor_LS_WF) 

ggplot(table3,aes( cor_LS_WF, med_income)) +
  geom_point(size=4) +
  ggtitle("Corr(Life Satisfaction, Work First) v Median Income")

# Hypothesis testing

test_data_G <- wb_data %>% 
  filter(S003 == "Germany") %>%     # pick German data
  filter(S002EVS == "2008-2010")    # pick latest wave

mean_G <- mean(test_data_G$A170)

test_data_GB <- wb_data %>% 
  filter(S003 == "Great Britain") %>%  # pick British data
  filter(S002EVS == "2008-2010")       # pick latest wave

mean_GB <- mean(test_data_GB$A170)

sample_diff <- mean_G - mean_GB

# Regression

test_data <- wb_data %>% 
  filter(S003 =="Great Britain") %>%  # pick British data
  filter(S002EVS == "2008-2010")         # pick latest wave

mod1 <- lm(A170~1,data=test_data)
stargazer(mod1, type="text")

mod1 <- lm(A170~X047D,data=test_data)
stargazer(mod1, type="text")

ggplot(test_data, aes(x=X047D, y=A170, colour = S003)) +
  geom_point() +    # Use jitter rather than point so we can see indiv obs
  geom_abline(intercept = mod1$coefficients[1], slope = mod1$coefficients[2])+
  ggtitle("Income v Life Satisfaction, Britain")


ggplot(test_data, aes(x=X047D, y=A170, colour = S003)) +
  geom_jitter(width=0.2) +    # Use jitter rather than point so we can see indiv obs
  geom_abline(intercept = mod1$coefficients[1], slope = mod1$coefficients[2])+
  ggtitle("Income v Life Satisfaction, Britain")
