clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
cd "Y:\agrajg\Research\Paper1_demand_stata\"

// using property data to obtain neighnorhoods
use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
keep propertyid hostid  state neighborhood listingtype maxguests bedrooms bathrooms createddate latitude longitude 
save "Y:\agrajg\Research\Paper1_demand_stata\Some_property_characteristics.dta", replace

// merging neighborhood to the market data
clear all 
use "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final.dta", clear
merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\Some_property_characteristics.dta"
keep if _merge == 3
drop _merge
save "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final_with_some_Prod_char.dta", replace
********************************************************************************
clear all
cd "Y:\agrajg\Research\Paper1_demand_stata\"
use "000103_AIRDNA_market_data_clean_final_with_some_Prod_char.dta", clear
********************************************************************************
* We will work with data that is common in both AIRDNA and MCOX. The airdna includes 
* all data fron New Jersey and Pesylvenia. This may not show up in MCOX data. 
* It will be useful to find purged properties from data common in both data. 
* Following commands will help understand why this is the best choice to move forward
// tab status if state == "New York"
// tab status if AIRDNAMarketdum == 1 & MCOXPropertydum == 0
// tab status if state =="New York" & AIRDNAMarketdum == 1 & MCOXPropertydum == 0
// tab status if state =="New York" & AIRDNAMarketdum == 1 & MCOXPropertydum == 1
// tab status if state =="New York" & AIRDNAMarketdum == 1 & MCOXPropertydum == 1 & MCOXreviewdum == 0
// tab status if state =="New York" & AIRDNAMarketdum == 1 & MCOXPropertydum == 1 & MCOXreviewdum == 1
* filtering properties that exist in MCOX as well as AIRDNA data.
merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\DataSource.dta"
keep if _merge == 3
drop _merge
********************************************************************************
** Subseting the data dor completeness
keep if AIRDNAMarketdum ==1 & MCOXPropertydum ==1
drop  AIRDNAPropertydum AIRDNAMarketdum MCOXPropertydum MCOXreviewdum
********************************************************************************
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
preserve
keep propertyid date latitude longitude
save "03_01_Full_sample_latitude_longitude_no_date_gap.dta", replace
restore
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
sort propertyid date
compress
cd "Y:\agrajg\Research\Paper1_demand_stata\"
save "03_01_Filtered_Data_on_property_date.dta" ,replace
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

