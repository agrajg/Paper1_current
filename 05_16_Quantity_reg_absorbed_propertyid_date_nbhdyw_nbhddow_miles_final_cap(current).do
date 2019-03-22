clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "04_07_Price_regression_ready_data.dta", clear
drop if status == "B"
drop if price > 10000 & price !=.
// keep if date >=td(01nov2015) & date <=td(15nov2015)
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
gen year = year(date)
gen week = week(date)
gen month = month(date)
gen ym = ym(year, month)
gen yw = yw(year, week)
gen dow = dow(date)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*===============================================================================

global ALL_CONTROLS p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5
order N_cap_inmile_0_500 N_cap_inmile_0_1000 N_cap_inmile_0_2000 N_cap_inmile_0_5000 N_cap_inmile_0_10000 N_cap_inmile_0_20000 N_cap_inmile_500_1000 N_cap_inmile_1000_2000 N_cap_inmile_2000_5000 N_cap_inmile_5000_10000 N_cap_inmile_10000_20000, after (qdemand)

timer on 1
reghdfe qdemand  p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5 N_cap_inmile_* , /// 
	a(propertyid date nbhd#yw nbhd#dow) cache(save) vce(cl propertyid) 
timer off 1
timer list 

* Regressions
timer on 2
capture estimates clear
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe qdemand p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5  ///
	N_cap_inmile_0_500 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cl propertyid)
estimate store model_set_A1

reghdfe qdemand p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5 ///
	N_cap_inmile_0_500 N_cap_inmile_500_1000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cl propertyid)
estimate store model_set_A2

reghdfe qdemand p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5 ///
	N_cap_inmile_0_500 N_cap_inmile_500_1000 N_cap_inmile_1000_2000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cl propertyid)
estimate store model_set_A3

reghdfe qdemand p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5 ///
	N_cap_inmile_0_500 N_cap_inmile_500_1000 N_cap_inmile_1000_2000 N_cap_inmile_2000_5000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cl propertyid)
estimate store model_set_A4

reghdfe qdemand p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5 ///
	N_cap_inmile_0_500 N_cap_inmile_500_1000 N_cap_inmile_1000_2000 N_cap_inmile_2000_5000 N_cap_inmile_5000_10000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cl propertyid)
estimate store model_set_A5

// reghdfe qdemand p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5 ///
// 	N_cap_inmile_0_500 N_cap_inmile_500_1000 N_cap_inmile_1000_2000 N_cap_inmile_2000_5000 N_cap_inmile_5000_10000 N_cap_inmile_10000_20000 ///
// 	, a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cl propertyid)
// estimate store model_set_A6
*===============================================================================
// label var ladj_price_per_person100  "$ ln(Price) (X100\%) $"
// label var ladj_price_per_person "$ ln(Price) $"
*Labelling variables 
label var N_cap_inmile_0_1000 "Purged capacity $(0 \leq distance < 1 mile)$"
label var N_cap_inmile_0_2000 "Purged capacity $(0 \leq distance < 2 mile)$"
label var N_cap_inmile_0_5000 "Purged capacity $(0 \leq distance < 5 mile)$"
label var N_cap_inmile_0_10000 "Purged capacity $(0 \leq distance < 10 mile)$"
label var N_cap_inmile_0_20000 "Purged capacity $(0 \leq distance < 20 mile)$"
label var N_cap_inmile_0_500 "Purged capacity $(0 \leq distance < 0.5 mile)$"
label var N_cap_inmile_500_1000 "Purged capacity $(0.5 \leq distance < 1 mile)$"
label var N_cap_inmile_1000_2000 "Purged capacity $(1 \leq distance < 2 mile)$"
label var N_cap_inmile_2000_5000 "Purged capacity $(2 \leq distance < 5 mile)$"
label var N_cap_inmile_5000_10000 "Purged capacity $(5 \leq distance < 10 mile)$"
label var N_cap_inmile_10000_20000 "Purged capacity $(10 \leq distance < 20 mile)$"
*-------------------------------------------------------------------------------
*labeling thse variables
label var qdemand "Quantity"
// label var qdemand_l1 "Quantity (lag 1)"
// label var qdemand_l2 "Quantity (lag 2)"
// label var qdemand_l3 "Quantity (lag 3)" 
label var p_age "Rental Age" 
label var h_age "Host Age" 
// label var p_dayshosting "Past hosting days (rental)" 
// label var h_dayshosting  "Past hosting days (host)"
label var p_daysbooked  "Past booked days (rental)"
label var h_daysbooked  "Past booked days (host)"
label var p_guestcount  "Past guests count (rental)"
label var h_guestcount "Past guests count (host)"
// label var ladj_price_per_person "ln(Price)"
label var prod_week1  "Days unblocked in past 1 week"
label var prod_week2  "Days unblocked in past 2 week"
label var prod_week3  "Days unblocked in past 3 week"
label var prod_week4  "Days unblocked in past 4 week"
label var prod_week5  "Days unblocked in past 5 week"
label var propertyid  "Property ID"
label var date  "Date"
// label var nbhd "Neighborhood"
// label var yw "Year-Week"
// label var dow "Day of Week"
*===============================================================================
*-------------------------------------------------------------------------------
estfe model_set_A* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_A* using "05_16_Quantity_reg_absorbed_propertyid_date_nbhdyw_set_mile_A_final_cap.tex", replace ///
	se /// 
	title("\textsc{Impact On Quantity}") ///
	b(a2) ///
	order(N_cap_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	addnote("Add note later")

estfe model_set_A* , restore
*-------------------------------------------------------------------------------
estfe model_set_A* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_A* using "05_16_Quantity_reg_absorbed_propertyid_date_nbhdyw_set_mile_A_final_cap.csv", replace ///
	se /// 
	title("\textsc{Impact On Quantity}") ///
	b(a2) ///
	order(N_cap_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	addnote("Add note later")

estfe model_set_A* , restore
*-------------------------------------------------------------------------------
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
