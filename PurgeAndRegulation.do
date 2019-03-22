clear all
set more off
use "Y:\agrajg\Research\Paper1_demand_stata\ElasticityEst2.dta", replace
xtset propertyid date


preserve
use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
keep propertyid state hostid listingtype
save "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta", replace
restore

merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta"
keep if _merge ==3
drop _merge


merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\MCOX_property_host.dta"
keep if _merge ==3
drop _merge


preserve
