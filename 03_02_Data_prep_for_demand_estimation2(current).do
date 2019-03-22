timer clear
timer on 1
clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
*-------------------------------------------------------------------------------
cd "Y:\agrajg\Research\Paper1_demand_stata\"
use "03_01_Filtered_Data_on_property_date.dta" , clear
// keep if date >= td(15dec2016) & date < td(15jan2017)

*-------------------------------------------------------------------------------
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* creating demand variables
gen demand = (status =="R")
* converting quantity as capacity
gen capacity = maxguests if maxguests > 0
replace capacity = 1 if maxguests == 0

* quantity demanded 
gen qdemand = demand*capacity
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* creating lagged demand variables 
forval i=1(1)3 {
		capture drop demand_l`i'
		by propertyid : gen demand_l`i' = demand[_n -`i']
		replace demand_l`i' = 0 if demand_l`i' == .
		capture drop qdemand_l`i'
		by propertyid : gen qdemand_l`i' = qdemand[_n -`i']
		replace qdemand_l`i' = 0 if qdemand_l`i' == .
}
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Creating price variables
gen year = year(date)
gen month = month(date)
merge m:1 year month using "00_00_Inflation_data_raw.dta"
drop if _merge==2
drop _merge year month

gen adj_price = (price * 100 )/inf_base_jan2014
drop inf_base_jan2014
* Need price per person
capture drop lprice 
capture drop ladj_price 


gen lprice = ln(price)
gen price_per_person = price/capacity
gen lprice_per_person = ln(price_per_person)
gen ladj_price = ln(adj_price)
gen adj_price_per_person = adj_price/capacity
gen ladj_price_per_person = ln(adj_price_per_person)
order lprice price_per_person lprice_per_person ladj_price adj_price_per_person ladj_price_per_person, after(price)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// * Creating lagged price variables
// forval i=1(1)3 {
// 	capture drop lprice_l`i' 
// 	by propertyid : gen lprice_l`i' = lprice[_n -`i']
// 	capture drop lprice_per_person_l`i' 
// 	by propertyid : gen lprice_per_person_l`i' = lprice_per_person[_n -`i']
//	
// }
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* So far these were the price quantity data. Now we turn to time varying product characteristics

gen proddum = (status != "B")
sort propertyid date

* property time Variables
replace createddate = date if createddate > date
* property age
gen p_age = date - createddate
* Host age
bys hostid: egen oldest_createdate = min(createddate)
gen h_age = date - oldest_createdate
drop oldest_createdate

* Number of days of hosting since August 2014
sort propertyid date 
by propertyid : gen p_dayshosting = proddum  if _n == 1
by propertyid : replace p_dayshosting = proddum + p_dayshosting[_n-1]  if _n > 1
replace p_dayshosting = p_dayshosting - 1 if p_dayshosting > 0
* Number of days combined of hosting by a host since August 2014
sort hostid date propertyid
by hostid date : egen h_dayshosting = sum(p_dayshosting)

* Number of days booked by property 
sort propertyid date
by propertyid : gen p_daysbooked = demand if _n == 1
by propertyid : replace p_daysbooked = demand + p_daysbooked[_n-1]  if _n > 1
replace p_daysbooked = p_daysbooked - 1 if p_daysbooked > 0
* Number of days combined of booking by a host since August 2014
sort hostid date propertyid
by hostid date : egen h_daysbooked = sum(p_daysbooked)

* Number of guests in the past hosted by a property
sort propertyid reservationid bookeddate date
by propertyid reservationid bookeddate : gen guestdum = (_n==1 & reservationid !=.)
sort propertyid date
by propertyid : gen p_guestcount = guestdum  if _n == 1
by propertyid : replace p_guestcount = guestdum  + p_guestcount[_n-1]  if _n > 1
replace p_guestcount = p_guestcount - 1 if p_guestcount > 0
* Number of guest the host has had in the past 
sort hostid date propertyid
by hostid date : egen h_guestcount = sum(p_guestcount)

*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Instruments 
* IV's 
sort propertyid date
forval i=1(1)40 {
	capture drop proddum_l`i'
	by propertyid : gen proddum_l`i' = proddum[_n-`i']
	replace proddum_l`i' = 0 if proddum_l`i' == .
}

// forval i=1(1)40 {
// 	capture drop proddum_f`i'
// 	by propertyid : gen proddum_f`i' = proddum[_n+`i']
// 	replace proddum_f`i' = 0 if proddum_f`i' == .
// }

capture drop prod_week*
egen prod_week1 = rowtotal(proddum_l1-proddum_l7)
egen prod_week2 = rowtotal(proddum_l1-proddum_l14)
egen prod_week3 = rowtotal(proddum_l1-proddum_l21)
egen prod_week4 = rowtotal(proddum_l1-proddum_l28)
egen prod_week5 = rowtotal(proddum_l1-proddum_l35)

// capture drop prod_win_day*
// egen prod_win_day3 = rowtotal(proddum_l1 proddum_l2 proddum_l3 proddum_f1 proddum_f2 proddum_f3)
// egen prod_win_day5 = rowtotal(proddum_l1 proddum_l2 proddum_l3 proddum_l4 proddum_l5 proddum_f1 proddum_f2 proddum_f3 proddum_f4 proddum_f5)
// egen prod_win_day7 = rowtotal(proddum_l1 proddum_l2 proddum_l3 proddum_l4 proddum_l5 proddum_l6 proddum_l7 proddum_f1 proddum_f2 proddum_f3 proddum_f4 proddum_f5 proddum_f6 proddum_f7)
// egen prod_win_day14 = rowtotal(proddum_l1 proddum_l2 proddum_l3 proddum_l4 proddum_l5 proddum_l6 proddum_l7 proddum_l8 proddum_l9 proddum_l10 proddum_l11 proddum_l12 proddum_l13 proddum_l14 proddum_f1 proddum_f2 proddum_f3 proddum_f4 proddum_f5 proddum_f6 proddum_f7 proddum_f8 proddum_f9 proddum_f10 proddum_f11 proddum_f12 proddum_f13 proddum_f14)

drop proddum_l*
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* adding locations from map
do "Y:\agrajg\Research\Paper1_demand_stata\00_00_nbhd_map.do" 
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

order nbhd nbhd_group borough, after( neighborhood )
compress
*-------------------------------------------------------------------------------
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Subsetting the data
keep if date >= td(01sep2014) & date <= td(31mar2017)

*-------------------------------------------------------------------------------
cd "Y:\agrajg\Research\Paper1_demand_stata\"
save "03_02_Regression_Data_All.dta" , replace
*-------------------------------------------------------------------------------

drop if status =="B"
*-------------------------------------------------------------------------------
cd "Y:\agrajg\Research\Paper1_demand_stata\"
save "03_02_Regression_Data.dta" , replace
*-------------------------------------------------------------------------------
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*-------------------------------------------------------------------------------
timer off 1
timer list
