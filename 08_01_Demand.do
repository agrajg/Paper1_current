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
*===============================================================================
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
preserve
timer on 99
reghdfe qdemand qdemand_l1 qdemand_l2 qdemand_l3 ladj_price_per_person lprice_per_person ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, ///
	a(propertyid date nbhd#yw nbhd#dow) cache(save, ///
	keep(propertyid date status reservationid bookeddate hostid listingtype ///
	state neighborhood nbhd nbhd_group borough bedrooms bathrooms latitude longitude))
timer off 99
capture estimates clear
*-------------------------------------------------------------------------------
timer on 1
reghdfe qdemand  ///
	ladj_price_per_person, ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use)

estimate store model_1
timer off 1
*-------------------------------------------------------------------------------
timer on 2
reghdfe qdemand  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	ladj_price_per_person, ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use)
	
estimate store model_2
timer off 2
*-------------------------------------------------------------------------------
timer on 3
reghdfe qdemand  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use)

estimate store model_3
timer off 3
*-------------------------------------------------------------------------------
timer on 4
reghdfe qdemand qdemand_l1  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use)

estimate store model_4
timer off 4
*-------------------------------------------------------------------------------
timer on 5
reghdfe qdemand qdemand_l1 qdemand_l2  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use)

estimate store model_5
timer off 5
*-------------------------------------------------------------------------------
timer on 6
reghdfe qdemand qdemand_l1 qdemand_l2 qdemand_l3  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(propertyid date nbhd#yw nbhd#dow) cache(use)
	
estimate store model_6
timer off 6
*-------------------------------------------------------------------------------
*labeling thse variables
label var qdemand "Quantity"
label var qdemand_l1 "Quantity (lag 1)"
label var qdemand_l2 "Quantity (lag 2)"
label var qdemand_l3 "Quantity (lag 3)" 
label var p_age "Rental Age" 
label var h_age "Host Age" 
label var p_dayshosting "Past hosting days (rental)" 
label var h_dayshosting  "Past hosting days (host)"
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
estfe model_*  ///
	, labels(propertyid "Property FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE" nbhd#dow "Neighborhood-DOW FE")
return list

esttab model_* using "08_01_Demand_reg_absorbed_propertyid_date_nbhdyw_nbhddow.tex",  replace ///
	se /// 
	title("\textsc{Demand Estimation}") ///
	b(a2) ///
	order(ladj_price_per_person qdemand_l1 qdemand_l2 qdemand_l3) ///
	label ///
	indicate(          /// // "Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later....")


estfe model_* ///
	, restore
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
restore
*===============================================================================

*saving Fixed effects
reghdfe qdemand qdemand_l1 qdemand_l2 qdemand_l3  ///
	p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount ///
	(ladj_price_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), ///
	a(FE_propertyid = i.propertyid FE_date = i.date FE_nbhd_yw = i.nbhd#i.yw FE_nbhd_dow = i.nbhd#i.dow)

predict xb ,xb
predict xbd, xbd
predict d, d
predict r, r

di _b[ ladj_price_per_person ]
gen beta = _b[ ladj_price_per_person]
gen elas = beta / xbd
gen mc = adj_price_per_person*(1 + (xbd/beta))

gen elas2 = elas if xbd > 0
gen mc2 = mc if xbd > 0
replace mc2 = 0 if xbd > 0 & mc < 0

save "08_01_Demand_elasticity_mc.dta", replace 


*===============================================================================

timer list 
