clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm

*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "04_03_Price_regression_ready_data.dta", clear
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
keep if status =="R"
gen week = week(date)
gen month = month(date)
gen dow = dow(date)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// reghdfe lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount , absorb( prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid date nbhd#week)
// reghdfe lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount 	ex_*_minus ex_*_minus_p* ex_*_minus_f* , absorb( prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid date nbhd#week)
// reghdfe lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount 	ex_*_minus ex_*_minus_p* ex_*_minus_f* , absorb( prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid nbhd#date )


preserve

* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid date nbhd#week) cache(save)
save "04_05_Price_reg_absorbed_propertyid_date_nbhdweek.dta", replace
// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
// restore

preserve

* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid nbhd#date) cache(save)
save "04_05_Price_reg_absorbed_propertyid_nbhddate.dta", replace

// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
// restore


preserve

* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid#week nbhd#date) cache(save)
save "04_05_Price_reg_absorbed_propertyidweek_nbhddate.dta", replace

// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
// restore


preserve

* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid#month nbhd#date) cache(save)
save "04_05_Price_reg_absorbed_propertyidmonth_nbhddate", replace

// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
// restore


preserve

* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid#month nbhd#week dow) cache(save)
save "04_05_Price_reg_absorbed_propertyidmonth_nbhdweek_dow.dta", replace

// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
// restore

preserve

* Save the cache
reghdfe price lprice price_per_person lprice_per_person p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount  ex_*, a(prod_week1 prod_week2 prod_week3 prod_week4 prod_week5 propertyid#month nbhd#week date) cache(save)
save "04_05_Price_reg_absorbed_propertyidmonth_nbhdweek_date.dta", replace

// * Run regressions
// reghdfe price weight, a(turn rep) cache(use)
// reghdfe price length, a(turn rep) cache(use)
//
// * Clean up
// reghdfe, cache(clear)
// restore
