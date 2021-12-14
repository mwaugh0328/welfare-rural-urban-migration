/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Appendix Table 5. 
	
	*************************************************************************** */
version 12.1
clear
mat drop _all
set more off

/*     ======================================================================================
Appendix Table 5.Effects of Migration in 2008 on Savings, Earnings and 
Changes in Children's Middle Upper Arm Circumference (MUAC)											 						
=============================================================================================*/   

use "$dta/Round2.dta", clear



local controls lit walls_good  monga dhaka_remit dhaka_network exp_total_pc subsistencer1  ///
			   num_adltmalesr1 num_childrenr1 avgQ13earned constrainedr1 bankedr1
			   
local random cash credit info

loc outregoptions excel label bdec(3) nocons drop(_Iupaz*) \`append' addtext(Controls?, No)

loc tot_save_outlier 20000
loc tot_earn_outlier 120000
loc muac_r2_outlier .
loc change_muac_outlier .
loc tot_save_label "Total Savings by household"
loc tot_earn_label "Total Earnings by household"
loc muac_r2_label "MUAC (mm)"
loc change_muac_label "Change in MUAC (mm)"


loc append replace

foreach outcome in tot_save tot_earn muac_r2 change_muac {

  /* ITT */
	xi: reg  `outcome'  incentivized i.upazila if `outcome'<``outcome'_outlier' , cl(village)
	sum `outcome' if e(sample) & incentivized==0
	outreg2 incentivized using "$tb/AT5",  `outregoptions' ctitle(``outcome'_label', ITT) ///
		addstat(Mean of Control, r(mean)) 
	loc append append

  /* IV */ 
	xi: ivreg2  `outcome'  (migrant_new  = `random') i.upazila if `outcome'<``outcome'_outlier', cl(village) 
	outreg2 migrant_new using "$tb/AT5",   `outregoptions' ctitle(``outcome'_label', IV)
	}

erase  "$tb/AT5.txt"
