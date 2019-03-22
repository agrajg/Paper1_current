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
// keep if date >= td(15dec2016) & date < td(15jan2017)
// save "12_01_Welfare_Calculations_Data_demo.dta", replace 
*===============================================================================

drop N_inmile_*
recast double N_cap_*
recast double adj_price_per_person
*-------------------------------------------------------------------------------
timer on 2
* Calculation of actual surplus
*-------------------------------------------------------------------------------


* First we calculate the price at which the quantity demanded =0
* this is calculated for all the blocked rentals too
capture drop ppp_zero_demand
gen double ppp_zero_demand = exp(-(OOS_D_xbd_noP/D_beta)) 
label var ppp_zero_demand "Price when Demand = 0"
*-------------------------------------------------------------------------------
* Now calculate the area under the demand curve for consumer surplus. 
* CS at existing prices
capture drop CS_exist_actual
gen double CS_exist_actual = .
// replace CS_exist_actual = (D_beta*((ppp_zero_demand*ln(ppp_zero_demand)) - ppp_zero_demand) + ((OOS_D_xbd_noP)*ppp_zero_demand)) - ///
// 	(D_beta*((adj_price_per_person*ln(adj_price_per_person)) - adj_price_per_person) + ((OOS_D_xbd_noP)*adj_price_per_person)) /// 
// 	if proddum == 1 & ppp_zero_demand > adj_price_per_person
replace CS_exist_actual = (ppp_zero_demand*(OOS_D_xbd_noP + D_beta*ln(ppp_zero_demand) - D_beta)) - ///
							(adj_price_per_person*(OOS_D_xbd_noP + D_beta * ln(adj_price_per_person) - D_beta)) /// 
							if proddum == 1 & ppp_zero_demand >= adj_price_per_person & D_xbd >=0
replace CS_exist_actual = 0 if proddum == 1 & ppp_zero_demand < adj_price_per_person | D_xbd < 0
replace CS_exist_actual = 0 if proddum == 1 & CS_exist_actual <0
replace CS_exist_actual = 0 if proddum == 1 & CS_exist_actual==.
label var CS_exist_actual "Consumer Surplus Existing Rentals (actual)"	

*-------------------------------------------------------------------------------
capture drop CS_exist_actual_new
gen double CS_exist_actual_new = .

replace CS_exist_actual_new = ((D_beta*exp((D_xbd-OOS_D_xbd_noP-0)/D_beta)) - (D_beta*exp((0-OOS_D_xbd_noP-0)/D_beta))) - adj_price_per_person *D_xbd + adj_price_per_person *D_xbd ///
							if proddum == 1 & D_xbd >=0
replace CS_exist_actual_new = 0 if proddum == 1 & D_xbd < 0
replace CS_exist_actual_new = 0 if proddum == 1 & CS_exist_actual_new <0
replace CS_exist_actual_new = 0 if proddum == 1 & CS_exist_actual_new==.
label var CS_exist_actual_new "Consumer Surplus Existing Rentals (actual)"	
*-------------------------------------------------------------------------------
* Producer's surplus for existing properties
capture drop PS_exist_actual
gen double PS_exist_actual = (adj_price_per_person - mc)*D_xbd if proddum == 1 & adj_price_per_person >= mc & D_xbd >=0
replace PS_exist_actual = 0 if proddum == 1 & adj_price_per_person < mc & & D_xbd >=0
replace PS_exist_actual = 0 if proddum == 1 & PS_exist_actual==.

label var PS_exist_actual "Producer Surplus Existing Rentals (actual)"
*-------------------------------------------------------------------------------
*===============================================================================
* Counter
*-------------------------------------------------------------------------------
* Counterfactual PRICE
local beta_p_0_500 = 0.0032
local beta_p_500_1000 = 0.0015
local beta_p_1000_2000 = 0
local beta_p_2000_5000 = 0
local beta_p_5000_10000 = 0

