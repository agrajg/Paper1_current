clear all
set more off
clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
timer on 1
use "13_02_Computed_WTP_Welfare.dta", clear
drop if price > 10000 & price != .
timer off 1
timer list
*===============================================================================
