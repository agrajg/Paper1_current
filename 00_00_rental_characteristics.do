clear all 
set more off
use "Y:\agrajg\Research\Data\temp\000102_AIRDNA_listings_data_clean_final.dta", clear
keep propertyid propertytype listingtype bedrooms bathrooms maxguests cancellationpolicy securitydeposit cleaningfee extrapeoplefee checkintime checkouttime minimumstay instantbookenabled latitude longitude
gen latitude_2 = latitude * latitude
gen longitude_2 = longitude *longitude
gen latitude_longitude = latitude * longitude
gen latitude_2_longitude_2 = latitude_2 * longitude_2

foreach lname of varlist propertytype listingtype cancellationpolicy checkintime checkouttime instantbookenabled {
	rename `lname' temp
	encode temp , gen (`lname')
	drop temp
}


save "Y:\agrajg\Research\Paper1_demand_stata\00_00_rental_characteristics.dta", replace
