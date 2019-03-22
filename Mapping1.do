clear all
set more off

cd "Y:\agrajg\Research\Paper1_demand_stata\CommunityDistricts"
spshape2dta using "geo_export_03713c52-dafd-43a3-867e-7d92a9bbbbef", database(usdb) coordinates(uscoord) genid(id) replace
