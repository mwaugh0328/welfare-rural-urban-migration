/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Table 5. Treatment Effects in 2011 Accounting for Basis Risk in the Insurance Program
	
	Notes: The "Assigned to" and "Went to" rows are combined in the final version of the table. This must
		be done manually. 
	*************************************************************************** */
clear
mat drop _all
set more off
	
use  "$dta/Table5.dta", clear
global treat2008 "incentivized2008 impure"
global treat2011 "inc2011_1 inc2011_4 inc2011_5 inc2011_6"

set more off
loc outregoptions excel lab dec(3) drop(_Iupaz* inc2011_5) nonotes
local notes "Robust standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.1. Regressions 2 and 3 control for interactions between Bogra and other randomized treatments."
local Bogra_r1l "Went to Bogra before"
local assigned_bogral "Assigned to Bogra"
local travel_bogral "Traveled to Bogra in 08"

loc sfarmer "agr_on==1"
loc snonfarmer "agr_on==0"
loc sfull 1
loc lfarmer "Farmers Only"
loc lnonfarmer "Non-Farmers Only"
loc lfull "Full Sample"
	
loc ap "replace"

/* ============================================== */

xi: reg  migrate2011 impure $treat2011  i.upazila, cluster(village)

	test  inc2011_1 =  inc2011_4
	local p1=r(p)
	
	sum assigned_bogra if e(sample)
	local mean = r(mean)
	
outreg2 using "$tb\t5", `ap' `outregoptions' ///
	addstat("Mean of `assigned_bogral'", `mean', "p-value for F-test: Conditional credit = Rainfall Insurance",  `p1') ///
	addtext("District Fixed Effects?", "Yes") ctitle("Assigned to travel to Bogra", "Full Sample")
loc ap append 

*2
xi: reg  migrate2011 impure $treat2011 assigned_bogra assigned_bogra_rain assigned_bogra_cond assigned_bogra_uncond assigned_bogra_impure ///
	 i.upazila, cluster(village)
	test 0 = inc2011_4 + assigned_bogra_rain
	local p1=r(p)
	
outreg2 using  "$tb\t5", `ap' `outregoptions' ///
	addstat("p-value of 0 = Rainfall Ins + Bogra*rain",  `p1') ///
	addtext("District Fixed Effects?", "Yes") ctitle("Full Sample")		
	
*3	
xi: reg  migrate2011 impure $treat2011 Bogra_r1 Bogra_r1_rain Bogra_r1_cond Bogra_r1_uncond Bogra_r1_impure ///
	 i.upazila, cluster(village)
	test 0 = inc2011_4 + Bogra_r1_rain
	local p1=r(p)
	
outreg2 using  "$tb\t5", `ap' `outregoptions' ///
	addstat("p-value of 0 = Rainfall Ins + Bogra*rain",  `p1') ///
	addtext("District Fixed Effects?", "Yes") ctitle("Went to Bogra before 2008", "Full Sample")	
	
erase "$tb\t5.txt"
