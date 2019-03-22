clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
use "01_04_purged_property_last_date.dta", clear
rename purge_date date
merge 1:1 purge_propertyid using "01_04_purged_property_latitude_longitude.dta"
keep if _merge == 3
drop _merge
save "04_01_purged_property_location_last_date.dta", replace
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
clear all
use "03_01_Full_sample_latitude_longitude_no_date_gap.dta", clear
count
sort date
joinby date using "04_01_purged_property_location_last_date.dta"
save "04_01_property_purge_property_location_last_date.dta", replace
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
clear all
use "04_01_property_purge_property_location_last_date.dta", clear
* this  data is not right, what data should have been here??
// keep if date >=td(01nov2015) & date <=td(15nov2015)
*-------------------------------------------------------------------------------
gen mile =  (sqrt((( latitude - purge_latitude )/0.009005)^2 + (( longitude - purge_longitude )/0.011834)^2))/1.60934
label var mile "Distance from purged rental (miles)"
gen km =  (sqrt((( latitude - purge_latitude )/0.009005)^2 + (( longitude - purge_longitude )/0.011834)^2))
label var km "Distance from purged rental (km)"
*-------------------------------------------------------------------------------

global DIST_INTERVAL 1000 2000 5000 10000 20000
foreach lname in $DIST_INTERVAL  {
	di `lname'
	gen byte inmile_0_`lname' = (mile >=0 & mile <(`lname'/1000))
	gen byte inmile_`lname'_plus = (mile >=(`lname'/1000)) 
	gen byte inkm_0_`lname' = (km >=0 & km <(`lname'/1000))		
	gen byte inkm_`lname'_plus = (km >=(`lname'/1000)) 		
}
global DIST_INTERVAL 500 1000 2000 5000 10000 20000
local prelname = 0
foreach lname in $DIST_INTERVAL  {
	di `prelname'
	di `lname'
	gen byte inmile_`prelname'_`lname' = (mile >=(`prelname'/1000) & mile <(`lname'/1000))
	gen byte inkm_`prelname'_`lname' = (km >=(`prelname'/1000) & km <(`lname'/1000))		
	local prelname = `lname'
}
collapse (sum) inmile_* inkm_* /// 
	(count) count_property_purged = mile , by ( propertyid date )
label var count_property_purged "Total rentals purged"
sort propertyid date 
save "04_01_property_purge_collapsed.dta", replace
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<





