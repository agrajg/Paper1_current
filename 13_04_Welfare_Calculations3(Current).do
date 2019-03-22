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

timer on 2
* ACTUAL CONSUMER SURPLUS
* Now calculate the area under the demand curve for consumer surplus. 
capture drop CS_exist_actual
gen double CS_exist_actual = .
replace CS_exist_actual = D_beta*(exp((D_xbd-OOS_D_xbd_noP)/D_beta)-exp(-OOS_D_xbd_noP/D_beta)) - adj_price_per_person*D_xbd ///
	if proddum==1 & D_xbd >= 0 & adj_price_per_person>=0

sum CS_exist_actual if CS_exist_actual <0
replace CS_exist_actual = 0 if proddum==1 & (D_xbd < 0 | adj_price_per_person<0)
replace CS_exist_actual = 0 if proddum==1 & CS_exist_actual==.
replace CS_exist_actual = 0 if proddum==1 & CS_exist_actual<0
label var CS_exist_actual "Consumer Surplus Existing Rentals (actual)"	
sum CS_exist_actual
*-------------------------------------------------------------------------------

* ACTUAL PRODUCER SURPLUS
* Producer's surplus for existing properties
capture drop PS_exist_actual
gen double PS_exist_actual = (adj_price_per_person - mc)*D_xbd if proddum == 1 & adj_price_per_person >= mc & D_xbd>=0
replace PS_exist_actual = 0 if proddum == 1 & (adj_price_per_person < mc | D_xbd < 0)
replace PS_exist_actual = 0 if proddum == 1 & PS_exist_actual==.
label var PS_exist_actual "Producer Surplus Existing Rentals (actual)"
sum PS_exist_actual
*-------------------------------------------------------------------------------
*===============================================================================

* COUNTERFACTUAL
*-------------------------------------------------------------------------------

* COUNTERFACTUAL PRICE
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
sum adj_price_per_person adj_ppp_cf if proddum == 1
count if adj_price_per_person < adj_ppp_cf & proddum == 1
* this should be zero
*-------------------------------------------------------------------------------

* COUNTERFACTUAL QUANTITY
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
sum D_xbd quantity_cf if proddum == 1
sum D_xbd quantity_cf if proddum == 1 & D_xbd <0
count if D_xbd > quantity_cf & proddum == 1
* this should be zero
*-------------------------------------------------------------------------------

* Shift in demand for every existing property as purge happened using counter factual price and quantity
capture drop demand_shift
gen double demand_shift = adj_ppp_cf - exp((quantity_cf - OOS_D_xbd_noP)/D_beta) if proddum == 1
label var demand_shift "Vertical inverse demand shift"
sum demand_shift if proddum == 1
* Now we have CF demand curve
*-------------------------------------------------------------------------------

* COUNTERFACTUAL CONSUMER SURPLUS

* CS at counterfactual prices
capture drop CS_exist_cf
gen double CS_exist_cf = .

replace CS_exist_cf = demand_shift*quantity_cf + D_beta*exp((quantity_cf - OOS_D_xbd_noP)/D_beta) - ///
	D_beta*exp((0 - OOS_D_xbd_noP)/D_beta) ///
	- adj_ppp_cf*quantity_cf ///
	if proddum==1 & quantity_cf >= 0 & adj_ppp_cf>=0

sum CS_exist_cf if CS_exist_cf <0
replace CS_exist_cf = 0 if proddum==1 & (quantity_cf < 0 | adj_ppp_cf <0)
replace CS_exist_cf = 0 if proddum==1 & CS_exist_cf==.
replace CS_exist_cf = 0 if proddum==1 & CS_exist_cf<0
label var CS_exist_cf "Consumer Surplus Existing Rentals (Counterfactual)"	
sum CS_exist_cf

*-------------------------------------------------------------------------------

