clear all
set more off
use "Y:\agrajg\Research\Paper1_demand_stata\ElasticityEst2.dta", replace
xtset propertyid date
count
br
preserve
use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
tab state
keep propertyid state hostid listingtype
save "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta", replace
restore
merge m:1 propertyid using temp_data.dta
merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta"
keep if _merge ==3
drop _mearge
drop _merge
tab state
peserve
preserve
collapse (sum) count_bookings = demand (count) count_prod = propertyid (mean) mean_price = price,by(date state)
br
gen year = year(date)
gen month = month(date)
gen week= week(date)
gen dow = dow(date)
reg count_bookings i.year i.month i.dow i.state
h encode
encode state , gen(state1)
reg count_bookings i.year i.month i.dow i.state1
predict ehat, residuals
twoway (line ehat date, sort)
twoway (line ehat date, sort lwidth(vvthin))
twoway (line ehat date, sort), by(state)
twoway (line ehat date, sort), xlabel(#30) by(state)
twoway (line ehat date, sort), xlabel(#30, angle(forty_five) grid) by(state)
drop ehat
reg count_bookings i.year i.month i.week i.dow i.state1
predict ehat, residuals
twoway (line ehat date, sort), xlabel(#30, angle(forty_five) grid) by(state)
drop ehat
reg count_bookings i.year i.month i.week i.dow i.state1 count_prod mean_price
predict ehat, residuals
twoway (line ehat date, sort), xlabel(#30, angle(forty_five) grid) by(state)
drop ehat
egen yearmonth = group(year month)
reg count_bookings i.yearmonth i.week i.dow i.state1
predict ehat, residuals
twoway (line ehat date, sort), xlabel(#30, angle(forty_five) grid) by(state)
drop ehat
egen yearweek = group(year week)
reg count_bookings i.yearmonth i.yearweek i.dow i.state1
predict ehat, residuals
twoway (line ehat date, sort), xlabel(#30, angle(forty_five) grid) by(state)
drop ehat
reg count_bookings i.yearmonth i.yearweek i.dow i.state1 count_prod mean_price
predict ehat, residuals
twoway (line ehat date, sort), xlabel(#30, angle(forty_five) grid) by(state)
drop ehat
reg count_bookings l1.count_bookings i.year i.month i.week i.dow
reg count_bookings l1.count_bookings i.year i.month i.week i.dow
reg count_bookings l(1).count_bookings i.year i.month i.week i.dow
reg count_bookings L1.count_bookings i.year i.month i.week i.dow
reg count_bookings  i.year i.month i.week i.dow
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings
tsset date
xtset state1 date
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings
reg count_bookings  i.year i.month i.week i.dow i.state1 l1.count_bookings
predict ehat, residuals
twoway (line ehat date, sort), xlabel(#30, angle(forty_five) grid) by(state)
tab state state1
twoway (line ehat date if state1==2, sort), xlabel(#30, angle(forty_five) grid)
drop ehat
twoway (line count_bookings  date if state1==2, sort), xlabel(#30, angle(forty_five) grid)
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings
predict ehat, residuals
twoway (line count_bookings  date if state1==2, sort), xlabel(#30, angle(forty_five) grid)
twoway (line ehat  date if state1==2, sort), xlabel(#30, angle(forty_five) grid)
gen purge1 = (date >= td(01nov2015))
gen purge2 = (date >= td(01jun2016))
gen purge3 = (date >= td(01nov2016))
reg ehat purge1 purge2 purge3
replace purge1 = (date >= td(01oct2015))
reg ehat purge1 purge2 purge3
replace purge1 = (date >= td(01nov2015))
reg ehat purge1 purge2 purge3, no
reg ehat purge1 purge2 purge3, n
reg ehat purge1
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings purge1
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings purge1 purge2 purge3
reg count_bookings  i.year i.month i.week i.dow l(1/3).count_bookings purge1 purge2 purge3
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings purge1 purge2 purge3
h reg
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings purge1 purge2 purge3, nocons
do "C:\TEMP\17\STD3434_000000.tmp"
merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\MCOX_property_host.dta"
tab state if _merge ==1
preserve
collapse (sum) count_bookings = demand (count) count_prod = propertyid (mean) mean_price = price,by(date state _merge)
bys _merge: sum count_bookings
tab state _merge
bys _merge: sum count_bookings, det
bys _merge state : sum count_bookings, det
encode state , gen(state1)
twoway (line count_bookings  date if state1==2, sort), xlabel(#30, angle(forty_five) grid)
twoway (line count_bookings  date if state1==2, sort), xlabel(#30, angle(forty_five) grid)
twoway (line count_bookings  date if state1==2 & _merge ==3, sort), xlabel(#30, angle(forty_five) grid)
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings purge1 purge2 purge3, nocons
gen year = year(date)
gen month = month(date)
gen week= week(date)
gen dow = dow(date)
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings purge1 purge2 purge3
gen purge1 = (date >= td(01nov2015))
gen purge3 = (date >= td(01nov2016))
gen purge2 = (date >= td(01jun2016))
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings purge1 purge2 purge3
xtset state1 date
preserve
keep if _merge ==3
bount
count
xtset state1 date
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings purge1 purge2 purge3
reg count_bookings  i.year i.month i.week i.dow l1.count_bookings
predict ehat, residuals
twoway (line ehat date, sort), xlabel(#30, angle(forty_five) grid) by(state)
twoway (line ehat  date if state1==2, sort), xlabel(#30, angle(forty_five) grid)
collapse (mean) mean_ehat = ehat , by( year month )
br
restore
clear all
set more off
use "Y:\agrajg\Research\Paper1_demand_stata\ElasticityEst2.dta", replace
xtset propertyid date
preserve
use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
keep propertyid state hostid listingtype
save "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta", replace
restore
merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta"
keep if _merge ==3
drop _merge
merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\MCOX_property_host.dta"
keep if _merge ==3
drop _merge
preserve
 count
collapse (sum) count_bookings = demand (count) count_prod = propertyid (mean) mean_price = price,by(date state)
collapse (sum) count_bookings = demand (count) count_prod = propertyid (mean) mean_price = price,by(date state)
count
tab state
keep if state =="New York"
tsset date
twoway (line count_bookings date, sort)
gen year = year(date)
gen month = month(date)
gen week= week(date)
gen dow = dow(date)
gen dom = day(date)
gen purge1 = (date >= td(01nov2015))
gen purge3 = (date >= td(01nov2016))
gen purge2 = (date >= td(01jun2016))
reg count_bookings i.year i.month i.dom l1.count_bookings
predict ehat , r
twoway (line ehat  date if state1==2, sort), xlabel(#30, angle(forty_five) grid)
twoway (line ehat  date, sort), xlabel(#30, angle(forty_five) grid)
drop ehat
reg count_bookings i.year i.month i.dom i.week i.dow l1.count_bookings
predict ehat , r
twoway (line ehat  date, sort), xlabel(#30, angle(forty_five) grid)
reg count_bookings i.year i.month i.dom i.week i.dow l1.count_bookings purge1 purge2 purge3
drop ehat
predict ehat , r
twoway (line ehat  date, sort), xlabel(#30, angle(forty_five) grid)
reg count_prod i.year i.month i.dom i.week i.dow l1.count_bookings purge1 purge2 purge3
reg count_prod i.year i.month i.dom i.week i.dow l1.count_bookings
drop ehat
predict ehat , r
twoway (line ehat  date, sort), xlabel(#30, angle(forty_five) grid)
reg count_prod i.year i.month i.dom i.week i.dow l1.count_prod
drop ehat
predict ehat , r
twoway (line ehat  date, sort), xlabel(#30, angle(forty_five) grid)
restore
count
count
sort hostid host_id
br hostid host_id
br hostid host_id if hostid != host_id
count hostid host_id if hostid != host_id
count if hostid != host_id
preserve
bys hostid date : gen count_pph = _N
label var count_pph "Host rental count on a given day"
tab count_pph
gen multihostdum = (count_pph > 1)
collapse (sum) count_bookings = demand (count) count_prod = propertyid (mean) mean_price = price,by(date state multihostdum )
bount
count
twoway (line count_bookings date, sort), scale(0.5) by(state multihostdum)
tab state
keep if state =="New York"
count
twoway (line count_bookings date, sort), scale(0.5) by(multihostdum, iscale(*0.5))
twoway (line count_bookings date, sort), scale(1) by(multihostdum, iscale(*0.5))
xtset multihostdum date
reg count_prod i.year i.month i.dom i.week i.dow l1.count_prod if multihostdum == 0
gen year = year(date)
gen month = month(date)
gen week= week(date)
gen dow = dow(date)
gen dom = day(date)
gen purge1 = (date >= td(01nov2015))
gen purge3 = (date >= td(01nov2016))
gen purge2 = (date >= td(01jun2016))
reg count_prod i.year i.month i.dom i.week i.dow l1.count_prod if multihostdum == 0
predict ehat1 , r
reg count_prod i.year i.month i.dom i.week i.dow l1.count_prod if multihostdum == 1
predict ehat2 , r
twoway (line ehat1 date, sort), scale(0.5)
twoway (line ehat2 date, sort), scale(0.5)
twoway (line count_bookings date, sort), scale(1) by(multihostdum, iscale(*0.5))
twoway (line count_prod  date, sort), scale(1) by(multihostdum, iscale(*0.5))
twoway (line count_prod  date, sort), scale(1) by(multihostdum, iscale(*0.5))
reg count_prod i.year i.month i.dom i.week i.dow l1.count_prod if multihostdum == 0 & (date < td(01oct2015)| date >td(15oct2015))
drop ehat*
predict ehat1 , r
reg count_prod i.year i.month i.dom i.week i.dow l1.count_prod if multihostdum == 1 & (date < td(01oct2015)| date >td(15oct2015))
predict ehat2 , r
twoway (line ehat1 date, sort), scale(0.5)
twoway (line ehat2 date, sort), scale(0.5)
br
restore
preserve
count
gen purge1 = (date >= td(01nov2015))
gen purge2 = (date >= td(01jun2016))
gen purge3 = (date >= td(01nov2016))
areg lprice i.year i.month i.week i.day i.dow l(1/3)lprice, absorb(propertyid )
sort propertyid date
xtset propertyid date
areg lprice i.year i.month i.week i.day i.dow l(1/3)lprice, absorb(propertyid )
predict ehat, residuals
twoway (line ehat2 date if propertyid == 1183005, sort), scale(0.5)
twoway (line ehat date if propertyid == 1183005, sort), scale(0.5)
areg lprice i.year i.month i.week i.day i.dow l(1/3)lprice if demand == 1, absorb(propertyid )
drop ehat
predict ehat, residuals
twoway (line ehat date if propertyid == 1183005, sort), scale(0.5)
bys hostid date : gen count_pph = _N
label var count_pph "Host rental count on a given day"
gen multihostdum = (count_pph > 1)
collapse (mean) mean_ehat (count) count_ehat, by (propertyid multihostdum)
collapse (mean) mean_ehat = ehat (count) count_ehat = ehat, by (propertyid multihostdum)
twoway (line mean_ehat date, sort), scale(1) by(multihostdum, iscale(*0.5))
restore
areg lprice i.year i.month i.week i.day i.dow l(1/3)lprice if demand == 1, absorb(propertyid )
xtset propertyid date
areg lprice i.year i.month i.week i.day i.dow l(1/3)lprice if demand == 1, absorb(propertyid )
drop ehat
predict ehat, residuals
twoway (line ehat date if propertyid == 1183005, sort), scale(0.5)
bys hostid date : gen count_pph = _N
label var count_pph "Host rental count on a given day"
gen multihostdum = (count_pph > 1)
collapse (mean) mean_ehat = ehat (count) count_ehat = ehat, by (date multihostdum)
twoway (line ehat date if propertyid == 1183005, sort), scale(0.5)
twoway (line mean_ehat  date, sort), scale(0.5) by (multihostdum)
twoway (line mean_ehat date, sort), scale(1) by(multihostdum, cols(1) iscale(*0.5))
twoway (line mean_ehat date, sort), xlabel(#30) scale(1) by(multihostdum, cols(1) iscale(*0.5))
twoway (line mean_ehat date, sort), xlabel(#30, angle(forty_five)) scale(1) by(multihostdum, cols(1) iscale(*0.5))
twoway (line mean_ehat date, sort), xlabel(#30, angle(forty_five) grid) scale(1) by(multihostdum, cols(1) iscale(*0.5))
restore
