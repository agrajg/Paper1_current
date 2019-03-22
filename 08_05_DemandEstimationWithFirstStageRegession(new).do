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

*-------------------------------------------------------------------------------
timer on 8
reghdfe ladj_price_per_person qdemand_l1 qdemand_l2  ///
	p_age h_age p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 c.capacity#prod_week1 c.capacity#prod_week2 c.capacity#prod_week3 c.capacity#prod_week4 c.capacity#prod_week5, ///
	a(propertyid date nbhd#yw nbhd#dow) vce(cluster propertyid)

	
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
	
// estimates dir
// estimate store model_7


estfe reghdfe_first1 ///
	, labels(propertyid "Property FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab reghdfe_first1 using "08_05_Demand_reg_First_Stage.tex",  replace ///
	se /// 
	title("\textsc{Demand Estimation}") ///
	b(a2) ///
	order(ladj_price_per_person qdemand_l1 qdemand_l2) ///
	label ///
	indicate(          /// 
			"Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	noconstant /// 
	scalars(r2 r2_within  r2_a F)

estfe reghdfe_first1 ///
	, restore

timer off 8
*------------------------------------------------------------------------------
