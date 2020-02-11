# ECON20222 Quantitative Methods
# Lecture 2 - R script

library(tidyverse)    # for almost all data handling tasks
library(readxl)       # to import Excel data
library(ggplot2)      # to produce nice graphiscs
library(stargazer)    # to produce nice results tables

load("C:/Rcode/RforQM/Data_Introduction/WBdata.Rdata")
str(wb_data)  # prints some basic info on variables

wb_data_Des

unique(wb_data$S003)   # unque finds all the different values in a variable

unique(wb_data$S002EVS)

table1 <- wb_data %>% group_by(S002EVS,S003) %>% # groups by Wave and Country
  summarise(nobs = n()) %>%               # summarises each group by calculating obs
  spread(S002EVS,nobs) %>%                # put Waves across columns
  print(n=Inf)                         # n = Inf makes sure that all rows are printed

table2 <- wb_data %>% group_by(S002EVS,S003) %>% # groups by Wave and Country
  summarise(Avg_LifeSatis = mean(A170),Avg_Health = mean(A009))     # summarises each group by calculating obs

ggplot(table2,aes(Avg_Health,Avg_LifeSatis, colour=S002EVS)) +
  geom_point() +
  ggtitle("Health v Life Satisfaction")

table2 <- wb_data %>% group_by(S002EVS,S003) %>% # groups by Wave and Country
  summarise(Avg_LifeSatis = mean(A170),Avg_WorkFirst = mean(C041))    # summarises each group by calculating obs

ggplot(table2,aes(Avg_WorkFirst, Avg_LifeSatis,colour=S002EVS)) +
  geom_point() +
  ggtitle("Work First v Life Satisfaction")

table3 <- wb_data %>% filter(S002EVS == "2008-2010") %>% 
  group_by(S003) %>% # groups by Country
  summarise(cor_LS_WF = cor(A170,C041,use = "pairwise.complete.obs"),
            med_income = median(X047D)) %>%    # correlation, remove missing data
  arrange(cor_LS_WF) 

ggplot(table3,aes( cor_LS_WF, med_income)) +
  geom_point() +
  ggtitle("Corr(Life Satisfaction, Work First) v Median Income")

# Mapping Data

library(tmap)   # mapping package
library(sf)     # required to deal with shape files
library(spData) # delivers shape files

count_list <- unique(wb_data$S003) # List of countries in well-being dataset
count_list

count_list <- count_list[!(count_list %in% c("United States","Canada","Russian Federation"))]

d_world <- world  # save country shape files
head(d_world)

d_sel <- d_world %>% 
  filter(name_long %in% count_list)

count_map <- d_sel$name_long   # countries included in d_sel
setdiff(count_list,count_map)  # finds the difference between the two arguments

d_world$name_long[grepl("Bosnia",d_world$name_long)]
d_world$name_long[grepl("Malta",d_world$name_long)]
d_world$name_long[grepl("United",d_world$name_long)]

wb_data_map <- wb_data   # duplicate the dataset so we keep the original unchanged
wb_data_map$S003[wb_data_map$S003 == "Bosnia Herzegovina"] <- "Bosnia and Herzegovina"
wb_data_map$S003[wb_data_map$S003 == "Great Britain"] <- "United Kingdom"

count_list <- unique(wb_data_map$S003)
count_list <- count_list[!(count_list %in% c("United States","Canada","Russian Federation"))]
d_sel <- d_world %>% 
  filter(name_long %in% count_list)

names(d_sel)

map1 <- tm_shape(d_sel) +  # basic map
  tm_borders()             # adds borders 

map2 <- tm_shape(d_sel) +
  tm_borders() +
  tm_fill(col = "gdpPercap") +
  tm_style("cobalt") +
  tm_layout(title = "GDP per capita across Europe") 

tmap_arrange(map1, map2)   # this arranges the maps next to each other

table2_map <- wb_data_map %>% group_by(S002EVS,S003) %>% # groups by Wave and Country
  summarise(Avg_LifeSatis = mean(A170),Avg_WorkFirst = mean(C041))    # summarises each group by calculating obs

d_sel_merged <- merge(x = d_sel,y = table2_map,by.x = "name_long",by.y="S003") # merge the data in x and y

d_sel_2018 <- d_sel_merged %>% filter(S002EVS == "2008-2010")

map1 <- tm_shape(d_sel_2018) +
  tm_borders() +
  tm_fill(col = "Avg_LifeSatis", title = "Satisfaction with your life") +
  tm_style("cobalt") +
  tm_layout(title = "Average Life Satisfaction") 

