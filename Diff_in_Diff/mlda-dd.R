## Minimum Legal Drinking Age (MLDA) - Diff-in-Diff
## Source of data: Angrist and Pischke, 
## https://www.masteringmetrics.com/ (Chp 5)
##
## Code based on: Jeffrey Arnold's R implementation
## https://jrnold.github.io/masteringmetrics/

## Libraries
library(tidyverse)
library(stargazer)
library(readxl)
library(ggplot2)


setwd("C:/Rcode/RforQM/Diff_in_Diff")
load("deaths.Rdata")

# Look at some data
deaths %>% filter(state == "5", year == "1980", agegr == "18-20 yrs") %>% 
  select(state,year,agegr, count,dtype, pop) %>%  print()

## Matching States
unique(deaths$state)
state<-read_excel("states.xlsx")
state$FIPS <- as.factor(state$FIPS)
names(state)

deaths <- merge(deaths,state,by.x = "state", by.y = "FIPS",x.all = TRUE)


## Some Summary
str(deaths)
summary(deaths)


## Some graphical representations
deaths_sel <- deaths %>%  filter(Cstate %in% c("MN","AR"), dtype == "MVA")

g1 <- ggplot(deaths_sel, aes(y=mrate, x=year, color = agegr)) +
  geom_line() + 
  ggtitle("Death rates (per 100,000) for MVA") +
  facet_grid(.~Cstate)
g1

deaths_sel <- deaths %>%  
  filter(Cstate %in% c("AR","MN"), agegr == "18-20 yrs") %>% 
  filter(!(dtype == "all"))

g2 <- ggplot(deaths_sel, aes(y=mrate, x=year, color = dtype)) +
  geom_line() + 
  ggtitle("Death rates (per 100,000), different reasons, 18-20 yrs") +
  facet_grid(.~Cstate)
g2


deaths_sel <- deaths %>%  filter(Cstate %in% c("AL","MI"), dtype == "MVA")

g1 <- ggplot(deaths_sel, aes(y=mrate, x=year, color = agegr)) +
  geom_line() + 
  ggtitle("Death rates (per 100,000) for MVA") +
  facet_grid(.~Cstate)
g1


deaths_sel <- deaths %>%  
  filter(Cstate %in% c("AL","MI"), agegr == "18-20 yrs") %>% 
  filter(!(dtype == "all"))

g2 <- ggplot(deaths_sel, aes(y=mrate, x=year, color = dtype)) +
  geom_line() + 
  ggtitle("Death rates (per 100,000), different reasons, 18-20 yrs") +
  facet_grid(.~Cstate)
g2


AP_data_1 <- deaths %>% filter(Cstate %in% c("CT","AR")) %>% 
  filter(year <= 1983, agegr == "18-20 yrs", dtype == "MVA") %>% 
  arrange(Cstate,year)

gdd <- ggplot(AP_data_1, aes(y=mrate, x=year, color = Cstate)) +
  geom_line() + 
  ggtitle("Death rates (per 100,000) for MVA") 
gdd


## 2xn Diff-in-Diff

AP_data_1 <- AP_data_1 %>% 
              mutate(treat = (Cstate == "CT"), # creates treat var
                     post = (year >= 1973),    # creates post variable
                     treatpost = treat*post)


dd_2state <- lm(mrate~treat+post+treatpost, data = AP_data_1)
stargazer(dd_2state, type = "text")


## Multi State - Multi Period Diff-in-Diff
deaths <- deaths %>% mutate(year_fct = factor(year), 
                            Cstate = factor(Cstate))

AP_data <- deaths %>% filter(year <= 1983, agegr == "18-20 yrs", dtype == "all") %>% 
  arrange(Cstate,year)

mod1 <- lm(mrate ~ legal + state + year_fct, data = AP_data)
stargazer(mod1, keep = "legal", type="text") # keep = "legal" only reports legal

mod2 <- lm(mrate ~ legal + year_fct + state + state:year, data = AP_data)
stargazer(mod1, mod2, dep.var.caption = "All Deaths", keep = "legal", type="text") 


## Cluster-robust inference
library(sandwich)
library(lmtest)
mod1_cr <- coeftest(mod1,vcovCL(mod1, cluster = ~ state))
mod1_cr[1:4,]


# Create vectors with cluster robust standard errors
# for use in stargazer below
mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ state)))
mod2_cr_se <- sqrt(diag(vcovCL(mod2, cluster = ~ state)))

stargazer(mod1, keep = "legal", type="text", se=list(mod1_cr_se)) 

