clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm

use  "Y:\agrajg\Research\Paper1_demand_stata\01_05_rectangularized_long_form_data_on_prop_and_purge_prop_dist.dta", clear 
egen ppid = group(purge_propertyid )
sum ppid

forval i = 1(1)`r(max)' {
preserve
keep if ppid == `i'
local pp = purge_propertyid[1]
di `pp'
rename dist dist_`pp'
capture drop ppid
capture drop purge_propertyid
save "Y:\agrajg\Research\Paper1_demand_stata\01_05_property_x_purged_property_fragmented_data\01_05_purged_property_`i'.dta", replace
restore
}


clear all
use "Y:\agrajg\Research\Paper1_demand_stata\01_05_property_x_purged_property_fragmented_data\01_05_purged_property_1.dta" , clear
forval i = 2(1)3807 {
merge 1:1 propertyid using  "Y:\agrajg\Research\Paper1_demand_stata\01_05_property_x_purged_property_fragmented_data\01_05_purged_property_`i'.dta"
keep if _merge == 3
drop _merge
}
save "Y:\agrajg\Research\Paper1_demand_stata\01_05_rectangularized_wide_form_data_on_prop_and_purge_prop_dist.dta", replace


// "Y:\agrajg\Research\Paper1_demand_stata\01_05_property_x_purged_property_fragmented_data\"
