* this file takes list of purged properties and finds distance from all the other listings
* and rectangularise the data propertyid X purged_propertyid 
* create distance measure and for each propery and purged property combination
* Finally reshape it to wide
clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm

cd "Y:\agrajg\Research\Paper1_demand_stata"
use "01_04_rectangulaized_data_property_and_purge_property.dta", clear
* calculating the distance between existing and purged listings
merge m:1 propertyid using "01_04_all_property_latitude_longitude.dta"
keep if _merge ==3
drop _merge
merge m:1 purge_propertyid  using "01_04_purged_property_latitude_longitude.dta"
keep if _merge ==3
drop _merge
gen dist =  sqrt((( latitude - purge_latitude )/0.009005)^2 + (( longitude - purge_longitude )/0.011834)^2)
keep propertyid purge_propertyid dist
save "01_05_rectangularized_long_form_data_on_prop_and_purge_prop_dist.dta", replace 





capture reshape wide dist , i( propertyid ) j( purge_propertyid )
save "01_05_rectangularized_wide_form_data_on_prop_and_purge_prop_dist.dta", replace 
