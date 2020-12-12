*************************************************************************************
* Purpose: Analyze house prices using John Snow's 1854 definition of BSP boundary
* Output: Table B5 "Boundary Effects using John Snow's boundary definition"
*************************************************************************************



* globals set in Master file

	clear all
	set more off



	use "$dir\data\19th\Merged_1853_1864_data.dta", clear

	
* change distance scale

	replace dist_snow = dist_snow/100

	
		forvalues i=2(1)4 {
			gen dist_snow`i'=dist_snow^`i'
	}
*


* Set negative values for the distances to the Snow boundary that are outside the BSP perimeter
	
		
	gen tempS=dist_snow
	replace tempS=-dist_snow if snow_in==0


* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))


	foreach var in log_rentals_1853 deaths death_ind log_rentals_1864 {
		rdbwselect `var' tempS, vce(nncluster block)
		scalar hopt_`var'_S=round(e(h_mserd), 0.01)
	}	
		

************************************************************************************
* Table B5, Columns 1-4
************************************************************************************	

* Column 1: Rental price (1853)	
	reg log_rentals_1853 snow_in dist_snow dist_snow2 dist_snow3 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
		if dist_snow<=hopt_log_rentals_1853_S , cl(block) 
			est store tab_b7_1
			estadd scalar Obs = e(N)			
			estadd scalar Cluster = e(N_clust)			
			estadd scalar Bw = hopt_log_rentals_1853_S*100
			
			
			
* Column 2: Number of Deaths in Household		
	reg deaths snow_in dist_snow dist_snow2 dist_snow3 dist_urinal no_sewer old_sewer ///  
		if dist_snow<=hopt_deaths_S, cl(block)	
			est store tab_b7_2
			estadd scalar Obs = e(N)			
			estadd scalar Cluster = e(N_clust)			
			estadd scalar Bw = hopt_deaths_S*100
	
* Column 3: House has at least one death	
	reg death_ind snow_in dist_snow dist_snow2 dist_snow3 dist_urinal no_sewer old_sewer ///  
		if dist_snow<=hopt_death_ind_S, cl(block)
			est store tab_b7_3
			estadd scalar Obs = e(N)			
			estadd scalar Cluster = e(N_clust)			
			estadd scalar Bw = hopt_death_ind_S*100		
		
		
* Column 4: Rental price 1864		
	reg log_rentals_1864 snow_in dist_snow dist_snow2 dist_snow3 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
		if dist_snow<=hopt_log_rentals_1864_S, cl(block) 
			est store tab_b7_4
			estadd scalar Obs = e(N)			
			estadd scalar Cluster = e(N_clust)			
			estadd scalar Bw = hopt_log_rentals_1864_S*100		



* export results to latex table
	estout  tab_b7_1 tab_b7_2 tab_b7_3  tab_b7_4 ///
	using "$dir\latex\snow.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(snow_in)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Cluster Bw, labels("Observations" "Clusters" "Bandwidth (meters)") )
	
	

************************************************************************************
* Table B5, Column 5
************************************************************************************	

use "$dir\data\19th\Merged_1846_1894_data.dta", clear
	
	replace dist_snow = dist_snow/100

	
	forvalues i=2(1)4 {
			gen dist_snow`i'=dist_snow^`i'
	}


* Set negative values for the distances to the Snow boundary that are outside the BSP perimeter
	gen tempS=dist_snow
	replace tempS=-dist_snow if snow_in==0


* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al (2014))
	foreach var in log_rentals_1894 {
		rdbwselect `var' tempS, vce(nncluster block)
		scalar hopt_`var'_S=round(e(h_mserd), 0.01)
	}	
	

* Column 5: Log rentals (1894)
	reg log_rentals_1894 snow_in dist_snow dist_snow2 dist_snow3 dist_cent dist_square dist_bank dist_vent dist_pit_f ///
		if dist_snow<=hopt_log_rentals_1894_S , cl(block) 
			est store tab_b7_7
			estadd scalar Obs = e(N)			
			estadd scalar Cluster = e(N_clust)			
			estadd scalar Bw = hopt_log_rentals_1894_S*100
	
* export results to latex table
	estout  tab_b7_7 ///
	using "$dir\latex\snow4.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(snow_in)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Cluster Bw, labels("Observations" "Clusters" "Bandwidth (meters)") )

	
******************************************************************************
* Table B5, Column 6
******************************************************************************

	use "$dir\data\20th\houses_1936_final.dta", clear


// rd using Snow's boundary definition
// Optimal bandwidth (Calonico et al. (2014))
	gen tempS=dist_snow
	replace tempS=-dist_snow if snow_in==0

	foreach var in lnrentals {
		rdbwselect `var' tempS, vce(nncluster block)
		scalar hopt_`var'S=round(e(b_mserd), 0.01)
	}


 * Column 6
	reg lnrentals snow_in dist_snow dist_snow2 dist_snow3 dist_cent dist_square dist_thea ///
	dist_police dist_school dist_pub dist_church dist_bank length width if dist_snow<=hopt_lnrentalsS, cluster(block)
			est store tab_b7_5
			estadd scalar Obs = e(N)			
			estadd scalar Cluster = e(N_clust)			
			estadd scalar Bw = hopt_lnrentalsS*100		

* export results to latex table
	estout  tab_b7_5 ///
	using "$dir\latex\snow2.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(snow_in)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Cluster Bw, labels("Observations" "Clusters" "Bandwidth (meters)") )

	
	
	

************************************************************************************
* Table B5, column 7
************************************************************************************
	
			
	use "$dir\data\current\houses_current_final.dta", clear


	drop if price==1073 //typo in house price
	drop if source==1 //Zoopla modes

	
		forvalues i=2(1)4 {
			gen dist_snow`i'=dist_snow^`i'
		}
	

* Set negative values for the distances to the boundary that are outside the BSP perimeter

	gen tempS=dist_netw
	replace tempS=-dist_netw if broad==0


* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))
		egen pcode = group(post_code)
		tab source, gen(source)

		rdbwselect lnprice tempS, vce(nncluster pcode)
		scalar hopt_lnprice_S=(round(e(b_mserd), 0.01))
		

* Column 6
	reg lnprice snow_in dist_snow dist_snow2 dist_snow3 flat dist_bomb year source2 ///
	if dist_snow<=hopt_lnprice_S, cluster(pcode)
		est store tab_b7_6
		estadd scalar Obs = e(N)			
		estadd scalar Cluster = e(N_clust)			
		estadd scalar Bw = hopt_lnprice_S*100		


* export results to latex table
	estout  tab_b7_6 ///
	using "$dir\latex\snow3.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(snow_in)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Cluster Bw, labels("Observations" "Clusters" "Bandwidth (meters)") )

	




		
