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

rename distdum_0_500 dd_0_500 
rename distdum_500_1000 dd_500_1000 
rename distdum_1000_2000 dd_1000_2000 
rename distdum_2000_5000 dd_2000_5000 
rename distdum_5000_10000 dd_5000_10000 
rename distdum_10000_plus dd_10000_plus
rename count_property_purged dd_all

* converting data from last date to exit date
sort propertyid date
foreach lname of varlist dd_0_500 dd_500_1000 dd_1000_2000 dd_2000_5000 dd_5000_10000 dd_10000_plus dd_all{
	capture drop tempvar
	rename `lname' tempvar
	gen `lname' = tempvar[_n-1]
	replace `lname' = 0 if `lname' == .
	by propertyid: gen ex_`lname' = `lname' if _n == 1
	by propertyid: replace ex_`lname' = ex_`lname'[_n-1] + `lname' if _n > 1 
	drop tempvar
}

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* ex_dd_10000_plus
* lag weeks 
by propertyid: gen ex_dd_0_500_p0_7 = ex_dd_0_500 - ex_dd_0_500[_n-7]
by propertyid: gen ex_dd_500_1000_p0_7 =  ex_dd_500_1000 - ex_dd_500_1000[_n-7]
by propertyid: gen ex_dd_1000_2000_p0_7 = ex_dd_1000_2000 - ex_dd_1000_2000[_n-7]
by propertyid: gen ex_dd_2000_5000_p0_7 = ex_dd_2000_5000 - ex_dd_2000_5000[_n-7]
by propertyid: gen ex_dd_5000_10000_p0_7 = ex_dd_5000_10000 - ex_dd_5000_10000[_n-7]
by propertyid: gen ex_dd_10000_plus_p0_7 = ex_dd_10000_plus - ex_dd_10000_plus[_n-7]
by propertyid: gen ex_dd_all_p0_7 = ex_dd_all - ex_dd_all[_n-7]

*lead weeks
by propertyid: gen ex_dd_0_500_f0_7 = ex_dd_0_500[_n+7] - ex_dd_0_500
by propertyid: gen ex_dd_500_1000_f0_7 =  ex_dd_500_1000[_n+7] - ex_dd_500_1000
by propertyid: gen ex_dd_1000_2000_f0_7 = ex_dd_1000_2000[_n+7] - ex_dd_1000_2000
by propertyid: gen ex_dd_2000_5000_f0_7 = ex_dd_2000_5000[_n+7] - ex_dd_2000_5000
by propertyid: gen ex_dd_5000_10000_f0_7 = ex_dd_5000_10000[_n+7] - ex_dd_5000_10000
by propertyid: gen ex_dd_10000_plus_f0_7 = ex_dd_10000_plus[_n+7] - ex_dd_10000_plus
by propertyid: gen ex_dd_all_f0_7 = ex_dd_all[_n+7] - ex_dd_all

* lag weeks 
by propertyid: gen ex_dd_0_500_p7_14 = ex_dd_0_500[_n-7] - ex_dd_0_500[_n-14]
by propertyid: gen ex_dd_500_1000_p7_14 =  ex_dd_500_1000[_n-7] - ex_dd_500_1000[_n-14]
by propertyid: gen ex_dd_1000_2000_p7_14 = ex_dd_1000_2000[_n-7] - ex_dd_1000_2000[_n-14]
by propertyid: gen ex_dd_2000_5000_p7_14 = ex_dd_2000_5000[_n-7] - ex_dd_2000_5000[_n-14]
by propertyid: gen ex_dd_5000_10000_p7_14 = ex_dd_5000_10000[_n-7] - ex_dd_5000_10000[_n-14]
by propertyid: gen ex_dd_10000_plus_p7_14 = ex_dd_10000_plus[_n-7] - ex_dd_10000_plus[_n-14]
by propertyid: gen ex_dd_all_p7_14 = ex_dd_all[_n-7] - ex_dd_all[_n-14]

