/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Appendix Table 2. 
	Outputs in 3 different excel workbooks - must be transposed and combined into one table. 
	*************************************************************************** */
version 12.1
clear
mat drop _all
set more off

/*     ======================================================================================
Appendix Table 2. Intensive and Extensive Margin Changes due to Incentive (Cash or Credit) 						
=============================================================================================*/   


*****************************************************2008**********************************************
use "$dta/Round2", clear


loc outregoptions excel label bdec(3) nocons drop(_Iupaz*) \`append'

loc append replace

foreach var in tot_episodes_hh num_migrants  {
	xi: reg `var' incentivized i.upazila, cl(village)
	outreg2 incentivized using "$tb/App_Table2_2008", `outregoptions' ///
		ctitle("`:var lab `var''", "Extensive margin")
	loc append append
	}

foreach var in  tot_episodes_hh num_migrants tot_episodes_person days_away_perepisode migr_male migr_age migr_hh_head {
	xi: reg `var' incentivized i.upazila if num_migrants>0, cl(village)
	outreg2 incentivized using "$tb/App_Table2_2008", `outregoptions' ///
		ctitle("`:var lab `var''", "Intensive margin")
	}

erase "$tb/App_Table2_2008.txt"

*****************************************************2009**********************************************

use "$dta/Round3", clear


loc outregoptions excel label bdec(3) nocons drop(_Iupaz*) \`append'

loc append replace

foreach var in tot_episodes_hh num_migrants  {
	xi: reg `var' incentivized i.upazila, cl(village)
	outreg2 incentivized using "$tb/App_Table2_2009", `outregoptions' ///
		ctitle("`:var lab `var''", "Extensive margin")
	loc append append
	}

foreach var in  tot_episodes_hh num_migrants tot_episodes_person days_away_perepisode migr_male migr_age migr_hh_head {
	xi: reg `var' incentivized i.upazila if num_migrants>0, cl(village)
	outreg2 incentivized using "$tb/App_Table2_2009", `outregoptions' ///
		ctitle("`:var lab `var''", "Intensive margin")
	}

erase "$tb/App_Table2_2009.txt"

*****************************************************2011**********************************************
use "$dta/Round4", clear

gen incentivized2011 = inlist(1, inc2011_1, inc2011_4, inc2011_5, inc2011_6) 
loc outregoptions excel label bdec(3) nocons drop(_Iupaz*) \`append'

loc append replace

foreach var in tot_episodes_hh num_migrants  {
	xi: reg `var' incentivized2011 i.upazila, cl(village)
	outreg2 incentivized2011 using "$tb/App_Table2_2011", `outregoptions' ///
		ctitle("`:var lab `var''", "Extensive margin")
	loc append append
	}

foreach var in  tot_episodes_hh num_migrants tot_episodes_person days_away_perepisode migr_male migr_age migr_hh_head {
	xi: reg `var' incentivized2011 i.upazila if num_migrants>0, cl(village)
	outreg2 incentivized2011 using "$tb/App_Table2_2011", `outregoptions' ///
		ctitle("`:var lab `var''", "Intensive margin")
	}

erase "$tb/App_Table2_2011.txt"
