************************************************************************************
* File Description: RD Analysis of death data
* Output:
* Table 2: Change in Exposure to Cholera at Boundary of Broad Street Pump Catchment Area
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

	local outcomes deaths death_ind 

* Change distance scale	 
	replace dist_netw = dist_netw/100
	replace dist_netw2 = dist_netw^2
	replace dist_netw3 = dist_netw^3

	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0	

	foreach var of local outcomes {
		qui: rdbwselect `var' temp, vce(nncluster block)
		scalar hopt_`var'=round(e(h_mserd), 0.00001) 
	}
	
* Calculate the means outside the Broad Street area for log variables
	foreach var of local outcomes {
		sum `var' if broad == 0 & dist_netw<hopt_`var'
		scalar mean_out_`var' = r(mean) 
		sum `var' if broad == 0 & dist_netw<1
		scalar mean_out_`var'_all = r(mean)
	}

*=======================================================================================
	**** Table 2, Panel A:  Deaths *****
*=======================================================================================
	* Column 1: LLR
	rdrobust deaths dist_2, vce(nncluster block) all
		est store tab2_1a 
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_deaths
		estadd scalar Bw = e(h_l)*100

	* Column 2: LLR with Controls
	rdrobust deaths dist_2, all vce(nncluster block) covs(dist_cent dist_urinal no_sewer old_sewer)
		est store tab2_2a
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum deaths if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_deaths = r(mean)
		estadd scalar Mean = mean_out_llr2_deaths
		estadd scalar Bw = e(h_l)*100

	* Column 3: Semi: Polynomial and bandwidth
	reg deaths broad dist_netw dist_netw2 dist_netw3 dist_cent dist_urinal no_sewer old_sewer if dist_netw<hopt_deaths, cl(block)
		est store tab2_3a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_deaths
		estadd scalar Bw = hopt_deaths*100

	* Column 4: Polynomial and Controls
	reg deaths broad dist_netw dist_netw2 dist_cent dist_urinal no_sewer old_sewer if dist_netw<1, cl(block)
		est store tab2_4a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_deaths_all
		estadd scalar Bw = 100

	* Column 5: Segment FE
	areg deaths broad dist_netw dist_netw2 dist_cent dist_urinal no_sewer old_sewer if dist_netw<1, a(seg_5) cl(block) 
		est store tab2_5a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_deaths_all
		estadd scalar Bw = 100

* Export results to latex table
	estout tab2_1a tab2_2a tab2_3a tab2_4a tab2_5a ///
	using "$dir\latex\temp_deaths.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	
*=======================================================================================
	*** Table 2, Panel B: At least one death ***
*=======================================================================================
	* Column 1: LLR
	rdrobust death_ind dist_2, all vce(nncluster block)
		est store tab2_1b 
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_death_ind
		estadd scalar Bw = e(h_l)*100

	* Column 2: LLR with Controls
	rdrobust death_ind dist_2, all vce(nncluster block) covs(dist_cent dist_urinal no_sewer old_sewer)
		est store tab2_2b
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum death_ind if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_death_ind = r(mean)
		estadd scalar Mean = mean_out_llr2_death_ind
		estadd scalar Bw = e(h_l)*100

	* Column 3: Semi: Polynomial and bandwidth
	reg death_ind broad dist_netw dist_netw2 dist_netw3 dist_cent dist_urinal no_sewer old_sewer if dist_netw<hopt_death_ind, cl(block)
		est store tab2_3b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_death_ind
		estadd scalar Bw = hopt_death_ind*100

	* Column 4: Polynomial and Controls
	reg death_ind broad dist_netw dist_netw2 dist_cent dist_urinal no_sewer old_sewer if dist_netw<1, cl(block)
		est store tab2_4b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_death_ind_all
		estadd scalar Bw = 100

	* Column 5: Segment FE
	areg death_ind broad dist_netw dist_netw2 dist_cent dist_urinal no_sewer old_sewer if dist_netw<1, a(seg_5) cl(block) 
		est store tab2_5b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_death_ind_all
		estadd scalar Bw = 100

* Export results to latex table
	estout tab2_1b tab2_2b tab2_3b tab2_4b tab2_5b ///
	using "$dir\latex\temp_death_ind.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )

