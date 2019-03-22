clear all
set more off
cd "Y:\agrajg\Research\Paper1_demand_stata\MAPS"
spshape2dta Y:\agrajg\Research\Paper1_demand_stata\MAPS\geo_export_03713c52-dafd-43a3-867e-7d92a9bbbbef.shp, replace

use  Y:\agrajg\Research\Paper1_demand_stata\MAPS\geo_export_03713c52-dafd-43a3-867e-7d92a9bbbbef.dta, clear
spset
grmap , fcolor(white) ocolor(ltblue) osize(vthin) opattern(longdash) ///
	point(data("50_01_Rentals_purged_location.dta") ///
	xcoord(longitude) ///
	ycoord(latitude) ///
	size(vtiny)) deviation(_freq) 
