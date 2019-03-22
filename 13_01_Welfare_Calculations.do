clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
timer on 1
use "12_01_Welfare_Calculations_Data.dta", clear
timer off 1
timer list
*===============================================================================
timer on 2
*-------------------------------------------------------------------------------
* Counterfactual PRICE
local beta_p_0_500 = 0.016 
local beta_p_500_1000 = 0.0089
local beta_p_1000_2000 = 0.0010
local beta_p_2000_5000 = 0.00063
local beta_p_5000_10000 = 0

* Calculating changes in prices depending on how many rentals had left the market.
* percent change in prices 
capture drop ppp_change_percent 
gen ppp_change_percent = `beta_p_0_500'*N_inmile_0_500 + ///
	`beta_p_500_1000'*N_inmile_500_1000 + ///
	`beta_p_1000_2000'*N_inmile_1000_2000 + ///
	`beta_p_2000_5000'*N_inmile_2000_5000 + /// 
	`beta_p_5000_10000'*N_inmile_5000_10000 ///
	if proddum == 1
label var ppp_change_percent "Price Change (%)"

* Absolute change in prices. This can be done only for rentals that exist in market 
* and have prices  
capture drop ppp_change_abs 
gen ppp_change_abs = (ppp_change_percent/100) *  adj_price_per_person if proddum == 1
label var ppp_change_abs "Price Change ($)"

* Counterfactual prices only for those that exist in the market.
capture drop adj_ppp_cf
gen adj_ppp_cf =  adj_price_per_person - ppp_change_abs if proddum == 1
label var adj_ppp_cf "Counterfactual Price Per Person (adjusted)" 
*-------------------------------------------------------------------------------
* Counterfactual QUANTITY
local beta_q_0_500 		= -0.000330
local beta_q_500_1000 	= -0.000230
local beta_q_1000_2000 	= -0.000070
local beta_q_2000_5000 	= -0.000032
local beta_q_5000_10000 = 0

capture drop quantity_change_abs
gen quantity_change_abs = `beta_q_0_500'*N_inmile_0_500 + ///
	`beta_q_500_1000'*N_inmile_500_1000 + ///
	`beta_q_1000_2000'*N_inmile_1000_2000 + ///
	`beta_q_2000_5000'*N_inmile_2000_5000 + /// 
	`beta_q_5000_10000'*N_inmile_5000_10000 ///
	if proddum == 1
label var quantity_change_abs "Quantity Change (Guest Count)"

* Counterfactual quantity
capture drop quantity_cf
gen quantity_cf =  qdemand - quantity_change_abs if proddum == 1
label var quantity_cf "Counterfactual Quantity (Guest Count)" 
*-------------------------------------------------------------------------------
* Shift in demand for every existing property as purge happened
capture drop demand_shift
gen demand_shift = quantity_cf - ((D_beta*ln(adj_ppp_cf))+OOS_D_xbd_noP)
replace demand_shift = 0 if ppp_change_percent == 0 & quantity_change_abs ==0
label var demand_shift "Demand shift at CF price quantity"
*-------------------------------------------------------------------------------

* Now we have CF demand curve
* Price at which demand = 0 
* generating for all the properties irrespective of weather they exist in market
* or not, will use it to measure the varity effect
capture drop ppp_zero_demand
gen ppp_zero_demand = exp(-(OOS_D_xbd_noP/D_beta)) 
label var ppp_zero_demand "Price when Demand = 0"

capture drop ppp_zero_demand_cf
gen ppp_zero_demand_cf = exp(-((OOS_D_xbd_noP+demand_shift)/D_beta)) 
label var ppp_zero_demand_cf "Price when CF Demand = 0"

