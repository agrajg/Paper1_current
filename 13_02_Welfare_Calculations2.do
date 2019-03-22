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
* Calculation of actual surplus
*-------------------------------------------------------------------------------
* First we calculate the price at which the quantity demanded =0
* this is calculated for all the blocked rentals too
capture drop ppp_zero_demand
gen ppp_zero_demand = exp(-(OOS_D_xbd_noP/D_beta)) 
label var ppp_zero_demand "Price when Demand = 0"
*-------------------------------------------------------------------------------
* Now calculate the area under the demand curve for consumer surplus. 
* CS at existing prices
capture drop CS_exist_actual
gen CS_exist_actual = .
replace CS_exist_actual = (D_beta*((ppp_zero_demand*ln(ppp_zero_demand)) - ppp_zero_demand) + ((OOS_D_xbd_noP)*ppp_zero_demand)) - ///
	(D_beta*((adj_price_per_person*ln(adj_price_per_person)) - adj_price_per_person) + ((OOS_D_xbd_noP)*adj_price_per_person)) /// 
	if proddum == 1 & ppp_zero_demand > adj_price_per_person 
replace CS_exist_actual = 0 if proddum == 1 & ppp_zero_demand <= adj_price_per_person
label var CS_exist_actual "Consumer Surplus Existing Rentals (actual)"	
*-------------------------------------------------------------------------------
// preserve
// collapse (sum) sum_CS_exist_actual=CS_exist_actual (count) count_CS_exist_actual=CS_exist_actual (mean) mean_CS_exist_actual=CS_exist_actual
// restore
// preserve
// collapse (sum) sum_CS_exist_actual=CS_exist_actual (count) count_CS_exist_actual=CS_exist_actual (mean) mean_CS_exist_actual=CS_exist_actual , by (year week)
// twoway (line sum_CS_exist_actual week if year==2014, sort) (line sum_CS_exist_actual week if year == 2015, sort) (line sum_CS_exist_actual week if year ==2016, sort) (line sum_CS_exist_actual week if year == 2017, sort), xlabel(0(13)52) legend(on order(1 "2014" 2 "2015" 3 "2016" 4 "2017")) scheme(tufte) scale(0.7)
// restore
*-------------------------------------------------------------------------------
* Producer's surplus for existing properties
* obtaining the intercept term of the marginal cost curve. The marginal cost only differs in terms of the intercept.
capture drop OOS_MC_xbd1_noQ
gen OOS_MC_xbd1_noQ = OOS_MC_xbd1 - ((MC_beta_maxguests*maxguests)+(MC_beta_maxguests_sq*maxguests_sq))

* Computing producer surplus integrating the area between marginal cost curve and the prices
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
*-------------------------------------------------------------------------------
// preserve
// collapse (sum) sum_PS_exist_actual=PS_exist_actual (count) count_PS_exist_actual=PS_exist_actual (mean) mean_PS_exist_actual=PS_exist_actual
// restore
// preserve
// collapse (sum) sum_PS_exist_actual=PS_exist_actual (count) count_PS_exist_actual=PS_exist_actual (mean) mean_PS_exist_actual=PS_exist_actual , by (year week)
// twoway (line sum_PS_exist_actual week if year==2014, sort) (line sum_PS_exist_actual week if year == 2015, sort) (line sum_PS_exist_actual week if year ==2016, sort) (line sum_PS_exist_actual week if year == 2017, sort), xlabel(0(13)52) legend(on order(1 "2014" 2 "2015" 3 "2016" 4 "2017")) scheme(tufte) scale(0.7)
// restore
*-------------------------------------------------------------------------------





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

* Shift in demand for every existing property as purge happened using counter factual price and quantity
capture drop demand_shift
gen demand_shift = quantity_cf - ((D_beta*ln(adj_ppp_cf))+OOS_D_xbd_noP) if proddum == 1
replace demand_shift = 0 if ppp_change_percent == 0 & quantity_change_abs ==0 & proddum == 1
label var demand_shift "Demand shift at CF price quantity"
*-------------------------------------------------------------------------------
* Now we have CF demand curve

