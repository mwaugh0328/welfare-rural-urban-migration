/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Table 2.
	
	Notes: Some formatting is required after xml_tab to excel, to convert proportion --> percentage,
		and add significance stars and parentheses.
		Control in 2011 includes both info and job leads group from 2011.The job leads treatment in 2011 was 
		   not considered an "incentive" to migrate. It had little impact and implementation was inconsistent. 
		 
		 There was no overlap between 2011-control and 2008-info, or between 2011-jobleads and 2008-control,
			thus the authors do not recommend splitting the takeup rates for 2011 into specific categories
			but rather focusing on incentivized vs non-incentivized. 
	*************************************************************************** */
	
	/*     ==========================   TABLE 2 PROGRAM TAKE UP RATES  ============================== */ 
clear
cap log close
set more off
mat drop _all

foreach round in 2 3  4 {
	use "$dta\Round`round'.dta", clear

	loc year2 2008
	loc year3 2009
	loc year4 2011
	if `round'==3 {
		rename migrant_r3 migrant
		}
	if `round'==4 {
		keep if inc2011_c==1		// Control in 2011 - this includes both info and job leads group from 2011
			// The job leads treatment in 2011 was not considered an "incentive" to migrate. It had little impact
			// and implementation was inconsistent. 
			
		ta incentive2008 inc2011 // no 2011_control in 2008_info, no 2011_jobleads in 2008_control groups
			// thus the authors do not recommend splitting the takeup rates for 2011 into specific categories
			// but rather focusing on incentivized vs non-incentivized. 
		drop if missing(incentive2008)

		gen cash = incentive2008 == 1
		gen credit = incentive2008==3
		gen info = incentive2008==4
		gen control = incentive2008==2
		
		rename incentivized2008 incentivized
		rename migrate2011 migrant
		}
		

	gen unincentivized = incentivized
	recode unincentivized (0=1) (1=0)
	local r`round'vars incentivized cash credit unincentivized info control difference 
	matrix allr`round' = J( 2 , 1 , . ) 
	mat blanks = J( 2, 1, .)
	foreach col in `r`round'vars' {
		if "`col'"!="difference" {
			tabstat migrant, by(`col') stat(mean sem) save
			tabstatmat c			// save results of tabstat into a matrix 
			matrix b = c[2,1...] 	// second row of matrix c has mean and std error for `var' == 1
			mat a = b' 				// transpose matrix to get SE underneath mean
			mat colnames a = `col'
			matrix allr`round' = allr`round' , a //, blanks	// add current results to last column of matrix
			*mat drop a b c 			// clear out matrices to go through loop again
			}
		else {
			reg migrant incentivized
			mat x = r(table)		// save regression results
			mat y = x[1..2,1]		// save just difference and SE in matrix y
			mat colnames y = "Diff (I-NI)"
			matrix allr`round' = allr`round', y		// append this to the "all" table at the end
			mat drop x y 			// clear out matrices
			}
		}
		*
	mat rownames allr`round' = "Migration Rate in `year`round''" "r`round' "

}
*

matrix ALL  = allr2 \ allr3 \ allr4
mat ALL = ALL[1...,2...]
matmap ALL ALL2, map(round(@,.0001)) // round to 4 digits for ease of excel-ing
loc x =colsof(ALL2)
forvalues i = 2(2)6 {
	forvalues j = 1/`x' {
		mat ALL2[`i',`j']=100*ALL2[`i',`j']   // multiply std errors by 100 to match betas once they are in % form
		}
	}
forval i=1(2)5 {
	mat ALL2[`i',`x'] = 100*ALL2[`i',`x'] // multiply Diff coeffs by 100 to match means in % form
	}
/* After tabbing out to excel: you must:
1) format all betas as percent 
2) manually add stars. See log file for significance levels.
*/
#delimit ;

xml_tab ALL2 using "$tb/Table2.xml", sheet(Table2) replace long
	title(Table 2: Program Take-up Rates) 
	font("Calibri" 10) format((SCCR0 NCCR2)) lines(SCOL_NAMES 3 LAST_ROW 3 COL_NAMES 2) 
	cblanks(0 1 2 3 4 5 6 7)  
	cwidth(0 160, 1 5, 2 60, 3 5, 4 60, 5 5, 6 60, 7 5, 8 65, 9 5, 10 60, 11 5, 12 60, 13 5, 14 60) 
	note("Standard errors reported below means/differences, already multiplied by 100 to match %",
	"Must add stars and parantheses manually. Convert means to %." ,
"P-value is obtained from the testing difference between migration rates of incentivized and 
non-incentivized households, regardless of whether they accepted our cash or credit.
No incentives were offered in 2009. For re-migration rate in 2011, we compare migration rates in control
villages that never received any incentives to villages that received incentives in 2008 but not in 2011.
Migration was measured over a different time period in 2011 than in 2008 or 2009.  ");

#delimit cr
