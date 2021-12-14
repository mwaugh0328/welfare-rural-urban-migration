/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates figure 4. 
	*************************************************************************** */
	
clear
capture log close
set more off 

/*     ==========================================================================================   
Figure 4. Migration Experience in 2008 by re-Migration Status in 2009.
==========================================================================================    */ 

	
	use "$dta\Round3.dta", clear

	/* Learning in the treatment versus control areas */

	twoway kdensity  tearning_hh_r2 if migrant_r3==1 & tearning_hh_r2<30000 & incentivized==1 , clwidth(medthick) color(gs3) || ///
		kdensity  tearning_hh_r2  if migrant_r3==0 & tearning_hh_r2<30000 & incentivized==1, ///
		title("Incentivized", color(black)) legend(  holes(2) label(1 "People who chose to remigrate") label(2 "People who chose not to remigrate")) ///
		note(Total Earnings less than 30000 ) xtitle(In Taka) ytitle(Density) clpattern(dash) color(gs8)  clwidth(medthick) ///
	saving("$gr\total earnings on remigration_inc_gray", replace)


	twoway kdensity  tearning_hh_r2 if migrant_r3==1 & tearning_hh_r2<30000 & incentivized==0 , clwidth(medthick) color(gs3) || ///
	kdensity  tearning_hh_r2  if migrant_r3==0 & tearning_hh_r2<30000 & incentivized==0, ///
	title("Not Incentivized", color(black)) legend(  holes(2) label(1 "People who chose to remigrate") label(2 "People who chose not to remigrate")) ///
	note(Total Earnings less than 30000 ) xtitle(In Taka) ytitle(Density) clpattern(dash)  color(gs8) clwidth(medthick) ///
	saving("$gr\total earnings on remigration_non_inc_gray", replace)

	graph combine "$gr\total earnings on remigration_inc_gray.gph" "$gr\total earnings on remigration_non_inc_gray.gph", ///
	            title("Distribution of Total Earnings", color(black)) 
				
	graph export "$gr\F4_remigr_newb_gray.emf", replace
				
