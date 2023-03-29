library(tidyverse)    # for almost all data handling tasks
library(ggplot2)      # to produce nice graphics
library(stargazer)    # to produce nice results tables
library(haven)        # to import stata file
library(ggplot2)      # for graphs
library(AER)          # access to HS robust standard errors
library(plm)          # for panel data methods
library(sandwich)     # for cluster robust se
library(lmtest)
library(coefplot)     # to create coefficient plots

data <- read_dta("Regression/did_4.dta") 
data <- as.data.frame(data)

str(data)

data$year <- as_factor(data$year)
data$w <- as_factor(data$w)
data$d <- as_factor(data$d)
levels(data$d) <- c("control","treated")
data$id <- as_factor(data$id)

pdata <- pdata.frame(data, index = c("id","year")) # defines the panel dimensions

is.pbalanced(pdata)

#Estimate (R)

mod1 <- lm(logy~id+year+w, data = pdata)

mod1_ro_se <- sqrt(diag(vcovHC(mod1, type = "HC1")))  # robust standard errors
stargazer(mod1, keep = "w", type="text", se=list(mod1_ro_se), 
          digits = 6, notes="HS Robust standard errors in parenthesis") 


mod1_cr_se <- sqrt(diag(vcovCL(mod1, cluster = ~ id)))
stargazer(mod1, keep = "w", type="text", se=list(mod1_cr_se), 
          digits = 6, notes="Cluster Robust standard errors in parenthesis")

# Estimate (U)

pdata <- pdata %>%  mutate(tr2013 = (year=="2013")*(d=="treated"),
                           tr2014 = (year=="2014")*(d=="treated"),
                           tr2015 = (year=="2015")*(d=="treated"))


mod3 <- lm(logy~id+year+tr2013+tr2014+tr2015, data = pdata)
mod3_cr_se <- sqrt(diag(vcovCL(mod3, cluster = ~ id)))
coef_keep = c("year","tr2013","tr2014","tr2015")
stargazer(mod3, type="text", keep = coef_keep, se=list(mod3_cr_se), digits = 6)

coefplot(mod3, coefficients = coef_keep, innerCI = 0, horizontal = TRUE)
