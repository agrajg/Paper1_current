clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"

// *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// use "03_01_Filtered_Data_on_property_date.dta" , clear
// keep propertyid date
// save "03_01_Panel_with_property_date_only.dta", replace
// *<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Distance measure
use  "01_05_rectangularized_wide_form_data_on_prop_and_purge_prop_dist.dta", clear
global DIST_INTERVAL 500 1000 2000 5000 10000
foreach lname in $DIST_INTERVAL  {
	di `lname'
	foreach vname of varlist dist_*{
		gen byte m`lname'_`vname' = (`vname' <=(`lname'/1000))
		order m`lname'_`vname', before(`vname')
	}
}
save "04_01_purge_distance_indicators.dta", replace


* Time measure

use  "01_06_rectangularized_wide_form_data_on_date_and_purge_prop_dist.dta", clear 
global TIME_INTREVAL  7 14 21 28 35 42 49 56 
foreach lname in $TIME_INTREVAL  {
	di `lname'
	foreach vname of varlist days_post_purge*{
		gen byte pre`lname'_`vname' = (`vname' > `lname' - 7 & `vname' <= `lname')
		gen byte post`lname'_`vname' = (`vname' > -`lname' & `vname' <= `lname'+7)
		order pre`lname'_`vname' post`lname'_`vname', before(`vname')
	}
}
save "04_01_purge_date_indicators.dta", replace