* COUNTERFACTUAL CONSUMER SURPLUS
* Price at which counterfactual demand = 0 
capture drop ppp_zero_demand_cf
gen ppp_zero_demand_cf = exp(-((OOS_D_xbd_noP+demand_shift)/D_beta)) if proddum == 1
label var ppp_zero_demand_cf "Price when CF Demand = 0"
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
sum CS_exist_cf, det
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
// preserve
// collapse (sum) sum_CS_exist_cf=CS_exist_cf (count) count_CS_exist_cf=CS_exist_cf (mean) mean_CS_exist_cf=CS_exist_cf
// restore
// preserve
// collapse (sum) sum_CS_exist_cf=CS_exist_cf (count) count_CS_exist_cf=CS_exist_cf (mean) mean_CS_exist_cf=CS_exist_cf , by (year week)
// twoway (line sum_CS_exist_cf week if year==2014, sort) (line sum_CS_exist_cf week if year == 2015, sort) (line sum_CS_exist_cf week if year ==2016, sort) (line sum_CS_exist_cf week if year == 2017, sort), xlabel(0(13)52) legend(on order(1 "2014" 2 "2015" 3 "2016" 4 "2017")) scheme(tufte) scale(0.7)
// restore
 *-------------------------------------------------------------------------------

* COUNTERFACTUAL PRODUCER SURPLUS
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
// preserve
// collapse (sum) sum_PS_exist_cf=PS_exist_cf (count) count_PS_exist_cf=PS_exist_cf (mean) mean_PS_exist_cf=PS_exist_cf
// restore
// preserve
// collapse (sum) sum_PS_exist_cf=PS_exist_cf (count) count_PS_exist_cf=PS_exist_cf (mean) mean_PS_exist_cf=PS_exist_cf , by (year week)
// twoway (line sum_PS_exist_cf week if year==2014, sort) (line sum_PS_exist_cf week if year == 2015, sort) (line sum_PS_exist_cf week if year ==2016, sort) (line sum_PS_exist_cf week if year == 2017, sort), xlabel(0(13)52) legend(on order(1 "2014" 2 "2015" 3 "2016" 4 "2017")) scheme(tufte) scale(0.7)
// restore
*-------------------------------------------------------------------------------
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
* CS at implied prices of rentals that were purged.
* the implied price is the price which a rental would have charged if it was not purged and all the other rentals were purged.
* I compute the impled quantity assuming that the shape of the residual demand curve would have been the same.
capture drop implied_quantity1
gen implied_quantity1 = D_beta*ln(implied_price1) + OOS_D_xbd_noP if purged_dummy == 1

