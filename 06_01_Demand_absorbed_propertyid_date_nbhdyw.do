clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
use  "03_02_Regression_Data.dta" , clear
// keep if date >= td(15dec2016) & date < td(15jan2017)
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
gen year = year(date)
gen week = week(date)
gen month = month(date)
gen ym = ym(year, month)
gen yw = yw(year, week)
gen dow = dow(date)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
global ALL_CONTROLS p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5
// use "04_04_Price_reg_absorbed_propertyid_date_nbhdyw.dta", clear
// timer on 1
// reghdfe price lprice price_per_person lprice_per_person demand qdemand $ALL_CONTROLS , a(propertyid date nbhd#yw) cache(save, keep(propertyid date nbhd))
// timer off 1
// timer list 

* Regressions
capture estimates clear
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 2
reghdfe qdemand p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), /// 
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw)
estimate store model_set_A_1
predict qd_hat , xbd
timer off 2
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
timer list


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Output Results
timer on 3
estfe model_set_*  ///
	, labels(propertyid "Property FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE")
return list

esttab model_set_* using "06_01_Demand_reg_absorbed_propertyid_date_nbhdyw.csv", replace ///
	se /// 
	title("Regression results - Demand") ///
	b(a2) ///
	order(lprice_per_person ) ///
	label ///
	indicate(          /// // "Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later....")
	

estfe model_set_* ///
	, restore
timer off 3
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
timer list 

