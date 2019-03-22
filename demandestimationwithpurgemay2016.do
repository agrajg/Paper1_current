clear all
set more off
use "Y:\agrajg\Research\Paper1_demand_stata\ElasticityEst2.dta", replace
drop if date >= td(01apr2017)

preserve
use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
keep propertyid state hostid listingtype
save "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta", replace
restore

merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta"
keep if _merge ==3
drop _merge

// merge m:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\MCOX_property_host.dta"
// keep if _merge ==3
// drop _merge

sort propertyid date
xtset propertyid date
preserve


tab listingtype , gen (ltypedum)
collapse (count) Nall = propertyid (sum) Neha = ltypedum1 (sum) Npr = ltypedum3 (sum)Nsr = ltypedum4 ,by(hostid date )
gen mldum_all = (Nall>1)
gen mldum_eha = (Neha>1)
replace mldum_eha = . if Neha == 0
gen mldum_pr = (Npr>1)
replace mldum_pr = . if Npr == 0
gen mldum_sr = (Nsr>1)
replace mldum_sr = . if Nsr == 0


sum Nall Neha Npr Nsr
collapse (sum)count_mldum_all = mldum_all (mean)frac_mldum_all= mldum_all (sum)count_mldum_eha = mldum_eha (mean)frac_mldum_eha= mldum_eha (sum)count_mldum_pr = mldum_pr (mean)frac_mldum_pr= mldum_pr  (sum)count_mldum_sr = mldum_sr (mean)frac_mldum_sr= mldum_sr ,by(date)
twoway (line count_mldum_all date, sort) (line count_mldum_eha date, sort) (line count_mldum_pr date, sort) (line count_mldum_sr date, sort), xlabel(#37, angle(forty_five) grid) scheme(tufte) scale(0.5)
twoway (line frac_mldum_all  date, sort) (line frac_mldum_eha  date, sort) (line frac_mldum_pr  date, sort) (line frac_mldum_sr  date, sort), xlabel(#37, angle(forty_five) grid) scheme(tufte) scale(0.5)



tab listingtype , gen (ltypedum)
collapse (count) Nall = propertyid (sum) Neha = ltypedum1 (sum) Npr = ltypedum3 (sum)Nsr = ltypedum4 ,by( date )
twoway (line Nall   date, sort) (line Neha   date, sort) (line Npr   date, sort) (line Nsr   date, sort), xlabel(#37, angle(forty_five) grid) scheme(tufte) scale(0.5)



drop if date >= td(01apr2017)
areg lprice l(1/3)lprice i.year i.month i.week i.dow i.day i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, absorb(propertyid )
predict lprice_hat, xbd
gen purgedum = (date >= td(01may2016))
logit demand  l(1/3).demand i.year i.month i.week i.dow i.day i.propertyid lprice_hat  purgedum
