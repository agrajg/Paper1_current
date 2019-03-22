* Estimating the impacat on the price and quantity.
* identifying the purged listings 
clear all
set more off
cd "Y:\agrajg\Research\Paper1_demand_stata\"
use "May25_RegInstrumentData.dta", clear
*-------------------------------------------------------------------------------
capture drop temp
gen temp = "01-pre"
replace  temp = "02-during" if date >= td(01sep2015)
replace  temp = "03-post" if date >= td(01dec2015)
encode temp, gen(purge1)

capture drop temp
gen temp = "01-pre"
replace  temp = "02-during" if date >= td(01mar2016)
replace  temp = "03-post" if date >= td(01jun2016)
encode temp, gen(purge2)

drop temp
*-------------------------------------------------------------------------------
collapse (count) Ndayslisted = date, by (propertyid purge1)
format %9.0g Ndayslisted
reshape wide Ndayslisted , i( propertyid ) j( purge1 )
foreach lname of varlist  Ndayslisted*    {
replace `lname' = 0 if `lname' == .
}
 merge 1:1 propertyid using "Y:\agrajg\Research\Paper1_demand_stata\Some_property_characteristics.dta"
keep if _merge ==3
bys hostid : gen listingperhost = _N
bys hostid listingtype  : gen listingtypeperhost = _N
capture drop temp
gen temp = "01-1listing"
replace temp = "02-23listing" if listingtypeperhost >=2
replace temp = "02-45678listing" if listingtypeperhost >=4
replace temp = "02-9pluslisting" if listingtypeperhost >=9
encode temp, gen (group_listing_count)
preserve
*-------------------------------------------------------------------------------



gen yearweek = yw(year, week)
capture drop temp
gen temp = ""
replace temp = "00p1preweek" if yearweek < 2995
replace temp = "01p1preweek12" if yearweek == 2995
replace temp = "02p1preweek11" if yearweek == 2896
replace temp = "03p1preweek10" if yearweek == 2897
replace temp = "04p1preweek09" if yearweek == 2898
replace temp = "05p1preweek08" if yearweek == 2899
replace temp = "06p1preweek07" if yearweek == 2900
replace temp = "07p1preweek06" if yearweek == 2901
replace temp = "08p1preweek05" if yearweek == 2902
replace temp = "09p1preweek04" if yearweek == 2903
replace temp = "10p1preweek03" if yearweek == 2904
replace temp = "11p1preweek02" if yearweek == 2905
replace temp = "12p1preweek01" if yearweek == 2906
replace temp = "13p1postweek00" if yearweek == 2907
replace temp = "14p1postweek01" if yearweek == 2908
replace temp = "15p1postweek02" if yearweek == 2909
replace temp = "16p1postweek03" if yearweek == 2910
replace temp = "17p1postweek04" if yearweek == 2911
replace temp = "18p1postweek05" if yearweek == 2912
replace temp = "19p1postweek06" if yearweek == 2913
replace temp = "20p1postweek07" if yearweek == 2914
replace temp = "21p1postweek08" if yearweek == 2915
replace temp = "22p1postweek09" if yearweek == 2916
replace temp = "23p1postweek10" if yearweek == 2917
replace temp = "24p1postweek11" if yearweek == 2918
replace temp = "25p1postweek12" if yearweek == 2919
replace temp = "26p1postweek" if yearweek > 2919
encode temp, gen(timingpurge1)

capture drop temp
gen temp = ""
replace temp = "00p2preweek" if yearweek < 2920
replace temp = "01p2preweek12" if yearweek == 2921
replace temp = "02p2preweek11" if yearweek == 2822
replace temp = "03p2preweek10" if yearweek == 2823
replace temp = "04p2preweek09" if yearweek == 2824
replace temp = "05p2preweek08" if yearweek == 2825
replace temp = "06p2preweek07" if yearweek == 2926
replace temp = "07p2preweek06" if yearweek == 2927
replace temp = "08p2preweek05" if yearweek == 2928
replace temp = "09p2preweek04" if yearweek == 2929
replace temp = "10p2preweek03" if yearweek == 2930
replace temp = "11p2preweek02" if yearweek == 2931
replace temp = "12p2preweek01" if yearweek == 2932
replace temp = "13p2postweek00" if yearweek == 2933
replace temp = "14p2postweek01" if yearweek == 2934
replace temp = "15p2postweek02" if yearweek == 2935
replace temp = "16p2postweek03" if yearweek == 2936
replace temp = "17p2postweek04" if yearweek == 2937
replace temp = "18p2postweek05" if yearweek == 2938
replace temp = "19p2postweek06" if yearweek == 2939
replace temp = "20p2postweek07" if yearweek == 2940
replace temp = "21p2postweek08" if yearweek == 2941
replace temp = "22p2postweek09" if yearweek == 2942
replace temp = "23p2postweek10" if yearweek == 2943
replace temp = "24p2postweek11" if yearweek == 2944
replace temp = "25p2postweek12" if yearweek == 2945
replace temp = "26p2postweek" if yearweek > 2945
encode temp, gen(timingpurge2)


capture drop temp
gen temp = ""
replace temp = "0PR" if listingtype == "Private room"
replace temp = "1SR" if listingtype == "Shared room"
replace temp = "2EHA" if listingtype == "Entire home/apt"
encode temp, gen(ltype)

egen id = group(propertyid year month)