* Calculating changes in prices depending on how many rentals had left the market.
* percent change in prices 
capture drop ppp_change_percent 
gen double ppp_change_percent = `beta_p_0_500'*N_cap_inmile_0_500 + ///
	`beta_p_500_1000'*N_cap_inmile_500_1000 + ///
	`beta_p_1000_2000'*N_cap_inmile_1000_2000 + ///
	`beta_p_2000_5000'*N_cap_inmile_2000_5000 + /// 
	`beta_p_5000_10000'*N_cap_inmile_5000_10000 ///
	if proddum == 1
label var ppp_change_percent "Price Change (%)"

* Absolute change in prices. This can be done only for rentals that exist in market 
* and have prices  
capture drop ppp_change_abs 
gen double ppp_change_abs = (ppp_change_percent/100) *  adj_price_per_person if proddum == 1
label var ppp_change_abs "Price Change ($)"

* Counterfactual prices only for those that exist in the market.
capture drop adj_ppp_cf
gen double adj_ppp_cf =  adj_price_per_person - ppp_change_abs if proddum == 1
label var adj_ppp_cf "Counterfactual Price Per Person (adjusted)" 
*-------------------------------------------------------------------------------
* Counterfactual QUANTITY
local beta_q_0_500 		= -0.000078
local beta_q_500_1000 	= 0
local beta_q_1000_2000 	= 0
local beta_q_2000_5000 	= 0
local beta_q_5000_10000 = 0

capture drop quantity_change_abs
gen double quantity_change_abs = `beta_q_0_500'*N_cap_inmile_0_500 + ///
	`beta_q_500_1000'*N_cap_inmile_500_1000 + ///
	`beta_q_1000_2000'*N_cap_inmile_1000_2000 + ///
	`beta_q_2000_5000'*N_cap_inmile_2000_5000 + /// 
	`beta_q_5000_10000'*N_cap_inmile_5000_10000 ///
	if proddum == 1
label var quantity_change_abs "Quantity Change (Guest Count)"

* Counterfactual quantity
capture drop quantity_cf
gen double quantity_cf =  D_xbd - quantity_change_abs if proddum == 1
label var quantity_cf "Counterfactual Quantity (Guest Count)" 
*-------------------------------------------------------------------------------
* Shift in demand for every existing property as purge happened using counter factual price and quantity
capture drop demand_shift
gen double demand_shift = quantity_cf - ((D_beta*ln(adj_ppp_cf))+OOS_D_xbd_noP) if proddum == 1
// replace demand_shift = 0 if ppp_change_percent == 0 & quantity_change_abs ==0 & proddum == 1

label var demand_shift "Demand shift at CF price quantity"
*-------------------------------------------------------------------------------
* Now we have CF demand curve

* COUNTERFACTUAL CONSUMER SURPLUS
* Price at which counterfactual demand = 0 
capture drop ppp_zero_demand_cf
gen double ppp_zero_demand_cf = exp(-((OOS_D_xbd_noP+demand_shift)/D_beta)) if proddum == 1
label var ppp_zero_demand_cf "Price when CF Demand = 0"
* CS at counterfactual prices
capture drop CS_exist_cf
gen double CS_exist_cf = .
// replace CS_exist_cf = (D_beta*((ppp_zero_demand_cf*ln(ppp_zero_demand_cf)) - ppp_zero_demand_cf) + ((OOS_D_xbd_noP+demand_shift)*ppp_zero_demand_cf)) - ///
// 						(D_beta*((adj_ppp_cf*ln(adj_ppp_cf)) - adj_ppp_cf) + ((OOS_D_xbd_noP+demand_shift)*adj_ppp_cf)) /// 
// 						if proddum == 1 & ppp_zero_demand_cf > adj_ppp_cf 

replace CS_exist_cf = 	ppp_zero_demand_cf*(OOS_D_xbd_noP+demand_shift + D_beta*ln(ppp_zero_demand_cf) - D_beta) - ///
							adj_ppp_cf*(OOS_D_xbd_noP+demand_shift+ D_beta*ln(adj_ppp_cf) - D_beta) ///
							if proddum == 1 & ppp_zero_demand_cf >= adj_ppp_cf  & quantity_cf >=0
replace CS_exist_cf = 0 if proddum == 1 & ppp_zero_demand_cf < adj_ppp_cf | quantity_cf <0
replace CS_exist_cf = 0 if proddum == 1 & CS_exist_cf <0
replace CS_exist_cf = 0 if proddum == 1 & CS_exist_cf ==.

label var CS_exist_cf "Consumer Surplus Existing Rentals (Counterfactual)"	
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
capture drop CS_exist_cf_new
gen double CS_exist_cf_new = .

replace CS_exist_cf_new = ((D_beta*exp((quantity_cf-OOS_D_xbd_noP-demand_shift)/D_beta)) - (D_beta*exp((0-OOS_D_xbd_noP-demand_shift)/D_beta))) - adj_ppp_cf *quantity_cf + adj_ppp_cf *quantity_cf ///
							if proddum == 1 & quantity_cf >=0
