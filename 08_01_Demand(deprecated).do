clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
do "00_00_parameters.do"
use  "03_02_Regression_Data.dta" , clear
// keep if date >= td(15dec2016) & date < td(15jan2017)
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*Creating necessary variables
gen year = year(date)
gen week = week(date)
gen month = month(date)
gen ym = ym(year, month)
gen yw = yw(year, week)
gen dow = dow(date)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
timer on 99
reghdfe qdemand qdemand_l1 qdemand_l2 qdemand_l3 ladj_price_per_person lprice_per_person ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(save, ///
	keep(propertyid date status reservationid bookeddate hostid listingtype ///
	state neighborhood nbhd nbhd_group borough bedrooms bathrooms latitude longitude))
timer off 99
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
capture estimates clear

*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
timer on 1
reghdfe qdemand  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 1
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
timer on 2
reghdfe qdemand qdemand_l1  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 2
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
timer on 3
reghdfe qdemand qdemand_l1 qdemand_l2  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 3
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
timer on 4
reghdfe qdemand qdemand_l1 qdemand_l2 qdemand_l3  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 4
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 1
reghdfe qdemand  ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 1
*===============================================================================
timer on 1
reghdfe qdemand  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	ladj_price_per_person, ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 1
timer on 1
reghdfe qdemand  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4), ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 1

timer on 1
reghdfe qdemand  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3), ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 1


timer on 1
reghdfe qdemand  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2), ///
	a(i.propertyid i.date i.nbhd#i.yw) cache(use)
timer off 1

*===============================================================================
timer list
