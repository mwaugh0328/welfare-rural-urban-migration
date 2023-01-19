/*****************************************************************
Replicating and Bootstrapping Consumption Growth
******************************************************************/

clear all

cd "${path}/Table 5/"

******************************************************************/
			*Cleaning Data
******************************************************************/
*2008
use "data/No Lean Season_Round2.dta", clear
keep hhid village upazila migrant migrant_new average_exp* incentive cash credit info control
gen year = 2008
encode incentive, generate(incentive2008)
drop incentive
rename migrant migrated
merge 1:1 hhid using  "data/No Lean Season_Round1_Savings", ///
	keepusing(assets_own_r1 tsave_d_r1) gen(_msav)
drop if _msav == 2

tempfile data08
save `data08'
isid hhid

*2009
use "data/No Lean Season_Round3.dta", clear
keep hhid village upazila migrant_r3 average_exp* cash credit info control 
gen year = 2009
rename migrant_r3 migrated

*append years
append using `data08'

isid hhid year

*egen add treatment groups to all years
egen mininc2008 = min(incentive2008), by(hhid)
replace incentive2008 = mininc2008 if incentive2008 == .
gen incentivized2008 = incentive2008 == 1 | incentive2008 == 3
drop mininc*

gen log_average_exp1 = log(average_exp1)

merge m:1 hhid using "data/No Lean Season_Round1_Controls_Table1.dta", keepusing(exp_total_pc_r1)
drop if hhid==92 // very high values for food expenditure (and total), also calories due to very high fish expenditure

bys hhid (year): gen logconsGrowth1 = (log_average_exp1[_n + 1] - log_average_exp1[_n])
gen logconsGrowth1_r1 = log_average_exp1 - log(exp_total_pc_r1)

matrix m = J(4, 4, .) //(control, treatment) X (non-migrant, migrant)
loc j = 0
foreach m in migrated {
	foreach i in 1 {
			loc ++ j
			sum logconsGrowth`i'_r1 if incentivized == 0 & `m' == 0 &  year == 2008
			matrix m[`j', 1] = `r(sd)'^2
			sum logconsGrowth`i'_r1 if incentivized == 0 & `m' == 1 & year == 2008
			matrix m[`j', 2] = `r(sd)'^2
			sum logconsGrowth`i'_r1 if incentivized == 1 & `m' == 0 &  year == 2008
			matrix m[`j', 3] = `r(sd)'^2
			sum logconsGrowth`i'_r1 if incentivized == 1 & `m' == 1 & year == 2008
			matrix m[`j', 4] = `r(sd)'^2
	}
}
tempfile d
save `d' , replace
clear
svmat m
rename (m1 m2 m3 m4) (control_stayer control_migrant treatment_stayer treatment_migrant)
export excel using "consgrowth_final.xlsx", first(variables) replace