replace CS_exist_cf_new = 0 if proddum == 1 & quantity_cf < 0
replace CS_exist_cf_new = 0 if proddum == 1 & CS_exist_cf_new <0
replace CS_exist_cf_new = 0 if proddum == 1 & CS_exist_cf_new==.
label var CS_exist_cf_new "Consumer Surplus Existing Rentals (actual)"	
*-------------------------------------------------------------------------------


// sum CS_exist_cf, det
*-------------------------------------------------------------------------------
* COUNTERFACTUAL PRODUCER SURPLUS
// capture drop quantity_lower_lim_cf
// gen quantity_lower_lim_cf = .
// replace quantity_lower_lim_cf = (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_ppp_cf))))/(2*MC_beta_maxguests_sq) if proddum == 1
// replace quantity_lower_lim_cf = 0 if (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_ppp_cf))))/(2*MC_beta_maxguests_sq) <=0 & proddum == 1
//
// capture drop quantity_upper_lim_cf
// gen quantity_upper_lim_cf = .
// replace quantity_upper_lim_cf = quantity_cf if quantity_cf > 0 & quantity_cf > quantity_lower_lim_cf
*replace quantity_upper_lim_cf = (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_ppp_cf))))/(2*MC_beta_maxguests_sq) if proddum == 1
*replace quantity_upper_lim_cf = quantity_cf if quantity_cf < (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - adj_ppp_cf))))/(2*MC_beta_maxguests_sq) & proddum == 1

capture drop PS_exist_cf
gen double PS_exist_cf = (adj_ppp_cf-mc)* ((D_beta*ln(adj_ppp_cf))+ OOS_D_xbd_noP+demand_shift) if proddum == 1 & adj_ppp_cf > mc & ((D_beta*ln(adj_ppp_cf))+ OOS_D_xbd_noP+demand_shift)>0
replace PS_exist_cf = 0 if proddum == 1 & PS_exist_cf <0
replace PS_exist_cf = 0 if proddum == 1 & PS_exist_cf == .

label var PS_exist_cf "Producer Surplus Existing Rentals (counterfactual)" 
 
*-------------------------------------------------------------------------------

* Now we turn to the welfare loss of consumers from not being able to choose from the purged rentals.
* For this we need the demand curve of the purged rentals had they not been in the market. 
* to get that, I use two pieces of information.
* First, we have from demand parameter estimates and cost side estimates.
* Assuming that the effect of presence of one rental in the market has neglegible impact on residual demand of all the other rentals, 
* we can use these estimates to approximate the demand curve of one purged rental in the scenario when it was not 
* purged and all other purged rentals were actually purged.
* Since we know the marginals costs parametes, I can backout the implied equilibrium price and quantity using the first order condition. 

* I repeat this process for all the purged listings keeping one purged listing in the market everytime while ignoring all other purged rental's presence in the market.
* this gives us price quantity and ddemand. From here we move to the counterfactual state when no listing was purged by first computing counterfactual price and 
* quantity using price and quantity change estimates. Since the cf price and quantity must lie 
* on the demand curve we can obtain the equation of the demand curve again by assuming that slope parameter stays same as before. 



*-------------------------------------------------------------------------------
* CONSUMER SURPLUS DUE TPO LOSS OF VARIETY
* Counsumer surplus due to loss of variety
* Starting with rentals that were purged and their last date in the market
* last_date
preserve
use "Y:\agrajg\Research\Paper1_demand_stata\01_04_purged_property_last_date.dta", clear
rename purge_date last_date
rename purge_propertyid propertyid 
keep propertyid last_date
save "Y:\agrajg\Research\Paper1_demand_stata\13_01_purge_property_last_date.dta", replace
restore
*-------------------------------------------------------------------------------

merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\13_01_purge_property_last_date.dta"
* Creating a dummy variable to represent a purged rental
capture drop purged_rental_dummy 
gen purged_rental_dummy = (_merge == 3)
label var purged_rental_dummy "Dummy == 1 if purged rental"
* Creating a dummy variable to represent purged properties post purge
capture drop purged_dummy
gen purged_dummy = (date > last_date)
replace purged_dummy = 0 if last_date ==.
label var purged_dummy "Dummy == 1 if purged rental has been purged"
drop if _merge ==2
drop _merge
*-------------------------------------------------------------------------------
* CS at implied prices of rentals that were purged.
* the implied price is the price which a rental would have charged if it was not purged and all the other rentals were purged.
* I compute the impled quantity assuming that the shape of the residual demand curve would have been the same.
capture drop implied_quantity1
gen double implied_quantity1 = D_beta*ln(implied_price1) + OOS_D_xbd_noP if purged_dummy == 1

