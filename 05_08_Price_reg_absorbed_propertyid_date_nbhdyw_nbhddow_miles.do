clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "04_07_Price_regression_ready_data.dta", clear
drop if status == "B"
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
gen ladj_price_per_person100 = 100*ladj_price_per_person
label var ladj_price_per_person100  "ln(Price) (X100\%)"
label var ladj_price_per_person "ln(Price)"
*Labelling variables 
label var N_inmile_0_1000 "Purged rentals $(0 \leq distance < 1 mile)$"
label var N_inmile_0_2000 "Purged rentals $(0 \leq distance < 2 mile)$"
label var N_inmile_0_5000 "Purged rentals $(0 \leq distance < 5 mile)$"
label var N_inmile_0_10000 "Purged rentals $(0 \leq distance < 10 mile)$"
label var N_inmile_0_20000 "Purged rentals $(0 \leq distance < 20 mile)$"
label var N_inmile_0_500 "Purged rentals $(0 \leq distance < 0.5 mile)$"
label var N_inmile_500_1000 "Purged rentals $(0.5 \leq distance < 1 mile)$"
label var N_inmile_1000_2000 "Purged rentals $(1 \leq distance < 2 mile)$"
label var N_inmile_2000_5000 "Purged rentals $(2 \leq distance < 5 mile)$"
label var N_inmile_5000_10000 "Purged rentals $(5 \leq distance < 10 mile)$"
label var N_inmile_10000_20000 "Purged rentals $(10 \leq distance < 20 mile)$"
*-------------------------------------------------------------------------------
*labeling thse variables
// label var qdemand "Quantity"
// label var qdemand_l1 "Quantity (lag 1)"
// label var qdemand_l2 "Quantity (lag 2)"
// label var qdemand_l3 "Quantity (lag 3)" 
label var p_age "Rental Age" 
label var h_age "Host Age" 
label var p_dayshosting "Past hosting days (rental)" 
label var h_dayshosting  "Past hosting days (host)"
label var p_daysbooked  "Past booked days (rental)"
label var h_daysbooked  "Past booked days (host)"
label var p_guestcount  "Past guests count (rental)"
label var h_guestcount "Past guests count (host)"
label var ladj_price_per_person "ln(Price)"
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
global ALL_CONTROLS p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5
order N_inmile_0_500 N_inmile_0_1000 N_inmile_0_2000 N_inmile_0_5000 N_inmile_0_10000 N_inmile_0_20000 N_inmile_500_1000 N_inmile_1000_2000 N_inmile_2000_5000 N_inmile_5000_10000 N_inmile_10000_20000, after (ladj_price_per_person)

timer on 1
reghdfe price lprice adj_price_per_person ladj_price_per_person $ALL_CONTROLS N_inmile_* , /// 
	a(propertyid date nbhd#yw nbhd#dow) cache(save)
timer off 1
timer list 

* Regressions
timer on 2
capture estimates clear
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_500 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_A1

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_500 N_inmile_500_1000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_A2

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_500 N_inmile_500_1000 N_inmile_1000_2000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_A3

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_500 N_inmile_500_1000 N_inmile_1000_2000 N_inmile_2000_5000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_A4

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_500 N_inmile_500_1000 N_inmile_1000_2000 N_inmile_2000_5000 N_inmile_5000_10000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_A5

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_500 N_inmile_500_1000 N_inmile_1000_2000 N_inmile_2000_5000 N_inmile_5000_10000 N_inmile_10000_20000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_A6
*-------------------------------------------------------------------------------
estfe model_set_A* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_A* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_A.tex", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_A* , restore
*-------------------------------------------------------------------------------
estfe model_set_A* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_A* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_A.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_A* , restore
*-------------------------------------------------------------------------------
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_1000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_B2

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_1000 N_inmile_1000_2000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_B3

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_1000 N_inmile_1000_2000 N_inmile_2000_5000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_B4

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_1000 N_inmile_1000_2000 N_inmile_2000_5000 N_inmile_5000_10000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_B5

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_1000 N_inmile_1000_2000 N_inmile_2000_5000 N_inmile_5000_10000 N_inmile_10000_20000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_B6
*-------------------------------------------------------------------------------
estfe model_set_B* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_B* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_B.tex", replace booktabs ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_B* , restore
*-------------------------------------------------------------------------------
estfe model_set_B* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_B* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_B.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_B* , restore
*-------------------------------------------------------------------------------
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_2000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_C3

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_2000 N_inmile_2000_5000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_C4

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_2000 N_inmile_2000_5000 N_inmile_5000_10000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_C5

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_2000 N_inmile_2000_5000 N_inmile_5000_10000 N_inmile_10000_20000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_C6
*-------------------------------------------------------------------------------
estfe model_set_C* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_C* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_C.tex", replace booktabs ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_C* , restore
*-------------------------------------------------------------------------------
estfe model_set_C* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_C* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_C.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_C* , restore
*-------------------------------------------------------------------------------
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_5000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_D4

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_5000 N_inmile_5000_10000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_D5

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_5000 N_inmile_5000_10000 N_inmile_10000_20000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_D6
*-------------------------------------------------------------------------------
estfe model_set_D* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_D* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_D.tex", replace booktabs ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_D* , restore
*-------------------------------------------------------------------------------
estfe model_set_D* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_D* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_D.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_D* , restore
*-------------------------------------------------------------------------------
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_10000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_E5

reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_10000 N_inmile_10000_20000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_E6
*-------------------------------------------------------------------------------
estfe model_set_E* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_E* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_E.tex", replace booktabs ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_E* , restore
*-------------------------------------------------------------------------------
estfe model_set_E* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_E* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_E.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_E* , restore
*-------------------------------------------------------------------------------
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe ladj_price_per_person $ALL_CONTROLS ///
	N_inmile_0_20000 ///
	, a(propertyid date nbhd#yw nbhd#dow) cache(use)
estimate store model_set_F6
*-------------------------------------------------------------------------------
estfe model_set_F* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_F* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_F.tex", replace booktabs ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_F* , restore
*-------------------------------------------------------------------------------
estfe model_set_F* ///
	, labels(propertyid "Rental FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_set_F* using "05_08_Price_reg_absorbed_propertyid_date_nbhdyw_set_mile_F.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(N_inmile_*) ///
	label ///
	indicate(`r(indicate_fe)' "Supply side controls = *prod_week*") ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

estfe model_set_F* , restore
*-------------------------------------------------------------------------------
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

timer off 2
timer list
 
