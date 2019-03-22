// * Elasticity estimates and further results
// clear all 
// set more off
// import delimited Y:\agrajg\Research\Paper1\ElasticityEst.csv
// gen date2=date(date,"DMY")
// format date2 %td
// drop date
// rename date2 date
// order propertyid date
// sort propertyid date
// save Y:\agrajg\Research\Paper1\ElasticityEst.dta, replace
// *-------------------------------------------------------------------------------
// clear all
// set more off
// use "Y:\agrajg\Research\Paper1\May25_RegInstrumentData.dta", clear
// merge 1:1 propertyid date using Y:\agrajg\Research\Paper1_demand_stata\ElasticityEst.dta
// drop _merge
// save "Y:\agrajg\Research\Paper1_demand_stata\ElasticityEst2.dta", replace
// *-------------------------------------------------------------------------------
clear all
set more off
use "Y:\agrajg\Research\Paper1_demand_stata\ElasticityEst2.dta", replace
xtset propertyid date
*-------------------------------------------------------------------------------
// preserve 
// keep elasticity
// outreg2 using Y:\agrajg\Research\Output_01_June_2018\ElasticitySummary, sum(detail) replace eqkeep(N mean sd min p10 p25 p50 p75 p90 max) see tex(frag)
// copy Y:\agrajg\Research\Output_01_June_2018\elasticitySummary.tex T:\agrajg\Output_01_June_2018\elasticitySummary.tex, replace
// restore
*-------------------------------------------------------------------------------
// xtsum elasticity
*-------------------------------------------------------------------------------
// preserve
// collapse (count)count = propertyid (mean)mean = elasticity (sd)sd = elasticity (min)min = elasticity (p01)p01 = elasticity (p05)p05 = elasticity (p10)p10 = elasticity (p25)p25 = elasticity (p50)p50 = elasticity (p75)p75 = elasticity (p90)p90 = elasticity (p95)p95 = elasticity (p99)p99 = elasticity (max)max = elasticity , by(date)
// twoway (line mean date, sort lwidth(thin)), ylabel(#10, grid) xlabel(#22, angle(forty_five) grid) xmtick(##1, grid) scheme(tufte) scale(1)
// graph save Graph "Y:\agrajg\Research\Output_01_June_2018\MeanElasticityVsDate.gph", replace
// graph export "Y:\agrajg\Research\Output_01_June_2018\MeanElasticityVsDate.png" , 	width(700) height(500) replace
// copy Y:\agrajg\Research\Output_01_June_2018\MeanElasticityVsDate.png T:\agrajg\Output_01_June_2018\MeanElasticityVsDate.png, replace	
// restore
*-------------------------------------------------------------------------------


// preserve
// drop if demand ==0
// local lprice_beta = -7.578455 
// local integral_qfunc = 1.02923
// g CS = exp(-((prbooking - (`lprice_beta' * lprice ))/`lprice_beta')) * `integral_qfunc'
// ** OUTREG
// keep CS
// outreg2 using Y:\agrajg\Research\Output_01_June_2018\CounsumerSurplus, sum(detail) replace keep(CS) eqkeep(N mean sd min p10 p25 p50 p75 p90 max) tex(frag)
// copy Y:\agrajg\Research\Output_01_June_2018\CounsumerSurplus.tex T:\agrajg\Output_01_June_2018\CounsumerSurplus.tex, replace
// restore

preserve
use "Y:\agrajg\Research\Paper1_demand_stata\000102_AIRDNA_listings_data_clean_final.dta" , clear
save "Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta", replace
restore

preserve
drop if demand ==0
local lprice_beta = -7.578455 
local integral_qfunc = 1.02923
g CS = exp(-((prbooking - (`lprice_beta' * lprice ))/`lprice_beta')) * `integral_qfunc'
merge m:1 propertyid using Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta
*erase Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta
keep if _merge == 3
drop _merge
bys year : sum CS , det
bys month : sum CS , det
bys year month : sum CS
collapse (count) count_bookings = demand (mean) mean_CS = CS (sum)sum_CS = CS, by(year month )
reshape wide count_bookings mean_CS sum_CS, i(month) j(year)
twoway (line mean_CS2014 month, sort) (line mean_CS2015 month, sort) (line mean_CS2016 month, sort) (line mean_CS2017 month, sort), xlabel(#12, grid) scheme(tufte)
// The 
restore

preserve
drop if demand ==0
local lprice_beta = -7.578455 
local integral_qfunc = 1.02923
g CS = exp(-((prbooking - (`lprice_beta' * lprice ))/`lprice_beta')) * `integral_qfunc'
merge m:1 propertyid using Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta
*erase Y:\agrajg\Research\Paper1_demand_stata\temp_data.dta
keep if _merge == 3
drop _merge
bys listingtype : sum CS
collapse (count) count_bookings = demand (mean) mean_CS = CS (sum)sum_CS = CS, by(year month listingtype )




