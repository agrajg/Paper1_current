clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
do "00_00_parameters.do"
use  "03_02_Regression_Data_All.dta" , clear
*drop if price > 10000 & price !=.

// keep if date >= td(15dec2016) & date < td(01jan2017)
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*Creating necessary variables
gen year = year(date)
gen week = week(date)
gen month = month(date)
gen ym = ym(year, month)
gen yw = yw(year, week)
gen dow = dow(date)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*Demand specification final and saving FE
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// timer on 1
//
// reghdfe qdemand qdemand_l1 qdemand_l2  ///
// 	p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount ///
// 	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5) ///
// 	if proddum == 1 , ///
// 	a(D_FE_propertyid = i.propertyid D_FE_date = i.date D_FE_nbhd_yw = i.nbhd#i.yw D_FE_nbhd_dow = i.nbhd#i.dow)
//
// timer off 1
// *-------------------------------------------------------------------------------

preserve
keep if proddum == 1
sample 0.1
