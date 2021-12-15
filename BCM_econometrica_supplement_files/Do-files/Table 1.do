/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Table 1
	
	Notes: Columns have been re-ordered before publication. Difference Incent - Non Incent is
	output on a different sheet in the same workbook. 
	*************************************************************************** */
	
capture clear
capture log close
set more off 

/*     ==========================   TABLE 1 RANDOMIZATION CHECK AND SUMMARY STATISTICS  ============================== */ 


use "$dta/Round1_Controls_Table1", clear

#delimit ;
global vars "mfx_hh mnfx_hh exp_total_pc_r1  q9pdcalq9 q9pdproq9 cmtc_hh cmlegc_hh cfshc_hh  edu_exp_ch 
	cloths_shoes_hh med_exp_m_hh med_exp_f_hh tsaving_hh_r1 hhmembers_r1 hhh_education num_adltmalesr1 
	num_childrenr1 walls_good lit monga dhaka_remit dhaka_network subsistencer1 avgQ13earned constrainedr1 bankedr1 Bogra_r1 ";
#delimit cr

loc rnames
foreach var in $vars {
	local lbl : var label `var'
	local rnames `"`rnames' "`lbl'" "'
	}

// mean and standard error of mean by type of incentive (cash/credit/control/info)

qui tabstat $vars, stat(mean sem) by(incentive) save
qui tabstatmat C

xml_tab C using "$tb\Table 1 Random check", replace ///
	title("Mean and SE by Incentive")   ///
	sheet(mean by incentive, color(1)) rnames(`rnames') ///
	line(COL_NAMES 2 LAST_ROW 13) cwidth(0 250, 1 100, 2 100, 3 100, 4 100, 5 100, 6 100) ///
	font("Times New Roman" 11) format((S2100) (N2202))

// Test Incentivized = Non-Incentivized. The following loop creates difference, 
//standard error, and p-value. 
	
mat drop _all

foreach i in $vars {
qui reg `i' incentivized, cl(village)
	qui reg `i' incentivized, cl(village)
	mat reg = r(table)
	mat C = reg[1..2, 1]' // coefficient and std error of regression
	mat p = reg[4,1] // p value from the regression above 
  	mat D = nullmat(D) \ C, p
	}

mat colnames D = Difference SE Pvalue

xml_tab D using "$tb\Table 1 Random check", append ///
	title("Summary Statistics - Diff I v NI ")    ///
	sheet(Diff I v NI, color(1)) rnames(`rnames') ///
	line(COL_NAMES 2 LAST_ROW 13) cwidth(0 250, 1 100, 2 100, 3 100, 4 100, 5 100, 6 100) ///
	font("Times New Roman" 11) format((S2100) (N2202))

