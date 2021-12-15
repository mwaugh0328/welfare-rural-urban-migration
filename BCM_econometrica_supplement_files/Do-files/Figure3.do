/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates figure 3. 
	
	Note: This can be easily modified to test the effect of different incentive amounts, migration costs
		# household members, expenditures, etc, by editing lines 40-60.
	*************************************************************************** */
	
clear
capture log close
set more off 

/*     ==========================================================================================   
FIGURE 3 - Distribution of Consumption in Control Villages subtracted from Distribution of Consumption
	in Treatment Villages 
========================================================================================== 	 */ 


{
// create dataset with values 100 to 4000 to represent the cutoffs of consumption
tempname cutfile
postfile `cutfile' cut using "$dta\support\cutfile", replace
forvalues time = 100(100)4000 {
	post `cutfile' (`time') 
       
}

postclose `cutfile'

{ // Panel A
// setup using the values of # hh members, amount of incentive to subtract from expenditure

use "$dta\Round2.dta", clear
	drop if hhid==92 // outlier
	
	// insert amount of incentive you want to use 
	scalar sca_incent 	= 	600
	local lincent = sca_incent
	
	// denominator you want to use 
	clonevar 	num_hh_members 	= total_home_int_2 
	loc denom : var lab num_hh_members
	
	// incentive per capita
	gen incent_pc = sca_incent / num_hh_members
	
	// expenditures per capita per month, using # people home in last 7 days
	clonevar new_exp = average_exp2
	
	// expenditures per capita, net of incentive per capita for those who received incentive
	replace new_exp = new_exp - incent_pc if incentivized==1 & migrated==1
	
	loc note "Incentive of `lincent' taka subtracted from total monthly expenditures of incentivized migrant households " 
	loc note2 "and dividing by `denom'." 
	*loc note " "Incentive of `lincent' taka, divided by `denom'," "subtracted from per capita expenditures of incentivized migrant households." "
	
	*

// generate treatment distribution
preserve
egen treat_distribution=cut(new_exp) if incentivized==1, at(100(100)4000)
tab treat_distribution, matcell(treat) matrow(X)
mat tdist = X, treat
svmat tdist
keep if !mi(tdist1) & !mi(tdist2)
keep tdist*
tempfile treatdist
rename tdist1 cut
rename tdist2 treatment_freq
save `treatdist'
restore 

// generate control distriubtion
egen control_distribution=cut(new_exp) if incentivized==0, at(100(100)4000)
tab control_distribution, matcell(control) matrow(Y)
mat cdist = Y, control
svmat cdist
keep if !mi(cdist1) & !mi(cdist2)
keep cdist*
tempfile contdist
rename cdist1 cut
rename cdist2 control_freq
save `contdist'

//combine all 
use "$dta\support\cutfile", clear
merge 1:1 cut using `treatdist', nogen
merge 1:1 cut using `contdist', nogen

mvencode _all, mv(0) // fill in space where there is no distribution with a 0

sum treatment_freq
scalar treat_sum = r(sum)
gen treatment_dist = treatment_freq/treat_sum // % of treatment group in each cut

sum control_freq
scalar control_sum = r(sum)
gen control_dist = control_freq/control_sum // % of control group in each cut

gen T_minus_C = treatment_dist - control_dist // Difference of Treatment and Control



twoway bar T_minus_C cut, ///
barwidth(60) color(gs2) ///
title("Panel A: Risk if the cost of migration were borne by household", span color(black)) ///
ytitle("Percentage point difference in distribution") xtitle("Expenditures in Taka per person per month") ///
xlabel(0(250)3750, angle(vertical) ) ///
ylabel(-0.03(.01)0.03) scale(.8) ///
xline(450 660, lstyle(foreground)) ///
note("`note'" "`note2'" "Lines at 450 and 660 taka per person per month.", span)
graph export "$fg\Figure 3 Panel A.png", replace

}
*

{ // Panel B



use "$dta\Round2.dta", clear
	drop if hhid==92 // outlier
	
	// expenditures per capita per month, using # people home in last 7 days
	clonevar new_exp = average_exp2

	loc note "No adjustment made for value of incentive given."
	
	*

// generate treatment distribution
preserve
egen treat_distribution=cut(new_exp) if incentivized==1, at(100(100)4000)
tab treat_distribution, matcell(treat) matrow(X)
mat tdist = X, treat
svmat tdist
keep if !mi(tdist1) & !mi(tdist2)
keep tdist*
tempfile treatdistB
rename tdist1 cut
rename tdist2 treatment_freq
save `treatdistB'
restore 

// generate control distriubtion
egen control_distribution=cut(new_exp) if incentivized==0, at(100(100)4000)
tab control_distribution, matcell(control) matrow(Y)
mat cdist = Y, control
svmat cdist
keep if !mi(cdist1) & !mi(cdist2)
keep cdist*
tempfile contdistB
rename cdist1 cut
rename cdist2 control_freq
save `contdistB'

//combine all 
use "$dta\support\cutfile", clear
merge 1:1 cut using `treatdistB', nogen
merge 1:1 cut using `contdistB', nogen

mvencode _all, mv(0) // fill in space where there is no distribution with a 0

sum treatment_freq
scalar treat_sum = r(sum)
gen treatment_dist = treatment_freq/treat_sum // % of treatment group in each cut

sum control_freq
scalar control_sum = r(sum)
gen control_dist = control_freq/control_sum // % of control group in each cut

gen T_minus_C_panelB = treatment_dist - control_dist // Difference of Treatment and Control



twoway bar T_minus_C_panelB cut, ///
barwidth(60) color(gs2) ///
title("Panel B: Treatment minus Control Distribution" "(no adjustment for migration incentive)", span color(black)) ///
ytitle("Percentage point difference in distribution") xtitle("Expenditures in Taka per person per month") ///
xlabel(0(250)3750, angle(vertical) ) ///
ylabel(-0.03(.01)0.03) scale(.8) ///
xline(450 660, lstyle(foreground)) ///
note("Lines at 450 and 660 taka per person per month.", span)
graph export "$gr\Figure 3 Panel B.png" , replace
}
*
}
* end Figure 3

