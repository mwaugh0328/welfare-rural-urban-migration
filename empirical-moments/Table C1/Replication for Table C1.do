/***************************************************************
Replicating Table C1
****************************************************************/

clear all

ssc install outreg2
ssc install estout

* cd "C:\Users\hm526\Y-RISE Dropbox\Harrison Mitchell\LMW Replication\Table 13\"

cd "${path}/Table C1/"


*Household level data and main data frame

use "Monga_Endline_data_2014 - revised.dta", clear


rename s1_q5 village
rename s1_1_q3_01 sex
rename s1_1_q5_1_01 age

*dropping personal info
drop s1_*

******************************************************************/
			*Cleaning Data
******************************************************************/

label define treat 0 control 1 treatment

*Village level data frame for selecting subset of sample, second data frame

preserve

	use "Round 2 (2008).dta", clear
	drop if village ==.
	collapse (mean) incentivized , by(village) // treatment status by village
	rename incentivized control_status_2008
	label values control_status_2008 treat
	*only keeping control villages (includes info villages)
	drop if control_status_2008 ==1
	tempfile control_villages
	save `control_villages'

restore	

*Pulling treatment status of villages from info in Round 2.dta

merge m:1 village using `control_villages', nogen



*frget control_status_2008, from(villages)

*drops all non control observations, per LMW's description
drop if control_status_2008 !=0 

*Only keeping id info and DCE questions

keep village control_status_2008 hhid interview s0_q1 survey_3__check s16* sex age

*Dropping unsucessful surveys

foreach var in survey_3__check s16aq1 s16aq2 s16aq3 s16aq3 s16bq0_1 s16bq1_1 s16bq2_1 s16bq3_1 s16bq4_1 s16bq5_1 s16bq6_1 {
	drop if `var' ==. | `var' == -33
}

*Dropping everyone that's not a male between 14-60
keep if sex == 1
keep if age > 14 & age <=60

*Dropping irrational respondents
drop if s16aq1-2 == 2
drop if s16aq3 ==1

*Preparing data for reshape 

keep hhid village survey_3__check s16bq1_1 s16bq2_1 s16bq3_1 s16bq4_1 s16bq5_1 s16bq6_1


tempfile preshape
save `preshape'

*Importing choice profiles

preserve

	import delimited "Choice_Profiles_MailMerge", clear
	rename csurvey survey_3__check
	tempfile csurv
	save `csurv'

restore

merge m:1 survey_3__check using `csurv', nogen

*Reshaping data

forval i=1(1)6{
	rename s16bq`i'_1 c`i'_answer
	}
	
tempfile master
save `master'

forval i = 1(1)6 {
	use `master'
	keep hhid survey_3__check c`i'*
	rename c`i'_* *
	tempfile `i'st
	save ``i'st'
}

use `1st'

forval i = 2(1)6 {
	append using ``i'st'
	}

*Renaming for convenience

rename chanceofemployment* employ_perc*
rename dailywagetaka* wage*
rename friendsfamilyatlocation* latrine*
rename returnfrequency* fam_visit*


*Encoding all string variables
label define perc 0 "33" 1 "66" 2 "100" 
label define vist 0 "See Family Every 2 Months" 1 "See Family Every Month" 2 "See Family Every 2 Weeks" 
label define lat 0 "Walk to Open Defecate or Public Pay Toilet" 1 "Pucca Latrine in Residence"

*chance of employment
forval i = 1(1)2 {
	gen ep`i' = 0
	replace ep`i'=1 if employ_perc`i'=="66%"
	replace ep`i'=2 if employ_perc`i'=="100%"
}
label values ep* perc

forval i = 1(1)2 {
	gen vis`i' = 0
	replace vis`i'=1 if fam_visit`i'=="See Family Every Month"
	replace vis`i'=2 if fam_visit`i'=="See Family Every 2 Weeks"
}
label values vis* vist

forval i = 1(1)2 {
	gen lat`i' = 0
	replace lat`i'=1 if latrine`i'=="Pucca Latrine in Residence"
	label values lat`i' lat
}


*Creating Table C1
******************
capt prog drop appendmodels
program appendmodels, eclass
    // using first equation of model
    version 8
    syntax namelist
    tempname b V tmp
    foreach name of local namelist {
        qui est restore `name'
        mat `tmp' = e(b)
        local eq1: coleq `tmp'
        gettoken eq1 : eq1
        mat `tmp' = `tmp'[1,"`eq1':"]
        local cons = colnumb(`tmp',"_cons")
        if `cons'<. & `cons'>1 {
            mat `tmp' = `tmp'[1,1..`cons'-1]
        }
        mat `b' = nullmat(`b') , `tmp'
        mat `tmp' = e(V)
        mat `tmp' = `tmp'["`eq1':","`eq1':"]
        if `cons'<. & `cons'>1 {
            mat `tmp' = `tmp'[1..`cons'-1,1..`cons'-1]
        }
        capt confirm matrix `V'
        if _rc {
            mat `V' = `tmp'
        }
        else {
            mat `V' = ///
            ( `V' , J(rowsof(`V'),colsof(`tmp'),0) ) \ ///
            ( J(rowsof(`tmp'),colsof(`V'),0) , `tmp' )
        }
    }
    local names: colfullnames `b'
    mat coln `V' = `names'
    mat rown `V' = `names'
    eret post `b' `V'
    eret local cmd "whatever"
