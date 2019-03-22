areg lprice lprice_l*, absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
xtset pywid date
xtlogit demand demand_l* i.dow lpricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[lpricehat] * (1-qhat )
sum elas , det
********************************************************************************
areg lprice lprice_l* , absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
capture drop pricehat
gen pricehat = exp(lpricehat)
xtset pywid date
xtlogit demand demand_l* i.dow pricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[pricehat] * (1-qhat ) * price
sum elas , det
********************************************************************************
areg lprice lprice_l* , absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
capture drop invpricehat
gen invpricehat = 1/exp(lpricehat)
xtset pywid date
xtlogit demand demand_l* i.dow invpricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = - _b[invpricehat] * (1-qhat ) / price
sum elas , det
********************************************************************************



********************************************************************************
areg lprice lprice_l* proddum_l1-proddum_l7, absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
xtset pywid date
xtlogit demand demand_l* i.dow lpricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[lpricehat] * (1-qhat )
sum elas , det
********************************************************************************
areg lprice lprice_l* , absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
capture drop pricehat
gen pricehat = exp(lpricehat)
xtset pywid date
xtlogit demand demand_l* i.dow pricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[pricehat] * (1-qhat ) * price
sum elas , det
********************************************************************************
areg lprice lprice_l* , absorb(pywid)
capture drop lpricehat
predict lpricehat , xbd
capture drop invpricehat
gen invpricehat = 1/exp(lpricehat)
xtset pywid date
xtlogit demand demand_l* i.dow invpricehat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = - _b[invpricehat] * (1-qhat ) / price
sum elas , det
********************************************************************************



areg price l(1/2).price , absorb(pywid )
capture drop phat
predict phat , xbd
xtlogit demand l(1/2).demand i.dow phat , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[phat] * (1-qhat ) * price
sum elas , det
********************************************************************************
areg lprice l(1/2).lprice , absorb(pywid)
capture drop phat
predict phat , xbd
capture drop invprice
gen invprice = 1/exp(phat)
xtlogit demand l(1/2).demand i.dow invprice , fe
capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = _b[invprice] * (1-qhat ) * (-invprice)
sum elas , det
********************************************************************************


areg lprice l(1/2).lprice proddum_l*, absorb(pywid )
capture drop phat
predict phat , xbd
xtlogit demand l(1/2).demand i.dow  proddum_l* phat, fe



capture drop qhat
capture drop elas
predict qhat, pc1
gen elas = abs(_b[phat] * (1-qhat ))
sum elas , det

