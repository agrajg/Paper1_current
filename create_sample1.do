clear all 
set more off 

local rad = 0.005
glo t_lat = 40.76
glo t_long = -73.99
// local rad = 0.01
// glo t_lat = 40.81
// glo t_long = -73.96


cd "Y:\agrajg\Research\Paper1_demand_stata"
use "000102_AIRDNA_listings_data_clean_final.dta", clear
keep if sqrt((longitude - $t_long)^2+(latitude - $t_lat)^2) <= `rad'
local file_name_num  = `rad' * 10000
save "sample_prop_lessthan_`file_name_num'.dta", replace
count


clear all
use "000103_AIRDNA_market_data_clean_final.dta", clear


// gen proddum = (status != "B")
// sort propertyid date
// forval i=1(1)90 {
// 	capture drop proddum_l`i'
// 	gen proddum_l`i' = proddum[_n-`i']
// 	replace proddum_l`i' = 0 if proddum_l`i' == .
// }

count
gen demand = (status =="R")
gen lagdemand = 
gen lprice = ln(price)
gen invprice = 1/invprice
gen year = year(date)
gen month = month(date)
gen week = week(date)
gen dow = dow(date)

egen pymid = group(propertyid year month)
egen pywid = group(propertyid year week)

drop if status == "B"
drop proddum





merge m:1 propertyid using "sample_prop_lessthan_`file_name_num'.dta"
keep if _merge ==3




*xtset propertyid date



