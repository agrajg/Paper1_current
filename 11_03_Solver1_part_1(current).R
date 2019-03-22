# Rscript "y:\agrajg\Research\Paper1_demand_stata\11_03_Solver1_part_1(current).R"

rm(list = ls())
setwd("Y:/agrajg/Research/Paper1_demand_stata")
.libPaths(new = c("Y:/agrajg/Research/Paper1/packrat/lib/x86_64-w64-mingw32/3.4.3",
                  "H:/agrajg/R",
                  "H:/agrajg/R2"))

library(plyr)
library(dplyr)
library(rootSolve)
library(magrittr)
library(parallel)
library(multidplyr)

ptm <- proc.time()
MC_demand <- read.csv(file = "10_01_For_non_linear_price_computation_part_31.csv", header = TRUE)
proc.time() - ptm



df <-as.data.frame(MC_demand)
# df <- df %>% sample_frac(size = 0.0001, replace = FALSE)
df <- df %>% mutate(OOS_MC_xbd1 = if_else(OOS_MC_xbd1 > 0, OOS_MC_xbd1,0))
df

ptm <- proc.time()
df <- df %>%
  as.data.frame() %>%
  adply(1, summarize,
        implied_price1 = uniroot.all(function(p) ((p - OOS_MC_xbd1)*(D_beta / p) +  (OOS_D_xbd_noP + (D_beta * log(p)))), interval = c(0,100000))[1])
proc.time() - ptm

df %>% head(50)

# Write CSV in R
df %>%
  select(propertyid, date, implied_price1) %>%
  write.csv( file = "11_03_solved_nonlinear_computed_price_oos1_part_31.csv", row.names=TRUE , na = "")
