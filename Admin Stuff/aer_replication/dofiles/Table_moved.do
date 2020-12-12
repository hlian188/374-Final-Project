************************************************************************************
* File Purpose: Analyze BSP effect on decision to move after outbreak
* Output: Table 4: Boundary Effects on Residential Mobility
************************************************************************************


* globals set in Master file

	clear all
	set more off


	use "$dir\data\19th\Merged_1853_1864_data.dta", clear


************************************************************************************
* Analysis
************************************************************************************


* Set negative values for the distances to the boundary that are outside the BSP perimeter


	gen temp=dist_netw/100
	replace temp=-dist_netw/100 if broad==0


	
* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))
	local outcomes 	moved log_rentals_1864 /// 
	 
* change distance scale	 
	replace dist_netw = dist_netw/100
	replace dist_netw2 = dist_netw^2
	replace dist_netw3 = dist_netw^3

	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0	

	foreach var of local outcomes {
	qui: rdbwselect `var' temp, vce(nncluster block)
	scalar hopt_`var'=round(e(h_mserd), 0.00001) 
	}
	
* Calculate the means outside the Braod Street area for log variables
	foreach var of local outcomes {
		sum `var' if broad == 0 & dist_netw<hopt_`var'
		scalar mean_out_`var' = r(mean)  

		sum `var' if broad == 0 & dist_netw<1
		scalar mean_out_`var'_all = r(mean)  
	}


*************************************************************************************
* Table 4: Boundary Effects on Residential Mobility
*************************************************************************************

	* Column 1: LLR with Controls
	rdrobust moved dist_2, vce(nncluster block) covs(no_sewer old_sewer /// 
	dist_vent dist_urinal) all
		est store tab_1
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum moved if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_moved = r(mean)
		estadd scalar Mean = mean_out_llr2_moved
		estadd scalar Bw = e(h_l)*100

	* Column 2: Semi: Polynomial and bandwidth
	reg moved broad dist_netw dist_netw2 dist_netw3 no_sewer old_sewer /// 
	dist_vent dist_urinal if dist_netw<hopt_moved, cl(block)
		est store tab_2
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_moved
		estadd scalar Bw = hopt_moved*100

	* Column 3: Polynomial and Wide Bandwidth
	reg moved broad dist_netw dist_netw2 dist_netw3 no_sewer old_sewer /// 
	dist_vent dist_urinal if dist_netw<1, cl(block)
		est store tab_3
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_moved_all
		estadd scalar Bw = 100

	* Column 4: Polynomial and bandwidth + Death control
	reg moved broad death_ind dist_netw dist_netw2 dist_netw3 no_sewer old_sewer ///
	dist_vent dist_urinal if dist_netw<hopt_moved, cl(block)
		est store tab_4
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_moved
		estadd scalar Bw = hopt_moved*100

	* Column 5: Polynomial and bandwidth + Death controls
	reg moved broad death_ind neighborhood_deaths_others neighborhood_houses ///
	dist_netw dist_netw2 dist_netw3 no_sewer old_sewer ///
	dist_vent dist_urinal if dist_netw<hopt_moved, cl(block)
		est store tab_5
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_moved
		estadd scalar Bw = hopt_moved*100

	* Column 6: Polynomial and bandwidth: Rental prices + Death control
	reg log_rentals_1864 broad death_ind dist_netw dist_netw2 dist_netw3 no_sewer old_sewer /// 
	dist_vent dist_urinal if dist_netw<hopt_log_rentals_1864, cl(block)
		est store tab_6
		estadd scalar Obs = e(N)
		sum moved if broad==0 & dist_netw<=hopt_log_rentals_1864
		scalar mean_out_64_moved = r(mean)
		estadd scalar Mean = mean_out_64_moved
		estadd scalar Bw = hopt_log_rentals_1864*100
	
	* Column 7: Polynomial and bandwidth: Rental prices + Death controls 
	reg log_rentals_1864 broad death_ind neighborhood_deaths_others neighborhood_houses ///
	dist_netw dist_netw2 dist_netw3 no_sewer old_sewer dist_vent dist_urinal ///
	if dist_netw<hopt_log_rentals_1864, cl(block)
		est store tab_7
		estadd scalar Obs = e(N)
		sum moved if broad==0 & dist_netw<=hopt_log_rentals_1864
		scalar mean_out_64_moved = r(mean)
		estadd scalar Mean = mean_out_64_moved
		estadd scalar Bw = hopt_log_rentals_1864*100

* export results to latex table
	estout tab_1 tab_2 tab_3 tab_4 tab_5 tab_6 tab_7 ///
	using "$dir\latex\temp_mobility.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad death_ind neighborhood_deaths_others neighborhood_houses)  ///
	order(broad death_ind neighborhood_deaths_others neighborhood_houses) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	
	

	
