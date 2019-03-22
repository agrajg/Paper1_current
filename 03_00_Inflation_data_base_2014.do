clear all
set more off
use "Y:\agrajg\Research\Paper1_demand_stata\00_00_Inflation_data_raw.dta", clear

drop half*

foreach var of varlist jan-dec{
rename `var' inf`var'
}
reshape long inf, i(year) j(month_str) s

gen month=month(date(month_str ,"M"))
gen ym = ym( year, month)
drop month_str
format %tmCCYY!mNN ym