* Computing the price at counterfactual level
capture drop implied_price1_cf
gen double implied_price1_cf = implied_price1-((`beta_p_0_500'*N_cap_inmile_0_500 + ///
	`beta_p_500_1000'*N_cap_inmile_500_1000 + ///
	`beta_p_1000_2000'*N_cap_inmile_1000_2000 + ///
	`beta_p_2000_5000'*N_cap_inmile_2000_5000 + /// 
	`beta_p_5000_10000'*N_cap_inmile_5000_10000)*implied_price1/100) /// 
	if purged_dummy == 1
	
capture drop implied_quantity1_cf
gen double implied_quantity1_cf = implied_quantity1 - (`beta_q_0_500'*N_cap_inmile_0_500 + ///
	`beta_q_500_1000'*N_cap_inmile_500_1000 + ///
	`beta_q_1000_2000'*N_cap_inmile_1000_2000 + ///
	`beta_q_2000_5000'*N_cap_inmile_2000_5000 + /// 
	`beta_q_5000_10000'*N_cap_inmile_5000_10000) /// 
	if purged_dummy == 1

* Computing the demand shift 
capture drop implied_demand_shift1
gen double implied_demand_shift1 = implied_quantity1_cf - ((D_beta*ln(implied_price1_cf))+OOS_D_xbd_noP) if purged_dummy == 1
replace implied_demand_shift1 = 0 if implied_quantity1_cf == implied_quantity1 & implied_price1_cf ==implied_quantity1 & purged_dummy == 1
label var implied_demand_shift1 "Purged rental demand shift at CF price quantity"

* Consumer Surplus generated 
* Using the demand we compute, price at which the demnand = 0
* COUNTERFACTUAL CONSUMER SURPLUS FROM PURGED RENTALS
* Price at which counterfactual demand = 0 
capture drop ppp_zero_demand_cf1
gen double ppp_zero_demand_cf1 = exp(-((OOS_D_xbd_noP+implied_demand_shift1)/D_beta)) if purged_dummy == 1
label var ppp_zero_demand_cf1 "Price when CF Demand = 0"
* CS at counterfactual prices
capture drop CS_purged_cf1
gen double CS_purged_cf1 = .
replace CS_purged_cf1 = (D_beta*((ppp_zero_demand_cf1*ln(ppp_zero_demand_cf1)) - ppp_zero_demand_cf1) + ((OOS_D_xbd_noP+implied_demand_shift1)*ppp_zero_demand_cf1)) - ///
	(D_beta*((implied_price1_cf*ln(implied_price1_cf)) - implied_price1_cf) + ((OOS_D_xbd_noP+implied_demand_shift1)*implied_price1_cf)) /// 
	if purged_dummy == 1 & ppp_zero_demand_cf1 > implied_price1_cf 
replace CS_purged_cf1 = 0 if purged_dummy == 1 & ppp_zero_demand_cf1 <= implied_price1_cf
replace CS_purged_cf1 = 0 if purged_dummy == 1 & CS_purged_cf1 <0
label var CS_purged_cf1 "Consumer Surplus Purged Rentals (Counterfactual)"	
*-------------------------------------------------------------------------------
* PRODUCER'S LOSS 
* Producer Surplus from lost sales
// gen double PS_purged_cf1 = (implied_price1_cf - MC_xbd1)*implied_quantity1_cf if purged_dummy == 1

capture drop PS_purged_cf1
gen double PS_purged_cf1 = (implied_price1_cf-OOS_MC_xbd1)*((D_beta*ln(implied_price1_cf))+ OOS_D_xbd_noP+implied_demand_shift1) /// 
	if purged_dummy == 1 & implied_price1_cf > OOS_MC_xbd1 & ((D_beta*ln(implied_price1_cf))+ OOS_D_xbd_noP+implied_demand_shift1)>0
replace PS_purged_cf1 = 0 if purged_dummy == 1 & PS_purged_cf1 == .
label var PS_purged_cf1 "Producer Surplus Purged Rentals (Counterfactual)"

*-------------------------------------------------------------------------------

*===============================================================================
*-------------------------------------------------------------------------------
* CS at implied prices of rentals that were purged.
* the implied price is the price which a rental would have charged if it was not purged and all the other rentals were purged.
* I compute the impled quantity assuming that the shape of the residual demand curve would have been the same.
capture drop implied_quantity2
gen double implied_quantity2 = D_beta*ln(implied_price2) + OOS_D_xbd_noP if purged_dummy == 1

* Computing the price at counterfactual level
capture drop implied_price2_cf
gen double implied_price2_cf = implied_price2-((`beta_p_0_500'*N_cap_inmile_0_500 + ///
	`beta_p_500_1000'*N_cap_inmile_500_1000 + ///
	`beta_p_1000_2000'*N_cap_inmile_1000_2000 + ///
	`beta_p_2000_5000'*N_cap_inmile_2000_5000 + /// 
	`beta_p_5000_10000'*N_cap_inmile_5000_10000)*implied_price1/100) /// 
	if purged_dummy == 1
	
capture drop implied_quantity2_cf
gen double implied_quantity2_cf = implied_quantity2 - (`beta_q_0_500'*N_cap_inmile_0_500 + ///
	`beta_q_500_1000'*N_cap_inmile_500_1000 + ///
	`beta_q_1000_2000'*N_cap_inmile_1000_2000 + ///
	`beta_q_2000_5000'*N_cap_inmile_2000_5000 + /// 
	`beta_q_5000_10000'*N_cap_inmile_5000_10000) /// 
	if purged_dummy == 1

* Computing the demand shift 
capture drop implied_demand_shift2
gen double implied_demand_shift2 = implied_quantity2_cf - ((D_beta*ln(implied_price2_cf))+OOS_D_xbd_noP) if purged_dummy == 1
replace implied_demand_shift2 = 0 if implied_quantity2_cf == implied_quantity2 & implied_price2_cf ==implied_quantity2 & purged_dummy == 1
label var implied_demand_shift2 "Purged rental demand shift at CF price quantity"

* Consumer Surplus generated 
* Using the demand we compute, price at which the demnand = 0
* COUNTERFACTUAL CONSUMER SURPLUS FROM PURGED RENTALS
* Price at which counterfactual demand = 0 
capture drop ppp_zero_demand_cf2
gen double ppp_zero_demand_cf2 = exp(-((OOS_D_xbd_noP+implied_demand_shift2)/D_beta)) if purged_dummy == 1
label var ppp_zero_demand_cf2 "Price when CF Demand = 0"
* CS at counterfactual prices
capture drop CS_purged_cf2
gen double CS_purged_cf2 = .
replace CS_purged_cf2 = (D_beta*((ppp_zero_demand_cf2*ln(ppp_zero_demand_cf2)) - ppp_zero_demand_cf2) + ((OOS_D_xbd_noP+implied_demand_shift2)*ppp_zero_demand_cf2)) - ///
	(D_beta*((implied_price2_cf*ln(implied_price2_cf)) - implied_price2_cf) + ((OOS_D_xbd_noP+implied_demand_shift2)*implied_price2_cf)) /// 
	if purged_dummy == 1 & ppp_zero_demand_cf2 > implied_price2_cf 
replace CS_purged_cf2 = 0 if purged_dummy == 1 & ppp_zero_demand_cf2 <= implied_price2_cf
replace CS_purged_cf2 = 0 if purged_dummy == 1 & CS_purged_cf2 <0
label var CS_purged_cf2 "Consumer Surplus Purged Rentals (Counterfactual)"	
*-------------------------------------------------------------------------------
* PRODUCER'S LOSS 
* Producer Surplus from lost sales

capture drop PS_purged_cf2
// gen double PS_purged_cf2 = (implied_price2_cf - MC_xbd2)*implied_quantity2_cf if purged_dummy == 1
gen double PS_purged_cf2 = (implied_price2_cf-OOS_MC_xbd2)*((D_beta*ln(implied_price2_cf))+ OOS_D_xbd_noP+implied_demand_shift2) /// 
	if purged_dummy == 1 & implied_price2_cf > OOS_MC_xbd2 & ((D_beta*ln(implied_price2_cf))+ OOS_D_xbd_noP+implied_demand_shift2)>0
replace PS_purged_cf2 = 0 if purged_dummy == 1 & PS_purged_cf2 == .
label var PS_purged_cf2 "Producer Surplus Purged Rentals (Counterfactual)"

*-------------------------------------------------------------------------------
*===============================================================================
// sum CS_* PS_*
// * WILLINGNESS TO PAY
// capture drop WTP
// gen double WTP = exp((D_xbd - OOS_D_xbd_noP )/(D_beta)) if proddum == 1
// label var WTP "Willingness to pay ($)"
// timer off 2
*-------------------------------------------------------------------------------
sum CS_* PS_*


cd "Y:\agrajg\Research\Paper1_demand_stata"
timer on 3
save "13_03_Computed_WTP_Welfare.dta", replace
timer off 3
timer list
*===============================================================================