* COUNTERFACTUAL PRODUCER SURPLUS
capture drop PS_exist_cf
gen double PS_exist_cf = (adj_ppp_cf-mc)* quantity_cf if proddum == 1 & adj_ppp_cf >= mc & quantity_cf >=0
replace PS_exist_cf = 0 if proddum == 1 & (adj_ppp_cf < mc | quantity_cf < 0)
replace PS_exist_cf = 0 if proddum == 1 & PS_exist_cf == .
label var PS_exist_cf "Producer Surplus Existing Rentals (counterfactual)" 
sum PS_exist_cf
*-------------------------------------------------------------------------------

* PURGED RENTALS
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
* CONSUMER SURPLUS DUE TO LOSS OF VARIETY
* Counsumer surplus due to loss of variety
* Starting with rentals that were purged and their last date in the market
* last_date
preserve
use "Y:\agrajg\Research\Paper1_demand_stata\01_04_purged_property_last_date.dta", clear
rename purge_date last_date
rename purge_propertyid propertyid 
keep propertyid last_date
count
save "Y:\agrajg\Research\Paper1_demand_stata\13_04_purge_property_last_date.dta", replace
restore
*-------------------------------------------------------------------------------

merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\13_04_purge_property_last_date.dta"
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
gen double implied_price1_cf = implied_price1- ((`beta_p_0_500'*N_cap_inmile_0_500 + ///
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
	
* Computing the vertical inverse demand shift 
capture drop implied_demand_shift1
gen double implied_demand_shift1 = implied_price1_cf - exp((implied_quantity1_cf - OOS_D_xbd_noP)/D_beta)
label var implied_demand_shift1 "Purged rental demand shift at CF price quantity"

* COUNTERFACTUAL CONSUMER SURPLUS FROM PURGED RENTALS
capture drop CS_purged_cf1
gen double CS_purged_cf1 = .
replace CS_purged_cf1 = (implied_demand_shift1*implied_quantity1_cf) + ///
	(D_beta*exp((implied_quantity1_cf - OOS_D_xbd_noP)/D_beta)) - /// 
	(D_beta*exp((0 - OOS_D_xbd_noP)/D_beta)) - ///
	(implied_price1_cf*implied_quantity1_cf) ///
	if purged_dummy==1 & implied_quantity1_cf >= 0 & implied_price1_cf >=0
replace CS_purged_cf1 = 0 if purged_dummy==1 & (implied_quantity1_cf < 0 | implied_price1_cf < 0)
replace CS_purged_cf1 = 0 if purged_dummy==1 & CS_purged_cf1==.
replace CS_purged_cf1 = 0 if purged_dummy==1 & CS_purged_cf1<0
label var CS_purged_cf1 "Consumer Surplus Purged Rentals (Counterfactual)"	

*-------------------------------------------------------------------------------

* COUNTERFACTUAL PRODUCER SURPLUS FROM PURGED RENTALS
capture drop implied_MC1
gen double implied_MC1 = OOS_MC_xbd1 if OOS_MC_xbd1 >=0
replace implied_MC1 = 0 if OOS_MC_xbd1 < 0

capture drop PS_purged_cf1
gen double PS_purged_cf1 = (implied_price1_cf-implied_MC1)*implied_quantity1_cf ///
	if purged_dummy==1 & implied_quantity1_cf >= 0 & implied_price1_cf >= implied_MC1

replace PS_purged_cf1 = 0 if purged_dummy == 1 & (implied_price1_cf < implied_MC1 | implied_quantity1_cf < 0)
replace PS_purged_cf1 = 0 if purged_dummy == 1 & PS_purged_cf1 == .
label var PS_purged_cf1 "Producer Surplus Purged Rentals (Counterfactual)"
sum PS_purged_cf1
*-------------------------------------------------------------------------------

* CS at implied prices of rentals that were purged.
* the implied price is the price which a rental would have charged if it was not purged and all the other rentals were purged.
* I compute the impled quantity assuming that the shape of the residual demand curve would have been the same.
capture drop implied_quantity2
gen double implied_quantity2 = D_beta*ln(implied_price2) + OOS_D_xbd_noP if purged_dummy == 1

* Computing the price at counterfactual level
capture drop implied_price2_cf
gen double implied_price2_cf = implied_price2- ((`beta_p_0_500'*N_cap_inmile_0_500 + ///
	`beta_p_500_1000'*N_cap_inmile_500_1000 + ///
	`beta_p_1000_2000'*N_cap_inmile_1000_2000 + ///
	`beta_p_2000_5000'*N_cap_inmile_2000_5000 + /// 
	`beta_p_5000_10000'*N_cap_inmile_5000_10000)*implied_price2/100) /// 
	if purged_dummy == 1
	
capture drop implied_quantity2_cf
gen double implied_quantity2_cf = implied_quantity2 - (`beta_q_0_500'*N_cap_inmile_0_500 + ///
	`beta_q_500_1000'*N_cap_inmile_500_1000 + ///
	`beta_q_1000_2000'*N_cap_inmile_1000_2000 + ///
	`beta_q_2000_5000'*N_cap_inmile_2000_5000 + /// 
	`beta_q_5000_10000'*N_cap_inmile_5000_10000) /// 
	if purged_dummy == 1
	
* Computing the vertical inverse demand shift 
capture drop implied_demand_shift2
gen double implied_demand_shift2 = implied_price2_cf - exp((implied_quantity2_cf - OOS_D_xbd_noP)/D_beta)
label var implied_demand_shift2 "Purged rental demand shift at CF price quantity"

* COUNTERFACTUAL CONSUMER SURPLUS FROM PURGED RENTALS
capture drop CS_purged_cf2
gen double CS_purged_cf2 = .
replace CS_purged_cf2 = (implied_demand_shift2*implied_quantity2_cf) + ///
	(D_beta*exp((implied_quantity2_cf - OOS_D_xbd_noP)/D_beta)) - /// 
	(D_beta*exp((0 - OOS_D_xbd_noP)/D_beta)) - ///
	(implied_price2_cf*implied_quantity2_cf) ///
	if purged_dummy==1 & implied_quantity2_cf >= 0 & implied_price2_cf >=0
replace CS_purged_cf2 = 0 if purged_dummy==1 & (implied_quantity2_cf < 0 | implied_price2_cf < 0)
replace CS_purged_cf2 = 0 if purged_dummy==1 & CS_purged_cf2==.
replace CS_purged_cf2 = 0 if purged_dummy==1 & CS_purged_cf2<0
label var CS_purged_cf2 "Consumer Surplus Purged Rentals (Counterfactual)"	

*-------------------------------------------------------------------------------

* COUNTERFACTUAL PRODUCER SURPLUS FROM PURGED RENTALS
capture drop implied_MC2
gen double implied_MC2 = OOS_MC_xbd2 if OOS_MC_xbd2 >=0
replace implied_MC2 = 0 if OOS_MC_xbd2 < 0

capture drop PS_purged_cf2
gen double PS_purged_cf2 = (implied_price2_cf-implied_MC2)*implied_quantity2_cf ///
	if purged_dummy==1 & implied_quantity2_cf >= 0 & implied_price2_cf >= implied_MC2

replace PS_purged_cf2 = 0 if purged_dummy == 1 & (implied_price2_cf < implied_MC2 | implied_quantity2_cf < 0)
replace PS_purged_cf2 = 0 if purged_dummy == 1 & PS_purged_cf2 == .
label var PS_purged_cf2 "Producer Surplus Purged Rentals (Counterfactual)"
sum PS_purged_cf2
*===============================================================================
sum CS_* PS_*
*-------------------------------------------------------------------------------
replace CS_purged_cf1 = 0 if purged_dummy == 1 & PS_purged_cf1 == 0 
replace PS_purged_cf1 = 0 if purged_dummy == 1 & CS_purged_cf1 == 0 
replace CS_purged_cf2 = 0 if purged_dummy == 1 & PS_purged_cf2 == 0 
replace PS_purged_cf2 = 0 if purged_dummy == 1 & CS_purged_cf2 == 0 
sum CS_* PS_*
*===============================================================================



cd "Y:\agrajg\Research\Paper1_demand_stata"
timer on 3
save "13_04_Computed_WTP_Welfare.dta", replace
timer off 3
timer list
*===============================================================================
