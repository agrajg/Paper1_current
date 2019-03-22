clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "04_03_Price_regression_ready_data.dta", clear
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
keep if status =="R"
gen year = year(date)
gen week = week(date)
gen month = month(date)
gen ym = ym(year, month)
gen yw = yw(year, week)
gen dow = dow(date)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// reghdfe lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount , absorb( prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid date nbhd#week)
// reghdfe lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount 	ex_*_minus ex_*_minus_p* ex_*_minus_f* , absorb( prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid date nbhd#week)
// reghdfe lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount 	ex_*_minus ex_*_minus_p* ex_*_minus_f* , absorb( prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid nbhd#date )


preserve
timer on 1
* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid date nbhd#yw) cache(save)
save "04_05_Price_reg_absorbed_propertyid_date_nbhdyw.dta", replace
timer off 1
// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
restore

preserve
timer on 2
* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid nbhd#date) cache(save)
save "04_05_Price_reg_absorbed_propertyid_nbhddate.dta", replace
timer off 2
// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
restore


preserve
timer on 3
* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid#yw nbhd#date) cache(save)
save "04_05_Price_reg_absorbed_propertyidyw_nbhddate.dta", replace
timer off 3
// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
restore


preserve
timer on 4
* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid#ym nbhd#date) cache(save)
save "04_05_Price_reg_absorbed_propertyidym_nbhddate", replace
timer off 4
// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
restore


preserve
timer on 5
* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid#ym nbhd#yw dow) cache(save)
save "04_05_Price_reg_absorbed_propertyidym_nbhdyw_dow.dta", replace
timer off 5
// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
restore

preserve
timer on 6
* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid#ym nbhd#yw date) cache(save)
save "04_05_Price_reg_absorbed_propertyidym_nbhdyw_date.dta", replace
timer off 6
// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
restore
