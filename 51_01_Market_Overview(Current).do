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
* Number of days in the panel
preserve
contract date
count
restore
*-------------------------------------------------------------------------------
* Number of hosts that appeared on Airbnb
preserve
contract hostid
count if hostid !=.
restore
*-------------------------------------------------------------------------------
* Number if rentals that appeared on Airbnb
preserve
contract propertyid
count if propertyid !=.
restore
*-------------------------------------------------------------------------------

* Total number of hosts and rentals in each market
preserve
collapse (count) count_rentals = propertyid , by (hostid date)
collapse (count) count_hosts = hostid (sum) count_rentals , by (date)
gen year = year(date)
gen month = month(date)
gen week=week(date)
gen dow = dow(date)
bys year month: egen maxwom = max(week)
gen usopenstartdate = date if month ==8 & maxwom==week & dow==1
carryforward usopenstartdate ,replace
gen usopendummy = (date - usopenstartdate < 14)
replace count_rentals =count_rentals / 1000
replace count_hosts = count_hosts / 1000
twoway (scatter count_rentals date, sort) (lfit count_rentals date) (scatter count_rentals date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msize(large) msymbol(circle_hollow)) (scatter count_hosts date, sort msymbol(square_hollow)) (lfit count_hosts date) (scatter count_hosts date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msize(large) msymbol(square_hollow)),  xline(20393, lpattern(vshortdash)) ytitle("Count (1000 Rentals)") xtitle(Date) xlabel(#10, grid) legend(on order(1 "Rental" 4 "Host") size(medium) position(10) ring(0)) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\51_01_count_propertyid_hostid_all.png", width(1600) replace
graph export "Z:\Paper1_Output\51_01_count_propertyid_hostid_all.png", width(1600) replace
restore
*-------------------------------------------------------------------------------

* Capacity total and booked and available
preserve
collapse (sum) sum_capacity = capacity , by (date demand)
reshape wide sum_capacity , i( date ) j( demand )
gen total_capacity = sum_capacity0 + sum_capacity1
gen year = year(date)
gen month = month(date)
gen week=week(date)
gen dow = dow(date)
bys year month: egen maxwom = max(week)
gen usopenstartdate = date if month ==8 & maxwom==week & dow==1
carryforward usopenstartdate ,replace
gen usopendummy = (date - usopenstartdate < 14)
replace total_capacity = total_capacity/1000
replace sum_capacity1 = sum_capacity1/1000
twoway (scatter total_capacity date, sort msymbol(smcircle_hollow)) (scatter total_capacity date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msymbol(circle_hollow)) (scatter sum_capacity1 date, sort msymbol(smsquare_hollow)) (scatter sum_capacity1 date if ((week == 52)|(usopendummy==1)), sort mcolor(gray) msymbol(square_hollow)), xline(20393, lpattern(vshortdash)) ytitle(Capacity (1000 persons)) xtitle(Date) xlabel(#10, grid) legend(on order(1 "Total" 3 "Booked") size(medium) position(10) ring(0)) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\51_01_sum_capacity.png", width(1600) replace
graph export "Z:\Paper1_Output\51_01_sum_capacity.png", width(1600) replace
restore
*-------------------------------------------------------------------------------

* Table for rented days capacity and occumancy
preserve

collapse 	(count) vardays_operation = demand ///
			(sum) vardays_booked = demand ///
			(mean) varmean_capacity_op = capacity ///
			(sum) varsum_capacity_op = capacity ///
			, by (propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd)

capture drop varoccupancy
gen varoccupancy = 100 * vardays_booked / vardays_operation
			
reshape long var, i(propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd) j(var_name) s
tab var_name

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


outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_Number_of_rentals" if var_name == "days_operation" , sum(log) eqkeep(N mean) cttop("Number of Rentals" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_Number_of_rentals" if var_name == "days_operation" & purged_rental_dummy ==1 , sum(log) eqkeep(N mean) cttop("Number of Rentals" , "Purged Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_Number_of_rentals" if var_name == "days_operation" , sum(log) eqkeep(N mean) cttop("Number of Rentals" , "All Rentals") /// 
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
			) label  dta
			
			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy" if var_name == "days_operation" , sum(log) eqkeep(mean sd) cttop("Operation (Days)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy" if var_name == "days_operation" & purged_rental_dummy ==1 , sum(log) eqkeep(mean sd) cttop("Operation (Days)" , "Purged Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy" if var_name == "mean_capacity_op" , sum(log) eqkeep(mean sd) cttop("Operation (Capacity)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy" if var_name == "mean_capacity_op"  & & purged_rental_dummy ==1  , sum(log) eqkeep(mean sd) cttop("Operation (Capacity)" , "Purged Rentals") /// 
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

		
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy" if var_name == "occupancy"  , sum(log) eqkeep(mean sd) cttop("Occupancy ($\%$)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy" if var_name == "occupancy" & purged_rental_dummy ==1 , sum(log) eqkeep(mean sd) cttop("Occupancy ($\%$)" , "Purged Rentals") /// 
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
			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy" if var_name == "occupancy"  , sum(log) eqkeep(mean sd) cttop("Occupancy ($\%$)" , "All Rentals") /// 
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
			
use "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy_dta.dta" , clear
drop in 1
texsave v1-v13 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy_dta_format" , replace nofix title("\textsc{Opeartion and Occupancy Across Rentals}") marker("Table:51_01_operation_occupancy_dta_format") size("footnotesize") width("\textwidth") location("tph") autonumber hlines(2 5 9 14) frag nonames footnote("Notes: " , size("footnotesize"))
copy "Y:\agrajg\Research\Paper1_demand_stata\51_01_operation_occupancy_dta_format.tex" "Z:\Paper1_Output\51_01_operation_occupancy_dta_format.tex" , replace



use "Y:\agrajg\Research\Paper1_demand_stata\51_01_Number_of_rentals_dta.dta" , clear
drop in 1
texsave v1 v2 v4 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_Number_of_rentals_dta_format" , replace nofix title("\textsc{Rentals}") marker("Table:51_01_Number_of_rentals_dta_format") size("footnotesize") width("\textwidth") location("tph") autonumber hlines(2 5 9 14) frag nonames footnote("Notes: " , size("footnotesize"))
copy "Y:\agrajg\Research\Paper1_demand_stata\51_01_Number_of_rentals_dta_format.tex" "Z:\Paper1_Output\51_01_Number_of_rentals_dta_format.tex" , replace


restore
*-------------------------------------------------------------------------------
* Table for prices , daily average revenue and total revenue.
preserve

capture drop revenue
gen double revenue = adj_price_per_person * qdemand 

collapse 	(mean) varmeanprice = adj_price_per_person ///
			(mean) varmeanrevenue = revenue ///
			(sum) varsumrevenue = revenue ///
			, by (propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd)


replace varsumrevenue	 = varsumrevenue/1000000
			
reshape long var, i(propertyid purged_rental_dummy listingtype propertytype borough nbhd_group nbhd) j(var_name) s
tab var_name

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


outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue" if var_name == "meanprice" , sum(log) eqkeep(mean sd) cttop("Price (USD)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue" if var_name == "meanprice" & purged_rental_dummy ==1 , sum(log) eqkeep(mean sd) cttop("Price (USD)" , "Purged Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue" if var_name == "meanrevenue" , sum(log) eqkeep(mean sd) cttop("Daily Revenue (USD)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue" if var_name == "meanrevenue"  & & purged_rental_dummy ==1  , sum(log) eqkeep(mean sd) cttop("Daily Revenue (USD)" , "Purged Rentals") /// 
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

		
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue" if var_name == "sumrevenue"  , sum(detail) eqkeep(sum sd) cttop("Total Revenue (1M USD)" , "All Rentals") /// 
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

outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue" if var_name == "sumrevenue" & purged_rental_dummy ==1 , sum(detail) eqkeep(sum sd) cttop("Total Revenue (1M USD)" , "Purged Rentals") /// 
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
			
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue" if var_name == "sumrevenue"  , sum(detail) eqkeep(sum sd) cttop("Total Revenue (1M USD)"  , "All Rentals") /// 
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
			
use "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue_dta.dta" , clear
drop in 1
texsave v1-v9 v10 v12 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue_dta_format" , replace nofix title("\textsc{Price and Revenue Across Rentals}") marker("Table:51_01_price_revenue_dta_format") size("footnotesize") width("\textwidth") location("tph") autonumber hlines(2 5 9 14) frag nonames footnote("Notes: " , size("footnotesize"))
copy "Y:\agrajg\Research\Paper1_demand_stata\51_01_price_revenue_dta_format.tex" "Z:\Paper1_Output\51_01_price_revenue_dta_format.tex" , replace

restore
*-------------------------------------------------------------------------------

preserve
keep if proddum == 1
collapse 	(mean) mean_adj_ppp = adj_price_per_person ///
			(sd) sd_adj_ppp = adj_price_per_person ///
			(p5) p05_adj_ppp = adj_price_per_person ///
			(p25) p25_adj_ppp = adj_price_per_person ///
			(p50) p50_adj_ppp = adj_price_per_person ///
			(p75) p75_adj_ppp = adj_price_per_person ///
			(p95) p95_adj_ppp = adj_price_per_person ///
			(sum) market_quantity = qdemand ///
			(sum) supply_quantity = capacity ///
			, by (date)


twoway (line p50_adj_ppp date, sort) (line p25_adj_ppp date, lpattern(dash)) (line p75_adj_ppp date, sort lpattern(dash)) (line p05_adj_ppp date, lpattern(dash_dot)) (line p95_adj_ppp date, sort lpattern(dash_dot)), ytitle(Price per person ($)) xtitle(Date) xline(20393, lpattern(shortdash_dot)) xlabel(#10, grid) legend(on order(1 "Median" 2 "First/Third Quartile" 4 "5/95 th percentile") cols(2) position(1) ring(0)) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\51_01_median_adj_ppp.png", width(1600) replace
graph export "Z:\Paper1_Output\51_01_median_adj_ppp.png", width(1600) replace


gen frac = 100 * market_quantity / supply_quantity
twoway (scatter frac date, sort) (lfit frac date), ytitle(Capacity (Number of persons) booked) xtitle(Date) xline(20393, lpattern(shortdash_dot)) xlabel(#10, grid) legend(off) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\51_01_sum_capacity_booked_frac.png", width(1600) replace
graph export "Z:\Paper1_Output\51_01_sum_capacity_booked_frac.png", width(1600) replace


restore

*===============================================================================
preserve
keep if proddum == 1
gen revenue = adj_price * demand
collapse (count) count_rentals= propertyid (sum) total_revenue = revenue , by (hostid  date)
bys date : egen sum_count_rentals = sum (count_rentals)
bys date : egen sum_total_revenue = sum (total_revenue)
gen share_count_rental = 100 * count_rentals/ sum_count_rentals
gen share_total_revenue = 100 * total_revenue/ sum_total_revenue
save "51_01_For_industry_concentration.dta", replace
*-------------------------------------------------------------------------------
*use "51_01_For_industry_concentration.dta", clear 
*gsort date -count_rentals
*by date : gen obs = _n
*keep if obs <=4
*collapse (sum) share_count_rental,  by (date )
*save "51_01_top4_share_count_rental.dta", replace
*sum share_count_rental
*-------------------------------------------------------------------------------
use "51_01_For_industry_concentration.dta", clear 
gsort date -total_revenue
by date : gen obs = _n
keep if obs <=4
collapse (sum) share_total_revenue,  by (date )
*save "51_01_top4_share_total_revenue.dta", replace
// twoway (line share_total_revenue date, sort), ytitle(Share (%)) xtitle(Date) xline(20240, lpattern(dash)) xlabel(, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1)
twoway (line share_total_revenue date, sort), ytitle(Share (%)) xtitle(Date) xline(20393, lpattern(vshortdash)) xlabel(#10, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\51_01_top4_revenue_share.png", width(1600) replace
graph export "Z:\Paper1_Output\51_01_top4_revenue_share.png", width(1600) replace
sum share_total_revenue
*-------------------------------------------------------------------------------
use "51_01_For_industry_concentration.dta", clear 
gen share_count_rental_sq = share_count_rental* share_count_rental
gen share_total_revenue_sq =share_total_revenue* share_total_revenue
collapse (sum) HHI_count_rental = share_count_rental_sq HHI_total_revenue = share_total_revenue_sq,  by (date )
sum HHI_count_rental HHI_total_revenue, det 
// twoway (line HHI_total_revenue date, sort), ytitle(HHI) xtitle(Date) xline(20240, lpattern(dash)) xlabel(, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1)
twoway (line HHI_total_revenue date, sort), ytitle(HHI) xtitle(Date) xline(20393, lpattern(vshortdash)) xlabel(#10, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\51_01_HHI_revenue_share.png", width(1600) replace
graph export "Z:\Paper1_Output\51_01_HHI_revenue_share.png", width(1600) replace
*-------------------------------------------------------------------------------
erase "51_01_For_industry_concentration.dta"
*-------------------------------------------------------------------------------
restore
*-------------------------------------------------------------------------------
preserve
sort propertyid date
by propertyid : gen lastdatedum = (_n==_N & purged_rental_dummy ==1)
sort date propertyid
collapse (sum) lastdatedum ,by(date)
capture drop lostrental
gen lostrental = lastdatedum if _n==1
replace lostrental = lostrental[_n-1] + lastdatedum if _n>1
replace lostrental = lostrental /1000
twoway (line lostrental date, sort), ytitle("Count (1000 Rentals)") xtitle(Date) xline(20393, lpattern(shortdash)) xlabel(#10, grid) scheme(tufte) xsize(5) ysize(1.5) scale(1.2)
graph export "Y:\agrajg\Research\Paper1_demand_stata\51_01_Rentals_purged_overtime.png", width(1600) replace
graph export "Z:\Paper1_Output\51_01_Rentals_purged_overtime.png", width(1600) replace
restore
*-------------------------------------------------------------------------------

/*
preserve
keep if year == 2015 | year == 2016
collapse (count) daysrentalsupplied = date (sum)daysrentalbooked = demand (sum) capactyrentalsupplied = capacity (sum) capactyrentalbooked = qdemand, by (propertyid year listingtype propertytype borough nbhd_group nbhd)
format %9.0g daysrentalsupplied
reshape long daysrental capactyrental , i( propertyid nbhd nbhd_group borough year propertytype listingtype ) j(status) s

label var daysrental "Days (All rentals)"
label var capactyrental "Capacity (All rentals)" 

* By listing type
capture drop ltype*
tab listingtype , gen (ltype)
foreach var of varlist ltype1 ltype2 ltype3 {
replace `var' = . if `var' == 0
capture drop daysrental_`var'
capture drop capactyrental_`var'
gen daysrental_`var' = daysrental*`var'
gen capactyrental_`var' = capactyrental*`var'
drop `var'
}

label var daysrental_ltype1 "Days (EHA)"
label var capactyrental_ltype1 "Capacity (EHA)" 
label var daysrental_ltype2 "Days (PR)"
label var capactyrental_ltype2 "Capacity (PR)" 
label var daysrental_ltype3 "Days (SR)"
label var capactyrental_ltype3 "Capacity (SR)" 

* Property type

capture drop ptype*
decode propertytype , gen(ptype)
gen ptype1 = 1 if ptype =="Apartment" | ptype =="Condominium" | ptype =="Loft" | ptype =="Townhouse"
gen ptype2 = 1 if ptype =="House"
gen ptype3 = 1 if ptype =="Bungalow" | ptype =="Castle" | ptype =="Guesthouse" | ptype =="Vacation home" | ptype == "Villa"
gen ptype4 = 1 if ptype =="Boat" | ptype =="Cabin" | ptype =="Camper/RV" | ptype =="Hut" | ptype == "Lighthouse" | ptype == "Plane" | ptype == "Treehouse"
foreach var of varlist ptype1 ptype2 ptype3 ptype4 {
replace `var' = . if `var' == 0
capture drop daysrental_`var'
capture drop capactyrental_`var'
gen daysrental_`var' = daysrental*`var'
gen capactyrental_`var' = capactyrental*`var'
drop `var'
}

label var daysrental_ptype1 "Days (Apartment/Condominium/Loft/Townhouse)"
label var capactyrental_ptype1 "Capacity (Apartment/Condominium/Loft/Townhouse)" 
label var daysrental_ptype2 "Days (House)"
label var capactyrental_ptype2 "Capacity (House)" 
label var daysrental_ptype3 "Days (Bungalow/Castle/Guesthouse/Vacation home/Villa)"
label var capactyrental_ptype3 "Capacity (Bungalow/Castle/Guesthouse/Vacation home/Villa)"
label var daysrental_ptype4 "Days (Boat/Cabin/Camper/RV/Hut/Lighthouse/Plane/Treehouse)"
label var capactyrental_ptype4 "Capacity (Boat/Cabin/Camper/RV/Hut/Lighthouse/Plane/Treehouse)" 

keep 			year status ///
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
// drop listingtype
*2015
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_days_capacity_all_2015" if year == 2015 & status == "supplied", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015, Supply) /// 
	groupvar(	/// 
				\textbf{All} daysrental capactyrental /// 
				\textbf{Rental-Type} daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				\textbf{Property-Type} daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) /// 
	keep(		///
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) label tex(frag pr) replace
outreg2 using "Z:\Paper1_Output\51_01_days_capacity_all_2015" if year == 2015 & status == "supplied", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015, Supply) /// 
	groupvar( /// 
				\textbf{All} daysrental capactyrental /// 
				\textbf{Rental-Type} daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				\textbf{Property-Type} daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) /// 
	keep( /// 
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) label tex(frag pr) replace
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_days_capacity_all_2015" if year == 2015 & status == "booked", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015, Booking) /// 
	groupvar( /// 
				\textbf{All} daysrental capactyrental /// 
				\textbf{Rental-Type} daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				\textbf{Property-Type} daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) /// 
	keep( /// 
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) label tex(frag pr)
outreg2 using "Z:\Paper1_Output\51_01_days_capacity_all_2015" if year == 2015 & status == "booked", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015, Booking) /// 
	groupvar( /// 
				\textbf{All} daysrental capactyrental /// 
				\textbf{Rental-Type} daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				\textbf{Property-Type} daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///				
			) /// 
	keep( /// 
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) label tex(frag pr)

*2016
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_days_capacity_all_2016" if year == 2016 & status == "supplied", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016, Supply) /// 
	groupvar(	/// 
				\textbf{All} daysrental capactyrental /// 
				\textbf{Rental-Type} daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				\textbf{Property-Type} daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) /// 
	keep(		///
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) label tex(frag pr) replace
outreg2 using "Z:\Paper1_Output\51_01_days_capacity_all_2016" if year == 2016 & status == "supplied", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016, Supply) /// 
	groupvar( /// 
				\textbf{All} daysrental capactyrental /// 
				\textbf{Rental-Type} daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				\textbf{Property-Type} daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) /// 
	keep( /// 
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) label tex(frag pr) replace
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_days_capacity_all_2016" if year == 2016 & status == "booked", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016, Booking) /// 
	groupvar( /// 
				\textbf{All} daysrental capactyrental /// 
				\textbf{Rental-Type} daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				\textbf{Property-Type} daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) /// 
	keep( /// 
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) label tex(frag pr)
outreg2 using "Z:\Paper1_Output\51_01_days_capacity_all_2016" if year == 2016 & status == "booked", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016, Booking) /// 
	groupvar( /// 
				\textbf{All} daysrental capactyrental /// 
				\textbf{Rental-Type} daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				\textbf{Property-Type} daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) /// 
	keep( /// 
				daysrental capactyrental /// 
				daysrental_ltype1 capactyrental_ltype1 daysrental_ltype2 capactyrental_ltype2 daysrental_ltype3 capactyrental_ltype3 ///
				daysrental_ptype1 capactyrental_ptype1 daysrental_ptype2 capactyrental_ptype2 daysrental_ptype3 capactyrental_ptype3 daysrental_ptype4 capactyrental_ptype4 ///
			) label tex(frag pr)

restore


preserve
keep if year == 2015 | year == 2016
collapse (count) daysrentalsupplied = date (sum)daysrentalbooked = demand (sum) capactyrentalsupplied = capacity (sum) capactyrentalbooked = qdemand, by (propertyid year listingtype propertytype borough nbhd_group nbhd)
format %9.0g daysrentalsupplied
reshape long daysrental capactyrental , i( propertyid nbhd nbhd_group borough year propertytype listingtype ) j(status) s
label var daysrental "Days (All rentals)"
label var capactyrental "Capacity (All rentals)" 


capture drop ntype*
gen ntype1 = 1 if borough ==1 & nbhd_group==1
gen ntype2 = 1 if borough ==1 & nbhd_group==4
gen ntype3 = 1 if borough ==1 & nbhd_group==8
gen ntype4 = 1 if borough ==1 & nbhd_group==12

gen ntype5 = 1 if borough ==2 & nbhd_group==5
gen ntype6 = 1 if borough ==2 & nbhd_group==16
gen ntype7 = 1 if borough ==2 & nbhd_group==6
gen ntype8 = 1 if borough ==2 & nbhd_group==1

gen ntype9 = 1 if borough ==3 & nbhd_group==11
gen ntype10 = 1 if borough ==3 & nbhd_group==12
gen ntype11 = 1 if borough ==3 & nbhd_group==1
gen ntype12 = 1 if borough ==3 & nbhd_group==3

gen ntype13 = 1 if borough ==4 & nbhd_group==3
gen ntype14 = 1 if borough ==4 & nbhd_group==4
gen ntype15 = 1 if borough ==4 & nbhd_group==6
gen ntype16 = 1 if borough ==4 & nbhd_group==9

gen btype1 = 1 if borough ==1
gen btype2 = 1 if borough ==2
gen btype3 = 1 if borough ==3
gen btype4 = 1 if borough ==4
gen btype5 = 1 if borough ==5


foreach var of varlist ntype* btype* {
	replace `var' = . if `var' == 0
	capture drop daysrental_`var'
	capture drop capactyrental_`var'
	gen daysrental_`var' = daysrental*`var'
	gen capactyrental_`var' = capactyrental*`var'
	drop `var'
}


* Bronx
label var daysrental_btype1 "Days (All Bronx)"
label var capactyrental_btype1 "Capacity (All Bronx)"
label var daysrental_ntype1 "Days (Melrose, Mott Haven, Port Morris)"
label var capactyrental_ntype1 "Capacity (Melrose, Mott Haven, Port Morris)"
label var daysrental_ntype2 "Days (Concourse, High Bridge)"
label var capactyrental_ntype2 "Capacity (Concourse, High Bridge)"
label var daysrental_ntype3 "Days (Fieldston, Riverdale, Kingsbridge Heights)"
label var capactyrental_ntype3 "Capacity (Fieldston, Riverdale, Kingsbridge Heights)"
label var daysrental_ntype4 "Days (Wakefield, Eastchester, Edenwald, Baychester)"
label var capactyrental_ntype4 "Capacity (Wakefield, Eastchester, Edenwald, Baychester)"
*Brooklyn
label var daysrental_btype2 "Days (All Brooklyn)"
label var capactyrental_btype2 "Capacity (All Brooklyn)"
label var daysrental_ntype5 "Days (East New York, Highland Park, New Lots, Starrett City)"
label var capactyrental_ntype5 "Capacity (East New York, Highland Park, New Lots, Starrett City)"
label var daysrental_ntype6 "Days (Brownsville, Ocean Hill)"
label var capactyrental_ntype6 "Capacity (Brownsville, Ocean Hill)"
label var daysrental_ntype7 "Days (Cobble Hill, Carroll Gardens, Red Hook, Park Slope)"
label var capactyrental_ntype7 "Capacity (Cobble Hill, Carroll Gardens, Red Hook, Park Slope)"
label var daysrental_ntype8 "Days (Greenpoint, Williamsburg)"
label var capactyrental_ntype8 "Capacity (Greenpoint, Williamsburg)"
*Manhattan
label var daysrental_btype2 "Days (All Manhattan)"
label var capactyrental_btype2 "Capacity (All Manhattan)"
label var daysrental_ntype9 "Days (Harlem)"
label var capactyrental_ntype9 "Capacity (Harlem)"
label var daysrental_ntype10 "Days (Inwood, Washington Heights)"
label var capactyrental_ntype10 "Capacity (Inwood, Washington Heights)"
label var daysrental_ntype11 "Days (Financial District, Battery Park, Tribeca)"
label var capactyrental_ntype11 "Capacity (Financial District, Battery Park, Tribeca)"
label var daysrental_ntype12 "Days (East Side, NoHo, Chinatown)"
label var capactyrental_ntype12 "Capacity (East Side, NoHo, Chinatown)"
*Queens
label var daysrental_btype2 "Days (All Queens)"
label var capactyrental_btype2 "Capacity (All Queens)"
label var daysrental_ntype13 "Days (Jackson Heights, North Corona)"
label var capactyrental_ntype13 "Capacity (Jackson Heights, North Corona)"
label var daysrental_ntype14 "Days (Elmhurst, Corona, Lefrac City)"
label var capactyrental_ntype14 "Capacity (Elmhurst, Corona, Lefrac City)"
label var daysrental_ntype15 "Days (Rego Park, Forest Hills)"
label var capactyrental_ntype15 "Capacity (Rego Park, Forest Hills)"
label var daysrental_ntype16 "Days (Kew Gardens, Richmond Hill, Wood Haven)"
label var capactyrental_ntype16 "Capacity (Kew Gardens, Richmond Hill, Wood Haven)"
*Staten Island
label var daysrental_btype2 "Days (All Staten Island)"
label var capactyrental_btype2 "Capacity (All Staten Island)"


keep 			year status ///
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
// drop listingtype
*2015
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_days_capacity_by_nbhd_2015" if year == 2015 & status == "supplied", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015, Supply) /// 
	groupvar(	/// 
				\textbf{Bronx} daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				\textbf{Brooklyn} daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				\textbf{Manhattan} daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				\textbf{Queens} daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				\textbf{Staten-Island} daysrental_btype5 capactyrental_btype5 ///
			) /// 
	keep(		///
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
			) label tex(frag pr) replace
outreg2 using "Z:\Paper1_Output\51_01_days_capacity_by_nbhd_2015" if year == 2015 & status == "supplied", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015, Supply) /// 
	groupvar( /// 
				\textbf{Bronx} daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				\textbf{Brooklyn} daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				\textbf{Manhattan} daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				\textbf{Queens} daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				\textbf{Staten-Island} daysrental_btype5 capactyrental_btype5 ///
			) /// 
	keep( /// 
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
			) label tex(frag pr) replace
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_days_capacity_by_nbhd_2015" if year == 2015 & status == "booked", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015, Booking) /// 
	groupvar( /// 
				\textbf{Bronx} daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				\textbf{Brooklyn} daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				\textbf{Manhattan} daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				\textbf{Queens} daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				\textbf{Staten-Island} daysrental_btype5 capactyrental_btype5 ///
			) /// 
	keep( /// 
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
			) label tex(frag pr)
outreg2 using "Z:\Paper1_Output\51_01_days_capacity_by_nbhd_2015" if year == 2015 & status == "booked", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015, Booking) /// 
	groupvar( /// 
				\textbf{Bronx} daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				\textbf{Brooklyn} daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				\textbf{Manhattan} daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				\textbf{Queens} daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				\textbf{Staten-Island} daysrental_btype5 capactyrental_btype5 ///
			) /// 
	keep( /// 
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
			) label tex(frag pr)

*2016
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_days_capacity_by_nbhd_2016" if year == 2016 & status == "supplied", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016, Supply) /// 
	groupvar(	/// 
				\textbf{Bronx} daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				\textbf{Brooklyn} daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				\textbf{Manhattan} daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				\textbf{Queens} daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				\textbf{Staten-Island} daysrental_btype5 capactyrental_btype5 ///
			) /// 
	keep(		///
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
			) label tex(frag pr) replace
outreg2 using "Z:\Paper1_Output\51_01_days_capacity_by_nbhd_2016" if year == 2016 & status == "supplied", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016, Supply) /// 
	groupvar( /// 
				\textbf{Bronx} daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				\textbf{Brooklyn} daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				\textbf{Manhattan} daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				\textbf{Queens} daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				\textbf{Staten-Island} daysrental_btype5 capactyrental_btype5 ///
			) /// 
	keep( /// 
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
			) label tex(frag pr) replace
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_days_capacity_by_nbhd_2016" if year == 2016 & status == "booked", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016, Booking) /// 
	groupvar( /// 
				\textbf{Bronx} daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				\textbf{Brooklyn} daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				\textbf{Manhattan} daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				\textbf{Queens} daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				\textbf{Staten-Island} daysrental_btype5 capactyrental_btype5 ///
			) /// 
	keep( /// 
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
			) label tex(frag pr)
outreg2 using "Z:\Paper1_Output\51_01_days_capacity_by_nbhd_2016" if year == 2016 & status == "booked", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016, Booking) /// 
	groupvar( /// 
				\textbf{Bronx} daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				\textbf{Brooklyn} daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				\textbf{Manhattan} daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				\textbf{Queens} daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				\textbf{Staten-Island} daysrental_btype5 capactyrental_btype5 ///
			) /// 
	keep( /// 
				daysrental_btype1 capactyrental_btype1 daysrental_ntype1 capactyrental_ntype1 daysrental_ntype2 capactyrental_ntype2 daysrental_ntype3 capactyrental_ntype3 daysrental_ntype4 capactyrental_ntype4 ///
				daysrental_btype2 capactyrental_btype2 daysrental_ntype5 capactyrental_ntype5 daysrental_ntype6 capactyrental_ntype6 daysrental_ntype7 capactyrental_ntype7 daysrental_ntype8 capactyrental_ntype8 ///
				daysrental_btype3 capactyrental_btype3 daysrental_ntype9 capactyrental_ntype9 daysrental_ntype10 capactyrental_ntype10 daysrental_ntype11 capactyrental_ntype11 daysrental_ntype12 capactyrental_ntype12 ///
				daysrental_btype4 capactyrental_btype4 daysrental_ntype13 capactyrental_ntype13 daysrental_ntype14 capactyrental_ntype14 daysrental_ntype15 capactyrental_ntype15 daysrental_ntype16 capactyrental_ntype16 ///
				daysrental_btype5 capactyrental_btype5 ///
			) label tex(frag pr)


			
preserve
keep if year == 2015 | year == 2016
gen sum_var = date
collapse (count) sum_var , by (propertyid year listingtype propertytype borough nbhd_group nbhd)
format %9.0g sum_var

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
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_Days_of_renting" if year == 2015 , sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015) /// 
	groupvar(	/// 
				sum_var ///
				\textbf{Space-Type} sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				\textbf{Property-Type} sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				\textbf{Location} ///
				\textit{\textbf{Bronx}} sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				\textit{\textbf{Brooklyn}} sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				\textit{\textbf{Manhattan}} sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				\textit{\textbf{Queens}} sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				\textit{\textbf{Staten-Island}} sum_var_btype5 ///
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
outreg2 using "Z:\Paper1_Output\51_01_Days_of_renting" if year == 2015 , sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015) /// 
	groupvar(	/// 
				sum_var ///
				\textbf{Space-Type} sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				\textbf{Property-Type} sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				\textbf{Location} ///
				\textit{\textbf{Bronx}} sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				\textit{\textbf{Brooklyn}} sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				\textit{\textbf{Manhattan}} sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				\textit{\textbf{Queens}} sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				\textit{\textbf{Staten-Island}} sum_var_btype5 ///
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
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\51_01_Days_of_renting" if year == 2016 , sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016) /// 
	groupvar(	/// 
				sum_var ///
				\textbf{Space-Type} sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				\textbf{Property-Type} sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				\textbf{Location} ///
				\textit{\textbf{Bronx}} sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				\textit{\textbf{Brooklyn}} sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				\textit{\textbf{Manhattan}} sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				\textit{\textbf{Queens}} sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				\textit{\textbf{Staten-Island}} sum_var_btype5 ///
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
outreg2 using "Z:\Paper1_Output\51_01_Days_of_renting" if year == 2016 , sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016) /// 
	groupvar(	/// 
				sum_var ///
				\textbf{Space-Type} sum_var_ltype1 sum_var_ltype2 sum_var_ltype3 ///
				\textbf{Property-Type} sum_var_ptype1 sum_var_ptype2 sum_var_ptype3 sum_var_ptype4 ///
				\textbf{Location} ///
				\textit{\textbf{Bronx}} sum_var_btype1 sum_var_ntype1 sum_var_ntype2 sum_var_ntype3 sum_var_ntype4 ///
				\textit{\textbf{Brooklyn}} sum_var_btype2 sum_var_ntype5 sum_var_ntype6 sum_var_ntype7 sum_var_ntype8 ///
				\textit{\textbf{Manhattan}} sum_var_btype3 sum_var_ntype9 sum_var_ntype10 sum_var_ntype11 sum_var_ntype12 ///
				\textit{\textbf{Queens}} sum_var_btype4 sum_var_ntype13 sum_var_ntype14 sum_var_ntype15 sum_var_ntype16 ///
				\textit{\textbf{Staten-Island}} sum_var_btype5 ///
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
						
					
restore

*===============================================================================
* Number of properties by borough
preserve
keep if proddum == 1
collapse (count) count_rental = propertyid ,by (borough date)
twoway (line count_rental date if borough == 1, sort) (line count_rental date if borough == 2, sort) (line count_rental date if borough == 3, sort) (line count_rental date if borough == 4) (line count_rental date if borough == 5, sort), ytitle(Number of Active Rentals) xtitle(Date) xlabel(#12, angle(forty_five) grid) legend(on order(1 "Bronx" 2 "Brooklyn" 3 "Manhattan" 4 "Queens" 5 "Staten Island") position(10) ring(0)) scheme(tufte) xsize(10) ysize(6)
restore
*===============================================================================
