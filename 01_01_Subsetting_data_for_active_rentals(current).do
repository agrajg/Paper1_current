clear all
set more off
// // using property data to obtain neighnorhoods
// use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
// keep propertyid hostid  state neighborhood listingtype maxguests bedrooms bathrooms createddate latitude longitude 
// save "Y:\agrajg\Research\Paper1_demand_stata\Some_property_characteristics.dta", replace
//
// // merging neighborhood to the market data
// clear all 
// use "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final.dta", clear
// merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\Some_property_characteristics.dta"
// keep if _merge == 3
// drop _merge
// save "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final_with_some_Prod_char.dta", replace
// ********************************************************************************

* Subsetting the data for active listing that are common to both 
clear all
set more off
*-------------------------------------------------------------------------------
cd "Y:\agrajg\Research\Paper1_demand_stata\"
use "000103_AIRDNA_market_data_clean_final_with_some_Prod_char.dta", clear

merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\DataSource.dta"
keep if _merge == 3
drop _merge

********************************************************************************
** Subseting the data dor completeness
keep if AIRDNAMarketdum ==1 & MCOXPropertydum ==1
drop  AIRDNAPropertydum AIRDNAMarketdum MCOXPropertydum MCOXreviewdum
********************************************************************************


*-------------------------------------------------------------------------------
* This data may not be very accurate
drop if date < td(01sep2014)
drop if status =="B"
*-------------------------------------------------------------------------------
compress
save "01_01_active_listing_data_common_with_MCOX.dta", replace
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------