*lead weeks
by propertyid: gen ex_dd_0_500_f7_14 = ex_dd_0_500[_n+14] - ex_dd_0_500[_n+7]
by propertyid: gen ex_dd_500_1000_f7_14 =  ex_dd_500_1000[_n+14] - ex_dd_500_1000[_n+7]
by propertyid: gen ex_dd_1000_2000_f7_14 = ex_dd_1000_2000[_n+14] - ex_dd_1000_2000[_n+7]
by propertyid: gen ex_dd_2000_5000_f7_14 = ex_dd_2000_5000[_n+14] - ex_dd_2000_5000[_n+7]
by propertyid: gen ex_dd_5000_10000_f7_14 = ex_dd_5000_10000[_n+14] - ex_dd_5000_10000[_n+7]
by propertyid: gen ex_dd_10000_plus_f7_14 = ex_dd_10000_plus[_n+14] - ex_dd_10000_plus[_n+7]
by propertyid: gen ex_dd_all_f7_14 = ex_dd_all[_n+14] - ex_dd_all[_n+7]

* lag weeks 
by propertyid: gen ex_dd_0_500_p14_21 = ex_dd_0_500[_n-14] - ex_dd_0_500[_n-21]
by propertyid: gen ex_dd_500_1000_p14_21 =  ex_dd_500_1000[_n-14] - ex_dd_500_1000[_n-21]
by propertyid: gen ex_dd_1000_2000_p14_21 = ex_dd_1000_2000[_n-14] - ex_dd_1000_2000[_n-21]
by propertyid: gen ex_dd_2000_5000_p14_21 = ex_dd_2000_5000[_n-14] - ex_dd_2000_5000[_n-21]
by propertyid: gen ex_dd_5000_10000_p14_21 = ex_dd_5000_10000[_n-14] - ex_dd_5000_10000[_n-21]
by propertyid: gen ex_dd_10000_plus_p14_21 = ex_dd_10000_plus[_n-14] - ex_dd_10000_plus[_n-21]
by propertyid: gen ex_dd_all_p14_21 = ex_dd_all[_n-14] - ex_dd_all[_n-21]

*lead weeks
by propertyid: gen ex_dd_0_500_f14_21 = ex_dd_0_500[_n+21] - ex_dd_0_500[_n+14]
by propertyid: gen ex_dd_500_1000_f14_21 =  ex_dd_500_1000[_n+21] - ex_dd_500_1000[_n+14]
by propertyid: gen ex_dd_1000_2000_f14_21 = ex_dd_1000_2000[_n+21] - ex_dd_1000_2000[_n+14]
by propertyid: gen ex_dd_2000_5000_f14_21 = ex_dd_2000_5000[_n+21] - ex_dd_2000_5000[_n+14]
by propertyid: gen ex_dd_5000_10000_f14_21 = ex_dd_5000_10000[_n+21] - ex_dd_5000_10000[_n+14]
by propertyid: gen ex_dd_10000_plus_f14_21 = ex_dd_10000_plus[_n+21] - ex_dd_10000_plus[_n+14]
by propertyid: gen ex_dd_all_f14_21 = ex_dd_all[_n+21] - ex_dd_all[_n+14]

* lag weeks 
by propertyid: gen ex_dd_0_500_p21_28 = ex_dd_0_500[_n-21] - ex_dd_0_500[_n-28]
by propertyid: gen ex_dd_500_1000_p21_28 =  ex_dd_500_1000[_n-21] - ex_dd_500_1000[_n-28]
by propertyid: gen ex_dd_1000_2000_p21_28 = ex_dd_1000_2000[_n-21] - ex_dd_1000_2000[_n-28]
by propertyid: gen ex_dd_2000_5000_p21_28 = ex_dd_2000_5000[_n-21] - ex_dd_2000_5000[_n-28]
by propertyid: gen ex_dd_5000_10000_p21_28 = ex_dd_5000_10000[_n-21] - ex_dd_5000_10000[_n-28]
by propertyid: gen ex_dd_10000_plus_p21_28 = ex_dd_10000_plus[_n-21] - ex_dd_10000_plus[_n-28]
by propertyid: gen ex_dd_all_p21_28 = ex_dd_all[_n-21] - ex_dd_all[_n-28]

