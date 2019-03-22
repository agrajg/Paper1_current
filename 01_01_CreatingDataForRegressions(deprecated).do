// clear all
// set more off
// // using property data to obtain neighnorhoods
// use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
// keep propertyid hostid  state neighborhood listingtype maxguests bedrooms bathrooms createddate latitude longitude 
// save "Y:\agrajg\Research\Paper1_demand_stata\Some_property_characteristics.dta", replace
//
// // merging neighborhood to the market data
// clear all 
// use "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final.dta", clear
// merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\Some_property_characteristics.dta"
// keep if _merge == 3
// drop _merge
// save "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final_with_some_Prod_char.dta", replace
// ********************************************************************************
clear all
set more off
use "Y:\agrajg\Research\Paper1_demand_stata\000103_AIRDNA_market_data_clean_final_with_some_Prod_char.dta", clear

// // subsetting the data
// // change these parameters to change location
// local rad = 0.005
// glo t_lat = 40.76
// glo t_long = -73.99
// // local rad = 0.01
// // glo t_lat = 40.81
// // glo t_long = -73.96
// gen dist = sqrt((longitude - $t_long)^2+(latitude - $t_lat)^2)
// keep if dist <= `rad'
// count
********************************************************************************
* Estimating the impacat on the price and quantity.
* identifying the purged listings 
merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\DataSource.dta"
keep if _merge == 3
drop _merge
********************************************************************************
* We will work with data that is common in both AIRDNA and MCOX. The airdna includes 
* all data fron New Jersey and Pesylvenia. This may not show up in MCOX data. 
* It will be useful to find purged properties from data common in both data. 
* Following commands will help understand why this is the best choice to move forward
// tab status if state == "New York"
// tab status if AIRDNAMarketdum == 1 & MCOXPropertydum == 0
// tab status if state =="New York" & AIRDNAMarketdum == 1 & MCOXPropertydum == 0
// tab status if state =="New York" & AIRDNAMarketdum == 1 & MCOXPropertydum == 1
// tab status if state =="New York" & AIRDNAMarketdum == 1 & MCOXPropertydum == 1 & MCOXreviewdum == 0
// tab status if state =="New York" & AIRDNAMarketdum == 1 & MCOXPropertydum == 1 & MCOXreviewdum == 1
********************************************************************************
** Subseting the data dor completeness
keep if AIRDNAMarketdum ==1 & MCOXPropertydum ==1
drop  AIRDNAPropertydum AIRDNAMarketdum MCOXPropertydum MCOXreviewdum
********************************************************************************
// creating variables 
sort propertyid date
gen demand = (status =="R")
gen qdemand = demand*maxguests

forval i=1(1)3 {
	capture drop demand_l`i'
	by propertyid : gen demand_l`i' = demand[_n -`i']
	replace demand_l`i' = 0 if demand_l`i' == .
	capture drop qdemand_l`i'
	by propertyid : gen qdemand_l`i' = qdemand[_n -`i']
	replace qdemand_l`i' = 0 if qdemand_l`i' == .
}

capture drop lprice
gen lprice = ln(price)

gen price_per_person = price/maxguests
gen lprice_per_person = ln(price_per_person)

forval i=1(1)3 {
	capture drop lprice_l`i' 
	by propertyid : gen lprice_l`i' = lprice[_n -`i']
	capture drop lprice_per_person_l`i' 
	by propertyid : gen lprice_per_person_l`i' = lprice_per_person[_n -`i']
	
}

gen year = year(date) 
gen month = month(date) 
gen day = day(date) 
gen halfyear = halfyear(date)
gen quarter = quarter(date) 
gen week = week(date) 
gen dow = dow(date)
gen doy = doy(date) 

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



sort propertyid date
 

* IV's 
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

egen pid = group(propertyid)
egen pymid = group(pid year month)
egen pywid = group(pid year week)
drop pid

keep if date >= td(01aug2014) & date <= td(31mar2017)
drop if status == "B"
drop proddum_l1-proddum_l40
********************************************************************************
gen purgedum1a = (date >= td(01oct2015))
gen purgedum1b = (date >= td(01nov2015))

gen purgedum2a = (date >= td(01may2016))
gen purgedum2b = (date >= td(01jun2016))

gen purgedum3a = (date >= td(01oct2016))
gen purgedum3b = (date >= td(01nov2016))
********************************************************************************




********************************************************************************
areg lprice i.year i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, absorb(propertyid)
predict lprice_hat_pid1, xbd

areg lprice  i.year i.month i.day i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, absorb(propertyid)
predict lprice_hat_pid2, xbd

// areg lprice i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 i.dow, absorb(pywid )
// predict lprice_hat_pywid1, xbd
//
// areg lprice i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 i.dow i.month i.day, absorb(pywid )
// predict lprice_hat_pywid2, xbd
********************************************************************************

********************************************************************************
areg lprice l(1/3)lprice i.year i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, absorb(propertyid)
predict lprice_l_hat_pid1, xbd

areg lprice l(1/3)lprice i.year i.month i.day i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, absorb(propertyid)
predict lprice_l_hat_pid2, xbd

// areg lprice l(1/3)lprice i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 i.dow, absorb(pywid )
// predict lprice_l_hat_pywid1, xbd
//
// areg lprice l(1/3)lprice i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5 i.dow i.month i.day, absorb(pywid )
// predict lprice_l_hat_pywid2, xbd


xtset propertyid date 
count
********************************************************************************
save "Y:\agrajg\Research\Paper1_demand_stata\01_01_May25_RegInstrumentData.dta", replace
*export delimited using "Y:\agrajg\Research\Paper1_demand_stata\May25_RegInstrumentData.csv", replace
********************************************************************************
// preserve 
// sample 20
// save "Y:\agrajg\Research\Paper1\May25_RegInstrumentData_Sample.csv", replace
// export delimited using "Y:\agrajg\Research\Paper1\May25_RegInstrumentData_Sample.csv", replace
// restore
********************************************************************************


** Demand Estimation 

*xtreg qdemand p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount i.year i.month i.day i.week i.dow lprice_hat_pid2, fe
* the best demand regression
* xtivreg qdemand p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount i.date (lprice_per_person = i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5), fe


