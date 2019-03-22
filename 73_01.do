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

global STATS_VALUE PS_exist_actual
global STATS sum
global STATS_NAME "PS"
global STATS_NAME_LABEL "Producer Surplus ($)"
global FILE_NAME "Y:\agrajg\Research\Paper1_demand_stata\73_01_Table_Data_PS.dta"
do "Y:\agrajg\Research\Paper1_demand_stata\00_00_By_property_table_data_creator.do"
