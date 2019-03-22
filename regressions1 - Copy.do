areg lprice l(1/2).lprice , absorb(pywid )
capture drop phat
predict phat , xbd
xtlogit demand l(1/2).demand i.dow phat , fe
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
