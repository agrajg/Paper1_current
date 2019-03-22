clear all
set more off
use  "01_01_active_listing_data_common_with_MCOX.dta", clear
*-------------------------------------------------------------------------------
drop if price > 10000
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* count the number of days
preserve
collapse (count) count_property = propertyid , by (date listingtype)
drop if listingtype == "NR"
encode listingtype , gen (ltype)
drop listingtype
reshape wide count_property , i(date) j(ltype )
twoway (line count_property1 date, sort) (line count_property2 date, sort) (line count_property3 date, sort), ytitle(Number of active rentals) ylabel(#12, grid glwidth(vthin)) xtitle(Date) xline(20423 20606 20748, lwidth(thin) lpattern(longdash)) xlabel(#20, angle(forty_five) grid glwidth(vthin)) legend(order(1 "Entire home or apartment" 2 "Private room" 3 "Shared room")) scheme(tufte) scale(0.7)
graph export "02_01_count_rental_by_type.png", width(800) replace
graph export "H:\Output_Oct2018\02_01_count_rental_by_type.png", width(800) replace
restore
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* count the number of properties
preserve
contract propertyid longitude latitude
twoway (scatter latitude longitude, sort mcolor(gs10%50) msymbol(point)), yscale(off) ylabel(#10, ticks grid glwidth(thin) glcolor(%50)) xscale(off) xlabel(#15, grid glwidth(thin) glcolor(%50)) scheme(tufte) scale(0.7)
graph export "02_01_rental_locattion.png", width(800) height(600) replace
graph export "H:\Output_Oct2018\02_01_rental_locattion.png", width(800) height(600) replace


restore
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