*lead weeks
by propertyid: gen ex_dd_0_500_f21_28 = ex_dd_0_500[_n+28] - ex_dd_0_500[_n+21]
by propertyid: gen ex_dd_500_1000_f21_28 =  ex_dd_500_1000[_n+28] - ex_dd_500_1000[_n+21]
by propertyid: gen ex_dd_1000_2000_f21_28 = ex_dd_1000_2000[_n+28] - ex_dd_1000_2000[_n+21]
by propertyid: gen ex_dd_2000_5000_f21_28 = ex_dd_2000_5000[_n+28] - ex_dd_2000_5000[_n+21]
by propertyid: gen ex_dd_5000_10000_f21_28 = ex_dd_5000_10000[_n+28] - ex_dd_5000_10000[_n+21]
by propertyid: gen ex_dd_10000_plus_f21_28 = ex_dd_10000_plus[_n+28] - ex_dd_10000_plus[_n+21]
by propertyid: gen ex_dd_all_f21_28 = ex_dd_all[_n+28] - ex_dd_all[_n+21]

* lag weeks 
by propertyid: gen ex_dd_0_500_p28_35 = ex_dd_0_500[_n-28] - ex_dd_0_500[_n-35]
by propertyid: gen ex_dd_500_1000_p28_35 =  ex_dd_500_1000[_n-28] - ex_dd_500_1000[_n-35]
by propertyid: gen ex_dd_1000_2000_p28_35 = ex_dd_1000_2000[_n-28] - ex_dd_1000_2000[_n-35]
by propertyid: gen ex_dd_2000_5000_p28_35 = ex_dd_2000_5000[_n-28] - ex_dd_2000_5000[_n-35]
by propertyid: gen ex_dd_5000_10000_p28_35 = ex_dd_5000_10000[_n-28] - ex_dd_5000_10000[_n-35]
by propertyid: gen ex_dd_10000_plus_p28_35 = ex_dd_10000_plus[_n-28] - ex_dd_10000_plus[_n-35]
by propertyid: gen ex_dd_all_p28_35 = ex_dd_all[_n-28] - ex_dd_all[_n-35]

*lead weeks
by propertyid: gen ex_dd_0_500_f28_35 = ex_dd_0_500[_n+35] - ex_dd_0_500[_n+28]
by propertyid: gen ex_dd_500_1000_f28_35 =  ex_dd_500_1000[_n+35] - ex_dd_500_1000[_n+28]
by propertyid: gen ex_dd_1000_2000_f28_35 = ex_dd_1000_2000[_n+35] - ex_dd_1000_2000[_n+28]
by propertyid: gen ex_dd_2000_5000_f28_35 = ex_dd_2000_5000[_n+35] - ex_dd_2000_5000[_n+28]
by propertyid: gen ex_dd_5000_10000_f28_35 = ex_dd_5000_10000[_n+35] - ex_dd_5000_10000[_n+28]
by propertyid: gen ex_dd_10000_plus_f28_35 = ex_dd_10000_plus[_n+35] - ex_dd_10000_plus[_n+28]
by propertyid: gen ex_dd_all_f28_35 = ex_dd_all[_n+35] - ex_dd_all[_n+28]
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
gen ex_dd_0_1000 = ex_dd_0_500+ ex_dd_500_1000
gen ex_dd_0_2000 = ex_dd_0_500+ ex_dd_500_1000+ ex_dd_1000_2000
gen ex_dd_0_5000 = ex_dd_0_500+ ex_dd_500_1000+ ex_dd_1000_2000+ ex_dd_2000_5000
gen ex_dd_0_10000 = ex_dd_0_500+ ex_dd_500_1000+ ex_dd_1000_2000+ ex_dd_2000_5000+ ex_dd_5000_10000
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
gen ex_dd_0_1000_p0_7 = ex_dd_0_500_p0_7 + ex_dd_500_1000_p0_7 
gen ex_dd_0_2000_p0_7 = ex_dd_0_500_p0_7 + ex_dd_500_1000_p0_7 + ex_dd_1000_2000_p0_7 
gen ex_dd_0_5000_p0_7 = ex_dd_0_500_p0_7 + ex_dd_500_1000_p0_7 + ex_dd_1000_2000_p0_7 + ex_dd_2000_5000_p0_7 
gen ex_dd_0_10000_p0_7 = ex_dd_0_500_p0_7 + ex_dd_500_1000_p0_7 + ex_dd_1000_2000_p0_7 + ex_dd_2000_5000_p0_7 + ex_dd_5000_10000_p0_7 

