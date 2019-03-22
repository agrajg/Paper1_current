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
// gen double date_booked = 1 if demand == 1
global STATS_VALUE CS_exist_actual
global STATS sum
global STATS_NAME "CS_exist_actual"
global STATS_NAME_LABEL "Total Counsumer Surplus"
global FILE_NAME "Y:\agrajg\Research\Paper1_demand_stata\63_01_Table_Data_Total_Counsumer_Surplus.dta"
do "Y:\agrajg\Research\Paper1_demand_stata\00_00_By_property_table_data_creator.do"
// drop date_booked
