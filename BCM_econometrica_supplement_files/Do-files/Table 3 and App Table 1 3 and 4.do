/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Table 3, and Appendix Table 1, 3 and 4. 
	

	Table Formatting Note: This requires significant work in excel to create a workable table.
		Table 3 is output over 4 different excel sheets: 
			Table3_2008_IV.xml - Panel A, IV regressions
			Table3_2008_OLS - Panel A, ITT and OLS regressions
			Table3_2009_IV.xml - Panel B, IV regressions
			Table3_2009_OLS - Panel B, ITT and OLS regressions
		Please note the column titles which refer to the outcome variable and specification used. 
		Sample means (for both control & intervention) are in the IV workbooks. 
	
	Note: for Appendix Table 3, we re-run the same regressions with different dependent variables, based on
		different denominators to create the per capita variables. These are not automatically produced
		by this do-file, but one may easily run these alternate specifications by changing global used 
		to run the regression/output loops.
		In the lines: 
			foreach var in $depvars_T1 {
		One would swap $depvars_T1 for $appvars_AT3_PA, to create Panel A of Appendix Table 3.

		Panel A: variables are prefixed with q7*
			variables: q7_average_food q7_average_nonfood q7_average_exp q7_average_calorie_perday
			denominator: hhsize_cons hhsize_mth kids_at_home2 mhealth_hhsize fhealth_hhsize, 
				depending on outcome category variable
		Panel B: variables are prefixed with q9* and suffixed with 2
			variables: q9_average_food2 q9_average_nonfood2 q9_average_exp2 q9_average_cloths_shoes2 q9_average_calorie_perday2
			denomiator: q9_total_home_int_2 
		Panel C: variables are suffixed with 1 (or without suffix)
			variables: average_food1 average_nonfood1 average_exp1 average_calorie_perday1
			denominator: total_home_int1 as denominator
		Panel D: variables are suffixed with 3
			variables: average_food3 average_nonfood3 average_exp3 average_calorie_perday3
			denominator: total_home_int_3 
		Panel E: variables are prefixed with total*
			variables: total_food total_nonfood total_expenditures total_calorie_day
			no denominator
		
		compare T3: variables are suffixed with 2
			variables: average_food2 average_nonfood2 average_exp2  average_calorie_perday2 
			denominator: total_home_int_2 
	
	AT4 - Same as T3, with different dependent variables/consumption categories
	*************************************************************************** */
	
clear
set more off

/*     ==========================   TABLE 3 EFFECTS OF MIGRATION in 2008 ON EXPENDITURE   ============================== */ 

use "$dta/Round2.dta", clear

* Using # people home in the last 7 days prior to thei nterview as the denominator to create average per capita
* (These variables have already been created. Shortening labels for the table)
la var total_home_int_2 "number of household members home within 7 days of interview"
la var average_protein_perday2 "Calories from Protein (per person per day)"
la var average_meat2 "Consumption of Meat"
la var average_milkegg2 "Consumption of Milk and Egg"
la var average_fish2 "Consumption of Fish"
la var average_edu_exp_kds2 "Consumption of Childrens' Education"
la var average_cloths_shoes2 "Consumption of Clothing and Shoes"
la var average_med_exp_f2 "Consumption of Medical Care for Females"
la var average_med_exp_m2 "Consumption of Medical Care for Males"
la var average_food2 "Consumption of Food"
la var average_nonfood2 "Consumption of Non-Food"
la var average_exp2 "Total Consumption"
la var average_calorie_perday2 "Total Calories per person per day"

gl controls lit walls_good  monga dhaka_remit dhaka_network exp_total_pc subsistencer1  ///
			   num_adltmalesr1 num_childrenr1 avgQ13earned constrainedr1 bankedr1
			   
local random cash credit info

drop if hhid==92 // very high values for food expenditure (and total), aslo calories due to very high fish expenditure

loc outregoptions excel label bdec(3) nocons drop(_Iupaz* $controls) \`append'

gl depvars_T1_08 average_food2 average_nonfood2 average_exp2  average_calorie_perday2 

gl appvars_AT3_PA q7_average_food q7_average_nonfood q7_average_exp q7_average_calorie_perday

gl appvars_AT3_PB q9_average_food2 q9_average_nonfood2 q9_average_exp2 q9_average_cloths_shoes2 q9_average_calorie_perday2

gl appvars_AT3_PC average_food1 average_nonfood1 average_exp1 average_calorie_perday1

gl appvars_AT3_PD average_food3 average_nonfood3 average_exp3 average_calorie_perday3

gl appvars_AT3_PE total_food total_nonfood total_expenditures total_calorie_day

gl appvars_AT4_08 average_protein_perday2  ///
	average_meat2 average_milkegg2 average_fish2 average_edu_exp_kds2 average_cloths_shoes2 average_med_exp_f2 ///
	average_med_exp_m2 Female_Wage Kids_School ag_expenditure

/* OLS */

loc append replace

foreach var in $depvars_T1_08 {

	xi: reg `var' incentivized i.upazila, cl(village) 
	outreg2 incentivized using "$tb/Table3_2008_OLS", `outregoptions' ///
		ctitle("`:var lab `var''", ITT, No Controls)
	loc append append
	
		
	xi: reg `var' incentivized $controls i.upazila, cl(village) 
	outreg2 incentivized using "$tb/Table3_2008_OLS", `outregoptions' ///
		ctitle("`:var lab `var''", ITT, Controls)
		
		
	xi: reg  `var'  `random' i.upazila, cl(village)	
	outreg2 `random' using "$tb/Table3_2008_OLS",  `outregoptions' ///
		ctitle("`:var lab `var''", ITT, No Controls)

	xi: reg  `var'  migrant_new i.upazila, cl(village)	
	outreg2  migrant_new using "$tb/Table3_2008_OLS",  `outregoptions' ///
		ctitle("`:var lab `var''", OLS, No Controls)


	} 
	
