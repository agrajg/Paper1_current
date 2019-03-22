clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "04_03_Price_regression_ready_data.dta", clear
// keep if date >= td(15dec2016) & date < td(15jan2017)
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
keep if status =="R"
gen year = year(date)
gen week = week(date)
gen month = month(date)
gen ym = ym(year, month)
gen yw = yw(year, week)
gen dow = dow(date)
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
global ALL_CONTROLS p_age h_age p_dayshosting h_dayshosting p_daysbooked h_daysbooked p_guestcount h_guestcount i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5
// use "04_04_Price_reg_absorbed_propertyid_nbhddate.dta", clear
timer on 1
reghdfe price lprice price_per_person lprice_per_person $ALL_CONTROLS ex_*, a(propertyid#ym nbhd#date) cache(save)
timer off 1
timer list 

* Regressions
timer on 2
capture estimates clear
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe lprice_per_person /// 
	ex_dd_0_500  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_A_1

reghdfe lprice_per_person /// 
	ex_dd_0_500 ex_dd_500_1000 /// 
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_A_2

reghdfe lprice_per_person ///
	ex_dd_0_500 ex_dd_500_1000 ex_dd_1000_2000  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_A_3

reghdfe lprice_per_person /// 
	ex_dd_0_500 ex_dd_500_1000 ex_dd_1000_2000 ex_dd_2000_5000  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_A_4

reghdfe lprice_per_person ///
	ex_dd_0_500 ex_dd_500_1000 ex_dd_1000_2000 ex_dd_2000_5000 ex_dd_5000_10000  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_A_5
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe lprice_per_person ///
	ex_dd_0_500 ex_dd_500_1000 ex_dd_1000_2000 ex_dd_2000_5000 ex_dd_5000_10000  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_B_1

reghdfe lprice_per_person ///
	ex_dd_0_1000 ex_dd_1000_2000 ex_dd_2000_5000 ex_dd_5000_10000  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_B_2

reghdfe lprice_per_person ///
	ex_dd_0_2000 ex_dd_2000_5000 ex_dd_5000_10000  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_B_3

reghdfe lprice_per_person ///
	ex_dd_0_5000 ex_dd_5000_10000  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_B_4

reghdfe lprice_per_person ///
	ex_dd_0_10000  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_B_5
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_1

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_2

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_3

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_4

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ex_dd_0_500_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_5

reghdfe lprice_per_person /// 
	ex_dd_0_500_p0_7 ///
	ex_dd_500_1000_p0_7  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_6

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_7

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_8

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ex_dd_500_1000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_9

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ex_dd_0_500_p28_35 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ex_dd_500_1000_p21_28 ex_dd_500_1000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_10

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ///
	ex_dd_500_1000_p0_7 ///
	ex_dd_1000_2000_p0_7  $ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_11

reghdfe lprice_per_person /// 
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_12

reghdfe lprice_per_person ///
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_13

reghdfe lprice_per_person /// 
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ex_dd_500_1000_p21_28 /// 
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_14

reghdfe lprice_per_person ///  
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ex_dd_0_500_p28_35 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ex_dd_500_1000_p21_28 ex_dd_500_1000_p28_35 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ex_dd_1000_2000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_15

reghdfe lprice_per_person ///  
	ex_dd_0_500_p0_7 ///
	ex_dd_500_1000_p0_7 ///
	ex_dd_1000_2000_p0_7 ///
	ex_dd_2000_5000_p0_7 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_16

reghdfe lprice_per_person ///  
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_17

reghdfe lprice_per_person ///  
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_18

reghdfe lprice_per_person ///  
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ex_dd_500_1000_p21_28 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_19

reghdfe lprice_per_person ///  
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ex_dd_0_500_p28_35 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ex_dd_500_1000_p21_28 ex_dd_500_1000_p28_35 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ex_dd_1000_2000_p28_35 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ex_dd_2000_5000_p28_35 /// 
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_20

reghdfe lprice_per_person ///  
	ex_dd_0_500_p0_7 ///
	ex_dd_500_1000_p0_7 ///
	ex_dd_1000_2000_p0_7 ///
	ex_dd_2000_5000_p0_7 ///
	ex_dd_5000_10000_p0_7 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_21

reghdfe lprice_per_person ///  
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_22

reghdfe lprice_per_person /// 
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 /// 
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_23

reghdfe lprice_per_person /// 
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ex_dd_500_1000_p21_28 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 ex_dd_5000_10000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_24

reghdfe lprice_per_person /// 
	ex_dd_0_500_p0_7 ex_dd_0_500_p7_14 ex_dd_0_500_p14_21 ex_dd_0_500_p21_28 ex_dd_0_500_p28_35 ///
	ex_dd_500_1000_p0_7 ex_dd_500_1000_p7_14 ex_dd_500_1000_p14_21 ex_dd_500_1000_p21_28 ex_dd_500_1000_p28_35 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ex_dd_1000_2000_p28_35 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ex_dd_2000_5000_p28_35 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 ex_dd_5000_10000_p21_28 ex_dd_5000_10000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_C_25
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe lprice_per_person ///   
	ex_dd_0_1000_p0_7  $ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_1

reghdfe lprice_per_person ///  
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_2

reghdfe lprice_per_person ///     
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_3

reghdfe lprice_per_person ///     
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ex_dd_0_1000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_4

reghdfe lprice_per_person ///      
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ex_dd_0_1000_p21_28 ex_dd_0_1000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_5

reghdfe lprice_per_person ///   
	ex_dd_0_1000_p0_7 ///
	ex_dd_1000_2000_p0_7 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_6

reghdfe lprice_per_person ///    
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_7

reghdfe lprice_per_person ///    
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_8

reghdfe lprice_per_person ///     
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ex_dd_0_1000_p21_28 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_9

reghdfe lprice_per_person ///      
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ex_dd_0_1000_p21_28 ex_dd_0_1000_p28_35 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ex_dd_1000_2000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_10

reghdfe lprice_per_person ///   
	ex_dd_0_1000_p0_7 ///
	ex_dd_1000_2000_p0_7 ///
	ex_dd_2000_5000_p0_7 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_11

reghdfe lprice_per_person ///    
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_12

reghdfe lprice_per_person ///    
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_13

reghdfe lprice_per_person ///      
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ex_dd_0_1000_p21_28 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_14

reghdfe lprice_per_person ///      
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ex_dd_0_1000_p21_28 ex_dd_0_1000_p28_35 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ex_dd_1000_2000_p28_35 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ex_dd_2000_5000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_15

reghdfe lprice_per_person ///   
	ex_dd_0_1000_p0_7 ///
	ex_dd_1000_2000_p0_7 ///
	ex_dd_2000_5000_p0_7 ///
	ex_dd_5000_10000_p0_7 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_16

reghdfe lprice_per_person ///    
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_17

reghdfe lprice_per_person ///     
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21  ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ////
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_18

reghdfe lprice_per_person ///      
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ex_dd_0_1000_p21_28 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 ex_dd_5000_10000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_19

reghdfe lprice_per_person ///      
	ex_dd_0_1000_p0_7 ex_dd_0_1000_p7_14 ex_dd_0_1000_p14_21 ex_dd_0_1000_p21_28 ex_dd_0_1000_p28_35 ///
	ex_dd_1000_2000_p0_7 ex_dd_1000_2000_p7_14 ex_dd_1000_2000_p14_21 ex_dd_1000_2000_p21_28 ex_dd_1000_2000_p28_35 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ex_dd_2000_5000_p28_35 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 ex_dd_5000_10000_p21_28 ex_dd_5000_10000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_D_20
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
reghdfe lprice_per_person ///    
	ex_dd_0_2000_p0_7  ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_1

reghdfe lprice_per_person ///      
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_2

reghdfe lprice_per_person ///       
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_3

reghdfe lprice_per_person ///         
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ex_dd_0_2000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_4

reghdfe lprice_per_person ///            
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ex_dd_0_2000_p21_28 ex_dd_0_2000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_5

reghdfe lprice_per_person ///    
	ex_dd_0_2000_p0_7 ///
	ex_dd_2000_5000_p0_7 /// 
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_6

reghdfe lprice_per_person ///      
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_7

reghdfe lprice_per_person ///        
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_8

reghdfe lprice_per_person ///         
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ex_dd_0_2000_p21_28 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_9

reghdfe lprice_per_person ///            
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ex_dd_0_2000_p21_28 ex_dd_0_2000_p28_35 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ex_dd_2000_5000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_10

reghdfe lprice_per_person ///    
	ex_dd_0_2000_p0_7 ///
	ex_dd_2000_5000_p0_7 ///
	ex_dd_5000_10000_p0_7 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_11

reghdfe lprice_per_person ///      
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_12

reghdfe lprice_per_person ///       
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_13

reghdfe lprice_per_person ///          
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ex_dd_0_2000_p21_28 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 ex_dd_5000_10000_p21_28 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_14

reghdfe lprice_per_person ///            
	ex_dd_0_2000_p0_7 ex_dd_0_2000_p7_14 ex_dd_0_2000_p14_21 ex_dd_0_2000_p21_28 ex_dd_0_2000_p28_35 ///
	ex_dd_2000_5000_p0_7 ex_dd_2000_5000_p7_14 ex_dd_2000_5000_p14_21 ex_dd_2000_5000_p21_28 ex_dd_2000_5000_p28_35 ///
	ex_dd_5000_10000_p0_7 ex_dd_5000_10000_p7_14 ex_dd_5000_10000_p14_21 ex_dd_5000_10000_p21_28 ex_dd_5000_10000_p28_35 ///
	$ALL_CONTROLS /// 
	, a(propertyid#ym nbhd#date) cache(use)
estimate store model_set_E_15
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

timer off 2


*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* Output Results
timer on 3
estfe model_set_A_* model_set_B_* model_set_C_* model_set_D_* model_set_E_*  ///
	, labels(propertyid "Asin FE" date "Date FE"  nbhd#yw "Neighborhood-Week FE")
return list

esttab model_set_A_* using "05_04_Price_reg_absorbed_propertyidym_nbhddate_set_A.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(ex_*) ///
	label ///
	indicate("Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")
	
esttab model_set_B_* using "05_04_Price_reg_absorbed_propertyidym_nbhddate_set_B.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(ex_*) ///
	label ///
	indicate("Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

esttab model_set_C_* using "05_04_Price_reg_absorbed_propertyidym_nbhddate_set_C.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(ex_*) ///
	label ///
	indicate("Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")


esttab model_set_D_* using "05_04_Price_reg_absorbed_propertyidym_nbhddate_set_D.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(ex_*) ///
	label ///
	indicate("Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

esttab model_set_E_* using "05_04_Price_reg_absorbed_propertyidym_nbhddate_set_E.csv", replace ///
	se /// 
	title("Regression results - Equilibrium Prices") ///
	b(a2) ///
	order(ex_*) ///
	label ///
	indicate("Supply side controls = *prod_week*" ///
			`r(indicate_fe)') ///	
			scalars(r2 r2_within r2_a) ///
	addnote("Add note later")

	
	
estfe model_set_A_* model_set_B_* model_set_C_* model_set_D_* model_set_E_* ///
	, restore
timer off 3
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
timer list 
