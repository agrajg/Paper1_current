clear all
set more off
clear all 
set more off
set maxvar 120000, perm
set matsize 11000, perm
capture timer clear
*===============================================================================
cd "Y:\agrajg\Research\Paper1_demand_stata"
*-------------------------------------------------------------------------------
* Number of days a rental is supplied in the market
use "Y:\agrajg\Research\Paper1_demand_stata\73_01_Table_Data_PS.dta", clear
*2015
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\74_01_Table_PS" if year == 2015 & stats_name  == "PS", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2015) /// 
	groupvar(	/// 
				stats_value ///
				\underline{\textbf{Space-Type}} stats_value_ltype1 stats_value_ltype2 stats_value_ltype3 ///
				\underline{\textbf{Property-Type}} stats_value_ptype1 stats_value_ptype2 stats_value_ptype3 stats_value_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} stats_value_btype1 stats_value_ntype1 stats_value_ntype2 stats_value_ntype3 stats_value_ntype4 ///
				\textit{\textbf{Brooklyn}} stats_value_btype2 stats_value_ntype5 stats_value_ntype6 stats_value_ntype7 stats_value_ntype8 ///
				\textit{\textbf{Manhattan}} stats_value_btype3 stats_value_ntype9 stats_value_ntype10 stats_value_ntype11 stats_value_ntype12 ///
				\textit{\textbf{Queens}} stats_value_btype4 stats_value_ntype13 stats_value_ntype14 stats_value_ntype15 stats_value_ntype16 ///
				\textit{\textbf{Staten-Island}} stats_value_btype5 ///
			) /// 
	keep(		///
				stats_value ///
				stats_value_ltype1 stats_value_ltype2 stats_value_ltype3 ///
				stats_value_ptype1 stats_value_ptype2 stats_value_ptype3 stats_value_ptype4 ///
				stats_value_btype1 stats_value_ntype1 stats_value_ntype2 stats_value_ntype3 stats_value_ntype4 ///
				stats_value_btype2 stats_value_ntype5 stats_value_ntype6 stats_value_ntype7 stats_value_ntype8 ///
				stats_value_btype3 stats_value_ntype9 stats_value_ntype10 stats_value_ntype11 stats_value_ntype12 ///
				stats_value_btype4 stats_value_ntype13 stats_value_ntype14 stats_value_ntype15 stats_value_ntype16 ///
				stats_value_btype5 ///
			) label tex(frag pr) ///
			addn("Notes: ") replace

*2016
outreg2 using "Y:\agrajg\Research\Paper1_demand_stata\74_01_Table_PS" if year == 2016 & stats_name  == "PS", sum(detail) eqkeep(N mean sd p5 p50 p95) cttop(2016) /// 
	groupvar(	/// 
				stats_value ///
				\underline{\textbf{Space-Type}} stats_value_ltype1 stats_value_ltype2 stats_value_ltype3 ///
				\underline{\textbf{Property-Type}} stats_value_ptype1 stats_value_ptype2 stats_value_ptype3 stats_value_ptype4 ///
				\underline{\textbf{Location}} ///
				\textit{\textbf{Bronx}} stats_value_btype1 stats_value_ntype1 stats_value_ntype2 stats_value_ntype3 stats_value_ntype4 ///
				\textit{\textbf{Brooklyn}} stats_value_btype2 stats_value_ntype5 stats_value_ntype6 stats_value_ntype7 stats_value_ntype8 ///
				\textit{\textbf{Manhattan}} stats_value_btype3 stats_value_ntype9 stats_value_ntype10 stats_value_ntype11 stats_value_ntype12 ///
				\textit{\textbf{Queens}} stats_value_btype4 stats_value_ntype13 stats_value_ntype14 stats_value_ntype15 stats_value_ntype16 ///
				\textit{\textbf{Staten-Island}} stats_value_btype5 ///
			) /// 
	keep(		///
				stats_value ///
				stats_value_ltype1 stats_value_ltype2 stats_value_ltype3 ///
				stats_value_ptype1 stats_value_ptype2 stats_value_ptype3 stats_value_ptype4 ///
				stats_value_btype1 stats_value_ntype1 stats_value_ntype2 stats_value_ntype3 stats_value_ntype4 ///
				stats_value_btype2 stats_value_ntype5 stats_value_ntype6 stats_value_ntype7 stats_value_ntype8 ///
				stats_value_btype3 stats_value_ntype9 stats_value_ntype10 stats_value_ntype11 stats_value_ntype12 ///
				stats_value_btype4 stats_value_ntype13 stats_value_ntype14 stats_value_ntype15 stats_value_ntype16 ///
				stats_value_btype5 ///
			) label tex(frag pr)
					

copy "Y:\agrajg\Research\Paper1_demand_stata\74_01_Table_PS.tex" "Z:\Paper1_Output\74_01_Table_PS.tex" , replace
