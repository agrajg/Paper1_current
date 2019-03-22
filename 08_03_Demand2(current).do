clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
do "00_00_parameters.do"
use  "03_02_Regression_Data.dta" , clear
*drop if price > 10000 & price !=.
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
*===============================================================================
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
preserve
timer on 99
reghdfe qdemand qdemand_l1 qdemand_l2 ladj_price_per_person lprice_per_person ///
	p_age h_age  p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 ///
	c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5, ///
	a(propertyid date nbhd#yw nbhd#dow)  vce(cluster propertyid) cache(save, ///
	keep(propertyid date status reservationid bookeddate hostid listingtype ///
	state neighborhood nbhd nbhd_group borough bedrooms bathrooms latitude longitude))
timer off 99
capture estimates clear
*-------------------------------------------------------------------------------
timer on 1
reghdfe qdemand  ///
	ladj_price_per_person, ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use)  vce(cluster propertyid)

estimate store model_1
timer off 1
*-------------------------------------------------------------------------------
timer on 2
reghdfe qdemand  ///
	p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	ladj_price_per_person, ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cluster propertyid)
	
estimate store model_2
timer off 2
*-------------------------------------------------------------------------------
timer on 3
reghdfe qdemand  ///
	p_age h_age  p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5), ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cluster propertyid)

estimate store model_3
timer off 3
*-------------------------------------------------------------------------------
timer on 4
reghdfe qdemand qdemand_l1  ///
	p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5), ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cluster propertyid)

estimate store model_4
timer off 4
*-------------------------------------------------------------------------------
timer on 5
reghdfe qdemand qdemand_l1 qdemand_l2  ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5), ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cluster propertyid)

estimate store model_5
timer off 5
*-------------------------------------------------------------------------------
timer on 8
reghdfe qdemand qdemand_l1 qdemand_l2  ///
	p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5), ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use) vce(cluster propertyid)

estimate store model_8
timer off 8
*------------------------------------------------------------------------------
restore

*-------------------------------------------------------------------------------
timer on 6
ivregress 2sls  qdemand qdemand_l1 qdemand_l2  ///
	p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5) , vce(cluster propertyid)
	
estimate store model_6
timer off 6
*-------------------------------------------------------------------------------
timer on 7
reghdfe qdemand qdemand_l1 qdemand_l2  ///
	p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5), ///
	a(propertyid date) vce(cluster propertyid)

estimate store model_7
timer off 7
*------------------------------------------------------------------------------




*labeling thse variables
label var qdemand "Quantity"
label var qdemand_l1 "Quantity (lag 1)"
label var qdemand_l2 "Quantity (lag 2)"
label var p_age "Rental Age" 
label var h_age "Host Age" 
// label var p_dayshosting "Past hosting days (rental)" 
// label var h_dayshosting  "Past hosting days (host)"
label var p_daysbooked  "Past booked days (rental)"
label var h_daysbooked  "Past booked days (host)"
label var p_guestcount  "Past guests count (rental)"
label var h_guestcount "Past guests count (host)"
label var ladj_price_per_person "ln(Price per guest)"
label var prod_week1  "Days unblocked in past 1 week"
label var prod_week2  "Days unblocked in past 2 week"
label var prod_week3  "Days unblocked in past 3 week"
label var prod_week4  "Days unblocked in past 4 week"
label var prod_week5  "Days unblocked in past 5 week"
label var propertyid  "Property ID"
label var date  "Date"
label var nbhd "Neighborhood"
// label var yw "Year-Week"
// label var dow "Day of Week"

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Output Results
estfe model_1 model_2 model_3 model_4 model_5 model_6 model_7 model_8 ///
	, labels(propertyid "Property FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_1 model_2 model_3 model_4 model_5 model_6 model_7 model_8 using "08_03_Demand_reg_absorbed_propertyid_date_nbhdyw_nbhddow.tex",  replace ///
	se /// 
	title("\textsc{Demand Estimation}") ///
	b(a2) ///
	order(ladj_price_per_person qdemand_l1 qdemand_l2) ///
	label ///
	indicate(          /// // "Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	noconstant ///
	addnote("Notes: (1) The Within R-Square computes the R-Square of a regression where every variable has already been demeaned with respect to all the fixed effects." , "(2) If R-square is negative, it is because in the regression the variables are demeaned first with respect to all fixed effects and then demeaned outcome variable is regressed on demanded regressors without a constant term")


estfe model_1 model_2 model_3 model_4 model_5 model_6 model_7 model_8 ///
	, restore
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
copy "Y:\agrajg\Research\Paper1_demand_stata\08_03_Demand_reg_absorbed_propertyid_date_nbhdyw_nbhddow.tex" "Z:\Paper1_Output\08_03_Demand_reg_absorbed_propertyid_date_nbhdyw_nbhddow.tex" , replace
*===============================================================================
timer list 
