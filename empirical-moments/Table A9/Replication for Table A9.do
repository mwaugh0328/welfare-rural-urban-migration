******************************************************************/
*Replicating Table 5
******************************************************************/

clear all

ssc install outtable

cd "${path}/Table A9/"

*2008
use "data/No Lean Season_Round2.dta", clear
keep hhid village upazila migrant migrant_new average_exp* incentive cash credit info control
gen year = 2008
encode incentive, generate(incentive2008)
gen incentivized08 = cash == 1 | credit == 1
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
egen minc08 = max(incentivized08), by(hhid)
replace incentivized08 = minc08 if missing(incentivized08)

gen m08 = migrated if year == 2008
egen mig08 = max(m08), by(hhid)



******************************************************************/

matrix b = J(2,2,.)
qui reg migrated if year == 2009 & control == 1 & mig08 == 1
matrix b[1,1] = _b[_cons]
matrix b[2,1] = _se[_cons]
qui reg migrated if year == 2009 & control == 1 & mig08 == 0
matrix b[1,2] = _b[_cons]
matrix b[2,2] = _se[_cons]

matrix colnames b = "$$P(Migrate_{2009}|Migrate_{2008})$" "$$P(Migrate_{2009}|NoMigrate_{2008})$"
matrix rownames b = "Mean" "SE"

outtable using "mig_tbl", mat(b) replace asis nobox ///
		cap("Migration probabilities in control group") center f(%9.3f)
		
