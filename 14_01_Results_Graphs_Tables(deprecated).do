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
use "13_01_Computed_WTP_Welfare.dta", clear
drop if price > 10000
timer off 1
timer list
*===============================================================================
* RESULTS 
* Price change
*-------------------------------------------------------------------------------
// preserve
// keep if proddum == 1
// collapse (mean) adj_price_per_person adj_ppp_cf , by (date borough listingtype)
// drop if borough ==.
// drop if listingtype == 2
// keep if listingtype == 1
// twoway (line adj_price_per_person date, sort lcolor(black) lwidth(thin)) (line adj_ppp_cf date, sort lwidth(thin) lpattern(vshortdash)), xline(20393, lwidth(vthin) lpattern(shortdash)) xlabel(#9, grid) by(, legend(on)) legend(order(1 "Actual Prices" 2 "Counterfactual Prices")) scheme(tufte) xsize(5) ysize(6.5) scale(0.7) by(borough, rows(5) scale(0.7))
// graph export "Y:\agrajg\Research\Paper1_demand_stata\50_01_Growth_Of_Hosts_and)Rentals.png", width(800) replace
// graph export "H:\Output_Oct2018\50_01_Growth_Of_Hosts_and.png", width(800) replace
// restore
*-------------------------------------------------------------------------------
