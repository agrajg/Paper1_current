* Subsetting the data for active listing that are common to both 
clear all
set more off
*-------------------------------------------------------------------------------
cd "Y:\agrajg\Research\Paper1_demand_stata\"

* This is the period of observation when we belive the purge was taking place 
global BUFFER_PERIOD = 365
* If the number of days with multi-listing exceeds this number, I claim the host to be a multi-listing host
global MULTI_LISTING_THRESHOLD = 30

local tempnum = $BUFFER_PERIOD
local tempnum2 = $MULTI_LISTING_THRESHOLD

use "01_02_Purged_rentals_in_past_`tempnum'_days_wt_`tempnum2'_since_20606.dta", clear
global update_date_list  20698 20728 20759 20789 20820 20851 20879
foreach lname of global   update_date_list   {
	di `lname'
	preserve
	contract propertyid listingtype borough purge_dum last_date
	tab borough listingtype  if purge_dum == 1 & last_date>=td(01nov2015)
	restore
	append using "01_02_Purged_rentals_in_past_`tempnum'_days_wt_`tempnum2'_since_`lname'.dta"

}

drop if purge_dum ==0
contract propertyid listingtype nbhd nbhd_group borough hostid last_date
tab  borough listingtype
keep if listingtype == "Entire home/apt"
keep if last_date >=td(01nov2015) & last_date < td(01mar2017)
drop _freq
duplicates drop propertyid, force
tab borough
// keep propertyid
merge 1:1 propertyid using "00_00_rental_characteristics.dta", force
keep if _merge ==3
tab propertytype
decode propertytype , gen(ptype)
keep if ptype == "Apartment" | ptype == "Condominium" | ptype == "Dorm" | ptype == "Loft" | ptype == "Townhouse"
tab borough
keep propertyid
save "01_03_purged_properties_list.dta", replace
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

