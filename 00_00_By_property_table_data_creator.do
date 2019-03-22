preserve

capture drop stats_value
gen stats_value = $STATS_VALUE
collapse ($STATS) stats_value , by (propertyid year listingtype propertytype borough nbhd_group nbhd)
format %9.0g stats_value
gen stats_name = "$STATS_NAME"
label var stats_name "$STATS_NAME_LABEL"


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


foreach var of varlist ltype* ptype* ntype* btype* {
	replace `var' = . if `var' == 0
	capture drop stats_value_`var'
	gen double stats_value_`var' = stats_value*`var'
	drop `var'
}


*All rentals
label var stats_value "All rentals"
*Listingtype
label var stats_value_ltype1 "Entire Home/Apartment"
label var stats_value_ltype2 "Private Room"
label var stats_value_ltype3 "Shared Room"
*Propertytype
label var stats_value_ptype1 "Apartment/Condominium/Loft/Townhouse"
label var stats_value_ptype2 "House"
label var stats_value_ptype3 "Bungalow/Castle/Guesthouse/Vacation home/Villa"
label var stats_value_ptype4 "Boat/Cabin/Camper/RV/Hut/Lighthouse/Plane/Treehouse"
* Neighborhood
* Bronx
label var stats_value_btype1 "All Bronx"
label var stats_value_ntype1 "Melrose, Mott Haven, Port Morris"
label var stats_value_ntype2 "Concourse, High Bridge"
label var stats_value_ntype3 "Fieldston, Riverdale, Kingsbridge Heights"
label var stats_value_ntype4 "Wakefield, Eastchester, Edenwald, Baychester"
*Brooklyn
label var stats_value_btype2 "All Brooklyn"
label var stats_value_ntype5 "East New York, Highland Park, New Lots, Starrett City"
label var stats_value_ntype6 "Brownsville, Ocean Hill"
label var stats_value_ntype7 "Cobble Hill, Carroll Gardens, Red Hook, Park Slope"
label var stats_value_ntype8 "Greenpoint, Williamsburg"
*Manhattan
label var stats_value_btype3 "All Manhattan"
label var stats_value_ntype9 "Harlem"
label var stats_value_ntype10 "Inwood, Washington Heights"
label var stats_value_ntype11 "Financial District, Battery Park, Tribeca"
label var stats_value_ntype12 "East Side, NoHo, Chinatown"
*Queens
label var stats_value_btype4 "All Queens"
label var stats_value_ntype13 "Jackson Heights, North Corona"
label var stats_value_ntype14 "Elmhurst, Corona, Lefrac City"
label var stats_value_ntype15 "Rego Park, Forest Hills"
label var stats_value_ntype16 "Kew Gardens, Richmond Hill, Wood Haven"
*Staten Island
label var stats_value_btype5 "All Staten Island"

save "$FILE_NAME", replace


restore

