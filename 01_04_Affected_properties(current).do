* This file creates two rectangularized files
* one for property matched with purged properties
* one for date with purged properties

clear all 
set more off
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "01_01_active_listing_data_common_with_MCOX.dta", clear
contract propertyid latitude longitude maxguests
drop _freq
count if latitude ==.
compress
save "01_04_all_property_latitude_longitude.dta" , replace
*-------------------------------------------------------------------------------
merge 1:1 propertyid using 01_03_purged_properties_list.dta
gen purge_dum = (_merge == 3)
gen purge_propertyid = propertyid if purge_dum ==1
*-------------------------------------------------------------------------------
preserve
keep if purge_dum == 1
order propertyid purge_propertyid latitude longitude maxguests
keep  purge_propertyid latitude longitude maxguests
rename latitude purge_latitude
rename longitude purge_longitude

* converting quantity as capacity
gen capacity = maxguests if maxguests > 0
replace capacity = 1 if maxguests == 0
rename capacity purge_capacity
drop maxguests

compress
recast long purge_propertyid
replace purge_propertyid = 17233439 if purge_propertyid ==17233440
save "01_04_purged_property_latitude_longitude.dta" , replace
restore
*-------------------------------------------------------------------------------
keep propertyid purge_propertyid 
fillin propertyid purge_propertyid
drop if propertyid ==. | purge_propertyid ==.
drop _fillin
compress
save "01_04_rectangulaized_data_property_and_purge_property.dta", replace
*-------------------------------------------------------------------------------



*This section rectangularizes the data date X purged property
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* last date of the purged properties.
clear all 
set more off
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "01_01_active_listing_data_common_with_MCOX.dta", clear
collapse (max) last_date = date , by(propertyid)
merge 1:1 propertyid using "01_03_purged_properties_list.dta"
keep if _merge == 3
drop _merge
rename propertyid purge_propertyid
rename last_date purge_date
sort purge_propertyid
save "01_04_purged_property_last_date.dta", replace
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
clear all 
set more off 
use "01_01_active_listing_data_common_with_MCOX.dta", clear
contract date
gen purge_date = date
drop _freq
merge 1:m purge_date using "01_04_purged_property_last_date.dta"
drop if _merge ==2
drop _merge
drop purge_date
fillin date purge_propertyid
drop if date == . | purge_propertyid ==.
drop _fillin
save "01_04_rectangulaized_data_date_and_purge_property.dta", replace
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

