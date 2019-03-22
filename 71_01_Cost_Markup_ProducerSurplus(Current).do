
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
use "13_03_Computed_WTP_Welfare.dta", clear
drop if price > 10000 & price != .
timer off 1
timer list
keep if proddum ==1
*===============================================================================
preserve
capture drop sum_sales
bys date: egen sum_sales = sum(pqd)
capture drop sales_weight
gen double sales_weight = pqd/sum_sales

capture drop markup
gen double markup = ((adj_price_per_person - mc)/adj_price_per_person)*sales_weight*100

*-------------------------------------------------------------------------------

collapse 	(count) count_propertyid = propertyid ///
			(mean) mean_mc = mc ///
			(sum) mean_markup = markup ///
			(mean) mean_PS_exist_actual = PS_exist_actual ///
			(sum) sum_PS_exist_actual = PS_exist_actual ///
			, by (date)

gen year = year(date)
gen month = month(date)
gen week=week(date)
gen dow = dow(date)
bys year month: egen maxwom = max(week)
gen usopenstartdate = date if month ==8 & maxwom==week & dow==1
carryforward usopenstartdate ,replace
gen usopendummy = (date - usopenstartdate < 14)


twoway (scatter count_propertyid date, sort) (lfit count_propertyid date) (scatter count_propertyid date if ((week == 52)|(usopendummy==1)) , sort mcolor(gray) msize(large) msymbol(circle_hollow)), ytitle(Number of rentals) ylabel(#5, ticks) xtitle(Date) xlabel(#10, grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\71_01_count_propertyid_all.png", width(1600) replace
graph export "Z:\Paper1_Output\71_01_count_propertyid_all.png", width(1600) replace

twoway (scatter mean_mc date, sort) (lfit mean_mc date) (scatter mean_mc date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msize(large) msymbol(circle_hollow)), ytitle(Average Marginal Cost ($)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\71_01_mean_mc_all.png", width(1600) replace
graph export "Z:\Paper1_Output\71_01_mean_mc_all.png", width(1600) replace

twoway (scatter mean_markup date, sort) (lfit mean_markup date) (scatter mean_markup date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msize(large) msymbol(circle_hollow)), ytitle(Average Markup (%)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\71_01_mean_markup_all.png", width(1600) replace
graph export "Z:\Paper1_Output\71_01_mean_markup_all.png", width(1600) replace

twoway (scatter mean_PS_exist_actual date, sort) (lfit mean_PS_exist_actual date) (scatter mean_PS_exist_actual date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msize(large) msymbol(circle_hollow)), ytitle(Average Producer Surplus ($)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)	
graph export "Y:\agrajg\Research\Paper1_demand_stata\71_01_mean_PS_exist_actual_all.png", width(1600) replace
graph export "Z:\Paper1_Output\71_01_mean_PS_exist_actual_all.png", width(1600) replace


replace sum_PS_exist_actual = sum_PS_exist_actual/1000000
twoway (scatter sum_PS_exist_actual date, sort) (lfit sum_PS_exist_actual date) (scatter sum_PS_exist_actual date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msize(large) msymbol(circle_hollow)), ytitle(Total Producer Surplus (1M $)) ylabel(#5, ticks) xtitle(Date) xlabel(#10, grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\71_01_sum_PS_exist_actual_all.png", width(1600) replace
graph export "Z:\Paper1_Output\71_01_sum_PS_exist_actual_all.png", width(1600) replace

restore
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------

preserve
keep if proddum ==1
capture drop sum_sales
bys propertyid: egen sum_sales = sum(pqd)
capture drop sales_weight
gen double sales_weight = pqd/sum_sales

capture drop markup
gen double markup = ((adj_price_per_person - mc)/adj_price_per_person)*sales_weight*100


collapse 	(mean) varmean_mc = mc ///
			(sum) varmean_markup = markup ///
			(mean) varmean_PS_exist_actual = PS_exist_actual ///
			(sum) varsum_PS_exist_actual = PS_exist_actual ///
			, by (propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd)

replace varsum_PS_exist_actual = varsum_PS_exist_actual/1000
			
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
label var var_btype5 "Staten Island"


outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_markup_MC_table" if var_name == "mean_markup" , sum(log) eqkeep(mean sd) cttop("Markup (\%)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_markup_MC_table" if var_name == "mean_markup" & purged_rental_dummy ==1 , sum(log) eqkeep(mean sd) cttop("Markup (\%)" , "Purged Rentals") /// 
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
			
		
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_markup_MC_table" if var_name == "mean_mc"  , sum(log) eqkeep(mean sd) cttop("Marginal Cost (USD)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_markup_MC_table" if var_name == "mean_mc" & purged_rental_dummy ==1 , sum(log) eqkeep(mean sd) cttop("Marginal Cost (USD)" , "Purged Rentals") /// 
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
			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_markup_MC_table" if var_name == "mean_markup" , sum(log) eqkeep(mean sd) cttop("Markup (\%)" , "All") /// 
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

			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_Producer_Profit_Surplus_table" if var_name == "mean_PS_exist_actual" , sum(log) eqkeep(mean sd) cttop("Average Profits (USD)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_Producer_Profit_Surplus_table" if var_name == "mean_PS_exist_actual" & purged_rental_dummy ==1 , sum(log) eqkeep(mean sd) cttop("Average Profits (USD)" , "Purged Rentals") /// 
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
			
		
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_Producer_Profit_Surplus_table" if var_name == "sum_PS_exist_actual"  , sum(detail) eqkeep(sum sd) cttop("Total Profits (USD)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_Producer_Profit_Surplus_table" if var_name == "sum_PS_exist_actual" & purged_rental_dummy ==1 , sum(detail) eqkeep(sum sd) cttop("Total Profits (USD)" , "Purged Rentals") /// 
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
			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_Producer_Profit_Surplus_table" if var_name == "sum_PS_exist_actual" , sum(detail) eqkeep(sum sd) cttop("Markup (\%)" , "All") /// 
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
			
			
use "Y:\agrajg\Research\Paper1_demand_stata\71_01_markup_MC_table_dta.dta" , clear
drop in 1
texsave v1 v6 v7 v8 v9 v2 v3 v4 v5 using "Y:\agrajg\Research\Paper1_demand_stata\71_01_markup_MC_table_dta_format" , replace nofix title("\textsc{Markup and Marginal Cost Across Rentals}") marker("Table:71_01_markup_MC_table_dta_format") size("footnotesize") width("\textwidth") location("t") autonumber hlines(2 5 9 14) frag nonames footnote("Notes: The reported markups are sales wieghted averages." , size("footnotesize"))
copy "Y:\agrajg\Research\Paper1_demand_stata\71_01_markup_MC_table_dta_format.tex" "Z:\Paper1_Output\71_01_markup_MC_table_dta_format.tex" , replace

use "Y:\agrajg\Research\Paper1_demand_stata\71_01_Producer_Profit_Surplus_table_dta.dta" , clear
drop in 1
texsave v1 v2 v3 v4 v5 v6 v7 v8 v9  using "Y:\agrajg\Research\Paper1_demand_stata\71_01_Producer_Profit_Surplus_table_dta_format" , replace nofix title("\textsc{Profit and Producer Surplus Across Rentals}") marker("Table:71_01_Producer_Profit_Surplus_table_dta_format") size("footnotesize") width("\textwidth") location("t") autonumber hlines(2 5 9 14) frag nonames footnote("Notes: " , size("footnotesize"))
copy "Y:\agrajg\Research\Paper1_demand_stata\71_01_Producer_Profit_Surplus_table_dta_format.tex" "Z:\Paper1_Output\71_01_Producer_Profit_Surplus_table_dta_format.tex" , replace


restore


*===============================================================================
*===============================================================================


