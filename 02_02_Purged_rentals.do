clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
// *-------------------------------------------------------------------------------
// use "01_04_purged_property_last_date.dta", clear
// gen month = month(purge_date )
// gen year = year(purge_date )
// gen ym = ym(year , month )
// format %tm ym
// collapse (count) purge_propertyid , by(ym)
// capture drop count_rental_purged
// gen count_rental_purged = purge_propertyid if _n==1
// replace count_rental_purged = count_rental_purged[_n-1] + purge_propertyid if _n>1
// twoway (connected count_rental_purged ym, sort), ytitle(Number of rentals purged (cumulative)) ylabel(0(500)4000, grid) xtitle(Time (months)) xlabel(#7, grid) scheme(tufte) scale(0.7)
// graph export "H:\Output_Oct2018\02_02_count_rental_purged.png", width(800) height(600) replace
// *-------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
use "Y:\agrajg\Research\Paper1_demand_stata\03_01_Filtered_Data_on_property_date.dta" , clear
gen long purge_propertyid = propertyid
replace purge_propertyid  = 17233439 if purge_propertyid == 17233440
// use "Y:\agrajg\Research\Paper1_demand_stata\01_04_purged_property_latitude_longitude.dta" 
// use "Y:\agrajg\Research\Paper1_demand_stata\01_04_purged_property_last_date.dta" 
merge m:1 purge_propertyid using "01_04_purged_property_last_date.dta"
gen purge_rental_dum = (_merge == 3)
drop _merge
drop purge_propertyid
* Correcting Neighborhood
do "00_00_nbhd_map.do"
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Creating price variables
gen year = year(date)
gen month = month(date)
merge m:1 year month using "00_00_Inflation_data_raw.dta"
drop if _merge==2
drop _merge year month
replace price = . if status == "B"
count if price !=.
gen adj_price = (price * 100 )/inf_base_jan2014
drop inf_base_jan2014
* Need price per person
capture drop lprice 
capture drop ladj_price 
gen lprice = ln(price)
gen price_per_person = price/maxguests
gen lprice_per_person = ln(price_per_person)
gen ladj_price = ln(adj_price)
gen adj_price_per_person = adj_price/maxguests
gen ladj_price_per_person = ln(adj_price_per_person)
order lprice price_per_person lprice_per_person adj_price ladj_price adj_price_per_person ladj_price_per_person, after(price)
* Status variables
tab status , gen (sdum)
tab status
order sdum*, after (status)
order nbhd nbhd_group borough, after (neighborhood)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
preserve
contract propertyid purge_rental_dum latitude longitude
twoway (scatter latitude longitude, sort mcolor(gs9) msymbol(point) mcolor(ltblue)) (scatter latitude longitude if purge_rental_dum ==1, sort mcolor(maroon) msymbol(point)), ylabel(#5) xlabel(#9, grid) legend(order(1 "(Light Blue points) All Rentals" 2 "(Maroon points) Purged Rentals") position(10) ring(0)) scheme(tufte) scale(1)
graph export "Y:\agrajg\Research\Paper1_demand_stata\02_02_Latitute_Longitude_rental_purged.png", width(800) height(600) replace
graph export "H:\Paper1_Output\02_02_Latitute_Longitude_rental_purged.png", width(800) height(600) replace

restore
*-------------------------------------------------------------------------------