gen ex_dd_0_1000_f0_7 = ex_dd_0_500_f0_7 + ex_dd_500_1000_f0_7 
gen ex_dd_0_2000_f0_7 = ex_dd_0_500_f0_7 + ex_dd_500_1000_f0_7 + ex_dd_1000_2000_f0_7 
gen ex_dd_0_5000_f0_7 = ex_dd_0_500_f0_7 + ex_dd_500_1000_f0_7 + ex_dd_1000_2000_f0_7 + ex_dd_2000_5000_f0_7 
gen ex_dd_0_10000_f0_7 = ex_dd_0_500_f0_7 + ex_dd_500_1000_f0_7 + ex_dd_1000_2000_f0_7 + ex_dd_2000_5000_f0_7 + ex_dd_5000_10000_f0_7 
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
gen ex_dd_0_1000_p7_14 = ex_dd_0_500_p7_14 + ex_dd_500_1000_p7_14 
gen ex_dd_0_2000_p7_14 = ex_dd_0_500_p7_14 + ex_dd_500_1000_p7_14 + ex_dd_1000_2000_p7_14 
gen ex_dd_0_5000_p7_14 = ex_dd_0_500_p7_14 + ex_dd_500_1000_p7_14 + ex_dd_1000_2000_p7_14 + ex_dd_2000_5000_p7_14 
gen ex_dd_0_10000_p7_14 = ex_dd_0_500_p7_14 + ex_dd_500_1000_p7_14 + ex_dd_1000_2000_p7_14 + ex_dd_2000_5000_p7_14 + ex_dd_5000_10000_p7_14 

gen ex_dd_0_1000_f7_14 = ex_dd_0_500_f7_14 + ex_dd_500_1000_f7_14 
gen ex_dd_0_2000_f7_14 = ex_dd_0_500_f7_14 + ex_dd_500_1000_f7_14 + ex_dd_1000_2000_f7_14 
gen ex_dd_0_5000_f7_14 = ex_dd_0_500_f7_14 + ex_dd_500_1000_f7_14 + ex_dd_1000_2000_f7_14 + ex_dd_2000_5000_f7_14 
gen ex_dd_0_10000_f7_14 = ex_dd_0_500_f7_14 + ex_dd_500_1000_f7_14 + ex_dd_1000_2000_f7_14 + ex_dd_2000_5000_f7_14 + ex_dd_5000_10000_f7_14 
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
gen ex_dd_0_1000_p14_21 = ex_dd_0_500_p14_21 + ex_dd_500_1000_p14_21 
gen ex_dd_0_2000_p14_21 = ex_dd_0_500_p14_21 + ex_dd_500_1000_p14_21 + ex_dd_1000_2000_p14_21 
gen ex_dd_0_5000_p14_21 = ex_dd_0_500_p14_21 + ex_dd_500_1000_p14_21 + ex_dd_1000_2000_p14_21 + ex_dd_2000_5000_p14_21 
gen ex_dd_0_10000_p14_21 = ex_dd_0_500_p14_21 + ex_dd_500_1000_p14_21 + ex_dd_1000_2000_p14_21 + ex_dd_2000_5000_p14_21 + ex_dd_5000_10000_p14_21 

