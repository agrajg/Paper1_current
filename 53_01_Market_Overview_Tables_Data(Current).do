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
* Number of days of renting

global STATS_VALUE date
global STATS count
global STATS_NAME "rsd"
global STATS_NAME_LABEL "Rental Supply (Days)"
global FILE_NAME "Y:\agrajg\Research\Paper1_demand_stata\53_01_Table_Data_Rental_Supply_Days.dta"
do "Y:\agrajg\Research\Paper1_demand_stata\00_00_By_property_table_data_creator.do"

gen double date_booked = 1 if demand == 1
global STATS_VALUE date_booked
global STATS count
global STATS_NAME "rbd"
global STATS_NAME_LABEL "Rental Booked (Days)"
global FILE_NAME "Y:\agrajg\Research\Paper1_demand_stata\53_01_Table_Data_Rental_Booked_Days.dta"
do "Y:\agrajg\Research\Paper1_demand_stata\00_00_By_property_table_data_creator.do"
drop date_booked

*===============================================================================


