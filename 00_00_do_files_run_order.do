clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
do "01_01_Subsetting_data_for_active_rentals(current).do"
do "01_02_Finding_Purged_listings(current).do"
do "01_03_Purge_properties_location_etc(current).do"
do "01_04_Affected_properties(current).do"
do "03_01_Data_prep_for_demand_estimation1(current).do"
do "03_02_Data_prep_for_demand_estimation2(current).do"
*Keep either one of the two below
do "04_01_regressors_for_price_regressions(current).do"
do "04_06_regressors_for_price_regressions_new_set(current).do"
do "04_07_regressors_for_price_regressions_new3(current).do"
do "05_11_Price_reg_absorbed_propertyid_date_nbhdyw_nbhddow_miles_final2(current).do"
do "05_12_Quantity_reg_absorbed_propertyid_date_nbhdyw_nbhddow_miles_final2(current).do"
do "05_13_Price_reg_absorbed_propertyid_date_nbhdyw_nbhddow_miles_final_cap(current).do"
do "05_14_Quantity_reg_absorbed_propertyid_date_nbhdyw_nbhddow_miles_final_cap(current).do"
do "05_15_Price_reg_absorbed_propertyid_date_nbhdyw_nbhddow_miles_final_cap(current).do"
do "05_16_Quantity_reg_absorbed_propertyid_date_nbhdyw_nbhddow_miles_final_cap(current).do"
do "08_03_Demand2(current).do"
do "09_01_Prediction_post_Demand_estimations(current).do"
do "10_01_Elasticity_Marginal_Cost_and_Profits(current).do"
--
R codes
11_03_Solver1_part_1(current).R
11_04_Solver2_part_1(current).R
--
do "12_01_Putting_All_columns_togather_for_Welfare(current).do"
do "13_04_Welfare_Calculations3(Current).do"
// do ".do"
// do ".do"
// do ".do"
// do ".do"
// do ".do"
// do ".do"
// do ".do"
// do ".do"

// timer on 55
// do "05_11_Price_reg_absorbed_propertyid_date_nbhdyw_nbhddow_miles_final2.do"
// do "05_12_Quantity_reg_absorbed_propertyid_date_nbhdyw_nbhddow_miles_final2.do"
// do "08_02_Demand2.do"
// do "09_01_Prediction_post_Demand_estimations.do"
// do "10_01_Elasticity_Marginal_Cost_and_Profits.do"
// timer off 55
// timer list
// capture timer clear
