/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Table 4. 
	Migrant Earnings and Savings at Destination (Data for Migrants Only; Non-Experimental) 	
	
	Note: Column order must be manually adjusted. Difference I-NI outputs on a separate sheet; 
		significance stars must be added manually. 

	*************************************************************************** */
clear
mat drop _all
set more off
	
use "$dta/Round2.dta", clear

sum  total_duration_hh

*excludes outliers - only 1 or 2 per variable
clonevar x_tot_sav=tsaving_hh
replace x_tot_sav=. if tsaving_hh>20000		/* exclude over 20,000 */

clonevar x_tot_earn=tearning_hh
replace x_tot_earn=. if x_tot_earn>120000	/* exclude over 120,000 */

clonevar x_sav_pd=hh_svg_perday_avrg		/* exclude over 500*/
replace x_sav_pd=. if x_sav_pd>500

clonevar x_earn_pd=hh_erng_perday_avrg
replace x_earn_pd=. if x_earn_pd>700

clonevar x_remit_pd=hh_rmtcs_perday_avrg

egen x=rsum(food_cost_hh_perepi travel_cost_hh_perepi)
replace x=. if migrant==0 | migrant==.
rename x x_trav_pe
la var x_trav_pe "One-way Travel Cost per Episode"

global vars "x_tot_sav x_tot_earn x_sav_pd x_earn_pd x_remit_pd x_trav_pe"

loc rnames
foreach var in $vars {
	local lbl : var label `var'
	local rnames `"`rnames' "`lbl'" "'
	}
	
qui tabstat $vars, stat(mean sem N) by(incentivized) save
qui tabstatmat C


xml_tab C using "$tb\t4", replace ///
	title("Summary Stats")    ///
	sheet(sum, color(1))  rnames(`rnames') ///
	line(COL_NAMES 2 LAST_ROW 13) cwidth(0 250, 1 100, 2 100, 3 100, 4 100, 5 100, 6 100) ///
	font("Times New Roman" 11) format((S2100) (N2202))

foreach i in $vars {
	qui reg `i' incentivized 
	mat reg = r(table)
	mat C = reg[1..2, 1]' // coefficient and std error of regression
	mat p = reg[4,1] // p value from the regression above 
  	mat D = nullmat(D) \ C, p
	}

mat colnames D = Difference SE Pvalue
	
xml_tab D using "$tb\t4", append ///
	title("difference I v NI")   ///
	sheet(Diff, color(1))  rnames(`rnames') ///
	line(COL_NAMES 2 LAST_ROW 13) cwidth(0 250, 1 100, 2 100, 3 100, 4 100, 5 100, 6 100) ///
	font("Times New Roman" 11) format((S2100) (N2202))



	
