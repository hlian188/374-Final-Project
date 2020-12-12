************************************************************************************
* File Purpose: Analysis of within BSP area effect of cholera (1853,1864)
* Output: Table B4 "Differences in Rental Price, House Occupancy due to Cholera Exposure within BSP Area"
************************************************************************************

clear
set more off





************************************************************************************
* Table B4, Columns 1-2, Log Rental Prices (1853, 1864)
************************************************************************************
use "$dir\data\19th\Merged_1853_1864_data.dta", clear
keep if log_rentals_1853!=.&log_rentals_1864!=.

*  Control Means	
	foreach var in rentals_53 rentals_64 {
		sum  `var' if death_in ==0 & broad==1
		scalar mean_out_BSP_`var' = r(mean)
	}



* Panel A, Column 1: Log rentals (1853)
areg log_rentals_1853 death_ind dist_cent dist_square dist_fire dist_thea dist_polic dist_urinal ///
dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
if broad==1, cl(block) a(block)
		est store pacol1
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_rentals_53 



* Panel A, Column 2: Log rentals (1853)
areg log_rentals_1853 deaths dist_cent dist_square dist_fire dist_thea dist_polic dist_urinal ///
dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
if broad==1, cl(block) a(block)
		est store pacol2
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_rentals_53 



* Panel B, Column 1: Log rentals (1864)
areg log_rentals_1864 death_ind dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal /// 
dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
if broad==1, cl(block) a(block)
		est store pbcol1
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_rentals_64 



* Panel B, Column 2: Log rentals (1864)
areg log_rentals_1864 deaths dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal /// 
dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
if broad==1, cl(block) a(block)
		est store pbcol2
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_rentals_64




************************************************************************************
* Table B4, Columns 3-6, Census outcomes (1851, 1861)
************************************************************************************
use "$dir\data\19th\Data_census.dta", clear
keep if house_pop51!=.&house_pop61!=.


* Control means	
	foreach var in far_immigrants51 immigrants_frac51 far_immigrants61 immigrants_frac61 {
		sum  `var' if death_in ==0 & broad==1
		scalar mean_out_BSP_`var' = r(mean)
	}



* Panel A, Column 3: Number of immigrant families (1851)
areg far_immigrants51 death_ind dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal ///
dist_school dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
  if broad==1, cl(block) a(block)
		est store pacol3
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_far_immigrants51


* Panel A, Column 4: Number of immigrant families (1851)
areg far_immigrants51 deaths dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal ///
dist_school dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
  if broad==1, cl(block) a(block)
		est store pacol4
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_far_immigrants51



* Panel A, Column 5: Fraction of immigrant families (1851)
areg immigrants_frac51 death_ind dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal ///
dist_school dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake  ///
 if broad==1, cl(block) a(block)
		est store pacol5
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_immigrants_frac51



* Panel A, Column 6: Fraction of immigrant families (1851)
areg immigrants_frac51 deaths dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal ///
dist_school dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake  ///
 if broad==1, cl(block) a(block)
		est store pacol6
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_immigrants_frac51



* Panel B, Column 3: Number of immigrant families (1861)
areg far_immigrants61 death_ind dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal ///
dist_school dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake  ///
 if broad==1, cl(block) a(block)
		est store pbcol3
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_far_immigrants61



* Panel B, Column 4: Number of immigrant families (1861)
areg far_immigrants61 deaths dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal ///
dist_school dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake  ///
 if broad==1, cl(block) a(block)
		est store pbcol4
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_far_immigrants61




* Panel B, Column 5: Fraction of immigrant families (1861)
areg immigrants_frac61 death_ind dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal ///
dist_school dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake   ///
if broad==1, cl(block) a(block)
		est store pbcol5
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_immigrants_frac61




* Panel B, Column 6: Fraction of immigrant families (1861)
areg immigrants_frac61 deaths dist_cent dist_square dist_fire dist_thea  dist_polic dist_urinal ///
dist_school dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake   ///
if broad==1, cl(block) a(block)
		est store pbcol6
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_out_BSP_immigrants_frac61	



* Export results to Latex
	estout pacol1 pacol2 pacol3 pacol4 pacol5 pacol6 ///
	using "$dir\latex\stigma1.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(death_ind deaths)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs  Mean , labels("Observations"  "Mean (house with no deaths)" ) )
	
	estout pbcol1 pbcol2 pbcol3 pbcol4 pbcol5 pbcol6  ///
	using "$dir\latex\stigma2.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(death_ind deaths)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs  Mean , labels("Observations"  "Mean (house with no deaths)" ) )