* Computing the price at counterfactual level
capture drop implied_price1_cf
gen implied_price1_cf = implied_price1-((`beta_p_0_500'*N_inmile_0_500 + ///
	`beta_p_500_1000'*N_inmile_500_1000 + ///
	`beta_p_1000_2000'*N_inmile_1000_2000 + ///
	`beta_p_2000_5000'*N_inmile_2000_5000 + /// 
	`beta_p_5000_10000'*N_inmile_5000_10000)*implied_price1/100) /// 
	if purged_dummy == 1
	
capture drop implied_quantity1_cf
gen implied_quantity1_cf = implied_quantity1 - (`beta_q_0_500'*N_inmile_0_500 + ///
	`beta_q_500_1000'*N_inmile_500_1000 + ///
	`beta_q_1000_2000'*N_inmile_1000_2000 + ///
	`beta_q_2000_5000'*N_inmile_2000_5000 + /// 
	`beta_q_5000_10000'*N_inmile_5000_10000) /// 
	if purged_dummy == 1

* Computing the demand shift 
capture drop implied_demand_shift
gen implied_demand_shift = implied_quantity1_cf - ((D_beta*ln(implied_price1_cf))+OOS_D_xbd_noP) if purged_dummy == 1
replace implied_demand_shift = 0 if implied_quantity1_cf == implied_quantity1 & implied_price1_cf ==implied_quantity1 & purged_dummy == 1
label var demand_shift "Purged rental demand shift at CF price quantity"

* Consumer Surplus generated 
* Using the demand we compute, price at which the demnand = 0
* COUNTERFACTUAL CONSUMER SURPLUS FROM PURGED RENTALS
* Price at which counterfactual demand = 0 
capture drop ppp_zero_demand_cf
gen ppp_zero_demand_cf = exp(-((OOS_D_xbd_noP+implied_demand_shift)/D_beta)) if purged_dummy == 1
label var ppp_zero_demand_cf "Price when CF Demand = 0"
* CS at counterfactual prices
capture drop CS_purged_cf
gen CS_purged_cf = .
replace CS_purged_cf = (D_beta*((ppp_zero_demand_cf*ln(ppp_zero_demand_cf)) - ppp_zero_demand_cf) + ((OOS_D_xbd_noP+implied_demand_shift)*ppp_zero_demand_cf)) - ///
	(D_beta*((implied_price1_cf*ln(implied_price1_cf)) - implied_price1_cf) + ((OOS_D_xbd_noP+implied_demand_shift)*implied_price1_cf)) /// 
	if purged_dummy == 1 & ppp_zero_demand_cf > implied_price1_cf 
replace CS_purged_cf = 0 if purged_dummy == 1 & ppp_zero_demand_cf <= implied_price1_cf
replace CS_purged_cf = 0 if purged_dummy == 1 & CS_purged_cf <0
label var CS_purged_cf "Consumer Surplus Purged Rentals (Counterfactual)"	
*-------------------------------------------------------------------------------
* PRODUCER'S LOSS 
* Producer Surplus from lost sales
* range within which to compute the surplus
capture drop quantity_purge_lower_lim_actual
gen quantity_purge_lower_lim_actual = .
replace quantity_purge_lower_lim_actual = (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - implied_price1_cf ))))/(2*MC_beta_maxguests_sq) if purged_dummy == 1
replace quantity_purge_lower_lim_actual = 0 if (-MC_beta_maxguests - sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - implied_price1_cf ))))/(2*MC_beta_maxguests_sq) <=0 & purged_dummy == 1

capture drop quantity_purge_upper_lim_actual
gen quantity_purge_upper_lim_actual = .
replace quantity_purge_upper_lim_actual = implied_quantity1_cf if implied_quantity1_cf > 0 & implied_quantity1_cf > quantity_purge_lower_lim_actual
*replace quantity_purge_upper_lim_actual = (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - implied_price1_cf ))))/(2*MC_beta_maxguests_sq) if purged_dummy == 1
*replace quantity_purge_upper_lim_actual = implied_quantity1_cf if implied_quantity1_cf < (-MC_beta_maxguests + sqrt((MC_beta_maxguests^2)-(4*(MC_beta_maxguests_sq)*(OOS_MC_xbd1_noQ - implied_price1_cf ))))/(2*MC_beta_maxguests_sq) & purged_dummy == 1
 
capture drop PS_purged_cf
gen PS_purged_cf = ((implied_price1_cf *quantity_purge_upper_lim_actual)-(MC_beta_maxguests*(quantity_purge_upper_lim_actual^2)/2)-(MC_beta_maxguests_sq*(quantity_purge_upper_lim_actual^3)/3)-(OOS_MC_xbd1_noQ*quantity_purge_upper_lim_actual)) - /// 
	((implied_price1_cf *quantity_purge_lower_lim_actual)-(MC_beta_maxguests*(quantity_purge_lower_lim_actual^2)/2)-(MC_beta_maxguests_sq*(quantity_purge_lower_lim_actual^3)/3)-(OOS_MC_xbd1_noQ*quantity_purge_lower_lim_actual)) /// 
	if purged_dummy == 1
label var PS_purged_cf "Producer Surplus Purged Rentals (Counterfactual)"
*-------------------------------------------------------------------------------
// sum CS_* PS_*
* WILLINGNESS TO PAY
capture drop WTP
gen WTP = exp((qdemand - OOS_D_xbd_noP )/(D_beta)) if proddum == 1
label var WTP "Willingness to pay ($)"
timer off 2
*-------------------------------------------------------------------------------
cd "Y:\agrajg\Research\Paper1_demand_stata"
timer on 3
save "13_02_Computed_WTP_Welfare.dta", replace
timer off 3
timer list
*===============================================================================
