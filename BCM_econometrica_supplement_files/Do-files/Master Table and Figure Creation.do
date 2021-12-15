/* **************************************************************************
	May 2014
	
	"Under-investment in a Profitable Technology:
		The Case of Seasonal Migration in Bangladesh"
		by Gharad Bryan, Shyamal Chowdhury and Ahmed Mushfiq Mobarak
		
	Readme and Master Do-file to Create all Main Tables and Figures
	*************************************************************************** */
	
/*==========================================================================================
										TABLES
============================================================================================*/										

/* Table 1 Summary Stats */	
do "$dof/Table 1.do"

/* Table 2 Program Take-up Rates */
do "$dof/Table 2.do"

/* 
Table 3  Effects of Migration before December 2008 on Consumption Amongst Remaining Household Member
Appendix Table 1 First Stage: Migration as a Function of Treatments in 2008
Appendix Table 3 Effects of Migration in 2008 on Consumption in 2008; 
				 Sensitivity to Changes in Definition of Household Size
Appendix Table 4  Effects of Migration before December 2008 on Consumption Amongst Remaining Household Members

	All of the above tables are related: 
		AT 1 is the first stage from one of the regressions in Table 3.
		AT3 is a sensitivity test of Table 3, using different denominators to determind household size and per-capita
			variables
		AT4 returns to to the same denominator as Table 3, but with different consumption categories 
*/

do "$dof/Table 3 and App Table 1 3 and 4.do"

/* Table 4 Migrant Earnings and Savings at Destination */

do "$dof/Table 4.do"

/* Table 5. Treatment Effects in 2011 Accounting for Basis Risk in the Insurance Program */

do "$dof/Table 5.do"

/* Table 6. Learning from Own Experience and Others' Experiences in 2009 Re-migration Decision */

do "$dof/Table 6.do"

/* Table 7. Differences in Characteristics Between Migrants in Treatment and in Control Group 
Two output options are included. Both require some manipulation in excel. 
*/

do "$dof/Table 7.do"

/* Table 8. Parameters Used for Calibration.
Not a data table
*/

/*==========================================================================================
										FIGURES
============================================================================================*/		

/* Figure 1. Seasonality in Consumption and Price in Rangpur and in Other Regions of Bangladesh 

These graphs use data from the Bangladesh Bureau of Statistics 2005 Household Income and Expenditure Survey. */

/* Figure 2. Trial Profile and Timeline. 
Not a data table */

/* Figure 3. Distribution of Consumption in Control Villages subtracted from Distribution of Consumption
	in Treatment Villages */
	
do "$dof/Figure3.do"

/* Figure 4. Migration Experience in 2008 by re-Migration Status in 2009. */

do "$dof/Figure4.do"

/* Figure 5. Migration Experience in 2008 by re-Migration Status in 2009. */

do "$dof/Figure5.do"

/* Figure 6. Not a data figure. */

/*==========================================================================================
										APPENDIX TABLES
============================================================================================*/	

/* Appendix Table 2. Intensive and Extensive Margin Changes due to Incentive (Cash or Credit) */

do "$dof/Appendix Table 2.do"

/* Appendix Table 5. Effects of Migration in 2008 on Savings, Earnings and Changes in 
	Children's Middle Upper Arm Circumference (MUAC) */
	
do "$dof/Appendix Table 5.do"

/* Appendix Table 6 - Migrant Characteristics by Destination and Sector */

do "$dof/Appendix Table 6.do"

/*Appendix Table 8. Summary Statistics on Household Savings */

do "$dof/Appendix Table 8.do"

/* Appendix Table 13a. Destination Choices of Re-Migrants
	Appendix Table 13b. First Stage	*/
	
do "$dof/Appendix Table 13.do"