loc append replace

foreach var in $appvars_AT4_08 {

	xi: reg `var' incentivized i.upazila, cl(village) 
	outreg2 incentivized using "$tb/App_Table4_2008_OLS", `outregoptions' ///
		ctitle("`:var lab `var''", ITT, No Controls)
	loc append append
	
	xi: reg `var' incentivized $controls i.upazila, cl(village) 
	outreg2 incentivized using "$tb/App_Table4_2008_OLS", `outregoptions' ///
		ctitle("`:var lab `var''", ITT, Controls)
		
	xi: reg  `var'  `random' i.upazila, cl(village)	
	outreg2 `random' using "$tb/App_Table4_2008_OLS",  `outregoptions' ///
		ctitle("`:var lab `var''", ITT, No Controls)

	xi: reg  `var'  migrant_new i.upazila, cl(village)	
	outreg2  migrant_new using "$tb/App_Table4_2008_OLS",  `outregoptions' ///
		ctitle("`:var lab `var''", OLS, No Controls)
		
	} 

/* IV */

loc append replace	
loc i 0
foreach var in $depvars_T1_08 {
est drop _all
	loc ++i

	xi: ivreg2  `var' (migrant_new  = `random') i.upazila, cl(village) savefirst
		qui sum `var' if e(sample)
		local mean = r(mean)
		
		matrix A=e(first)
		scalar Ftest=A[3,1]
		scalar Pvalue=A[6,1]
		scalar R2partial=A[2,1]
	outreg2 migrant_new using "$tb/Table3_2008_IV",   `outregoptions' ///
		ctitle("`:var lab `var''", IV, No Controls) addstat(Mean of Control, `mean')
		
	if `i'==1 {
		est restore _ivreg2_migrant_new
		
		outreg2 using "$tb/AT1_first_stage",   `outregoptions' ///
			ti("Appendix Table 1. First Stage: Migration as a Function of Treatments in 2008") ///
			addtext("Sub-district fixed effects?", Yes, "Additional controls?", No) ///
			addstat("1st F-test", Ftest, "1st pvalue", Pvalue, "1st partial R2", R2partial,  ///
			"R2 overall", e(r2))
		loc append append
		est drop _ivreg2_migrant_new
		}
	
	xi: ivreg2  `var' (migrant_new  = `random') $controls i.upazila, cl(village) savefirst
		matrix A=e(first)
		scalar Ftest=A[3,1]
		scalar Pvalue=A[6,1]
		scalar R2partial=A[2,1]
	outreg2 migrant_new using "$tb/Table3_2008_IV",   `outregoptions' ///
		ctitle("`:var lab `var''", IV, Controls) 
		
	if `i' ==1 {
		est restore _ivreg2_migrant_new
		
		outreg2 using "$tb/AT1_first_stage",   `outregoptions' ///
		ti("Appendix Table 1. First Stage: Migration as a Function of Treatments in 2008") ///
			addtext("Sub-district fixed effects?", Yes, "Additional controls?", Yes) ///
			addstat("1st F-test", Ftest, "1st pvalue", Pvalue, "1st partial R2", R2partial,  ///
			"R2 overall", e(r2))
		}
	}

loc append replace	
foreach var in $appvars_AT4_08 {
	
	xi: ivreg2  `var' (migrant_new  = `random') i.upazila, cl(village) 
		qui sum `var' if e(sample)
		local mean = r(mean)
	outreg2 migrant_new using "$tb/App_Table4_2008_IV",   `outregoptions' ///
		ctitle("`:var lab `var''", IV, No Controls) addstat(Mean of Control, `mean')
		
	
	xi: ivreg2  `var' (migrant_new  = `random') $controls i.upazila, cl(village) 
	outreg2 migrant_new using "$tb/App_Table4_2008_IV",   `outregoptions' ///
		ctitle("`:var lab `var''", IV, Controls) 
		
	}
	

	*
	
erase "$tb/Table3_2008_IV.txt"
erase "$tb/Table3_2008_OLS.txt"
erase "$tb/AT1_first_stage.txt"
erase "$tb/App_Table4_2008_OLS.txt"
erase "$tb/App_Table4_2008_IV.txt"


**************2009 - ROUND 3***********
set more off

use "$dta/Round3", clear

drop if average_food3>=2500 // outlier - over 99.9 percentile

gl controls litr1 walls_good  monga dhaka_remit dhaka_network exp_total_pcr1 subsistencer1  ///
			   num_adltmalesr1 num_childrenr1 avgQ13earned constrainedr1 bankedr1	
			   
local random cash credit info

loc outregoptions excel label bdec(3) nocons drop(_Iupaz* $controls)  \`append'

gl depvars_T1_09 average_food2 average_nonfood2 average_exp2  average_calorie_perday2 average_protein_perday2  
gl appvars_AT4_09	average_meat2 average_milkegg2 average_fish2 average_edu_exp_kds2 average_cloths_shoes2 ///
	average_med_exp_f2 	average_med_exp_m2 

/* OLS */

loc append replace

foreach var in $depvars_T1_09 {
	xi: reg `var' incentivized i.upazila, cl(village) 
	outreg2 incentivized using "$tb/Table3_2009_OLS", `outregoptions' ///
		ctitle("`:var lab `var''", ITT, No Controls)
	loc append append
	
		
	xi: reg `var' incentivized $controls i.upazila, cl(village) 
	outreg2 incentivized using "$tb/Table3_2009_OLS", `outregoptions' ///
		ctitle("`:var lab `var''", ITT, Controls)
		
		
	xi: reg  `var'  `random' i.upazila, cl(village)	
	outreg2 `random' using "$tb/Table3_2009_OLS",  `outregoptions' ///
		ctitle("`:var lab `var''", ITT, No Controls)

	xi: reg  `var'  `random'  $controls i.upazila, cl(village) 
	outreg2 `random' using "$tb/Table3_2009_OLS",   `outregoptions' ///
		ctitle("`:var lab `var''", ITT, Controls)
		

	xi: reg  `var'  migrant_r2 i.upazila, cl(village)	
	outreg2  migrant_r2 using "$tb/Table3_2009_OLS",  `outregoptions' ///
		ctitle("`:var lab `var''", OLS, No Controls)

	}
	
