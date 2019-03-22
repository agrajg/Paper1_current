// Logit with fe and instrumenting
********************************************************************************
areg lprice i.year i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, absorb(propertyid)
capture drop lprice_hat
predict lprice_hat, xbd
xtset propertyid date
xtlogit demand demand_l1 demand_l2 i.year i.week i.dow lprice_hat, fe 
********************************************************************************

********************************************************************************
areg lprice i.year i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4, absorb(propertyid)
capture drop lprice_hat
predict lprice_hat, xbd
xtset propertyid date
xtlogit demand demand_l1 demand_l2 i.year i.week i.dow lprice_hat, fe 
********************************************************************************

********************************************************************************
areg lprice i.year i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3, absorb(propertyid)
capture drop lprice_hat
predict lprice_hat, xbd
xtset propertyid date
xtlogit demand demand_l1 demand_l2 i.year i.week i.dow lprice_hat, fe 
********************************************************************************

********************************************************************************
areg lprice i.year i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4 i.prod_week5, absorb(propertyid)
capture drop lprice_hat
predict lprice_hat, xbd
xtset propertyid date
xtlogit demand demand_l1 demand_l2 demand_l3  i.year i.week i.dow lprice_hat, fe 
********************************************************************************

********************************************************************************
areg lprice i.year i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3 i.prod_week4, absorb(propertyid)
capture drop lprice_hat
predict lprice_hat, xbd
xtset propertyid date
xtlogit demand demand_l1 demand_l2 demand_l3 i.year i.week i.dow lprice_hat, fe 
********************************************************************************

********************************************************************************
areg lprice i.year i.week i.dow i.prod_week1 i.prod_week2 i.prod_week3, absorb(propertyid)
capture drop lprice_hat
predict lprice_hat, xbd
xtset propertyid date
xtlogit demand demand_l1 demand_l2 demand_l3 i.year i.week i.dow lprice_hat, fe 
********************************************************************************
