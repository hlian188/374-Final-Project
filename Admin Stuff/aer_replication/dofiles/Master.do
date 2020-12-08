 ************************************************************************************
 * Master do-file
 ************************************************************************************
 
	clear all
	set more off
 
 
 
* Packages needed:

*  rdrobust
*  rdbwselect
*  dropmiss
*  estout
*  outreg2
*  ols_spatial_HAC (.ado file replication folder)
*  DCdensity (.ado file in replication folder)	

* Set globals:

	
 cap global dir = "D:\Dropbox\United Kingdom GIS\final\analysis\aer_replication"
	

************************************************************************************
* TABLES
************************************************************************************

* Table 1 "House characteristics (1853)"
* Table B1 "House characteristics (1853) with Conley (1999) Standard error"
* Covariate analysis of 1853 data using "houses_1853_final.dta"
* Pre-treatment covariate means and RD, with and without Conley SE

	qui: do "$dir\dofiles\Table_summary_stats.do"


*****************************************

* Table 2 "Change in Exposure to Cholera"
* Analysis of death data using "Merged_1853_1864_data.dta"

	qui: do "$dir\dofiles\Table_deaths.do"


*****************************************

* Table 3 "Boundary Effects on Rental Prices"
* Analysis of rental data using:
* 		"Merged_1853_1864_data.dta"
*		"Merged_1846_1894_data.dta"
*		"houses_1936_final.dta"
* Years: 1853, 1864, 1894, 1936

	qui: do "$dir\dofiles\Table_main_results.do"



*****************************************

* Table 4 "Boundary Effects on Residential Mobility"
* Analysis of mobility data using "Merged_1853_1864_data.dta"
* Years: 1864,1853

	qui: do "$dir\dofiles\Table_moved.do"


*****************************************

* Table 5 "Migration Patterns by Cholera Exposure"
* Analysis of migration out of neighborhood using "Merged_1853_1864_data.dta"
* Years: 1864,1853

	qui: do "$dir\dofiles\Table_migration.do"


*****************************************

* Table 6 "Boundary Effects on House Occupancy"
* Analysis of household characteristics using "Data_census.dta"
* Years: 1851,1861

	qui: do "$dir\dofiles\Table_census.do"


*****************************************

* Table 7 "Boundary Effects on House Socioeconomic Status"
* Analysis of household socioeconomic status using "final_booth_RG.dta"
* Years: 1899

	qui: do "$dir\dofiles\Table_Booth_data.do"


*****************************************

* Table 8 "Boundary Effects on House Prices, Zoopla Estimates"
* Analysis of house values using "houses_current_final.dta"
* Analysis of rental values using "current_rentals_final.dta"
* Years: 1995-2013, 2015

	qui: do "$dir\dofiles\Table_current_results.do"



************************************************************************************
* APPENDIX TABLES
************************************************************************************

* Table B1 "House characteristics (1853) with Conley (1999) Standard error"
* Note: See do-file for Table 1 


*****************************************

* Table B2 "Fuzzy RD and IV estimates"
* Analysis of rental data using "Merged_1853_1864_data.dta"
* Years: 1864

	qui: do "$dir\dofiles\Table_fuzzy_iv.do"


*****************************************

* Table B3 "False Treatment Boundaries"
* Falsification tests using "falsification_final.dta"
* Years: 1853,1864,1894,1936,current

	qui: do "$dir\dofiles\Table_false_boundaries.do"


*****************************************

* Table B4 "Differences in Rental Price, House Occupancy due to Cholera Exposure within BSP Area"
* Effect of cholera within boundary using "Merged_1853_1864_data.dta"
* Years: 1853,1864

	qui: do "$dir\dofiles\Table_stigma.do"


*****************************************

* Table B5 "Boundary Effects using John Snow's boundary definition"
* Analysis using John Snow's boundary ("Merged_1853_1864_data.dta")
* Years: 1853,1864,1894,1936,current

	qui: do "$dir\dofiles\Table_snow_definition.do"



************************************************************************************
* SUPPLEMENTARY APPENDIX TABLES (ONLINE)
************************************************************************************

* Table SA1 "Charles Booth class categorization"
* No Do-file (Text table)


*****************************************

* Table SA2 "Evaluating Evidence of Pre-Trends in Log Rental Prices (1846, 1853)"
* Pre-trends analysis using "Merged_1846_1894_data.dta"
* Years: 1846, 1853

	qui: do "$dir\dofiles\Table_pre_trends_DID.do"


*****************************************

* Table SA3 "Analysis using Segments without Sharp Change in Sewage Status"
* Rental data analysis dropping segments using "Merged_1853_1864_data.dta"
* Years: 1853, 1864

	qui: do "$dir\dofiles\Table_robustness_sewer.do"


*****************************************

* Table SA4 "Boundary Effects on House Occupancy Characteristics: Irish Immigrants"
* Analysis of household characteristics by Irish immigrants using "Census_data.dta"
* Years: 1851, 1861

	qui: do "$dir\dofiles\Table_Irish_immigrants.do"


*****************************************

* Table SA5 "Boundary Effects on House Prices, Zoopla House Value Estimates, and Rental Prices 1995-2013, 2015, Restricted Sample"
* Analysis of current values restricting high density areas using "houses_current_final.dta"
* Years: 1995-2013, 2015

	qui: do "$dir\dofiles\Table_current_omit_high_density.do"




************************************************************************************
* FIGURES
************************************************************************************


* Figure 1: Map (Done in ArcGIS)


*****************************************


* Figure 2:  Cholera Deaths and BSP Boundary (1854)
* Figure 3:  RD plots for Main Outcomes (in logs)
* Figure B1: Covariate RD Plots (1853)
* Figure B2: Histogram and Density of Forcing Variable (Distance to BSP boundary)
* Figure B3: RD Plots for Residential Mobility Outcome
* Figure B4: RD Plots for House Occupancy Outcomes
* Figure B5: RD Plots for Socioeconomic Outcomes

	qui: do "$dir\dofiles\Fig_RD_plots.do"


	
*****************************************

* Figure 4: Difference in Log House Prices for Neighboring Cells, London 1995-2013	
* Resampling analysis

	qui: do "$dir\dofiles\Fig_variance_grid.do"
	
	
*****************************************

* Figure 5: Map (Done in ArcGIS)



*****************************************

* Figure SA1: Copy of historical tax record


*****************************************

* Figure SA2: Copy of Historical Map


*****************************************

* Figure SA3: Map (Done in ArcGIS)


*****************************************

* Figure SA4: Bandwidth Sensitivity
* Bandwidth sensitivity analysis for all variables
	
	qui: do "$dir\dofiles\Fig_bandwidth_sensitivity.do"


*****************************************

* Figure SA5: Mean Log Rental Prices in 1846 and 1853 by BSP status
* Analysis of pre-trends using "Merged_1846_1894_data.dta"

	qui: do "$dir\dofiles\Fig_pre-trends.do"


*****************************************

* Figure SA6: Map (Done in ArcGIS)


*****************************************

* Figure SA7: RD Plots for Sewer Status: Restricted Sample
* RD plot for data with restricted segments using "Merged_1853_1864_data.dta"	

	qui: do "$dir\dofiles\Table_robustness_sewer.do"

