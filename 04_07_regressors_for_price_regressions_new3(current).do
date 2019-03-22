clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
use  "03_02_Regression_Data.dta" , clear
merge 1:1 propertyid date using "04_06_Purge_variables_finalized_new.dta"
drop _merge 
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
* Price_regression_ready_data
save "04_07_Price_regression_ready_data.dta", replace