* CS at existing prices
capture drop CS_exist_actual
gen CS_exist_actual = .
replace CS_exist_actual = (D_beta*((ppp_zero_demand*ln(ppp_zero_demand)) - ppp_zero_demand) + ((OOS_D_xbd_noP)*ppp_zero_demand)) - ///
	(D_beta*((adj_price_per_person*ln(adj_price_per_person)) - adj_price_per_person) + ((OOS_D_xbd_noP)*adj_price_per_person)) /// 
	if proddum == 1 & ppp_zero_demand > adj_price_per_person 
replace CS_exist_actual = 0 if proddum == 1 & ppp_zero_demand <= adj_price_per_person
label var CS_exist_actual "Consumer Surplus Existing Rentals (actual)"	

* CS at counterfactual prices
capture drop CS_exist_cf
gen CS_exist_cf = .
replace CS_exist_cf = (D_beta*((ppp_zero_demand_cf*ln(ppp_zero_demand_cf)) - ppp_zero_demand_cf) + ((OOS_D_xbd_noP+demand_shift)*ppp_zero_demand_cf)) - ///
	(D_beta*((adj_ppp_cf*ln(adj_ppp_cf)) - adj_ppp_cf) + ((OOS_D_xbd_noP+demand_shift)*adj_ppp_cf)) /// 
	if proddum == 1 & ppp_zero_demand_cf > adj_ppp_cf 
replace CS_exist_cf = 0 if proddum == 1 & ppp_zero_demand_cf <= adj_ppp_cf
replace CS_exist_cf = 0 if proddum == 1 & CS_exist_cf <0
label var CS_exist_cf "Consumer Surplus Existing Rentals (Counterfactual)"	
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Counsumer surplus due to loss of variety
* Rentals purged and last date
* last_date
preserve
use "Y:\agrajg\Research\Paper1_demand_stata\04_01_purge_property_location_last_date.dta", clear
rename date last_date
rename purge_propertyid propertyid 
keep propertyid last_date
save "Y:\agrajg\Research\Paper1_demand_stata\13_01_purge_property_last_date.dta", replace
restore

merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\13_01_purge_property_last_date.dta"
drop if _merge ==2
drop _merge
*-------------------------------------------------------------------------------
capture drop purged_dummy
gen purged_dummy = (date > last_date)
replace purged_dummy = 0 if last_date ==.
*-------------------------------------------------------------------------------
// * implied price cf 
// local beta_p_0_500 = 0.016 
// local beta_p_500_1000 = 0.0089
// local beta_p_1000_2000 = 0.0010
// local beta_p_2000_5000 = 0.00063
// local beta_p_5000_10000 = 0
//
// capture drop implied_price1_cf
// gen implied_price1_cf = implied_price1 - ((`beta_p_0_500'*N_inmile_0_500 + ///
// 	`beta_p_500_1000'*N_inmile_500_1000 + ///
// 	`beta_p_1000_2000'*N_inmile_1000_2000 + ///
// 	`beta_p_2000_5000'*N_inmile_2000_5000 + /// 
// 	`beta_p_5000_10000'*N_inmile_5000_10000 ///
// 	) * implied_price1 / 100) ///
// 	if purged_dummy ==1


* CS at implied prices of rentals that were purged.
capture drop CS_purged_actual
gen CS_purged_actual = .
replace CS_purged_actual = (D_beta*((ppp_zero_demand*ln(ppp_zero_demand)) - ppp_zero_demand) + ((OOS_D_xbd_noP)*ppp_zero_demand)) - ///
	(D_beta*((implied_price1*ln(implied_price1)) - implied_price1) + ((OOS_D_xbd_noP)*implied_price1)) /// 
	if purged_dummy == 1 & ppp_zero_demand > implied_price1 
replace CS_purged = 0 if purged_dummy == 1 & ppp_zero_demand <= implied_price1
label var CS_purged "Consumer Surplus Loss (Variety)"	
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* producer's surplus
* for existing properties
capture drop OOS_MC_xbd1_noQ
gen OOS_MC_xbd1_noQ = OOS_MC_xbd1 - ((MC_beta_maxguests*maxguests)+(MC_beta_maxguests_sq*maxguests_sq))
*-------------------------------------------------------------------------------
* range within which to compute the surplus
capture drop quantity_lower_lim_actual
gen quantity_lower_lim_actual = .
replace quantity_lower_lim_actual = (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_price_per_person))))/(2*MC_beta_maxguests_sq) if proddum == 1
replace quantity_lower_lim_actual = 0 if (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_price_per_person))))/(2*MC_beta_maxguests_sq) <=0 & proddum == 1

