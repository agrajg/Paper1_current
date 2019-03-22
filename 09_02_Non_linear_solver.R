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
library(parallel)

df <-as.data.frame(MC_demand)
df <- df %>% sample_frac(size = 0.0001, replace = FALSE)
df <- df %>% mutate(OOS_MC_xbd1 = if_else(OOS_MC_xbd1 > 0, OOS_MC_xbd1,0)) 


cores <- detectCores()



cluster <- makePSOCKcluster(cores)

system.time(parLapply(cluster, 1:10, function(i) Sys.sleep(i)))


# n <- 10
# nr <- nrow(df)
# split(df, rep(1:ceiling(nr/n), each=n, length.out=nr))
# ptm <- proc.time()
# 
# df <- df %>% 
#   partition() %>% 
#   as.data.frame() %>% 
#   adply(1, summarize, 
#         implied_price1 = uniroot.all(function(p) ((p - OOS_MC_xbd1)*(D_beta / p) +  (OOS_D_xbd_noP + (D_beta * log(p)))), interval = c(0,100000))[1]) %>% 
#   collect()
# 
# proc.time() - ptm

# ptm <- proc.time()
# 
df <- df %>%
  parApply(cl= cl, MARGIN = 1, FUN =  function(z) (uniroot.all(function(p) ((p - z['OOS_MC_xbd1'])*(z['D_beta'] / p) +  (z['OOS_D_xbd_noP'] + (z['D_beta'] * log(p)))), interval = c(0,100000))[1]))
# 
# df <- df %>% 
#   apply(MARGIN = 1, 
#         FUN = function(z){uniroot.all(function(x)(x - z['OOS_MC_xbd1'])*(z['D_beta'] / x) +  (z['OOS_D_xbd_noP'] + (z['D_beta'] * log(x)))), interval = c(0,100000))[1]}
# 
# proc.time() - ptm

# Test Code
df <- as.data.frame(matrix(1:6,ncol=2))
apply(df, 1, function(z) uniroot.all(function(x)z[1]-z[2]+x,interval = c(0,100)))



df %>% head(50)

# Write CSV in R
df %>%
  select(propertyid, date, implied_price1) %>%
  write.csv( file = "09_02_solved_nonlinear_computed_price_oos1.csv", row.names=TRUE , na = "")