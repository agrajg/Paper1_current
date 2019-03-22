clear all
set more off
// // using property data to obtain neighnorhoods
// use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
// keep propertyid neighborhood latitude longitude 
// save "Y:\agrajg\Research\Paper1_demand_stata\property_neighborhood_lat_long_data.dta", replace
//
// // merging neighborhood to the market data
// clear all 
// use "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final.dta", clear
// merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\property_neighborhood_lat_long_data.dta"
// keep if _merge == 3
// drop _merge
// save "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final_with_location.dta", replace
********************************************************************************
clear all
set more off
use "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final_with_location.dta", clear
sort propertyid date
// // subsetting the data
// // change these parameters to change location
// local rad = 0.005
// glo t_lat = 40.76
// glo t_long = -73.99
// // local rad = 0.01
// // glo t_lat = 40.81
// // glo t_long = -73.96
// gen dist = sqrt((longitude - $t_long)^2+(latitude - $t_lat)^2)
// keep if dist <= `rad'

count

gen proddum = (status !="B")
by propertyid : gen switchdum = (proddum != proddum[_n-1])
gen spellcount = switchdum if switchdum ==1
by propertyid: replace spellcount  =sum(spellcount  )
by propertyid: egen maxspellcount = max(spellcount )
gen lastspelldum = (maxspellcount==spellcount & proddum ==0)
by propertyid : gen exitdum = (lastspelldum ==1 & lastspelldum[_n-1]==0 )

keep if exitdum==1
