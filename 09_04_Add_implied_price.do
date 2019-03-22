clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
cd "Y:\agrajg\Research\Paper1_demand_stata"
*===============================================================================
import delimited "09_02_solved_nonlinear_computed_price_oos1.csv", clear
keep propertyid date implied_price1
destring propertyid, replace
capture drop tempvar
gen tempvar = date(date, "DMY")
format tempvar %td
drop date
rename tempvar date
order propertyid date implied_price1
save "09_04_solved_nonlinear_computed_price_oos1.dta", replace
*===============================================================================
import delimited "09_03_solved_nonlinear_computed_price_oos2.csv", clear
keep propertyid date implied_price2
destring propertyid, replace
capture drop tempvar
gen tempvar = date(date, "DMY")
format tempvar %td
drop date
rename tempvar date
order propertyid date implied_price2
save "09_04_solved_nonlinear_computed_price_oos2.dta", replace
*===============================================================================
use "09_01_For_non_linear_price_computation_full.dta", clear
merge 1:1 propertyid date using "09_04_solved_nonlinear_computed_price_oos1.dta"
drop if _merge == 2
drop _merge
merge 1:1 propertyid date using "09_04_solved_nonlinear_computed_price_oos2.dta"
drop if _merge == 2
drop _merge

replace implied_price1 = exp(-((OOS_D_xbd_noP/D_beta)+1)) if OOS_MC_xbd1 <=0 & implied_price1 ==.
replace implied_price2 = exp(-((OOS_D_xbd_noP/D_beta)+1)) if OOS_MC_xbd2 <=0 & implied_price2 ==.

save "09_04_Data_for_welfare_calculationns.dta", replace
*===============================================================================
