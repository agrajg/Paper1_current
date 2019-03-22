* Subsetting the data for active listing that are common to both 
clear all
set more off
*-------------------------------------------------------------------------------
cd "Y:\agrajg\Research\Paper1_demand_stata\"

* This is the period of observation when we belive the purge was taking place 
global BUFFER_PERIOD = 365
* If the number of days with multi-listing exceeds this number, I claim the host to be a multi-listing host
global MULTI_LISTING_THRESHOLD = 30
*latest change

global update_date_list 20606 20698 20728 20759 20789 20820 20851 20879
foreach lname of global   update_date_list   {
	use  "01_01_active_listing_data_common_with_MCOX.dta", clear
	di `lname'
	*-------------------------------------------------------------------------------
	// * adding the last date.
	// preserve
	// collapse (max) last_date = date , by (propertyid)
	// save "01_02_last_date_of_properties.dta", replace
	// restore
	// * count the number of days
	// preserve
	// collapse (count) count_property = propertyid , by (date listingtype)
	// drop if listingtype == "NR"
	// encode listingtype , gen (ltype)
	// drop listingtype
	// reshape wide count_property , i(date) j(ltype )
	// twoway (line count_property1 date, sort) (line count_property2 date, sort) (line count_property3 date, sort), ytitle(Number of active rentals) ylabel(#12, grid glwidth(vthin)) xtitle(Date) xline(20423 20606 20748, lwidth(thin) lpattern(longdash)) xlabel(#20, angle(forty_five) grid glwidth(vthin)) legend(order(1 "Entire home or apartment" 2 "Private room" 3 "Shared room")) scheme(tufte) scale(0.7)
	// graph export "01_02_count_rental_by_type.png", width(800) height(600) replace
	// restore
	//
	// * count the number of properties
	// preserve
	// contract propertyid longitude latitude
	// twoway (scatter latitude longitude, sort mcolor(gs10%50) msymbol(point)), yscale(off) ylabel(#10, ticks grid glwidth(thin) glcolor(%50)) xscale(off) xlabel(#15, grid glwidth(thin) glcolor(%50)) scheme(tufte) scale(0.7)
	// graph export "01_02_rental_locattion.png", width(800) height(600) replace
	// restore
	*-------------------------------------------------------------------------------
	* Finding purged listings



	*-------------------------------------------------------------------------------
	* Specifying purge periods
	gen purge1 = "01_pre_purge_1" 	
	replace purge1 = "02_during_purge_1" if date >= (td(01dec2015) - $BUFFER_PERIOD) & date <= td(01dec2015)
	replace purge1 = "03_post_purge_1" if date > td(01dec2015)
	encode purge1 , gen (purge_1)
	capture drop purge1
	*-------------------------------------------------------------------------------
	gen purge2 = "01_pre_purge_2" 
	replace purge2 = "02_during_purge_2" if date >= (`lname' - $BUFFER_PERIOD) & date <= `lname'
	replace purge2 = "03_post_purge_2" if date > `lname'
	encode purge2 , gen (purge_2)
	capture drop purge2
	*-------------------------------------------------------------------------------
	gen reg = "01_pre_regulation" 
	replace reg = "02_post_regulation" if date > td(21oct2016)
	encode reg, gen (regulation)
	*-------------------------------------------------------------------------------

	*Assigning host to multi listing host or not
	preserve
	keep if purge_2 == 2
	* number of active rentals held by host on a give date
	
	collapse (count) count_property = propertyid, by (hostid listingtype date)
	* how many days a host has had each number of listing. 
	* For how many days, a host has held 2 listing, 3 listings etc .. 
	collapse (count) count_days = date , by (hostid listingtype count_property )
	format %9.0g count_days

	gen multiple_listing_dum = (count_property > 1) 
	* dummy to just indicate more than one active listing by host

	collapse (sum)sum_days = count_days , by (hostid listingtype multiple_listing_dum )
	* counting the days with multiple listings
	reshape wide sum_days, i( hostid listingtype) j( multiple_listing_dum )

	replace sum_days0 = 0 if sum_days0 == .
	replace sum_days1 = 0 if sum_days1== .

	drop if listingtype =="NR"
	keep if listingtype == "Entire home/apt"
	encode listingtype , gen(ltype )

	*bys listingtype:  sum sum_days1 if sum_days1 > 0, det
	capture drop listingtype

// 	reshape wide sum_days0 sum_days1 , i( hostid ) j( ltype )
// 	foreach var of varlist sum_day* {
// 	replace `var' = 0 if `var' == .
// 	}

	local tempnum = $BUFFER_PERIOD
	compress
	save "01_02_hosts_multilisting_activity_`tempnum'_before_`lname'_data_release.dta", replace 
	restore
	*-------------------------------------------------------------------------------
	preserve
	collapse (count) count_date  = date , by(propertyid hostid neighborhood state listingtype purge_2 )
	format %9.0g count_date
	reshape wide count_date , i( propertyid hostid neighborhood state listingtype  ) j( purge_2 )
	foreach var of varlist count_date* {
	replace `var'= 0 if `var'==.
	}



	local tempnum = $BUFFER_PERIOD
	capture drop sum_days0
	capture drop sum_days1
// 	capture drop sum_days01 
// 	capture drop sum_days11 
// 	capture drop sum_days02 
// 	capture drop sum_days12
// 	capture drop sum_days03 
// 	capture drop sum_days13
	capture drop _merge
	merge m:1 hostid using "01_02_hosts_multilisting_activity_`tempnum'_before_`lname'_data_release.dta"
	keep if _merge == 3
	drop _merge
	count if count_date1 >0 & count_date2 >0 & count_date3 ==0
	*tab1 neighborhood listingtype if count_date1 >0 & count_date2 >0 & count_date3 ==0
	*tab neighborhood listingtype if count_date1 >0 & count_date2 >0 & count_date3 ==0
	* add nbhd info 
	do "Y:\agrajg\Research\Paper1_demand_stata\00_00_nbhd_map.do" 
	bys borough : sum sum_days1  if count_date2 >0 & count_date3 ==0 &  sum_days1 > 0, det
	local tempnum2 = $MULTI_LISTING_THRESHOLD
	tab borough listingtype  if count_date2 >0 & count_date3 ==0 & sum_days1 > `tempnum2'
	gen purge_dum = (count_date2 >0 & count_date3 ==0 & sum_days1 > `tempnum2')
	merge 1:1 propertyid using "01_02_last_date_of_properties.dta"
	keep if _merge ==3
	save "01_02_Purged_rentals_in_past_`tempnum'_days_wt_`tempnum2'_since_`lname'.dta", replace
	restore
}