map2 <- tm_shape(d_sel_2018) +
  tm_borders() +
  tm_fill(col = "Avg_WorkFirst", title = "1 = Strongly Agree, 5 = Strongly Disagree") +
  tm_style("cobalt") +
  tm_layout(title = "Average Attitude to Work First") 

tmap_arrange(map1, map2)   # this arranges the maps next to each other

# Hypothesis Testing

test_data_G <- wb_data %>% 
  filter(S003 == "Germany") %>%     # pick German data
  filter(S002EVS == "2008-2010")    # pick latest wave

mean_G <- mean(test_data_G$A170)

test_data_GB <- wb_data %>% 
  filter(S003 == "Great Britain") %>%  # pick British data
  filter(S002EVS == "2008-2010")       # pick latest wave

mean_GB <- mean(test_data_GB$A170)

sample_diff <- mean_G - mean_GB

t.test(test_data_G$A170,test_data_GB$A170, mu=0)  # testing that mu = 0

test_data_SW <- wb_data %>% 
  filter(S003 == "Sweden") %>%  # pick British data
  filter(S002EVS == "2008-2010")       # pick latest wave

mean_SW <- mean(test_data_SW$A170)

t.test(test_data_SW$A170,test_data_GB$A170, mu=0)  # testing that mu = 0

wb_data$rvar <- rnorm(nrow(wb_data))   # add random variable

test_data <- wb_data %>% 
  filter(S002EVS == "2008-2010")       # pick latest wave

countries <- unique(test_data$S003)  # List of all countries
n_countries <- length(countries)   # Number of countries, 46

save_pvalue <- matrix(NA,n_countries,n_countries)

for (i in seq(2,n_countries)){
  for (j in seq(1,(i-1))){
    test_data_1 <- test_data %>% 
      filter(S003 == countries[i]) 
    mean_1 <- mean(test_data_1$A170)
    
    test_data_2 <- test_data %>% 
      filter(S003 == countries[j]) 
    mean_2 <- mean(test_data_2$A170)
    
    tt <- t.test(test_data_1$rvar,test_data_2$rvar, mu=0)  # testing that mu = 0
    save_pvalue[i,j] <- unlist(tt["p.value"])    # this will just pick the p-value
  }
}

tre <- (save_pvalue<0.1)   # value of TRUE if pvalue < 0.1

cols <- c("TRUE" = "#FFFFFF","FALSE" = "#66FF33")

image(1:nrow(tre), 1:ncol(tre), as.matrix(tre), col=cols)

table(tre)

save_pvalue <- matrix(NA,n_countries,n_countries)

for (i in seq(2,n_countries)){
  for (j in seq(1,(i-1))){
    test_data_1 <- test_data %>% 
      filter(S003 == countries[i]) 
    mean_1 <- mean(test_data_1$A170)
    
    test_data_2 <- test_data %>% 
      filter(S003 == countries[j]) 
    mean_2 <- mean(test_data_2$A170)
    
    tt <- t.test(test_data_1$A170,test_data_2$A170, mu=0)  # testing that mu = 0
    save_pvalue[i,j] <- unlist(tt["p.value"])    # this will just pick the p-value
  }
}

tre <- (save_pvalue<0.1)   # value of TRUE if pvalue < 0.1

cols <- c("TRUE" = "#FFFFFF","FALSE" = "#66FF33")

image(1:nrow(tre), 1:ncol(tre), as.matrix(tre), col=cols)

table(tre)


# Regression

test_data <- wb_data %>% 
  filter(S003 =="Great Britain") %>%  # pick British data
  filter(S002EVS == "2008-2010")         # pick latest wave

mod1 <- lm(A170~1,data=test_data)
stargazer(mod1, type="text")

t.test(test_data$A170, mu=0)  # testing that mu = 0

test_data <- wb_data %>% 
  filter(S003 %in% c("Sweden","Great Britain")) %>%  # pick British and Swedish data
  filter(S002EVS == "2008-2010")         # pick latest wave

mod1 <- lm(A170~S003,data=test_data)
stargazer(mod1, type="text")

test_data <- wb_data %>% 
  filter(S002EVS == "2008-2010")       # pick latest wave

mod1 <- lm(A170~X047D,data=test_data)
stargazer(mod1, type="text")

ggplot(test_data, aes(x=X047D, y=A170, colour = S003)) +
  geom_jitter(width=0.2, size = 0.5) +    # Use jitter rather than point so we can see indiv obs
  geom_abline(intercept = mod1$coefficients[1], slope = mod1$coefficients[2])+
  ggtitle("Income v Life Satisfaction, Britain and Sweden")

