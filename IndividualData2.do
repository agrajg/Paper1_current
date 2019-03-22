// In this do file, i create choice data using market data .
// Basically for each booking done, what were the available bookings that were unsuccessful
clear all
set more off
// Load the market data
use "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final.dta", clear
********************************************************************************
drop if status =="B"
sort propertyid date reservationid bookeddate
********************************************************************************
cd "Y:\agrajg\Research\Data\IndividualChoiceData2"
********************************************************************************
// // simply breaking data by dates
// sum date
// local begin_date = r(min)
// local end_date = r(max)
// forvalues t = `begin_date'(1)`end_date' {
// 	preserve
// 	keep if date == `t'
// 	save "Market_data_`t'.dta", replace
// 	restore
// }
********************************************************************************

sum date
// local begin_date = r(min)
local begin_date = 20351
// local end_date = r(max)
local end_date = 20400
// local t = 20084
forvalues t = `begin_date'(1)`end_date' {
	use "Market_data_`t'.dta", clear
	di "time = "
	di `t'
	di "-----------------------------------------------------------------------"
	gen bdate = bookeddate if bookeddate !=.
	replace bdate = date if bookeddate ==.
	format bdate %td
	duplicates list propertyid
	egen pid = group(propertyid)
	sum pid
	local begin_pid = r(min)
	local end_pid = r(max) 
	forvalues id = `begin_pid'(1)`end_pid' {
		preserve
		di "time = "
		di `t'	
		di "pid = "
		di `id'
		local propertyid_tag = propertyid[`id']
		di "propertyid = "
		di `propertyid_tag'
		di "-------------------------------------------------------------------"
		capture drop temp
		gen temp = bdate if pid == `id'
		 
		capture drop refdate
		egen refdate = min(temp)
		format refdate %td
		capture drop choicedum
		gen choicedum = (refdate <= bdate)
		drop if choicedum == 0
		capture drop choicedum
		gen choice = (pid == `id' & status=="R")
		drop bdate pid temp refdate 
		save "Choice_data_`t'_`propertyid_tag'.dta", replace
		restore
	}
}


 