capture drop quantity_upper_lim_actual
gen quantity_upper_lim_actual = .
replace quantity_upper_lim_actual = qdemand if qdemand > 0 & qdemand > quantity_lower_lim_actual
*replace quantity_upper_lim_actual = (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_price_per_person))))/(2*MC_beta_maxguests_sq) if proddum == 1
*replace quantity_upper_lim_actual = qdemand if qdemand < (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_price_per_person))))/(2*MC_beta_maxguests_sq) & proddum == 1
 
capture drop PS_exist_actual
gen PS_exist_actual = ((adj_price_per_person*quantity_upper_lim_actual)-(MC_beta_maxguests*(quantity_upper_lim_actual^2)/2)-(MC_beta_maxguests_sq*(quantity_upper_lim_actual^3)/3)-(OOS_MC_xbd1_noQ*quantity_upper_lim_actual)) - /// 
	((adj_price_per_person*quantity_lower_lim_actual)-(MC_beta_maxguests*(quantity_lower_lim_actual^2)/2)-(MC_beta_maxguests_sq*(quantity_lower_lim_actual^3)/3)-(OOS_MC_xbd1_noQ*quantity_lower_lim_actual)) /// 
	if proddum == 1
label var PS_exist_actual "Producer Surplus Existing Rentals (actual)"
*-------------------------------------------------------------------------------
* range within which to compute the surplus
capture drop quantity_lower_lim_cf
gen quantity_lower_lim_cf = .
replace quantity_lower_lim_cf = (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_ppp_cf))))/(2*MC_beta_maxguests_sq) if proddum == 1
replace quantity_lower_lim_cf = 0 if (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_ppp_cf))))/(2*MC_beta_maxguests_sq) <=0 & proddum == 1

capture drop quantity_upper_lim_cf
gen quantity_upper_lim_cf = .
replace quantity_upper_lim_cf = quantity_cf if quantity_cf > 0 & quantity_cf > quantity_lower_lim_cf
*replace quantity_upper_lim_cf = (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_ppp_cf))))/(2*MC_beta_maxguests_sq) if proddum == 1
*replace quantity_upper_lim_cf = quantity_cf if quantity_cf < (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_ppp_cf))))/(2*MC_beta_maxguests_sq) & proddum == 1

capture drop PS_exist_cf
gen PS_exist_cf = ((adj_ppp_cf*quantity_upper_lim_cf)-(MC_beta_maxguests*(quantity_upper_lim_cf^2)/2)-(MC_beta_maxguests_sq*(quantity_upper_lim_cf^3)/3)-(OOS_MC_xbd1_noQ*quantity_upper_lim_cf)) - /// 
	((adj_ppp_cf*quantity_lower_lim_cf)-(MC_beta_maxguests*(quantity_lower_lim_cf^2)/2)-(MC_beta_maxguests_sq*(quantity_lower_lim_cf^3)/3)-(OOS_MC_xbd1_noQ*quantity_lower_lim_cf)) /// 
	if proddum == 1
label var PS_exist_cf "Producer Surplus Existing Rentals (counterfactual)"

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* Producer Surplus from lost sales
capture drop implied_quantity1
gen implied_quantity1 = D_beta *ln(implied_price1) + OOS_D_xbd_noP 

* range within which to compute the surplus
capture drop quantity_purge_lower_lim_actual
gen quantity_purge_lower_lim_actual = .
replace quantity_purge_lower_lim_actual = (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - implied_price1 ))))/(2*MC_beta_maxguests_sq) if purged_dummy == 1
replace quantity_purge_lower_lim_actual = 0 if (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - implied_price1 ))))/(2*MC_beta_maxguests_sq) <=0 & purged_dummy == 1

