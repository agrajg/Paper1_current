rm(list = ls())

setwd("Y:/agrajg/Research/Paper1_demand_stata")
.libPaths(new = c("Y:/agrajg/Research/Paper1/packrat/lib/x86_64-w64-mingw32/3.4.3",
                  "H:/agrajg/R",
                  "H:/agrajg/R2"))

# ptm <- proc.time()
# MC_demand <- read.csv(file = "09_01_For_non_linear_price_computation_sample2.csv", header = TRUE)
# save(MC_demand, file = "09_02_For_non_linear_price_computation_sample2.RData")
# proc.time() - ptm


# ptm <- proc.time()
# MC_demand <- read.csv(file = "09_01_For_non_linear_price_computation.csv", header = TRUE)
# save(MC_demand, file = "09_02_For_non_linear_price_computation.RData")
# proc.time() - ptm

# load("09_02_For_non_linear_price_computation_sample2.RData")
load("09_02_For_non_linear_price_computation.RData")


library(plyr)
library(dplyr)
library(rootSolve)
library(magrittr)
library(multidplyr)

df <-as.data.frame(MC_demand)
# df <- df %>% sample_frac(size = 0.0001, replace = FALSE)
df <- df %>% mutate(OOS_MC_xbd2 = if_else(OOS_MC_xbd2 > 0, OOS_MC_xbd2,0)) 
# n <- 10
# nr <- nrow(df)
# split(df, rep(1:ceiling(nr/n), each=n, length.out=nr))

# ptm <- proc.time()
# 
# df <- df %>% 
#   partition() %>% 
#   as.data.frame() %>% 
#   adply(1, summarize, 
#         implied_price2 = uniroot.all(function(p) ((p - OOS_MC_xbd2)*(D_beta / p) +  (OOS_D_xbd_noP + (D_beta * log(p)))), interval = c(0,100000))[1]) %>% 
#   collect()
# 
# proc.time() - ptm

ptm <- proc.time()

df <- df %>% 
  as.data.frame() %>% 
  adply(1, summarize, 
        implied_price2 = uniroot.all(function(p) ((p - OOS_MC_xbd2)*(D_beta / p) +  (OOS_D_xbd_noP + (D_beta * log(p)))), interval = c(0,100000))[1])

proc.time() - ptm
df %>% head(50)

# Write CSV in R
df %>%
  select(propertyid, date, implied_price2) %>%
  write.csv( file = "09_03_solved_nonlinear_computed_price_oos2.csv", row.names=TRUE , na = "")