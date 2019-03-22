clear all
set more off
clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
timer on 1
use "13_04_Computed_WTP_Welfare.dta", clear
drop if price > 10000 & price != .
timer off 1
timer list
*-------------------------------------------------------------------------------
preserve
keep if proddum ==1
collapse (p50) p50_adj_ppp = adj_price_per_person (p50) p50_adj_ppp_cf = adj_ppp_cf (sum) sum_quantity = qdemand (sum) sum_quantity_cf = quantity_cf , by (date)
* meadian actual and counterfactual prices over time
twoway (line p50_adj_ppp date) (line p50_adj_ppp_cf date if date >= td(01nov2015), sort), ytitle(Price per person ($)) xtitle(Date) xline(20393, lpattern(shortdash_dot)) xlabel(#10, grid) legend(order(1 "Median (actual)" 2 "Median (counterfactual)") position(1) ring(0)) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\81_01_meadian_actual_and_counterfactual_prices_over_time.png", width(1600) replace
graph export "Z:\Paper1_Output\81_01_meadian_actual_and_counterfactual_prices_over_time.png", width(1600) replace
* actual and counterfactual prices over time
twoway (line sum_quantity date, lwidth(vthin)) (line sum_quantity_cf date if date >= td(01nov2015), sort), ytitle(Number of persons) xtitle(Date) xline(20393, lpattern(shortdash_dot)) xlabel(#10, grid) legend(order(1 "Quantity (actual)" 2 "Quantity (counterfactual)") position(1) ring(0)) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\81_01_actual_and_counterfactual_quantity_over_time.png", width(1600) replace
graph export "Z:\Paper1_Output\81_01_actual_and_counterfactual_quantity_over_time.png", width(1600) replace
restore
*-------------------------------------------------------------------------------

preserve
keep if proddum ==1 | purged_dummy ==1
collapse (sum) CS_exist_actual CS_exist_cf CS_purged_cf2 , by (propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd)
*format %9.0g stats_value
capture drop varCS_actual
gen double varCS_actual = CS_exist_actual/1000
egen double CS_cf = rowtotal(CS_exist_cf CS_purged_cf2)
capture drop varCS_cf
gen double varCS_cf = CS_cf/1000
capture drop varCS_diff_price
gen double varCS_diff_price = (CS_exist_actual - CS_exist_cf)/1000
capture drop varCS_diff_total
gen double varCS_diff_total = (CS_exist_actual - CS_cf)/1000

replace varCS_actual = . if purged_rental_dummy == 1 & CS_exist_cf  == 0 & CS_exist_actual == 0
replace varCS_diff_price = . if purged_rental_dummy == 1 & CS_exist_cf  == 0 & CS_exist_actual == 0

gen varCS_rental = purged_rental_dummy

reshape long var , i( propertyid purged_rental_dummy nbhd nbhd_group borough propertytype listingtype ) j(var_name) s
drop CS_*


foreach var of varlist nbhd nbhd_group borough propertytype listingtype {
	rename `var' temp_`var'
	decode temp_`var' , gen(`var')
	drop temp_`var'
}

capture drop ltype*
gen double ltype1 = 1 if listingtype == "Entire home/apt"
gen double ltype2 = 1 if listingtype == "Private room"
gen double ltype3 = 1 if listingtype == "Shared room"

capture drop ptype*
gen double ptype1 = 1 if propertytype =="Apartment" | propertytype =="Condominium" | propertytype =="Loft" | propertytype =="Townhouse"
gen double ptype2 = 1 if propertytype =="House"
gen double ptype3 = 1 if propertytype =="Bungalow" | propertytype =="Castle" | propertytype =="Guesthouse" | propertytype =="Vacation home" | propertytype == "Villa"
gen double ptype4 = 1 if propertytype =="Boat" | propertytype =="Cabin" | propertytype =="Camper/RV" | propertytype =="Hut" | propertytype == "Lighthouse" | propertytype == "Plane" | propertytype == "Treehouse"

capture drop ntype*
gen double ntype1 = 1 if borough =="Bronx" & nbhd_group=="1"
gen double ntype2 = 1 if borough =="Bronx" & nbhd_group=="4"
gen double ntype3 = 1 if borough =="Bronx" & nbhd_group=="8"
gen double ntype4 = 1 if borough =="Bronx" & nbhd_group=="12"

gen double ntype5 = 1 if borough =="Brooklyn" & nbhd_group=="5"
gen double ntype6 = 1 if borough =="Brooklyn" & nbhd_group=="16"
gen double ntype7 = 1 if borough =="Brooklyn" & nbhd_group=="6"
gen double ntype8 = 1 if borough =="Brooklyn" & nbhd_group=="1"

gen double ntype9 = 1 if borough =="Manhattan" & nbhd_group=="11"
gen double ntype10 = 1 if borough =="Manhattan" & nbhd_group=="12"
gen double ntype11 = 1 if borough =="Manhattan" & nbhd_group=="1"
gen double ntype12 = 1 if borough =="Manhattan" & nbhd_group=="3"

gen double ntype13 = 1 if borough =="Queens" & nbhd_group=="3"
gen double ntype14 = 1 if borough =="Queens" & nbhd_group=="4"
gen double ntype15 = 1 if borough =="Queens" & nbhd_group=="6"
gen double ntype16 = 1 if borough =="Queens" & nbhd_group=="9"

capture drop btype*
gen double btype1 = 1 if borough =="Bronx"
gen double btype2 = 1 if borough =="Brooklyn"
gen double btype3 = 1 if borough =="Manhattan"
gen double btype4 = 1 if borough =="Queens"
gen double btype5 = 1 if borough =="Staten Island"

foreach var2 of varlist ltype* ptype* ntype* btype* {
		replace `var2' = . if `var2' == 0
		capture drop var_`var2'
		gen double var_`var2' = var*`var2'
}

foreach var2 of varlist ltype* ptype* ntype* btype* {
	drop `var2'
}


*All rentals
label var var "All rentals"
*Listingtype
label var var_ltype1 "Entire Home/Apartment"
label var var_ltype2 "Private Room"
label var var_ltype3 "Shared Room"
*Propertytype
label var var_ptype1 "Apartment/Condominium/Loft/Townhouse"
label var var_ptype2 "House"
label var var_ptype3 "Bungalow/Castle/Guesthouse/Vacation home/Villa"
label var var_ptype4 "Boat/Cabin/Camper/RV/Hut/Lighthouse/Plane/Treehouse"
* Neighborhood
* Bronx
label var var_btype1 "All Bronx"
label var var_ntype1 "Melrose, Mott Haven, Port Morris"
label var var_ntype2 "Concourse, High Bridge"
label var var_ntype3 "Fieldston, Riverdale, Kingsbridge Heights"
label var var_ntype4 "Wakefield, Eastchester, Edenwald, Baychester"
*Brooklyn
label var var_btype2 "All Brooklyn"
label var var_ntype5 "East New York, Highland Park, New Lots, Starrett City"
label var var_ntype6 "Brownsville, Ocean Hill"
label var var_ntype7 "Cobble Hill, Carroll Gardens, Red Hook, Park Slope"
label var var_ntype8 "Greenpoint, Williamsburg"
*Manhattan
label var var_btype3 "All Manhattan"
label var var_ntype9 "Harlem"
label var var_ntype10 "Inwood, Washington Heights"
label var var_ntype11 "Financial District, Battery Park, Tribeca"
label var var_ntype12 "East Side, NoHo, Chinatown"
*Queens
label var var_btype4 "All Queens"
label var var_ntype13 "Jackson Heights, North Corona"
label var var_ntype14 "Elmhurst, Corona, Lefrac City"
label var var_ntype15 "Rego Park, Forest Hills"
label var var_ntype16 "Kew Gardens, Richmond Hill, Wood Haven"
*Staten Island
label var var_btype5 "All Staten Island"


outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if var_name == "CS_rental" , sum(detail) eqkeep(N sum) cttop("Number of rentals" , " ") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label  dta ///
			replace

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if var_name == "CS_actual" , sum(detail) eqkeep(sum N) cttop("Actual CS", "(1000 USD)") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label
			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if var_name == "CS_cf" , sum(detail) eqkeep(sum N) cttop("Counterfactual CS", "(1000 USD)") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label  dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if var_name == "CS_diff_price" , sum(detail) eqkeep(sum N) cttop("$ \Delta_{price}CS $", "(1000 USD)") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label  dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if var_name == "CS_diff_total" , sum(detail) eqkeep(sum N) cttop("$ \Delta_{total}CS $", "(1000 USD)") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label  dta
			


use "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF_dta.dta" , clear
drop in 1
texsave v1 v2 v3 v4 v6 v8 v10 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF_dta_format" , replace nofix title("\textsc{Changes in Consumer Welfare}") size("footnotesize") width("\textwidth") location("h") autonumber hlines(2 5 9 14 42) frag nonames footnote("Notes: " , size("footnotesize"))

copy "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF_dta_format.tex" "Z:\Paper1_Output\81_01_CS_Actual_CF_dta_format.tex" , replace

restore
*-------------------------------------------------------------------------------
* Change in Producer Surplus 
preserve
keep if proddum ==1 | purged_dummy ==1
collapse (sum) PS_exist_actual PS_exist_cf PS_purged_cf2 , by (propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd)
*format %9.0g stats_value
capture drop varPS_actual
gen double varPS_actual = PS_exist_actual/1000
egen double PS_cf = rowtotal(PS_exist_cf PS_purged_cf2)
capture drop varPS_cf
gen double varPS_cf = PS_cf/1000
capture drop varPS_diff_price
gen double varPS_diff_price = (PS_exist_actual - PS_exist_cf)/1000
capture drop varPS_diff_total
gen double varPS_diff_total = (PS_exist_actual - PS_cf)/1000

replace varPS_actual = . if purged_rental_dummy == 1 & PS_exist_cf  == 0 & PS_exist_actual == 0
replace varPS_diff_price = . if purged_rental_dummy == 1 & PS_exist_cf  == 0 & PS_exist_actual == 0

gen varPS_rental = purged_rental_dummy

reshape long var , i( propertyid purged_rental_dummy nbhd nbhd_group borough propertytype listingtype ) j(var_name) s
drop PS_*


foreach var of varlist nbhd nbhd_group borough propertytype listingtype {
	rename `var' temp_`var'
	decode temp_`var' , gen(`var')
	drop temp_`var'
}

capture drop ltype*
gen double ltype1 = 1 if listingtype == "Entire home/apt"
gen double ltype2 = 1 if listingtype == "Private room"
gen double ltype3 = 1 if listingtype == "Shared room"

capture drop ptype*
gen double ptype1 = 1 if propertytype =="Apartment" | propertytype =="Condominium" | propertytype =="Loft" | propertytype =="Townhouse"
gen double ptype2 = 1 if propertytype =="House"
gen double ptype3 = 1 if propertytype =="Bungalow" | propertytype =="Castle" | propertytype =="Guesthouse" | propertytype =="Vacation home" | propertytype == "Villa"
gen double ptype4 = 1 if propertytype =="Boat" | propertytype =="Cabin" | propertytype =="Camper/RV" | propertytype =="Hut" | propertytype == "Lighthouse" | propertytype == "Plane" | propertytype == "Treehouse"

capture drop ntype*
gen double ntype1 = 1 if borough =="Bronx" & nbhd_group=="1"
gen double ntype2 = 1 if borough =="Bronx" & nbhd_group=="4"
gen double ntype3 = 1 if borough =="Bronx" & nbhd_group=="8"
gen double ntype4 = 1 if borough =="Bronx" & nbhd_group=="12"

gen double ntype5 = 1 if borough =="Brooklyn" & nbhd_group=="5"
gen double ntype6 = 1 if borough =="Brooklyn" & nbhd_group=="16"
gen double ntype7 = 1 if borough =="Brooklyn" & nbhd_group=="6"
gen double ntype8 = 1 if borough =="Brooklyn" & nbhd_group=="1"

gen double ntype9 = 1 if borough =="Manhattan" & nbhd_group=="11"
gen double ntype10 = 1 if borough =="Manhattan" & nbhd_group=="12"
gen double ntype11 = 1 if borough =="Manhattan" & nbhd_group=="1"
gen double ntype12 = 1 if borough =="Manhattan" & nbhd_group=="3"

gen double ntype13 = 1 if borough =="Queens" & nbhd_group=="3"
gen double ntype14 = 1 if borough =="Queens" & nbhd_group=="4"
gen double ntype15 = 1 if borough =="Queens" & nbhd_group=="6"
gen double ntype16 = 1 if borough =="Queens" & nbhd_group=="9"

capture drop btype*
gen double btype1 = 1 if borough =="Bronx"
gen double btype2 = 1 if borough =="Brooklyn"
gen double btype3 = 1 if borough =="Manhattan"
gen double btype4 = 1 if borough =="Queens"
gen double btype5 = 1 if borough =="Staten Island"

foreach var2 of varlist ltype* ptype* ntype* btype* {
		replace `var2' = . if `var2' == 0
		capture drop var_`var2'
		gen double var_`var2' = var*`var2'
}

foreach var2 of varlist ltype* ptype* ntype* btype* {
	drop `var2'
}


*All rentals
label var var "All rentals"
*Listingtype
label var var_ltype1 "Entire Home/Apartment"
label var var_ltype2 "Private Room"
label var var_ltype3 "Shared Room"
*Propertytype
label var var_ptype1 "Apartment/Condominium/Loft/Townhouse"
label var var_ptype2 "House"
label var var_ptype3 "Bungalow/Castle/Guesthouse/Vacation home/Villa"
label var var_ptype4 "Boat/Cabin/Camper/RV/Hut/Lighthouse/Plane/Treehouse"
* Neighborhood
* Bronx
label var var_btype1 "All Bronx"
label var var_ntype1 "Melrose, Mott Haven, Port Morris"
label var var_ntype2 "Concourse, High Bridge"
label var var_ntype3 "Fieldston, Riverdale, Kingsbridge Heights"
label var var_ntype4 "Wakefield, Eastchester, Edenwald, Baychester"
*Brooklyn
label var var_btype2 "All Brooklyn"
label var var_ntype5 "East New York, Highland Park, New Lots, Starrett City"
label var var_ntype6 "Brownsville, Ocean Hill"
label var var_ntype7 "Cobble Hill, Carroll Gardens, Red Hook, Park Slope"
label var var_ntype8 "Greenpoint, Williamsburg"
*Manhattan
label var var_btype3 "All Manhattan"
label var var_ntype9 "Harlem"
label var var_ntype10 "Inwood, Washington Heights"
label var var_ntype11 "Financial District, Battery Park, Tribeca"
label var var_ntype12 "East Side, NoHo, Chinatown"
*Queens
label var var_btype4 "All Queens"
label var var_ntype13 "Jackson Heights, North Corona"
label var var_ntype14 "Elmhurst, Corona, Lefrac City"
label var var_ntype15 "Rego Park, Forest Hills"
label var var_ntype16 "Kew Gardens, Richmond Hill, Wood Haven"
*Staten Island
label var var_btype5 "All Staten Island"


outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_CF" if var_name == "PS_rental" , sum(detail) eqkeep(N sum) cttop("Number of rentals" , " ") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label  dta ///
			replace

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_CF" if var_name == "PS_actual" , sum(detail) eqkeep(sum N) cttop("Actual PS", "(1000 USD)") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label
			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_CF" if var_name == "PS_cf" , sum(detail) eqkeep(sum N) cttop("Counterfactual PS", "(1000 USD)") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label  dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_CF" if var_name == "PS_diff_price" , sum(detail) eqkeep(sum N) cttop("$ \Delta_{price}PS $", "(1000 USD)") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label  dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_CF" if var_name == "PS_diff_total" , sum(detail) eqkeep(sum N) cttop("$ \Delta_{total}PS $", "(1000 USD)") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label  dta
			


use "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_CF_dta.dta" , clear
drop in 1
texsave v1 v2 v3 v4 v6 v8 v10 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_CF_dta_format" , replace nofix title("\textsc{Changes in Producer Welfare}") size("footnotesize") width("\textwidth") location("h") autonumber hlines(2 5 9 14 42) frag nonames footnote("Notes: " , size("footnotesize"))

copy "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_CF_dta_format.tex" "Z:\Paper1_Output\81_01_PS_Actual_CF_dta_format.tex" , replace

restore
*-------------------------------------------------------------------------------
* Total welfare summary
preserve
rename CS_purged_cf2 CS_purged_cf
rename PS_purged_cf2 PS_purged_cf
collapse (sum) CS_exist_actual CS_exist_cf CS_purged_cf   PS_exist_actual PS_exist_cf PS_purged_cf
foreach var of varlist CS_exist_actual CS_exist_cf CS_purged_cf PS_exist_actual PS_exist_cf PS_purged_cf {
replace `var' = `var'/1000000
rename `var' surplus`var'
}
format %9.2f surplusCS_exist_actual surplusCS_exist_cf surplusCS_purged_cf surplusPS_exist_actual surplusPS_exist_cf surplusPS_purged_cf
gen obs = _n
reshape long surplus, i(obs) j(new) s
drop obs
split new , p("_")
order new1 new2 new3 surplus
format %5.2f surplus

drop new
replace new1 = "Counsumer" if new1 =="CS"
replace new1 = "Producer" if new1 =="PS"
label var new1 "Surplus"

replace new2 = "Existing" if new2 =="exist"
replace new2 = "Purged" if new2 =="purged"
label var new2 "Market Presence"

replace new3 = "Actual" if new3 =="actual"
replace new3 = "Counter-factual" if new3 =="cf"
label var new3 "Setting"
replace surplus = round(surplus, 0.01)
label var surplus "Sum (in million dollars)"


texsave using "Z:\Paper1_Output\81_01_WelfareSummary" , replace title("\textsc{Welfare Summary}") size(scriptsize) width(0.7\textwidth) align(lllC) location(t) marker("Table:81_01_WelfareSummary") autonumber hlines(3) footnote("Notes : These are aggregated figures summed up over all rental-time observation" , size(scriptsize) width(l)) varlabels nofix frag
texsave using "Y:\agrajg\Research\Paper1_demand_stata\81_01_WelfareSummary" , replace title(\textsc{Welfare Summary}) size(scriptsize) width(0.7\textwidth) align(lllC) location(t) marker("Table:81_01_WelfareSummary") autonumber hlines(3) footnote("Notes : These are aggregated figures summed up over all rental-time observation", size(scriptsize)width(l)) varlabels nofix frag
restore
*-------------------------------------------------------------------------------


*===============================================================================



// *-------------------------------------------------------------------------------

/*
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2015 & var_name == "CS_actual" , sum(detail) eqkeep(N sum) cttop("2015","Actual") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta
			

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2015 & var_name == "CS_cf" , sum(detail) eqkeep(N sum) cttop("2015","Counterfactual") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2015 & var_name == "CS_diff_price" , sum(detail) eqkeep(N sum) cttop("2015","$ \Delta_{price} $") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2015 & var_name == "CS_diff_total" , sum(detail) eqkeep(N sum) cttop("2015","$ \Delta_{total} $") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2016 & var_name == "CS_actual" , sum(detail) eqkeep(N sum) cttop("2016","Actual") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta
			

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2016 & var_name == "CS_cf" , sum(detail) eqkeep(N sum) cttop("2016","Counterfactual") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2016 & var_name == "CS_diff_price" , sum(detail) eqkeep(N sum) cttop("2016","$ \Delta_{price} $") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2016 & var_name == "CS_diff_total" , sum(detail) eqkeep(N sum) cttop("2016","$ \Delta_{total} $") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2017 & var_name == "CS_actual" , sum(detail) eqkeep(N sum) cttop("2017 (Jan-Mar)","Actual") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta
			

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2017 & var_name == "CS_cf" , sum(detail) eqkeep(N sum) cttop("2017 (Jan-Mar)","Counterfactual") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2017 & var_name == "CS_diff_price" , sum(detail) eqkeep(N sum) cttop("2017 (Jan-Mar)","$ \Delta_{price} $") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_CF" if year == 2017 & var_name == "CS_diff_total" , sum(detail) eqkeep(N sum) cttop("2017 (Jan-Mar)","$ \Delta_{total} $") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				\textit{\textbf{Brooklyn}} var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				\textit{\textbf{Manhattan}} var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				\textit{\textbf{Queens}} var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				\textit{\textbf{Staten-Island}} var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1 var_ntype1 var_ntype2 var_ntype3 var_ntype4 ///
				var_btype2 var_ntype5 var_ntype6 var_ntype7 var_ntype8 ///
				var_btype3 var_ntype9 var_ntype10 var_ntype11 var_ntype12 ///
				var_btype4 var_ntype13 var_ntype14 var_ntype15 var_ntype16 ///
				var_btype5 ///
			) label tex(frag pr) dta

			

/*
preserve
collapse (sum) sum_CS_exist_actual=CS_exist_actual  sum_PS_exist_actual=PS_exist_actual , by (year week)

replace sum_CS_exist_actual = round(sum_CS_exist_actual/1000000, 0.01)
label var week "Week of the year"
label var sum_CS_exist_actual "Consumer Surplus (in million $)"
twoway (line sum_CS_exist_actual week if year == 2014, sort) (line sum_CS_exist_actual week if year==2015, sort) (line sum_CS_exist_actual week if year ==2016, sort) (line sum_CS_exist_actual week if year==2017, sort), ylabel(0(1)8 ,grid) xlabel(0(13)52, grid) legend(on order(1 "2014" 2 "2015" 3 "2016" 4 "2017") position(10) ring(0)) scheme(tufte) xsize(10) ysize(6) scale(1)
graph export "Y:\agrajg\Research\Paper1_demand_stata\81_01_CS_Actual_exist.png", width(1600) replace
graph export "H:\Output_Oct2018\81_01_CS_Actual_exist.png", width(1600) replace

replace sum_PS_exist_actual = round(sum_PS_exist_actual/1000000, 0.01)
label var week "Week of the year"
label var sum_PS_exist_actual "Producer Surplus (in million $)"
twoway (line sum_PS_exist_actual week if year == 2014, sort) (line sum_PS_exist_actual week if year==2015, sort) (line sum_PS_exist_actual week if year ==2016, sort) (line sum_PS_exist_actual week if year==2017, sort), ylabel(0(1)8 ,grid) xlabel(0(13)52, grid) legend(on order(1 "2014" 2 "2015" 3 "2016" 4 "2017") position(10) ring(0)) scheme(tufte) xsize(10) ysize(6) scale(1)
graph export "Y:\agrajg\Research\Paper1_demand_stata\81_01_PS_Actual_exist.png", width(1600) replace
graph export "H:\Output_Oct2018\81_01_PS_Actual_exist.png", width(1600) replace
restore
*-------------------------------------------------------------------------------

preserve
gen CS_actual = CS_exist_actual/1000000
gen PS_actual = PS_exist_actual/1000000
gen CS_cf = (CS_exist_cf + CS_purged_cf)/1000000
gen PS_cf = (PS_exist_cf + PS_purged_cf)/1000000
twoway (line CS_actual yw) (line CS_cf yw, sort), ytitle(Consumer Surplus (Million $)) ylabel(0(2)14) xtitle(Week) xlabel(#10, angle(forty_five) grid) legend(on order(1 "Actual" 2 "Counterfactual") position(10) ring(0)) scheme(tufte) xsize(10) ysize(3)
twoway (line PS_actual yw) (line PS_cf yw, sort), ytitle(Producer Surplus (Million $)) ylabel(0(2)14) xtitle(Week) xlabel(#10, angle(forty_five) grid) legend(on order(1 "Actual" 2 "Counterfactual") position(10) ring(0)) scheme(tufte) xsize(10) ysize(3)

restore



// // preserve
// // drop if proddum ==0
// // collapse (sum) CS_exist_actual PS_exist_actual
// // foreach var of varlist CS_exist_actual PS_exist_actual{
// // replace `var' = `var'/1000000
// // }
// // restore
// *===============================================================================
// preserve
// drop if proddum ==0
// gen dom = day(date)
// gen christmasholiday = 1 if month == 12 & dom >=25 & dom <=31 
// collapse (sum) sum_CS_exist_actual = CS_exist_actual sum_PS_exist_actual = PS_exist_actual  (mean) mean_CS_exist_actual = CS_exist_actual mean_PS_exist_actual = PS_exist_actual , by(christmasholiday)
// foreach var of varlist *CS_exist_actual *PS_exist_actual{
// replace `var' = `var'/1000000
// }
// restore
// *===============================================================================
// preserve
// drop if proddum ==0
// collapse (sum) CS_exist_actual PS_exist_actual, by(dow)
// foreach var of varlist CS_exist_actual PS_exist_actual{
// replace `var' = `var'/1000000
// }
// restore
