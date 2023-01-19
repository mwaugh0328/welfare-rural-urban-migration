/***************************************************************
Replicating Table 4
****************************************************************/

clear all

cd "${path}/Table 4/"

use "data/section3_1.dta", clear

rename HHID hhid

collapse (sum) Q31_3 Q31_7 , by(hhid)

merge 1:1 hhid using "data/No Lean Season_Round1_Savings"

*for missing merges assuming that this means they have no land holdings
	*and therefore no land value
	
replace Q31_3 = 0 if Q31_3 == .

replace Q31_7 = 0 if Q31_7 == .

merge 1:1 hhid using "data/No Lean Season_Round1_Controls_Table1" , nogen

merge 1:1 hhid using "data/No Lean Season_Round2.dta" , nogen

*Share of ppl who can't afford bus ticked (savings < 800)

la var tsaving_hh_r1 "Savings"

drop if tsaving_hh_r1 == .

*determining cutoffs by savings

gen one_bus_1 = (tsaving_hh_r1 >= 800)

*making table 4

xtile consumption_group = exp_total_pc_r1, n(2)

cap file close _all 

file open ofile using "ctrl_mig_2x2.tex", write replace

{ // tex table top
file write ofile ///
"\begin{tabular}{c l | c c}" _n ///
"\toprule" _n ///
" & & \multicolumn{2}c{Savings} \\" _n ///
" & & $\leq$ 1 bus ticket & $>$ 1 bus ticket \\" _n ///
"\midrule" _n // 
}

{ // tex table body

preserve

keep if incentivized == 0

sum migrant if one_bus_1 == 0 & consumption_group == 1
local mean_11 = string(r(mean), "%10.3f")
dis `mean_11'

sum migrant if one_bus_1 == 1 & consumption_group == 1
local mean_21 = string(r(mean), "%10.3f")
dis `mean_21'

sum migrant if one_bus_1 == 0 & consumption_group == 2
local mean_12 = string(r(mean), "%10.3f")
dis `mean_12'

sum migrant if one_bus_1 == 1 & consumption_group == 2
local mean_22 = string(r(mean), "%10.3f")
dis `mean_22'

file write ofile "\multirow{2}{*}{Consumption} & Low & `mean_11' &  `mean_21' \\" _n ///
	
file write ofile " & High & `mean_12' & `mean_22' \\" _n ///
	
restore	

}


{ // tex table bottom 
file write ofile ///
"\bottomrule" _n ///
"\multicolumn{4}{l}{Savings split by whether the household could afford an 800 taka bus ticket} \\" _n ///
"\multicolumn{4}{l}{Consumption split by median value} \\" _n  ///
"\end{tabular}"
file close _all
}
