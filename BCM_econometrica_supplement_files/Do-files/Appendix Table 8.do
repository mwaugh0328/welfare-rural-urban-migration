/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Appendix Table 8. 
	
	*************************************************************************** */
version 12.1
clear
mat drop _all
set more off

/*     ======================================================================================
Appendix Table 8. Summary Statistics on Household Savings							 						
=============================================================================================*/   

***************DATA SETUP - MERGE ROUNDS
	use "$dta/Round1_Savings", clear
	
	merge 1:1 hhid using "$dta/Round2_Savings"
	
	sort hhid
	gen hhid2=round(hhid, 1) // household splits got a decimal (ie household 123 would split to 123.1 and 123.2)
	
	foreach var of varlist tsaving_hh_r1 - tsave_d_r1 {
		bysort hhid2: replace `var'=`var'[_n-1] if missing(`var')
		}
	
	rename _merge merge1
	label def merge1 1 "Only in R1 but not in R2" 2 "Only in R2 (split) but not in R1" 3 "Both in R1 & R2"
	label val merge1 merge1
	
	drop hhid2
	
	merge 1:1 hhid using "$dta/Round4_Savings"
	
	gen hhid2=round(hhid, 1)
	
	foreach var of varlist tsaving_hh_r1 - merge1 {
		bysort hhid2: replace `var'=`var'[_n-1] if missing(`var')
		}
	
	/* dropping "new" households*/
	drop if hhid>1900
	
	rename _merge merge2
	label def merge2 1 "In R1 or R2 but not in R4" 2 "Only in R4 (split) but not in R1 or R2" 3 "Both in R1 or R2 & R4"
	label val merge2 merge2
	
	/* Reshaping from wide to long */
	
	reshape long tsave_d_r tsaving_hh_r assets_own_r assets_val_r assets_pur12m_r ///
		assets_purval_r tsave_assets_r, i(hhid) j(round)
	rename *_r *_all
	isid hhid round
	tempfile RoundAll_Savings
	save `RoundAll_Savings'
	
************* END DATA SETUP 

*********** REGRESSIONS

mat drop _all	
foreach round in r1 r2 r4 all { // no savings module in R3 

	if "`round'"=="r1" use "$dta/Round1_Savings", clear
	if "`round'"=="r2" use "$dta/Round2_Savings", clear
	if "`round'"=="r4" use "$dta/Round4_Savings", clear
	if "`round'"=="all" use `RoundAll_Savings', clear
	
	* Labeling for table output

	la var tsave_d_`round' "Share with positive current savings"
	
	recode tsaving_hh_`round' 0=., gen(t_pos_saving_hh_`round')
	la var t_pos_saving_hh_`round' "Total value of current cash savings for HHs with reported savings"
	la var tsaving_hh_`round'  "Total value of current cash savings for all HHs"
	la var assets_own_`round' "Share with liquid assets"
	la var assets_val_`round' "Total value of liquid assets for all HHs"
	
	recode assets_val_`round' 0=., gen(t_pos_assets_val_`round')
	la var t_pos_assets_val_`round' "Total value of liquid assets for HHs with reported savings"
	la var assets_pur12m_`round' "1 if purchased assets in last 12 months (all HHs)"
	la var assets_purval_`round' "Value of purchased assets in the last 12 months"
	la var tsave_assets_`round' "Total savings (current + liquid assets) for all HHs"
	recode tsave_assets_`round' 0=., gen(t_pos_save_assets_`round')
	la var t_pos_save_assets_`round' "Total savings (current + liquid assets) for all HHs with reported savings"
	
	
	/* Summary stats */
	#delimit ;
		
	loc vars tsave_d_`round' tsaving_hh_`round' t_pos_saving_hh_`round'  assets_own_`round' 
	assets_val_`round'  t_pos_assets_val_`round' assets_pur12m_`round' assets_purval_`round' 
	tsave_assets_`round' t_pos_save_assets_`round' ;
	
	#delimit cr
	
	tabstat `vars', stat(mean sd) save 
	   tabstatmat A  
	   matrix TA`round'=A'
	   
	tabstat tsave_d_`round' tsaving_hh_`round', stat(N) save
		tabstatmat N
		mat rownames N = "Obs"
		
	mat TA`round' = TA`round' \ N
	
	loc rnames
	foreach var in `vars' {
		local rnames `"`rnames' "`:var lab `var''" "'
		}
		*
	} // end round loop
	* end round loop
	
********* OUTPUT ALL TO ONE TABLE	
mat TA = TAr1, TAr2, TAr4, TAall

# delimit ;
xml_tab TA using "$tb/AT8", replace
title("Appendix Table 8. Summary Statistics on Households Savings")   
sheet(`round', color(1)) rnames(`rnames')
line(COL_NAMES 2 LAST_ROW 13) cwidth(0 250, 1 100, 2 100, 3 100, 4 100, 5 100, 6 100)
font("Times New Roman" 11) format((S2100) (N2202));

# delimit cr