end

****************************

*Calculating predicted probabilities for C1

quietly mlogit answer i.ep* wage1 wage2 i.lat1 i.lat2 i.vis*, base(3) vce(cluster hhid)

** Prob Employ  **
quietly mlogit answer i.ep* wage1 wage2 i.lat1 i.lat2 i.vis*, base(3) vce(cluster hhid)
est store logitres

forval i=1(1)3 {

margins ep2, at(ep1=0 wage1=200 wage2=270 lat1=0 lat2=0 vis1=0 vis2=1) predict(outcome(`i')) post
eststo premp`i'
local numobvs`i' = r(N)
estimates restore logitres

}

** Fam Visit **
est restore logitres

forval i=1(1)3 {
margins vis2, at(ep1=0 ep2=1 wage1=200 wage2=270 lat1=0 lat2=0 vis1=0) predict(outcome(`i')) post
est store varyvis`i'

est restore logitres
}

** Latrine **

forval i=1(1)3 {

margins lat2, at(ep1=0 ep2=1 wage1=200 wage2=270 lat1=0 vis1=0 vis2=1) predict(outcome(`i')) post
est store varylat`i'
est restore logitres

}

*Grouping PP by migration options
forval i = 1(1)3 {
eststo bivar`i': appendmodels premp`i' varyvis`i' varylat`i'
estadd sca Observations = `numobvs`i''
}

* Now calculating ME portion of table
	* Prob of employment
est restore logitres

forval i = 1(1)3 {
margins, dydx(ep2) at(ep1=0 wage1=200 wage2=270 lat1=0 lat2=0 vis1=0 vis2=1) predict(outcome(`i')) post
est store meprob`i'

est restore logitres

}

	* Fam Visits
*est restore logitres

forval i = 1(1)3 {
margins, dydx(vis2) at(ep1=0 ep2=1 wage1=200 wage2=270 lat1=0 lat2=0 vis1=0) predict(outcome(`i')) post
est store mevis`i'

est restore logitres
}

	* Latrines
*est restore logitres

forval i = 1(1)3 {
margins, dydx(lat2) at(ep1=0 ep2=1 wage1=200 wage2=270 lat1=0 vis1=0 vis2=1) predict(outcome(`i')) post
est store melat`i'

est restore logitres
}	

	* Wages
*est restore logitres

forval i= 1(1)3 {
margins, dydx(wage2) at(ep1=0 ep2=1 wage1=200 lat1=0 lat2=0 vis1=0 vis2=1) predict(outcome(`i')) post
est store mewage`i'

est restore logitres

}

forval i = 1(1)3 {
eststo me`i': appendmodels meprob`i' mevis`i' melat`i' mewage`i'
estadd sca Observations = `numobvs`i''
}

* outputting as a csv, so the groupings for "Mig. Opp 1" "Mig Opp 2" "no Mig" will not merge across cells, see .tex output for that
*esttab bivar1 me1 bivar2 me2 bivar3 me3 using table13.csv, se replace ///
*mgroups("Migration Opp. #1" "Migration Opp. #2" "No Migration",pattern(1 0 1 0 1 0)) ///
*mtitle("PP" "ME" "PP" "ME" "PP" "ME") nonum stat(Observations) ///
*varlabels(0.ep2 "33% Prob. Employment" 1.ep2 "66% Prob. Employment" 2.ep2 "100% Prob. Employment" 0.vis2 "Family visit once in 60 days" 1.vis2 "Family visit twice in 60 days" 2.vis2 "Family visit 4 times in 60 days" 0.lat2 "No Latrine in residence" 1.lat2 "Pucca Latrine in residence" wage2 "Daily Wage (Taka) Opp #2") starlevels(* .1 ** .05 *** .01)

*Here is a .tex output, given some symbols used there will be edits that need to be done for style
esttab bivar1 me1 bivar2 me2 bivar3 me3 using table13.tex, se replace ///
mgroups("Migration Opp. #1" "Migration Opp. #2" "No Migration",pattern(1 0 1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
mtitle("PP" "ME" "PP" "ME" "PP" "ME") nonum stat(Observations) ///
varlabels(0.ep2 "33% Prob. Employment" 1.ep2 "66% Prob. Employment" 2.ep2 "100% Prob. Employment" 0.vis2 "Family visit once in 60 days" 1.vis2 "Family visit twice in 60 days" 2.vis2 "Family visit 4 times in 60 days" 0.lat2 "No Latrine in residence" 1.lat2 "Pucca Latrine in residence" wage2 "Daily Wage (Taka) Opp #2") starlevels(* .1 ** .05 *** .01)
