clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
use "09_01_Prediction_post_Demand_estimations.dta", replace
*===============================================================================


* Predicted Quantity Demanded (Number of Guests)
gen pqd = D_xbd if D_xbd >=0
label var pqd "Predicted Quantity Demanded (Number of Guests)"
replace pqd = 0 if D_xbd < 0

* Generating elasticities from estimated beta
capture drop elas
gen elas = (D_beta / pqd)
label var elas "Price Elasticty"

*-------------------------------------------------------------------------------
preserve
* predicted quantity groups
capture drop temp
gen temp  =  ""
replace temp = "Predicted Q = 0" if pqd ==0
replace temp = "0 < Predicted Q <= 1" if pqd > 0 & pqd <=1
replace temp = "1 < Predicted Q <= 2" if pqd > 1 & pqd <=2
replace temp = "2 < Predicted Q <= 3" if pqd > 2 & pqd <=3
replace temp = "3 < Predicted Q <= 4" if pqd > 3 & pqd <=4
replace temp = "4 < Predicted Q <= 5" if pqd > 4 & pqd <=5
replace temp = "5 < Predicted Q <= 6" if pqd > 5 & pqd <=6
replace temp = "6 < Predicted Q <= 7" if pqd > 6 & pqd <=7
replace temp = "7 < Predicted Q <= 8" if pqd > 7 & pqd <=8
replace temp = "8 < Predicted Q <= 9" if pqd > 8 & pqd <=9
replace temp = "9 < Predicted Q <= 10" if pqd > 9 & pqd <=10
replace temp = "Predicted Q >= 10" if pqd > 10 
rename temp predQinterval
label var predQinterval "Predicted Quantity Interval"
keep if proddum == 1 
drop if pqd == 0

collapse (count) N=elas (mean) Mean = elas (sd) SD = elas (min) Min = elas (p10) ///
	Pc_10 = elas (p50) Pc_50 = elas (p90) Pc_90 = elas (max) Max = elas, by (predQinterval)

sort predQinterval
drop if N == 0
ssc install texsave
texsave  using "09_01_Elasticity_estimated_by_predicted_quantity.tex", /// 
	size(3) replace frag varlabels title("Price Elasticity by Quantity (predicted)") ///
	footnote("footnote 1" , size(3))
	 
restore
*-------------------------------------------------------------------------------
* Marginal Costs
capture drop mc
gen mc = adj_price_per_person*(1 + (1/elas)) if elas <= -1
replace mc = 0 if elas > -1
label var mc "Implied Marginal Cost (per guest)"
*-------------------------------------------------------------------------------
* Obtaining property characteristics for out of sample marginal cost prediction
capture drop listingtype
merge m:1 propertyid using "00_00_rental_characteristics.dta"
drop if _merge ==2
drop _merge
recast int bedrooms, force
recast int bathrooms, force
recast int maxguests, force
*-------------------------------------------------------------------------------
* First prediction for marginal costs using property characteristics
capture drop MC_FE_date1
capture drop MC_FE_nbhd_yw1
capture drop MC_FE_nbhd_dow1
capture drop MC_xb1
capture drop MC_xbd1
capture drop MC_d1
capture drop MC_r1
capture drop OOS_MC_xbd1


timer on 2

reghdfe mc  i.cancellationpolicy securitydeposit cleaningfee extrapeoplefee /// 
	i.checkintime i.checkouttime i.minimumstay i.instantbookenabled /// 
	i.listingtype i.propertytype i.bedrooms i.bathrooms i.maxguests  if proddum == 1 , ///
	a(MC_FE_date1 = i.date MC_FE_nbhd_yw1 = i.nbhd#i.yw MC_FE_nbhd_dow1 = i.nbhd#i.dow)

timer off 2

predict MC_xb1, xb
predict MC_xbd1, xbd
predict MC_d1, d
predict MC_r1, r

* saving contant of demand regression as a local variable
sum MC_d1
gen MC_cons1 = `r(mean)'
// di `MC_cons1'

sort date propertyid
by date: carryforward MC_FE_date1, replace

gsort date -propertyid
by date: carryforward MC_FE_date1, replace

sort nbhd yw propertyid date
by nbhd yw: carryforward MC_FE_nbhd_yw1, replace

gsort nbhd yw -propertyid -date
by nbhd yw: carryforward MC_FE_nbhd_yw1, replace

sort nbhd dow propertyid date
by nbhd dow: carryforward MC_FE_nbhd_dow1, replace

gsort nbhd dow -propertyid -date
by nbhd dow: carryforward MC_FE_nbhd_dow1, replace

gen OOS_MC_xbd1 = MC_xb1 + MC_FE_date1 + MC_FE_nbhd_yw1 + MC_FE_nbhd_dow1 + MC_cons1
*-------------------------------------------------------------------------------
* another prediction for marginal costs
capture drop MC_FE_propertyid2
capture drop MC_FE_date2
capture drop MC_FE_nbhd_yw2
capture drop MC_FE_nbhd_dow2
capture drop MC_xb2
capture drop MC_xbd2
capture drop MC_d2
capture drop MC_r2
capture drop OOS_MC_xbd2

timer on 2

reghdfe mc if proddum == 1 , ///
	a(MC_FE_propertyid2 = i.propertyid MC_FE_date2 = i.date MC_FE_nbhd_yw2 = i.nbhd#i.yw MC_FE_nbhd_dow2 = i.nbhd#i.dow)

timer off 2

predict MC_xb2, xb
predict MC_xbd2, xbd
predict MC_d2, d
predict MC_r2, r

* saving contant of demand regression as a local variable
sum MC_d2
gen MC_cons2 = `r(mean)'
// di `MC_cons2'

sort propertyid date 
by propertyid: carryforward MC_FE_propertyid2, replace
gsort propertyid -date
by propertyid: carryforward MC_FE_propertyid2, replace

sort date propertyid
by date: carryforward MC_FE_date2, replace
gsort date -propertyid
by date: carryforward MC_FE_date2, replace

sort nbhd yw propertyid date
by nbhd yw: carryforward MC_FE_nbhd_yw2, replace
gsort nbhd yw -propertyid -date
by nbhd yw: carryforward MC_FE_nbhd_yw2, replace

sort nbhd dow propertyid date
by nbhd dow: carryforward MC_FE_nbhd_dow2, replace
gsort nbhd dow -propertyid -date
by nbhd dow: carryforward MC_FE_nbhd_dow2, replace

gen OOS_MC_xbd2 = MC_FE_propertyid2 + MC_FE_date2 + MC_FE_nbhd_yw2 + MC_FE_nbhd_dow2 + MC_cons2
*-------------------------------------------------------------------------------
sum mc OOS_MC_xbd1 OOS_MC_xbd2 , det
sum mc OOS_MC_xbd1 OOS_MC_xbd2 if proddum == 1, det
*-------------------------------------------------------------------------------
save "09_01_For_non_linear_price_computation_full.dta", replace
export delimited propertyid  date OOS_MC_xbd1 OOS_MC_xbd2 D_beta OOS_D_xbd_noP using "09_01_For_non_linear_price_computation_sample" in 1/20, replace

export delimited propertyid  date OOS_MC_xbd1 OOS_MC_xbd2 D_beta OOS_D_xbd_noP using "09_01_For_non_linear_price_computation", replace
