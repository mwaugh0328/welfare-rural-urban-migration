/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Table 6. Learning from Own Experience and Others' Experiences in 2009 Re-migration Decision
	*************************************************************************** */
clear
mat drop _all
set more off


use "$dta/Round3.dta", clear

/* Replacing with 0 missing */

foreach var in mean_friends_asg  mean_friends_slf_frm mean_friends_two mean_friends_dest_as ///
	 mean_relative_asg  mean_relative_slf_frm mean_relative_two mean_relative_dest_as {
		replace `var'=0 if `var'==.
	}
	
/* Combining friends and relatives together */

egen num_frrlt_migrated=rowtotal(num_friends_migrated  num_relative_migrated)
label var num_frrlt_migrated "Number of friends and relatives who migrated"

egen num_frrlt = rowtotal(num_friends num_relative)
foreach v in dest_asg asg slf_frm two {
	gen num_friends_`v' = num_friends*mean_friends_`v'
	gen num_relative_`v' = num_relative*mean_relative_`v'
	egen num_frrlt_`v' = rowtotal(num_friends_`v' num_relative_`v')
	gen mean_frrlt_`v' = num_frrlt_`v'/num_frrlt
	replace mean_frrlt_`v' = 0 if mi(mean_frrlt_`v')
	}


la var mean_frrlt_asg "Proportion of friends and relatives assigned to migrate in a group"
la var mean_frrlt_slf_frm "Proportion of friends and relatives in self-formed groups"
la var mean_frrlt_asg "Proportion of friends and relatives assigned to a destination"
la var mean_frrlt_asg "Proportion of friends and relatives assigned to migrate in a group of size 2"


* Sucess of friends and relatives - using total earnings only

loc outregoptions "excel  bdec(3) label drop(_I*) nonotes"
loc note "*** p<0.01, ** p<0.05, * p<0.1 Robust standard errors clustered at the village level in parentheses. All regressions include district fixed effects."

* ols
xi: reg migrant_r3 migrant_r2 i.upazila , cl(village)
outreg2 using "$tb\t6", replace `outregoptions' ctitle(OLS) addnote(`note')

* iv
xi: ivreg2 migrant_r3 (migrant_r2 = cash credit info)  i.upazila , cl(village) first
outreg2 using "$tb\t6", append  `outregoptions' ctitle(IV) 

***** combine friends and relatives
* ols 

xi: reg migrant_r3 migrant_r2 num_frrlt_migrated i.upazila , cl(village)
outreg2 using "$tb\t6", append `outregoptions' ctitle(OLS, Friends+relatives) 


* iv
xi: ivreg2 migrant_r3 (migrant_r2 num_frrlt_migrated = incentivized self_formed assigned destination_assigned two ///
	mean_frrlt_slf_frm mean_frrlt_asg mean_frrlt_dest_as ) i.upazila , cl(village) first
outreg2 using "$tb\t6", append  `outregoptions' ctitle(IV, Friends+relatives) 


*****just friends 
* ols 

xi: reg migrant_r3 migrant_r2 num_friends_migrated i.upazila , cl(village)
outreg2 using "$tb\t6", append `outregoptions' ctitle(OLS, Friends only) 


* iv

xi: ivreg2 migrant_r3 (migrant_r2 num_friends_migrated = incentivized self_formed assigned destination_assigned two ///
	mean_friends_asg  mean_friends_slf_frm  mean_friends_two mean_friends_dest_as ) i.upazila , cl(village) first
outreg2 using "$tb\t6", append  `outregoptions' ctitle(IV, Friends only) 

***** just relatives
* ols 

xi: reg migrant_r3 migrant_r2 num_relative_migrated i.upazila , cl(village)
outreg2 using "$tb\t6", append `outregoptions' ctitle(OLS, Relatives only) 


* iv

xi: ivreg2 migrant_r3 (migrant_r2 num_relative_migrated = incentivized self_formed assigned destination_assigned two ///
	mean_relative_asg  mean_relative_slf_frm   mean_relative_dest_asg ) i.upazila , cl(village) first
outreg2 using "$tb\t6", append  `outregoptions' ctitle(IV, Relatives only) 


erase "$tb/t6.txt"
