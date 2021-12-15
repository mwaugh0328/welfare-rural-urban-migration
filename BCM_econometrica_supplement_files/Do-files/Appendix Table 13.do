/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Appendix Table 13a panels A and B and Appendix Table S13b.
	
	*************************************************************************** */
version 12.1
clear
mat drop _all
set more off

/*     ======================================================================================
Appendix Table 13a. Destination Choices of Re-Migrants	
13b. First Stage						 						
=============================================================================================*/   

use "$dta/Round2_3_migration_dest", clear

****LABEL VARIABLES FOR TABLE

la var cash "Cash"
la var credit "Credit"
la var info "Info"
la var self_formed "Group formation - self-formed"
la var assigned "Group formation - assigned"
la var two "Group formation - two people"
la var destination_assigned "Destination assigned"
	foreach v in Dhaka Bogra Tangail {
		la var assign_`v' "Assigned to `v'"
		}
la var assign_Mush "Assigned to Munshigonj"

gl random1 assign_Bogra assign_Dhaka assign_Mush 
gl random2 cash credit info destination_assigned
gl random3 cash credit info self_formed assigned two destination_assigned  /* note: omit indiv */
gl random4 cash credit info self_formed assigned two assign_Bogra assign_Dhaka assign_Mush assign_Tang


/* note: dependent variable is=1 if went to the destination in R3; 
destination is where you migrated, instrumented with the initial assignment
*/

*---------------------------------------------------------------------------------------
 /* Migration destionation in R3 as a function of migration to the same place in R2, 
	instrumented by the full set of instruments; only for migrants in 2008 and 2009 */
*---------------------------------------------------------------------------------------

loc outregoptions coefastr excel label dec(3) drop(_I*) \`append'
loc outregoptions2 coefastr excel label dec(3) drop(_I*) \`append2'
loc append replace
loc append2 replace

* Panel A: Dep Var Migrated in 2009 to:
foreach loc in Dhaka Bogra Tangail Mush {
	xi: reg R3_`loc' R2_`loc' i.upazila, cl(village)
		outreg2 using "$tb\AT13aA",  `outregoptions' ctitle(`loc', OLS) 
		loc append append
		gen sample=e(sample)

	xi: ivreg2 R3_`loc' (R2_`loc'=$random3 assign_`loc') i.upazila, cl(village) savefirst
		matrix A=e(first)
		scalar Ftest=A[3,1]
		scalar Pvalue=A[6,1]
		scalar R2partial=A[2,1]
	 outreg2 using "$tb\AT13aA", `outregoptions' ctitle(`loc',IV) ///
		addstat("1st F-test", Ftest, "1st pvalue", Pvalue, "1st partial R2", R2partial, "Hansen J0", e(j)) 
		
	estimates restore _ivreg2_R2_`loc'
	outreg2 using "$tb\AT13b", `outregoptions2' ctitle(`loc') ///
		addstat("1st F-test", Ftest, "1st pvalue", Pvalue, "1st partial R2", R2partial) 
	loc append2 append

		drop sample
	}

erase "$tb\AT13aA.txt"
erase "$tb\AT13b.txt"

**Bring in 2011 data

merge 1:1 hhid using "$dta/Round4_migration_dest"
	
sort hhid	
gen hhid2= hhid
replace hhid2=round(hhid2, 1)

foreach var in assign_Bogra assign_Dhaka assign_Mush assign_Tangail ///
	cash credit info control self_formed assigned destination_assigned ///
	R2_Bogra R2_Dhaka R2_Mush R2_Tangail R3_Dhaka R3_Bogra R3_Tangail R3_Mush ///
	destination_r2 destination_r3 migrant_r3 {
		bysort hhid2: replace `var'=`var'[_n-1] if missing(`var') // for split households
		}
		*

***Panel B. Dep Var: Migrated in 2011 to:

loc append replace
foreach loc in Dhaka Bogra Tangail Mush {
	xi: reg R4_`loc' R2_`loc' i.upazila, cl(village)
		outreg2 using "$tb\AT13aB", `outregoptions' ctitle(`loc', OLS)
		loc append append

	xi: ivreg2 R4_`loc' (R2_`loc'=$random3 assign_`loc') i.upazila, cl(village)  savefirst
		matrix A=e(first)
		scalar Ftest=A[3,1]
		scalar Pvalue=A[6,1]
		scalar R2partial=A[2,1]
	outreg2 using "$tb\AT13aB", append excel se dec(3) ctitle(`loc',IV) drop(_I*) ///
		addstat("1st F-test", Ftest, "1st pvalue", Pvalue, "1st partial R2", R2partial, "Hansen J0", e(j)) 
	}

erase "$tb\AT13aB.txt"

