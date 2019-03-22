* Estimating the impacat on the price and quantity.
* identifying the purged listings 
clear all
set more off
cd "Y:\agrajg\Research\Paper1_demand_stata\"
use "May25_RegInstrumentData.dta", clear
// merge m:1 propertyid using "DataSource.dta"
// keep if _merge == 3
// drop _merge
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

********************************************************************************
* Identify the listings that were purged during purge 1 and Purge 2


********************************************************************************
* Construct a window of some week in past and future to see what happened to prices
* window to pick the purge
global PWINDOW = 6
* window to pick the effect
global EWINDOW = 12
g yearweek = yw(year, week)
format %tw yearweek

* 
gen purgeperiod1 = "pre"
replace purgeperiod1 = "during" if yearweek >= tw(2015w48) - $PWINDOW
replace purgeperiod1 = "post" if yearweek > tw(2015w48)

gen purgeperiod2 = "pre"
replace purgeperiod2 = "during" if yearweek >= tw(2016w22) - $PWINDOW
replace purgeperiod2 = "post" if yearweek > tw(2016w22)


collapse (max) max_date = date (count) numdays = date , by (propertyid listingtype hostid state neighborhood purgeperiod1 )
format %9.0g numdays
reshape wide max_date numdays , i( propertyid hostid listingtype state neighborhood ) j( purgeperiod1 ) s
bys hostid : gen propcount= _N
tab listingtype propcount if numdayspre > 0 & numdaysduring >0 & numdayspost ==.
 

gen plus = "+"
gen minus = "-"
tostring yearweek, gen(yearweek_purge1)
replace yearweek_purge1 = minus if yearweek <= tw(2015w48) - $WINDOW
replace yearweek_purge1 = plus if yearweek >= tw(2015w48) + $WINDOW
encode yearweek_purge1, gen(purge1)
drop yearweek_purge1

tostring yearweek, gen(yearweek_purge2)
replace yearweek_purge2 = minus if yearweek <= tw(2016w22) - $WINDOW
replace yearweek_purge2 = plus if yearweek >= tw(2016w22) + $WINDOW
encode yearweek_purge2, gen(purge2)
drop yearweek_purge2

drop plus minus
********************************************************************************
xtset propertyid date 
// xtreg  p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount i.year i.month i.day  i.dow , fe
tab purge1 , gen(p1)
tab purge2 , gen(p2)
xtreg lprice p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount i.year i.month i.day i.dow p1* p2* , fe
