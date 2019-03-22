* and rectangularise the data date X purged_propertyid 
* create days post purge measure  and for each date and purged property combination
* Finally reshape it to wide
clear all 
set more off
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "01_04_rectangulaized_data_date_and_purge_property.dta", clear
replace purge_propertyid =17233439 if purge_propertyid ==17233440

*use rectangularized data to create variable of departure with time of departure
merge m:1 purge_propertyid using "01_04_purged_property_last_date.dta"
keep if _merge==3
drop _merge

gen days_post_purge = date - purge_date
drop purge_date
save "01_06_rectangularized_long_form_data_on_date_and_purge_prop_dist.dta", replace 


capture reshape wide days_post_purge , i(date ) j(purge_propertyid)
save "01_06_rectangularized_wide_form_data_on_date_and_purge_prop_dist.dta", replace 
