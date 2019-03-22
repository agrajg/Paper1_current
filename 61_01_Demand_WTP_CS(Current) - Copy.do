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
keep if proddum==1
timer off 1
timer list
*===============================================================================
* Computing Willingness to pay 
capture drop WTP_q0
capture drop WTP_q1
capture drop WTP_q2
capture drop WTP_q3
capture drop WTP_q4
capture drop WTP_q5
capture drop WTP_q6
capture drop WTP_q7
capture drop WTP_q8
capture drop WTP_q9
capture drop WTP_q10
gen double WTP_q0 = exp((0-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q1 = exp((1-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q2 = exp((2-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q3 = exp((3-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q4 = exp((4-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q5 = exp((5-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q6 = exp((6-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q7 = exp((7-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q8 = exp((8-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q9 = exp((9-OOS_D_xbd_noP)/D_beta) if proddum ==1
gen double WTP_q10 = exp((10-OOS_D_xbd_noP)/D_beta) if proddum ==1
*-------------------------------------------------------------------------------
preserve
drop if listingtype ==2
collapse (mean) WTP_q*, by(listingtype)
reshape long WTP_q , i(listingtype) j(quantity_demanded)
label drop purge_2
label drop listingtype
reshape wide WTP_q , i( quantity_demanded ) j( listingtype )
label var quantity_demanded "Capacity (Number of persons)"
// br if quantity_demanded == 2
twoway (connected WTP_q1 quantity_demanded, sort mcolor(blue) lcolor(blue)) (connected WTP_q3 quantity_demanded, sort mcolor(red) lcolor(red)) (connected WTP_q4 quantity_demanded, sort mcolor(lime) lcolor(lime)), ytitle(Mean Willingness to Pay ($)) ylabel(#8) xlabel(#10) legend(order(1 "Entire Home or Apartment" 2 "Private Room" 3 "Shared Room") position(1) ring(0)) scheme(tufte)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_Willingness_to_Pay_by_listing_type.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_Willingness_to_Pay_by_listing_type.png", width(1600) replace
restore
*-------------------------------------------------------------------------------
preserve

collapse 	(mean) mean_WTP_q2 = WTP_q2 ///
			(mean) mean_CS_exist_actual = CS_exist_actual ///
			(sum) sum_CS_exist_actual = CS_exist_actual ///
			, by (date)


gen year = year(date)
gen month = month(date)
gen week=week(date)
gen dow = dow(date)
bys year month: egen maxwom = max(week)
gen usopenstartdate = date if month ==8 & maxwom==week & dow==1
carryforward usopenstartdate ,replace
gen usopendummy = (date - usopenstartdate < 14)

twoway (scatter mean_WTP_q2 date, sort mcolor(blue)) (lfit mean_WTP_q2 date, lcolor(navy)) (scatter mean_WTP_q2 date if ((week == 52)|(usopendummy==1)), sort mcolor(ltblue) msize(large) msymbol(circle_hollow)), ytitle(WTP for 2nd unit($)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, angle(forty_five) grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_mean_WTP_q2_all.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_mean_WTP_q2_all.png", width(1600) replace

twoway (scatter mean_CS_exist_actual date, sort mcolor(blue)) (lfit mean_CS_exist_actual date, lcolor(navy)) (scatter mean_CS_exist_actual date if ((week == 52)|(usopendummy==1)), sort mcolor(ltblue) msize(large) msymbol(circle_hollow)), ytitle(Mean Consumer Surplus ($)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, angle(forty_five) grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_mean_CS_exist_actual_all.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_mean_CS_exist_actual_all.png", width(1600) replace

replace sum_CS_exist_actual = sum_CS_exist_actual/1000000
twoway (scatter sum_CS_exist_actual date, sort mcolor(blue)) (lfit sum_CS_exist_actual date, lcolor(navy)) (scatter sum_CS_exist_actual date if ((week == 52)|(usopendummy==1)), sort mcolor(ltblue) msize(large) msymbol(circle_hollow)), ytitle(Total Consumer Surplus (1M $)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, angle(forty_five) grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_sum_CS_exist_actual_all.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_sum_CS_exist_actual_all.png", width(1600) replace

restore
*-------------------------------------------------------------------------------
preserve


collapse 	(mean) varmean_WTP_q2 = WTP_q2 ///
 			(mean) varmean_CS_exist_actual = CS_exist_actual ///
			(sum) varsum_CS_exist_actual = CS_exist_actual ///
			, by (propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd)

replace varsum_CS_exist_actual = varsum_CS_exist_actual/1000			

reshape long var, i(propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd) j(var_name) s

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
label var var_btype1 "Bronx"
label var var_ntype1 "Melrose, Mott Haven, Port Morris"
label var var_ntype2 "Concourse, High Bridge"
label var var_ntype3 "Fieldston, Riverdale, Kingsbridge Heights"
label var var_ntype4 "Wakefield, Eastchester, Edenwald, Baychester"
*Brooklyn
label var var_btype2 "Brooklyn"
label var var_ntype5 "East New York, Highland Park, New Lots, Starrett City"
label var var_ntype6 "Brownsville, Ocean Hill"
label var var_ntype7 "Cobble Hill, Carroll Gardens, Red Hook, Park Slope"
label var var_ntype8 "Greenpoint, Williamsburg"
*Manhattan
label var var_btype3 "Manhattan"
label var var_ntype9 "Harlem"
label var var_ntype10 "Inwood, Washington Heights"
label var var_ntype11 "Financial District, Battery Park, Tribeca"
label var var_ntype12 "East Side, NoHo, Chinatown"
*Queens
label var var_btype4 "Queens"
label var var_ntype13 "Jackson Heights, North Corona"
label var var_ntype14 "Elmhurst, Corona, Lefrac City"
label var var_ntype15 "Rego Park, Forest Hills"
label var var_ntype16 "Kew Gardens, Richmond Hill, Wood Haven"
*Staten Island
label var var_btype5 "All Staten Island"


outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_WTP_table" if var_name == "mean_WTP_q2" , sum(log) eqkeep(mean sd) cttop("WTP (USD)" , "All Rentals") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				 var_btype1 ///
				 var_btype2  ///
				 var_btype3  ///
				 var_btype4  ///
				 var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1  ///
				var_btype2  ///
				var_btype3  ///
				var_btype4  ///
				var_btype5 ///
			) label  dta ///
			replace

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_WTP_table" if var_name == "mean_WTP_q2" & purged_rental_dummy ==1 , sum(log) eqkeep(mean sd) cttop("WTP (USD)" , "Purged Rentals") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				 var_btype1  ///
				 var_btype2  ///
				 var_btype3  ///
				 var_btype4  ///
				 var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1  ///
				var_btype2  ///
				var_btype3  ///
				var_btype4  ///
				var_btype5 ///
			) label  dta ///

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_WTP_table" if var_name == "mean_WTP_q2" , sum(log) eqkeep(mean sd) cttop("WTP (USD)" , "All Rentals") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				 var_btype1  ///
				 var_btype2  ///
				 var_btype3  ///
				 var_btype4  ///
				 var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1  ///
				var_btype2  ///
				var_btype3  ///
				var_btype4  ///
				var_btype5 ///
			) label  dta			

* CS
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_CS_table" if var_name == "mean_CS_exist_actual"  , sum(log) eqkeep(mean sd) cttop("Average Consumer Surplus (USD)" , "All Rentals") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				 var_btype1  ///
				 var_btype2  ///
				 var_btype3  ///
				 var_btype4  ///
				 var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1  ///
				var_btype2  ///
				var_btype3  ///
				var_btype4  ///
				var_btype5 ///
			) label  dta ///
			replace

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_CS_table" if var_name == "mean_CS_exist_actual" & purged_rental_dummy ==1 , sum(log) eqkeep(mean sd) cttop("Average Consumer Surplus (USD)" , "Purged Rentals") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				 var_btype1  ///
				 var_btype2  ///
				 var_btype3  ///
				 var_btype4  ///
				 var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1  ///
				var_btype2  ///
				var_btype3  ///
				var_btype4  ///
				var_btype5 ///
			) label  dta ///
			
		
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_CS_table" if var_name == "sum_CS_exist_actual"  , sum(detail) eqkeep(sum N) cttop("Total Consumer Surplus (1000 USD)" , "All Rentals") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				 var_btype1  ///
				 var_btype2  ///
				 var_btype3  ///
				 var_btype4  ///
				 var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1  ///
				var_btype2  ///
				var_btype3  ///
				var_btype4  ///
				var_btype5 ///
			) label  dta 

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_CS_table" if var_name == "sum_CS_exist_actual" & purged_rental_dummy ==1 , sum(detail) eqkeep(sum N) cttop("Total Consumer Surplus (1000 USD)" , "Purged Rentals") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				 var_btype1  ///
				 var_btype2  ///
				 var_btype3  ///
				 var_btype4  ///
				 var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1  ///
				var_btype2  ///
				var_btype3  ///
				var_btype4  ///
				var_btype5 ///
			) label  dta ///
			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_CS_table" if var_name == "sum_CS_exist_actual" , sum(detail) eqkeep(sum N) cttop("Total Consumer Surplus (1000 USD)" , "All") /// 
	groupvar(	/// 
				var ///
				\underline{\textbf{Space-Type}} var_ltype1 var_ltype2 var_ltype3 ///
				\underline{\textbf{Property-Type}} var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				\underline{\textbf{Location}} ///
				 var_btype1  ///
				 var_btype2  ///
				 var_btype3  ///
				 var_btype4  ///
				 var_btype5 ///
			) /// 
	keep(		///
				var ///
				var_ltype1 var_ltype2 var_ltype3 ///
				var_ptype1 var_ptype2 var_ptype3 var_ptype4 ///
				var_btype1  ///
				var_btype2  ///
				var_btype3  ///
				var_btype4  ///
				var_btype5 ///
			) label  dta

			
use "Y:\agrajg\Research\Paper1_demand_stata\61_01_WTP_table_dta.dta" , clear
drop in 1
texsave v1 v2 v3 v4 v5 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_WTP_table_dta_format" , replace nofix title("\textsc{Willingness To Pay Across Rentals}") marker("Table:61_01_WTP_table_dta_format") size("footnotesize") width("\textwidth") location("t") autonumber hlines(2 5 9 14) frag nonames footnote("Notes: " , size("footnotesize"))
copy "Y:\agrajg\Research\Paper1_demand_stata\61_01_WTP_table_dta_format.tex" "Z:\Paper1_Output\61_01_WTP_table_dta_format.tex" , replace


use "Y:\agrajg\Research\Paper1_demand_stata\61_01_CS_table_dta.dta" , clear
drop in 1
texsave v1 v2 v3 v4 v5 v6 v8 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_CS_table_dta_format" , replace nofix title("\textsc{Consumer Surplus Across Rentals}") marker("Table:61_01_CS_table_dta_format") size("footnotesize") width("\textwidth") location("t") autonumber hlines(2 5 9 14) frag nonames footnote("Notes: " , size("footnotesize"))
copy "Y:\agrajg\Research\Paper1_demand_stata\61_01_CS_table_dta_format.tex" "Z:\Paper1_Output\61_01_CS_table_dta_format.tex" , replace

restore
/*
/*
preserve
collapse (mean) WTP_q*, by(date)
gen year = year(date)
gen month = month(date)
gen week=week(date)
gen dow = dow(date)
bys year month: egen maxwom = max(week)
gen usopenstartdate = date if month ==8 & maxwom==week & dow==1
carryforward usopenstartdate ,replace
gen usopendummy = (date - usopenstartdate < 14)

twoway (scatter WTP_q2 date, sort) (lfit WTP_q2 date) (scatter WTP_q2 date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msize(large) msymbol(circle_hollow)), ytitle(WTP ($)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, angle(forty_five) grid) legend(off) scheme(tufte) xsize(5) ysize(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_Willingness_to_Pay_over_time.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_Willingness_to_Pay_over_time.png", width(1600) replace
restore


preserve
collapse (mean) WTP_q*, by(date listingtype)
drop if listingtype ==2
drop if listingtype ==.
label drop listingtype
twoway (scatter WTP_q2 date if listingtype ==1, sort msize(small)) (lfit WTP_q2 date if listingtype ==1) (scatter WTP_q2 date if listingtype ==3, sort msize(small)) (lfit WTP_q2 date if listingtype ==3) (scatter WTP_q2 date if listingtype ==4, msize(small) msymbol(triangle_hollow)) (lfit WTP_q2 date if listingtype ==4), ytitle(WTP ($)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, angle(forty_five) grid) legend(off) scheme(tufte) xsize(5) ysize(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_Willingness_to_Pay_by_listing_type_over_time.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_Willingness_to_Pay_by_listing_type_over_time.png", width(1600) replace
restore


preserve
collapse (mean) WTP_q2, by(date nbhd_group borough)

drop if nbhd_group ==.
drop if borough ==.

decode nbhd_group, gen(temp)
drop nbhd_group
destring temp, gen (nbhd_group)

twoway 	(line WTP_q2 date if borough ==1 & nbhd_group==1, sort) /// 
		(line WTP_q2 date if borough ==1 & nbhd_group==4, sort) ///
		(line WTP_q2 date if borough ==1 & nbhd_group==8, sort) ///
		(line WTP_q2 date if borough ==1 & nbhd_group==12, sort), /// 
		legend(order(	1 "Melrose, Mott Haven, Port Morris" ///
						2 "Concourse, High Bridge" ///
						3 "Fieldston, Riverdale, Kingsbridge Heights" ///
						4 "Wakefield, Eastchester, Edenwald, Baychester" ///
						) position(1) ring(0)) ytitle(WTP($)) xtitle(Date) xline(20240, lpattern(dash)) ylabel(100(20)0) xlabel(, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_Willingness_to_Pay_by_nbhd_group_over_time_Bronx.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_Willingness_to_Pay_by_nbhd_group_over_time_Bronx.png", width(1600) replace

twoway 	(line WTP_q2 date if borough ==2 & nbhd_group==5, sort) /// 
		(line WTP_q2 date if borough ==2 & nbhd_group==16, sort) ///
		(line WTP_q2 date if borough ==2 & nbhd_group==6, sort) ///
		(line WTP_q2 date if borough ==2 & nbhd_group==1, sort), ///
		legend(order(	1 "East New York, Highland Park, New Lots, Starrett City" ///
						2 "Brownsville, Ocean Hill" ///
						3 "Cobble Hill, Carroll Gardens, Red Hook, Park Slope" ///
						4 "Greenpoint, Williamsburg" ///
						) position(1) ring(0)) ytitle(WTP($)) xtitle(Date) xline(20240, lpattern(dash)) ylabel(100(20)0) xlabel(, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_Willingness_to_Pay_by_nbhd_group_over_time_Brooklyn.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_Willingness_to_Pay_by_nbhd_group_over_time_Brooklyn.png", width(1600) replace

twoway 	(line WTP_q2 date if borough ==3 & nbhd_group==11, sort) ///
		(line WTP_q2 date if borough ==3 & nbhd_group==12, sort) ///
		(line WTP_q2 date if borough ==3 & nbhd_group==1, sort) ///
		(line WTP_q2 date if borough ==3 & nbhd_group==3, sort), ///
		legend(order(	1 "Harlem" ///
						2 "Inwood, Washington Heights" ///
						3 "Financial District, Battery Park, Tribeca" ///
						4 "East Side, NoHo, Chinatown" ///
						) position(1) ring(0)) ytitle(WTP($)) xtitle(Date) xline(20240, lpattern(dash)) ylabel(100(20)0) xlabel(, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_Willingness_to_Pay_by_nbhd_group_over_time_Manhattan.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_Willingness_to_Pay_by_nbhd_group_over_time_Manhattan.png", width(1600) replace

twoway 	(line WTP_q2 date if borough ==4 & nbhd_group==3, sort) ///
		(line WTP_q2 date if borough ==4 & nbhd_group==4, sort) ///
		(line WTP_q2 date if borough ==4 & nbhd_group==6, sort) ///
		(line WTP_q2 date if borough ==4 & nbhd_group==9, sort), ///
		legend(order(	1 "Jackson Heights, North Corona" ///
						2 "Elmhurst, Corona, Lefrac City" ///
						3 "Rego Park, Forest Hills" ///
						4 "Kew Gardens, Richmond Hill, Wood Haven" ///
						) position(1) ring(0)) ytitle(WTP($)) xtitle(Date) xline(20240, lpattern(dash)) ylabel(100(20)0) xlabel(, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1.5)
graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_Willingness_to_Pay_by_nbhd_group_over_time_Queens.png", width(1600) replace
graph export "Z:\Paper1_Output\61_01_Willingness_to_Pay_by_nbhd_group_over_time_Queens.png", width(1600) replace

// twoway (line WTP_q2 date if borough ==5 & nbhd_group==1, sort) (line WTP_q2 date if borough ==5 & nbhd_group==2, sort)  (line WTP_q2 date if borough ==5 & nbhd_group==3, sort),legend(order(1 "Poor1" 2 "Poor2" 3 "Rich1" 4 "Rich2")  position(1) ring(0)) ytitle(WTP($)) xtitle(Date) xline(20240, lpattern(dash)) xlabel(, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1.5)
// graph export "Y:\agrajg\Research\Paper1_demand_stata\61_01_Willingness_to_Pay_by_nbhd_group_over_time_StatenIsland.png", width(1600) replace
// graph export "Z:\Paper1_Output\61_01_Willingness_to_Pay_by_nbhd_group_over_time_StatenIsland.png", width(1600) replace
restore
capture drop WTP_q0
capture drop WTP_q1
capture drop WTP_q2
capture drop WTP_q3
capture drop WTP_q4
capture drop WTP_q5
capture drop WTP_q6
capture drop WTP_q7
capture drop WTP_q8
capture drop WTP_q9
capture drop WTP_q10
*===============================================================================

preserve
gen sum_var = CS_exist_actual

keep if year == 2015 | year == 2016
collapse (sum) sum_var , by (propertyid year listingtype propertytype borough nbhd_group nbhd)
foreach var of varlist nbhd nbhd_group borough propertytype listingtype {
	rename `var' temp_`var'
	decode temp_`var' , gen(`var')
	drop temp_`var'
}

capture drop ltype*
tab listingtype , gen (ltype)

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


foreach var of varlist ltype* ptype* ntype* btype* {
	replace `var' = . if `var' == 0
	capture drop sum_var_`var'
	gen double sum_var_`var' = sum_var*`var'
	drop `var'
}


*All rentals
label var sum_var "All rentals"
*Listingtype
label var sum_var_ltype1 "Entire Home/Apartment"
label var sum_var_ltype2 "Private Room"
label var sum_var_ltype3 "Shared Room"
*Propertytype
label var sum_var_ptype1 "Apartment/Condominium/Loft/Townhouse"
label var sum_var_ptype2 "House"
label var sum_var_ptype3 "Bungalow/Castle/Guesthouse/Vacation home/Villa"
label var sum_var_ptype4 "Boat/Cabin/Camper/RV/Hut/Lighthouse/Plane/Treehouse"
* Neighborhood
* Bronx
label var sum_var_btype1 "All Bronx"
label var sum_var_ntype1 "Melrose, Mott Haven, Port Morris"
label var sum_var_ntype2 "Concourse, High Bridge"
label var sum_var_ntype3 "Fieldston, Riverdale, Kingsbridge Heights"
label var sum_var_ntype4 "Wakefield, Eastchester, Edenwald, Baychester"
*Brooklyn
label var sum_var_btype2 "All Brooklyn"
label var sum_var_ntype5 "East New York, Highland Park, New Lots, Starrett City"
label var sum_var_ntype6 "Brownsville, Ocean Hill"
label var sum_var_ntype7 "Cobble Hill, Carroll Gardens, Red Hook, Park Slope"
label var sum_var_ntype8 "Greenpoint, Williamsburg"
*Manhattan
label var sum_var_btype3 "All Manhattan"
label var sum_var_ntype9 "Harlem"
label var sum_var_ntype10 "Inwood, Washington Heights"
label var sum_var_ntype11 "Financial District, Battery Park, Tribeca"
label var sum_var_ntype12 "East Side, NoHo, Chinatown"
*Queens
label var sum_var_btype4 "All Queens"
label var sum_var_ntype13 "Jackson Heights, North Corona"
label var sum_var_ntype14 "Elmhurst, Corona, Lefrac City"
label var sum_var_ntype15 "Rego Park, Forest Hills"
label var sum_var_ntype16 "Kew Gardens, Richmond Hill, Wood Haven"
*Staten Island
label var sum_var_btype5 "All Staten Island"

*2015
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_Consumer_Surplus_Actual" if year == 2015 , sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015) /// 
	groupvar(	/// 
				sum_var ///
				\textbf{Space-Type} sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				\textbf{Property-Type} sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				\textbf{Location} ///
				 sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				 sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				 sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				 sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				 sum_var_btype5 ///
			) /// 
	keep(		///
				sum_var ///
				sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				sum_var_btype5 ///
			) label tex(frag pr) replace
outreg2 using "Z:\Paper1_Output\61_01_Consumer_Surplus_Actual" if year == 2015 , sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015) /// 
	groupvar(	/// 
				sum_var ///
				\textbf{Space-Type} sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				\textbf{Property-Type} sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				\textbf{Location} ///
				 sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				 sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				 sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				 sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				 sum_var_btype5 ///
			) /// 
	keep(		///
				sum_var ///
				sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				sum_var_btype5 ///
			) label tex(frag pr) replace

*2016
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\61_01_Consumer_Surplus_Actual" if year == 2016 , sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016) /// 
	groupvar(	/// 
				sum_var ///
				\textbf{Space-Type} sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				\textbf{Property-Type} sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				\textbf{Location} ///
				 sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				 sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				 sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				 sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				 sum_var_btype5 ///
			) /// 
	keep(		///
				sum_var ///
				sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				sum_var_btype5 ///
			) label tex(frag pr) 
outreg2 using "Z:\Paper1_Output\61_01_Consumer_Surplus_Actual" if year == 2016 , sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016) /// 
	groupvar(	/// 
				sum_var ///
				\textbf{Space-Type} sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				\textbf{Property-Type} sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				\textbf{Location} ///
				 sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				 sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				 sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				 sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				 sum_var_btype5 ///
			) /// 
	keep(		///
				sum_var ///
				sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				sum_var_btype5 ///
			) label tex(frag pr) 
			
// sum_var ///
// sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
// sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
// sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
// sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
// sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
// sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
// sum_var_btype5 ///
			
restore




