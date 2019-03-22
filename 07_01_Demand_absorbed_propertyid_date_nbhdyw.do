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

gen lqdemand7 = ln(0.0000001 + qdemand)
gen lqdemand6 = ln(0.000001 + qdemand)
gen lqdemand5 = ln(0.00001 + qdemand)
gen lqdemand4 = ln(0.0001 + qdemand)
gen lqdemand3 = ln(0.001 + qdemand)
gen lqdemand2 = ln(0.01 + qdemand)

*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
global ALL_CONTROLS p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5
// reghdfe qdemand lqdemand* p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
// 	lprice_per_person  i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, /// 
// 	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw) cache(save, keep(propertyid date nbhd))

* Regressions
capture estimates clear
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 1
reghdfe qdemand p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), /// 
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw)
estimate store model_set_A_1
predict qd_hat , xbd
drop FE_*

timer off 1
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 2
reghdfe lqdemand2 p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), /// 
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw)
estimate store model_set_B_2
predict lqd_hat2 , xbd
drop FE_*

timer off 2
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 3
reghdfe lqdemand3 p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), /// 
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw)
estimate store model_set_B_3
predict lqd_hat3 , xbd
drop FE_*

timer off 3
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 4
reghdfe lqdemand4 p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), /// 
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw)
estimate store model_set_B_4
predict lqd_hat4 , xbd
drop FE_*

timer off 4
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 5
reghdfe lqdemand5 p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), /// 
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw)
estimate store model_set_B_5
predict lqd_hat5 , xbd
drop FE_*

timer off 5
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 6
reghdfe lqdemand6 p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), /// 
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw)
estimate store model_set_B_6
predict lqd_hat6 , xbd
drop FE_*

timer off 6
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
timer on 7
reghdfe lqdemand7 p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), /// 
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw)
estimate store model_set_B_7
predict lqd_hat7 , xbd
drop FE_*

timer off 7
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



timer list


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Output Results
timer on 3
estfe model_set_*  ///
	, labels(propertyid "Property FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE")
return list

esttab model_set_* using "07_01_Demand_reg_absorbed_propertyid_date_nbhdyw.csv", replace ///
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

