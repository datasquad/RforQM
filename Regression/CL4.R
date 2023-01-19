
## --------------------------------------------------------------------------------------------------
library(tidyverse)    # for almost all data handling tasks
library(ggplot2)      # to produce nice graphiscs
library(stargazer)    # to produce nice results tables
library(haven)        # to import stata file
library(AER)          # access to HS robust standard errors
library(readxl)       # enable the read_excel function
library(plm)          # enable panel data methods


## --------------------------------------------------------------------------------------------------
source("stargazer_HC.r")  # includes the robust regression 



var_info <- read_excel("sps_public.xlsx",sheet="Data Dictionary")
dat <- read_excel("sps_public.xlsx",sheet="Data")


str(dat)



dat$type <- factor(dat$type)
dat$taxed <- factor(dat$taxed, 
                    labels=c("not taxed","taxed"))
dat$supp <- factor(dat$supp,
                   labels=c("Standard","Supplemental"))
dat$store_id <- factor(dat$store_id)
dat$type2 <- factor(dat$type2)
dat$product_id <- factor(dat$product_id)


## --------------------------------------------------------------------------------------------------
var_info[var_info$`Variable Name` == "store_type",]
# or just open the var_info sheet

dat$store_type <- factor(dat$store_type,
                         labels=c("Large Supermarket",
                                  "Small Supermarket",
                                  "Pharmacy",
                                  "Gas Station"))


unique(dat$time)


dat$time[dat$time == "MAR2015"] <- "MAR2016"


dat$time <- factor(dat$time)


## ---- echo = FALSE---------------------------------------------------------------------------------
no_stores <- length(unique(dat$store_id))
no_products <- length(unique(dat$product_id))
paste("Number of Stores:", no_stores)
paste("Number of Products:", no_products)


table1 <- dat %>% group_by(store_type,taxed,time) %>%
                tally() %>%
                spread(time,n) %>%
                print(n=Inf)
                
            


table2 <- dat %>% group_by(type,time) %>%
                    tally() %>%  
                    spread(time,n) %>%
                    print(n=Inf)

                    
                  
dat %>%  filter(type == "TEA-DIET" & time %in% c("DEC2014", "MAR2016")) %>%
          select(store_id, product_id, time) %>%
          arrange(store_id) %>%
          print()


dat$period_test <- NA

sid_list = unique(dat$store_id)   # list of all store ids
pid_list = unique(dat$product_id) # list of all product ids


for (s in sid_list) {
  for (p in pid_list) {
    temp <- subset(dat, product_id == p & store_id == s)
    temp_time <- temp$time
    # test will take value TRUE if we have obs from all three periods, FALSE otherwise
    test <- (any(temp_time == "DEC2014") & any(temp_time == "JUN2015") & any(temp_time == "MAR2016"))
    
    dat$period_test[dat$product_id == p & dat$store_id == s] <- test
  }
}


dat_c <- dat %>% filter(period_test == TRUE & supp == "Standard")

table_res <- dat_c %>% 
      group_by(taxed,store_type,time) %>% 
      summarise(n = length(price_per_oz_c),avg.price = mean(price_per_oz_c)) %>%
      spread(time,avg.price) %>% 
      print()


dat_c$sp_id <- paste0(dat_c$store_id,"_",dat_c$product_id) 


dat_c$did <- (dat_c$time == "MAR2016") * (dat_c$taxed == "taxed")


dat_c_ls <- dat_c %>% filter(store_type == "Large Supermarket" & time %in% c("DEC2014","MAR2016"))


p_dat_c_ls <- pdata.frame(dat_c_ls, index = c("sp_id","time"))


mod1 <- plm(price_per_oz_c ~ time + sp_id + did, data = p_dat_c_ls, model = "fd")
stargazer_HC(mod1)


stargazer_HC(mod1, out = "Table1.doc")


stargazer_HC(mod1, type_out = "html",out = "Table1.doc")

