/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Figure 5. 
	
	Note: Figure 5 is comprised of 3 panels. 
	Panel A is automatically output by this do file.
	Panel B is a regression table, also output here. 
	Panel C was made in excel. No output in this do file - numbers are from tabulations run 
		in this file, then copied into excel. 
	*************************************************************************** */
	
clear
capture log close
set more off 

/*     ==========================================================================================   
Figure 5. Heterogeneity in Migration Responsiveness to Treatment by Subsistence Level
==========================================================================================    */ 

use "$dta\Round2.dta", clear

/* Panel A */

twoway kdensity subsistencer1 if migrant==1 & incentivized ==1, clwidth(medthick) color(gs3) || ///
	kdensity subsistencer1  if migrant==0 & incentivized==1, title("Incentivized", color(black)) ///
	legend( label(1 "Migrant") label(2 "Not Migrant")) ///
	xtitle(Percentage level) ytitle(Density) lpattern(dash) color(gs8) clwidth(medthick) ///
	saving("$gr\F5_subsistencer1_bymig_incentivized_gray", replace)

twoway kdensity subsistencer1 if migrant==1 & incentivized ==0, clwidth(medthick) color(gs3) || ///
	kdensity subsistencer1  if migrant==0 & incentivized==0, title("Not Incentivized", color(black)) ///
	legend( label(1 "Migrant") label(2 "Not Migrant")) ///
	xtitle(Percentage level) ytitle(Density) lpattern(dash) color(gs8) clwidth(medthick) ///
	saving("$gr\F5_subsistencer1_bymig_nonincentivized_gray", replace) 

graph combine "$gr\F5_subsistencer1_bymig_incentivized_gray.gph" ///
		"$gr\F5_subsistencer1_bymig_nonincentivized_gray.gph" , ///
			title("Panel A: Migration Rates and Baseline Subsistence Level", color(black)) ///
			subtitle("(by Treatment Status)") ///
			note("Subsistence is defined as percentage of food expenditures on total expenditures")

graph export "$gr\F5_panelA_gray.png", replace


		
/* Panel B */

use "$dta\Round2.dta", clear

la var incentivized "Incentivized"
la var subsistencer1 "Ratio of Food Expenditure over Total Expenditure Round 1"
la var subsistencer1_inc "Interaction: Ratio of food to total * Incentivized"

gen groupassigned=groupnature=="assigned"
tab destination, gen(dest_dum)
foreach var of varlist  dest_dum* {
	replace `var'=0 if `var'==.
	}

loc outregoptions "excel lab"
loc ap "replace"

loc controls "num_adltmalesr1 num_childrenr1 migrant_bef constrainedr1 bankedr1 exp_total_pc_r1 dhaka_network"
	
loc randomizations dest_dum1 dest_dum2 dest_dum3 dest_dum4 groupassigned

*subsistence level = ratio of 
reg migrant incentivized subsistencer1 subsistencer1_inc `randomizations' `controls' i.upazila, cl(village) 
outreg2 using "$tb\fig5_panb", `ap' `outregoptions' ///
	 keep(incentivized subsistencer1 subsistencer1_inc) 

erase "$tb\fig5_panb.txt"

/* Panel C */

sum subsistencer1, d

*  categories for subsistence in R1

gen x=1 if subsistencer1 	 <=  .5897685289382935
replace x=2 if subsistencer1 <=  .6434170603752136 & x==.
replace x=3 if subsistencer1 <=  .714106559753418  & x==.
replace x=4 if subsistencer1 <=  .7762086391448975 & x==.
replace x=5 if subsistencer1 <=	 .8247699737548828 & x==.
replace x=6 if subsistencer1 <=  .8593323230743408 & x==.
replace x=7 if subsistencer1 <=  .8773519992828369 & x==.
replace x=8 if x==.


ta x if incentivized==1, sum(migrant) mean

ta x if incentivized==0, sum(migrant) mean




