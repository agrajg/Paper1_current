areg lprice  prod_week1-prod_week5, absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
xtset pywid date
xtlogit demand demand_l* i.dow lpricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[lpricehat] * (1-qhat )
sum elas , det


// Lower prices induce low cost host to continue hosting, however cause high cost
// firms to shutdown their production. Prices will therefore be correlated with 
// production decision. however if production cost changes and prices don't , this 
// will habe no impact on the consumers demand. Putting this in another way , it 
// implies that hosts costs have no impact on the consumers willingness to pay. 
// why should lag activity be correlated with hosts opportunity cost??
// Why not lead activity?
// Consumers often book multiple days at once. lead inactivity implies that 
// consumers will not be able to book the property for reasons other than price.
// In this case the reason is that demand on a given day depends on lag demand , price fixed...
// lead activity will be correlated with current demand.

areg lprice  i.prod_week1 i.prod_week2 i.prod_week3, absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
xtset pywid date
xtlogit demand demand_l* i.dow lpricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[lpricehat] * (1-qhat )
sum elas , det


//instead of property week, just using property FE
areg lprice  prod_week1-prod_week5, absorb(propertyid)
capture drop lpricehat
predict lpricehat , xbd
xtset propertyid date
xtlogit demand demand_l* i.dow lpricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[lpricehat] * (1-qhat )
sum elas , det



// this does not work potentially because lead availibility may be correlated 
// with the bookings 
areg lprice  i.prod_win_day3, absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
xtset pywid date
xtlogit demand demand_l* i.dow lpricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[lpricehat] * (1-qhat )
sum elas , det