capture drop quantity_purge_upper_lim_actual
gen quantity_purge_upper_lim_actual = .
replace quantity_purge_upper_lim_actual = implied_quantity1 if implied_quantity1 > 0 & implied_quantity1 > quantity_purge_lower_lim_actual
*replace quantity_purge_upper_lim_actual = (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - implied_price1 ))))/(2*MC_beta_maxguests_sq) if purged_dummy == 1
*replace quantity_purge_upper_lim_actual = implied_quantity1 if implied_quantity1 < (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - implied_price1 ))))/(2*MC_beta_maxguests_sq) & purged_dummy == 1
 
capture drop PS_purged_actual
gen PS_purged_actual = ((implied_price1 *quantity_purge_upper_lim_actual)-(MC_beta_maxguests*(quantity_purge_upper_lim_actual^2)/2)-(MC_beta_maxguests_sq*(quantity_purge_upper_lim_actual^3)/3)-(OOS_MC_xbd1_noQ*quantity_purge_upper_lim_actual)) - /// 
	((implied_price1 *quantity_purge_lower_lim_actual)-(MC_beta_maxguests*(quantity_purge_lower_lim_actual^2)/2)-(MC_beta_maxguests_sq*(quantity_purge_lower_lim_actual^3)/3)-(OOS_MC_xbd1_noQ*quantity_purge_lower_lim_actual)) /// 
	if purged_dummy == 1
label var PS_purged_actual "Producer Surplus Existing Rentals (actual)"
*-------------------------------------------------------------------------------

* FINALIZING CONSUMER SURPLUS AND PRODUCER SURPLUS
replace CS_exist_actual = 0 if proddum == 1 & CS_exist_actual==.
replace CS_exist_cf = 0 if proddum == 1 & CS_exist_cf==.
replace CS_purged_actual = 0 if  purged_dummy == 1 & CS_purged_actual==.
replace PS_exist_actual = 0 if proddum == 1 & PS_exist_actual==.
replace PS_exist_cf = 0 if proddum == 1 & PS_exist_cf==.
replace PS_purged_actual = 0 if purged_dummy == 1 & PS_purged_actual==.

*-------------------------------------------------------------------------------
capture drop CS_change_exist
gen CS_change_exist = CS_exist_actual - CS_exist_cf if proddum == 1
label var CS_change_exist "Change in consumer surplus from price change"
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
capture drop PS_change_exist
gen PS_change_exist = PS_exist_actual - PS_exist_cf if proddum == 1
label var PS_change_exist "Change in producer surplus from price change"
*-------------------------------------------------------------------------------
* WILLINGNESS TO PAY
capture drop WTP
gen WTP = exp((qdemand - OOS_D_xbd_noP )/(D_beta)) if proddum == 1
label var WTP "Willingness to pay ($)"
timer off 2
*-------------------------------------------------------------------------------
cd "Y:\agrajg\Research\Paper1_demand_stata"
timer on 3
save "13_01_Computed_WTP_Welfare.dta", replace
timer off 3
timer list
 



// * Producers surplus loss of sales 
// capture drop implied_quantity1
// gen implied_quantity1 = D_beta*ln(implied_price1) + OOS_D_xbd_noP if purged_dummy ==1
// *-------------------------------------------------------------------------------
// capture drop PS_purged_cf
// gen PS_purged_cf = ((implied_price1*implied_quantity1)-(MC_beta_maxguests*(implied_quantity1^2)/2)-(MC_beta_maxguests_sq*(implied_quantity1^3)/3)-(OOS_MC_xbd1_noQ*implied_quantity1)) if purged_dummy ==1
// label var PS_purged_cf "Producer Surplus Existing Rentals (counterfactual)"
// *-------------------------------------------------------------------------------