gen ex_dd_0_1000_f14_21 = ex_dd_0_500_f14_21 + ex_dd_500_1000_f14_21 
gen ex_dd_0_2000_f14_21 = ex_dd_0_500_f14_21 + ex_dd_500_1000_f14_21 + ex_dd_1000_2000_f14_21 
gen ex_dd_0_5000_f14_21 = ex_dd_0_500_f14_21 + ex_dd_500_1000_f14_21 + ex_dd_1000_2000_f14_21 + ex_dd_2000_5000_f14_21 
gen ex_dd_0_10000_f14_21 = ex_dd_0_500_f14_21 + ex_dd_500_1000_f14_21 + ex_dd_1000_2000_f14_21 + ex_dd_2000_5000_f14_21 + ex_dd_5000_10000_f14_21 
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
gen ex_dd_0_1000_p21_28 = ex_dd_0_500_p21_28 + ex_dd_500_1000_p21_28 
gen ex_dd_0_2000_p21_28 = ex_dd_0_500_p21_28 + ex_dd_500_1000_p21_28 + ex_dd_1000_2000_p21_28 
gen ex_dd_0_5000_p21_28 = ex_dd_0_500_p21_28 + ex_dd_500_1000_p21_28 + ex_dd_1000_2000_p21_28 + ex_dd_2000_5000_p21_28 
gen ex_dd_0_10000_p21_28 = ex_dd_0_500_p21_28 + ex_dd_500_1000_p21_28 + ex_dd_1000_2000_p21_28 + ex_dd_2000_5000_p21_28 + ex_dd_5000_10000_p21_28 

gen ex_dd_0_1000_f21_28 = ex_dd_0_500_f21_28 + ex_dd_500_1000_f21_28 
gen ex_dd_0_2000_f21_28 = ex_dd_0_500_f21_28 + ex_dd_500_1000_f21_28 + ex_dd_1000_2000_f21_28 
gen ex_dd_0_5000_f21_28 = ex_dd_0_500_f21_28 + ex_dd_500_1000_f21_28 + ex_dd_1000_2000_f21_28 + ex_dd_2000_5000_f21_28 
gen ex_dd_0_10000_f21_28 = ex_dd_0_500_f21_28 + ex_dd_500_1000_f21_28 + ex_dd_1000_2000_f21_28 + ex_dd_2000_5000_f21_28 + ex_dd_5000_10000_f21_28 
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
gen ex_dd_0_1000_p28_35 = ex_dd_0_500_p28_35 + ex_dd_500_1000_p28_35 
gen ex_dd_0_2000_p28_35 = ex_dd_0_500_p28_35 + ex_dd_500_1000_p28_35 + ex_dd_1000_2000_p28_35 
gen ex_dd_0_5000_p28_35 = ex_dd_0_500_p28_35 + ex_dd_500_1000_p28_35 + ex_dd_1000_2000_p28_35 + ex_dd_2000_5000_p28_35 
gen ex_dd_0_10000_p28_35 = ex_dd_0_500_p28_35 + ex_dd_500_1000_p28_35 + ex_dd_1000_2000_p28_35 + ex_dd_2000_5000_p28_35 + ex_dd_5000_10000_p28_35 

gen ex_dd_0_1000_f28_35 = ex_dd_0_500_f28_35 + ex_dd_500_1000_f28_35 
gen ex_dd_0_2000_f28_35 = ex_dd_0_500_f28_35 + ex_dd_500_1000_f28_35 + ex_dd_1000_2000_f28_35 
gen ex_dd_0_5000_f28_35 = ex_dd_0_500_f28_35 + ex_dd_500_1000_f28_35 + ex_dd_1000_2000_f28_35 + ex_dd_2000_5000_f28_35 
gen ex_dd_0_10000_f28_35 = ex_dd_0_500_f28_35 + ex_dd_500_1000_f28_35 + ex_dd_1000_2000_f28_35 + ex_dd_2000_5000_f28_35 + ex_dd_5000_10000_f28_35 
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



* Finalizing and saving
keep if date >= td(01sep2014) & date <= td(31mar2017)
drop if status =="B"
compress exit_in_*
keep propertyid date  exit_in_*
save "04_02_Purge_variables_finalized.dta", replace


