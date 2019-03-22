clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
clear all
use "03_01_Full_sample_latitude_longitude_no_date_gap.dta", clear
merge 1:1 propertyid date using "04_01_property_purge_collapsed.dta"
drop _merge


// keep if date >=td(01nov2015) & date <=td(15nov2015)

* converting data from last date to exit date
sort propertyid date
foreach lname of varlist inmile_* inkm_* cap_inmile_* cap_inkm_* count_property_purged {
	capture drop tempvar
	rename `lname' tempvar
	gen `lname' = tempvar[_n-1]
	replace `lname' = 0 if `lname' == .
	by propertyid: gen N_`lname' = `lname' if _n == 1
	by propertyid: replace N_`lname' = N_`lname'[_n-1] + `lname' if _n > 1 
	drop tempvar
}
*-------------------------------------------------------------------------------
* Finalizing and saving
*drop if status =="B"
keep propertyid date  N_*
keep if date >= td(01sep2014) & date <= td(31mar2017)
compress N_*
save "04_06_Purge_variables_finalized_new.dta", replace
keep propertyid date N_inmile_0_500 N_inmile_500_1000 N_inmile_1000_2000 N_inmile_2000_5000 N_inmile_5000_10000 ///
	N_cap_inmile_0_500 N_cap_inmile_500_1000 N_cap_inmile_1000_2000 N_cap_inmile_2000_5000 N_cap_inmile_5000_10000
save "04_06_Purge_variables_finalized_CS.dta", replace
*===============================================================================

