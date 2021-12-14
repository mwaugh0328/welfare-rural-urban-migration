/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Table 7. 
	
	Note: There are two ways to create the output. Both produce similar results, and both require
	additional manipulation in Stata. 
	*************************************************************************** */
version 12.1
clear
mat drop _all
set more off

/*     ======================================================================================
Table 7. Differences in Characteristics Between Migrants in Treatment and in Control Group
=============================================================================================*/   

/*********************
DATA PREP
***********************/

use "$dta\Round2.dta", clear

/* Create variables based on all migration episodes */
*Know anyone at destination
egen know_any = rowmax(know_someone_first know_someone_second know_someone_third ///
	know_someone_fourth know_someone_fifth know_someone_sixth)
	
replace know_any = . if migrant!=1 // missing if not a migrant, or missing migrant indicator

label var know_any "Know someone, all episodes" 

*Job lead at Destination
egen lead_any = rowmax(lead_job_first lead_job_second lead_job_third ///
	lead_job_fourth lead_job_fifth lead_job_sixth)
 
replace lead_any = . if migrant!=1 // missing if not a migrant, or missing migrant indicator

label var lead_any "Job lead, all episodes"

*Traveling alone
egen travel_any = rowmax(travel_alone_first travel_alone_second ///
	travel_alone_third travel_alone_fourth travel_alone_fifth travel_alone_sixth)
 
replace travel_any = . if migrant!=1 // missing if not a migrant, or missing migrant indicator
	
label var travel_any "Travel alone, all episodes"

/* Summary statistics */

gl vars know_someone_first know_any lead_job_first lead_any  travel_alone_first travel_any  

local incent incentivized
recode incentivized (0=1) (1=0), gen(unincentivized) // so difference will be nonincent - Incent


**************************************OUTPUT OPTION 1**************************************
foreach i in $vars {
	qui reg `i' if `incent'==1
	est store `i'_1
	qui reg `i' if `incent'==0
	est store `i'_2
	qui reg `i' unincentivized
	est store `i'_3
	xml_tab `i'_1 `i'_2 `i'_3 using "$tb\tempstars.xml", below replace long savemat(stars, replace)
	
	matrix a = stars[3..4,1..2]
	matrix b = stars[1..2,3...]
	matrix `i' = a,b
	
	matrix c = (0,0\0,0)
	matrix d = stars_STARS[1..2,3...]
	matrix `i'_STARS = c,d

	}

local count : word count $vars

foreach var of varlist $vars { 
	local lbl : variable label `var' 
	local rnames `"`rnames'  "`lbl'" " " "' 
	* " 
	} 
	
matrix X = J(1,3,.)
matrix X_S = J(1,3,.)

forvalues i = 1/`count' {
	local n : word `i' of $vars 
	matrix X = X \ `n' 
	matrix X_S = X_S \ `n'_STARS
	}

matrix Y = X[2...,1...]
matrix Y_STARS = X_S[2...,1...]

local rows = `count'*2

matrix table = J(`rows',3,.)
matrix table_STARS = J(`rows',3,.)

forvalues r = 1/`rows' {
	forvalues c = 1/3 {
		matrix table[`r',`c'] = Y[`r',`c']
		matrix table_STARS[`r',`c'] = Y_STARS[`r',`c']
		}
	}
	
matrix drop X X_S Y Y_STARS

# delimit ;

	xml_tab table using "$tb\t7.xml", replace sheet(method1) 
	title("Table 7: Differences in Characteristics Between Migrants in Treatment and in Control Group") 
	cnames("Incentive" "Non Incentive" "Diff (NI - I)") rnames(`rnames')   
	line(COL_NAMES 2 LAST_ROW 13) cwidth(0 300) mv("")
	font("Times New Roman" 11) format((S2100) (N2203)) 
	note("*** p<0.01, ** p<0.05, * p<0.1. Must add parantheses manually. 
	Convert means in Incentive and NonIncentive cols to %." ,
	"Standard errors reported below means/differences, already multiplied by 100 to match %");;


# delimit cr

erase "$tb\tempstars.xml"
mat drop _all

*******************************************OUTPUT OPTION 2****************************
	mat drop _all
	foreach i in $vars {
	
		loc label : var lab `i'
	
		tabstat `i', by(unincentivized) s(mean sem) nototal save
		tabstatmat s // save results of tabstat into a matrix 
		mat s[1,2] = 100*s[1,2] // multiply std errors by 100 to match betas once they are in % form
		mat s[2,2] = 100*s[2,2] // multiply std errors by 100 to match betas once they are in % form
		mat s=s' // transpose matrix to get SE underneath mean

				
		reg `i' unincentivized
		mat x = r(table)		// save regression results
		mat y = x[1..2,1]		// save just difference and SE in matrix y
		mat y = 100*y // multiply by 100 to match group means once they are in % form
		
		matrix s = s , y	// append regression results to the right of sum stats
		
		*mat colnames s = "Non incentive" "Incentive" "Diff (NI - I)"
		mat rownames s = "`i'mean" "`i'SE"
		
		matrix allvar = nullmat(allvar) \ s // add current results below the full matrix of all vars
		mat drop x y 		// clear out matrices
		
		}
		
	
/* After tabbing out to excel: you must:
1) format all betas as percent 
2) multiply betas in final column by 100
3) manually add stars. 
*/


# delimit ;


xml_tab allvar using "$tb\t7.xml", append sheet(tabstat method)
	title("Table 7: Differences in Characteristics Between Migrants in Treatment and in Control Group") 
	cnames("Incentive" "Non Incentive" "Difference") 
	rnames("First Episode" " " "Any Episode" " "
	"First Episode" " " "Any Episode" " " "First Episode" " " "Any Episode" " ")   
	rblanks(COL_NAMES "Panel A: Percentage of Migrants that Know Someone at Destination", 
	know_anySE "Panel B: Percentage of Migrants that had a Job Lead at Destination",
	lead_anySE "Panel C: Percentage of Migrants Traveling Alone")
	cblanks(0 1 2)
	line(COL_NAMES 2 LAST_ROW 13) cwidth(0 300) mv("")
	font("Times New Roman" 11) format((S2100) (N2203)) 
	note("Must add stars and parantheses manually. Convert means in Incentive and NonIncentive cols to %." ,
	"Standard errors reported below means/differences, already multiplied by 100 to match %");


# delimit cr
