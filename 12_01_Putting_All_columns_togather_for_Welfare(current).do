clear all
forval i = 1(1)31 {
	import delimited Y:\agrajg\Research\Paper1_demand_stata\11_03_solved_nonlinear_computed_price_oos1_part_`i'.csv, bindquote(strict) varnames(1) asfloat clear
	keep propertyid date implied_price1
	gen date1 = date(date, "DM20Y")
	format date1 %td
	drop date
	rename date1 date
	order propertyid date implied_price1
	recast double implied_price1
	duplicates drop
	save "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos1_part_`i'.dta", replace
}
use "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos1_part_1.dta", clear
forval i = 2(1)31 {
	append using "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos1_part_`i'.dta"
}
save "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos1.dta", replace
*-------------------------------------------------------------------------------
clear all
forval i = 1(1)31 {
	import delimited Y:\agrajg\Research\Paper1_demand_stata\11_04_solved_nonlinear_computed_price_oos2_part_`i'.csv, bindquote(strict) varnames(1) asfloat clear
	keep propertyid date implied_price2
	gen date1 = date(date, "DM20Y")
	format date1 %td
	drop date
	rename date1 date
	order propertyid date implied_price2
	recast double implied_price2
	duplicates drop
	save "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos2_part_`i'.dta", replace
}
use "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos2_part_1.dta", clear
forval i = 2(1)31 {
	append using "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos2_part_`i'.dta"
}
save "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos2.dta", replace
*-------------------------------------------------------------------------------
* Run this part for one single file. Otherwise not necessary
// clear all
// import delimited Y:\agrajg\Research\Paper1_demand_stata\11_01_solved_nonlinear_computed_price_oos1.csv, bindquote(strict) varnames(1) asfloat
// keep propertyid date implied_price1
// gen date1 = date(date, "DM20Y")
// format date1 %td
// drop date
// rename date1 date
// order propertyid date implied_price1
// save "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos1.dta", replace
//
// clear all
// import delimited Y:\agrajg\Research\Paper1_demand_stata\11_02_solved_nonlinear_computed_price_oos2.csv, bindquote(strict) varnames(1) asfloat
// keep propertyid date implied_price2
// gen date1 = date(date, "DM20Y")
// format date1 %td
// drop date
// rename date1 date
// order propertyid date implied_price2
// save "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos2.dta", replace
// *-------------------------------------------------------------------------------
clear all
set more off
clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "10_01_For_non_linear_price_computation_full.dta", clear
*===============================================================================
merge 1:1 propertyid date using "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos1.dta"
drop if _merge==2
drop _merge
merge 1:1 propertyid date using "Y:\agrajg\Research\Paper1_demand_stata\12_01_solved_nonlinear_computed_price_oos2.dta"
drop if _merge==2
drop _merge
*===============================================================================
merge 1:1 propertyid date using "Y:\agrajg\Research\Paper1_demand_stata\04_06_Purge_variables_finalized_CS.dta"
drop _merge
sort propertyid date
foreach y of varlist N_inmile_0_500 N_inmile_500_1000 N_inmile_1000_2000 N_inmile_2000_5000 N_inmile_5000_10000 N_cap_inmile_0_500 N_cap_inmile_500_1000 N_cap_inmile_1000_2000 N_cap_inmile_2000_5000 N_cap_inmile_5000_10000{
	bysort propertyid: carryforward `y', replace
	replace `y' = 0 if `y'==.
}
*===============================================================================
// compress
save "Y:\agrajg\Research\Paper1_demand_stata\12_01_Welfare_Calculations_Data.dta", replace
*===============================================================================

