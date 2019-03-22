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
timer on 1

reghdfe qdemand qdemand_l1 qdemand_l2   ///
	p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5) ///
	if proddum == 1 , ///
	a(D_FE_propertyid = i.propertyid D_FE_date = i.date D_FE_nbhd_yw = i.nbhd#i.yw D_FE_nbhd_dow = i.nbhd#i.dow) vce(cluster propertyid)

timer off 1
*-------------------------------------------------------------------------------
* From estimated demand curve and optimal pricing condition, we try to infer 
* marginal cost for each property on a given day, which is a function of 
* predicted quantity.
* Predicting from regression the fixed effects and constant
predict D_xb ,xb
predict D_xbd , xbd
predict D_d , d
predict D_r , r

* saving contant of demand regression as a local variable
sum D_d
gen D_cons = `r(mean)'
// di `D_cons'
* saving beta as a local variable
gen D_beta = _b[ladj_price_per_person]
// di `D_beta'


* Since there will be no price for blocked days, the rental does not exist in the market
* therefore I predict without the price for all the rentals irresetpective of blocked
gen OOS_D_xb_noP = _b[qdemand_l1]*qdemand_l1 + _b[qdemand_l2]*qdemand_l2  /// 
	+ _b[p_age]*p_age + _b[h_age]*h_age ///
	+ _b[p_daysbooked]*p_daysbooked + _b[h_daysbooked]*h_daysbooked + _b[p_guestcount]*p_guestcount ///
	+ _b[h_guestcount]*h_guestcount

* Extrapolating Fixed effects
sort propertyid date 
by propertyid: carryforward D_FE_propertyid, replace
gsort propertyid -date
by propertyid: carryforward D_FE_propertyid, replace

sort date propertyid
by date: carryforward D_FE_date, replace
gsort date -propertyid
by date: carryforward D_FE_date, replace

sort nbhd yw propertyid date
by nbhd yw: carryforward D_FE_nbhd_yw, replace
gsort nbhd yw -propertyid -date
by nbhd yw: carryforward D_FE_nbhd_yw, replace

sort nbhd dow propertyid date
by nbhd dow: carryforward D_FE_nbhd_dow, replace
gsort nbhd dow -propertyid -date
by nbhd dow: carryforward D_FE_nbhd_dow, replace

gen OOS_D_xbd_noP = OOS_D_xb_noP + D_FE_propertyid + D_FE_date + D_FE_nbhd_yw + D_FE_nbhd_dow + D_cons

*-------------------------------------------------------------------------------
* Saving the data 
save "09_01_Prediction_post_Demand_estimations.dta", replace
*===============================================================================