stargazer(mod1,mod2, keep = "legal", type="text",
          se=list(mod1_cr_se,mod2_cr_se)) # keep = "legal" only reports legal


# MVAs
AP_data <- filter(deaths, year <= 1983, agegr == "18-20 yrs", dtype == "MVA")
mod1 <- lm(mrate ~ legal + state + year_fct, data = AP_data)
mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ state)))

mod2 <- lm(mrate ~ legal + year_fct + state + state:year, data = AP_data)
mod2_cr_se <- sqrt(diag(vcovCL(mod2, cluster = ~ state)))

stargazer(mod1, mod2, dep.var.caption = "MVA", keep = "legal", 
          type="text",se=list(mod1_cr_se,mod2_cr_se)) 

# Suicides
AP_data <- filter(deaths, year <= 1983, agegr == "18-20 yrs", dtype == "suicide")
mod1 <- lm(mrate ~ legal + state + year_fct, data = AP_data)
mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ state)))

mod2 <- lm(mrate ~ legal + year_fct + state + state:year, data = AP_data)
mod2_cr_se <- sqrt(diag(vcovCL(mod2, cluster = ~ state)))

stargazer(mod1, mod2, dep.var.caption = "Suicide", keep = "legal", 
          type="text",se=list(mod1_cr_se,mod2_cr_se)) 

# Internal
AP_data <- filter(deaths, year <= 1983, agegr == "18-20 yrs", dtype == "internal")
mod1 <- lm(mrate ~ legal + state + year_fct, data = AP_data)
mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ state)))

mod2 <- lm(mrate ~ legal + year_fct + state + state:year, data = AP_data)
mod2_cr_se <- sqrt(diag(vcovCL(mod2, cluster = ~ state)))

stargazer(mod1, mod2, dep.var.caption = "Internal", keep = "legal", 
          type="text",se=list(mod1_cr_se,mod2_cr_se)) 


## Include beertax as controls, Table 5.3
# All deaths

AP_data <- filter(deaths, year <= 1983, agegr == "18-20 yrs", dtype == "all")

mod1 <- lm(mrate ~ legal + beertaxa + state + year_fct, data = AP_data)
mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ state)))

mod2 <- lm(mrate ~ legal + beertaxa + year_fct + state + state:year, data = AP_data)
mod2_cr_se <- sqrt(diag(vcovCL(mod2, cluster = ~ state)))

stargazer(mod1, mod2, dep.var.caption = "MVA - incl. beertax", 
          keep = c("legal","beertaxa"), type="text",
          se=list(mod1_cr_se,mod2_cr_se)) 

# MVA
AP_data <- filter(deaths, year <= 1983, agegr == "18-20 yrs", dtype == "MVA")

mod1 <- lm(mrate ~ legal + beertaxa + state + year_fct, data = AP_data)
mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ state)))

mod2 <- lm(mrate ~ legal + beertaxa + year_fct + state + state:year, data = AP_data)
mod2_cr_se <- sqrt(diag(vcovCL(mod2, cluster = ~ state)))

stargazer(mod1, mod2, dep.var.caption = "MVA - incl. beertax", 
          keep = c("legal","beertaxa"), type="text",
          se=list(mod1_cr_se,mod2_cr_se)) 

# Suicide
AP_data <- filter(deaths, year <= 1983, agegr == "18-20 yrs", dtype == "suicide")
mod1 <- lm(mrate ~ legal + beertaxa + state + year_fct, data = AP_data)
mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ state)))

mod2 <- lm(mrate ~ legal + beertaxa + year_fct + state + state:year, data = AP_data)
mod2_cr_se <- sqrt(diag(vcovCL(mod2, cluster = ~ state)))

stargazer(mod1, mod2, dep.var.caption = "Suicide", 
          keep = c("legal","beertaxa"), type="text",
          se=list(mod1_cr_se,mod2_cr_se)) 

# Internal
AP_data <- filter(deaths, year <= 1983, agegr == "18-20 yrs", dtype == "internal")
mod1 <- lm(mrate ~ legal + beertaxa + state + year_fct, data = AP_data)
mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ state)))

mod2 <- lm(mrate ~ legal + beertaxa + year_fct + state + state:year, data = AP_data)
mod2_cr_se <- sqrt(diag(vcovCL(mod2, cluster = ~ state)))

stargazer(mod1, mod2, dep.var.caption = "Internal", 
          keep = c("legal","beertaxa"), type="text",
          se=list(mod1_cr_se,mod2_cr_se)) 