foreach var in $appvars_AT4_09 {
	xi: reg `var' incentivized i.upazila, cl(village) 
	outreg2 incentivized using "$tb/App_Table4_2009_OLS", `outregoptions' ///
		ctitle("`:var lab `var''", ITT, No Controls)
	loc append append
	
		
	xi: reg `var' incentivized $controls i.upazila, cl(village) 
	outreg2 incentivized using "$tb/App_Table4_2009_OLS", `outregoptions' ///
		ctitle("`:var lab `var''", ITT, Controls)
		
		
	xi: reg  `var'  `random' i.upazila, cl(village)	
	outreg2 `random' using "$tb/App_Table4_2009_OLS",  `outregoptions' ///
		ctitle("`:var lab `var''", ITT, No Controls)
	

	xi: reg  `var'  migrant_r2 i.upazila, cl(village)	
	outreg2  migrant_r2 using "$tb/App_Table4_2009_OLS",  `outregoptions' ///
		ctitle("`:var lab `var''", OLS, No Controls)

	}

/* IV */

loc append replace	
foreach var in $depvars_T1_09 {

	xi: ivreg2  `var' (migrant_r2  = `random') i.upazila, cl(village) 
		qui sum `var' if e(sample)
		local mean = r(mean)
	outreg2 migrant_r2 using "$tb/Table3_2009_IV",   `outregoptions' ///
		ctitle("`:var lab `var''", IV, No Controls) addstat(Mean, `mean')
	loc append append
	
	xi: ivreg2  `var' (migrant_r2  = `random') $controls i.upazila, cl(village) 
	outreg2 migrant_r2 using "$tb/Table3_2009_IV",   `outregoptions' ///
		ctitle("`:var lab `var''", IV, Controls) 
	}

loc append replace	
foreach var in $appvars_AT4_09 {

	xi: ivreg2  `var' (migrant_r2  = `random') i.upazila, cl(village) 
		qui sum `var' if e(sample)
		local mean = r(mean)
	outreg2 migrant_r2 using "$tb/App_Table4_2009_IV",   `outregoptions' ///
		ctitle(`"`:var lab `var''"', IV, No Controls) addstat(Mean of Control, `mean') 
	loc append append
	
	xi: ivreg2  `var' (migrant_r2  = `random') $controls i.upazila, cl(village) 
	outreg2 migrant_r2 using "$tb/App_Table4_2009_IV",   `outregoptions' ///
		ctitle("`:var lab `var''", IV, Controls) 
	}
	
erase "$tb/Table3_2009_OLS.txt"
erase "$tb/Table3_2009_IV.txt"
erase "$tb/App_Table4_2009_IV.txt"
erase "$tb/App_Table4_2009_OLS.txt"
