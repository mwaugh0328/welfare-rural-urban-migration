/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Creates Table Appendix Table 6 - Migrant Characteristics by Destination and Sector
	
	Note: Columns and rows are transposed from what appears in the paper. 
	*************************************************************************** */
clear
mat drop _all
set more off

use "$dta/migration_destinations_migration_survey.dta" , clear

recode b1_5 (13=1 Dhaka) (38=2 Mush) (63=3 Tang) (6=4 Bogra) (nonmissing = 5 Other), gen(migr_town)
tab migr_town, gen(migr_town_)
forval x= 1/5 {
	la var migr_town_`x' "`: label migr_town `x''"
	}


* Occupations at different destinaitons
recode b1_62 (6 = 1 Agr) (24 = 2 "Non ag day labor") (15 = 3 Transport) (nonmissing = 4 Other), gen(occ)
ta occ, gen(occ)
forval x = 1/4 {
	la var occ`x' "`: label occ `x''"
	}


* outlier of total cash earning
sum b1_64, d
gen outlier=1 if b1_64>=`r(p99)'
assert b1_64<25000 if outlier!=1


egen totearn=rowtotal(b1_64 b1_65)
replace totearn=. if outlier==1
tabstat totearn if outlier!=1, stat(mean sem) by(migr_town) save
tabstatmat EarnCity
mat EarnCity = EarnCity'




/* Table */
mat drop _all
levelsof occ, local(levels)
foreach level of local levels {

	tabstat occ1 occ2 occ3 occ4 totearn if migr_town==`level', stat(mean)  save
	tabstatmat MEAN
	mat rownames MEAN = "`: label migr_town `level'' Mean "
	mat colnames MEAN = "Agr" "Non ag day labor" "Transport" "Other" "Total Earnings City"
	matmap MEAN MEAN, map(@*100) // to represent % 
	loc cols = colsof(MEAN)
	mat MEAN[1,`cols'] = MEAN[1,`cols']/100 // don't need to multiply mean earnings
	
	tabstat occ1 occ2 occ3 occ4 totearn if migr_town==`level', stat(sem)  save
	tabstatmat SEM
	mat rownames SEM = "`: label migr_town `level'' Std Err"
	mat colnames SEM = "Agr" "Non ag day labor" "Transport" "Other" "Total Earnings City" 
	matmap SEM SEM, map(@*100) // to represent % 
	loc cols = colsof(SEM)
	mat SEM[1,`cols'] = SEM[1,`cols']/100 // don't need to multiply mean earnings
	
	tabstat occ1 occ2 occ3 occ4 totearn if migr_town==`level', stat(N)  save
	tabstatmat N
	mat rownames N = "`: label migr_town `level'' Number"
	mat colnames N = "Agr" "Non ag day labor" "Transport" "Other" "Total Earnings City" 
	
	mat B = MEAN \ SEM \ N
	mat A = nullmat(A)\ B

	}

	
tabstat totearn, stat(mean) by(occ) save nototal
tabstatmat EarnOcc
mat EarnOcc = EarnOcc \ .
mat rownames EarnOcc =  "Agr" "Non ag day labor" "Transport" "Other" "Total Earnings City" 
mat colnames EarnOcc = "Mean"
tabstat totearn, stat(sem) by(occ) save nototal
tabstatmat EarnOccSE
mat EarnOccSE = EarnOccSE \ .
mat rownames EarnOccSE =  "Agr" "Non ag day labor" "Transport" "Other" "Total Earnings City" 
mat colnames EarnOccSE = "SE"
mat X = EarnOcc' \ EarnOccSE'

mat A = A \ X



xml_tab A using "$tb\at6", replace ///
title("Summary Stats")   ///
sheet(by incentivized, color(1)) /// 
line(COL_NAMES 2 LAST_ROW 13) cwidth(0 250, 1 100, 2 100, 3 100, 4 100, 5 100, 6 100) ///
font("Times New Roman" 11) format((S2100) (N2202))
