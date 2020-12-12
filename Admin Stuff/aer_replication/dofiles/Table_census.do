************************************************************************************
* File Purpose: Analysis of census data, 1851, 1861
* Output: Table 6: Boundary Effects on House Occupancy Characteristics
************************************************************************************


* globals set in Master file

clear all
set more off


use "$dir\data\19th\Data_census.dta", clear

* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))
	local outcomes 	house_pop51 far_immigrants51 immigrants_frac51 ///
					house_pop61 far_immigrants61 immigrants_frac61 /// 
	 

	foreach var of local outcomes {
		qui: rdbwselect `var' temp, vce(nncluster block)
		scalar hopt_`var'=round(e(h_mserd), 0.00001) 
	}
	
* Calculate the means outside the Broad Street area for log variables
	foreach var of local outcomes {
		sum `var' if broad == 0 & dist_netw<hopt_`var'
		scalar mean_out_`var' = r(mean)  

		sum `var' if broad == 0 & dist_netw<=1
		scalar mean_out_`var'_all = r(mean)  
	}


*************************************************************************************
* Table 6, House Occupants (Columns 1-3)
*************************************************************************************

keep if house_pop51!=.&house_pop61!=.

* House population 1851
	* LLR with Controls
	rdrobust house_pop51 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer)  all
		est store tab_1
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum house_pop51 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_pop51 = r(mean)
		estadd scalar Mean = mean_out_llr2_pop51
		estadd scalar Bw = e(h_l)*100

	* Semi with Optimal band
	reg house_pop51 broad##c.(dist_netw dist_netw2) dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_2
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_pop51
		estadd scalar Bw = e(h_l)*100

	* Poly/ wide bandwidth
	reg house_pop51 broad##c.(dist_netw dist_netw2) dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_3
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_house_pop51_all
		estadd scalar Bw = 100

* House population 1861
	* LLR with Controls
	rdrobust house_pop61 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer) all
		est store tab_4
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum house_pop51 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_pop61 = r(mean)
		estadd scalar Mean = mean_out_llr2_pop61
		estadd scalar Bw = e(h_l)*100

	* Semi with Optimal band
	reg house_pop61 broad##c.(dist_netw dist_netw2) dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_5
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_pop61
		estadd scalar Bw = e(h_l)*100

	* Poly/ wide bandwidth
	reg house_pop61 broad##c.(dist_netw dist_netw2) dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_6
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_house_pop61_all
		estadd scalar Bw = 100


*************************************************************************************
* Table 6, Number of Immigrants  (Columns 4-6)
*************************************************************************************

use "$dir\data\19th\Data_census.dta", clear

	* LLR with Controls
	* Far immigrants 1851
	rdrobust far_immigrants51 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer)  all
		est store tab_7
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum far_immigrants51 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_far51 = r(mean)
		estadd scalar Mean = mean_out_llr2_far51
		estadd scalar Bw = e(h_l)*100

	* Semi with Optimal band
	reg far_immigrants51 broad dist_netw dist_netw2 dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_8
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_far51
		estadd scalar Bw = e(h_l)*100

	* Poly/ wide bandwidth
	reg far_immigrants51 broad dist_netw dist_netw2 dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_9
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_far_immigrants51_all
		estadd scalar Bw = 100

	* LLR with Controls
	rdrobust far_immigrants61 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer) all
		est store tab_10
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum far_immigrants61 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_far61 = r(mean)
		estadd scalar Mean = mean_out_llr2_far61
		estadd scalar Bw = e(h_l)*100

	* Semi with Optimal band
	reg far_immigrants61 broad dist_netw dist_netw2 dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_11
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_far61
		estadd scalar Bw = e(h_l)*100

	* Poly/ wide bandwidth
	reg far_immigrants61 broad dist_netw dist_netw2 dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_12
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_far_immigrants61_all
		estadd scalar Bw = 100



*************************************************************************************
* Table 6, Immigrant fraction  (Columns 7-9)
*************************************************************************************

	* LLR with Controls
	rdrobust immigrants_frac51 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer)  all
		est store tab_13
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum immigrants_frac51 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_frac51 = r(mean)
		estadd scalar Mean = mean_out_llr2_frac51
		estadd scalar Bw = e(h_l)*100

	* Semi with Optimal band
	reg immigrants_frac51 broad dist_netw dist_netw2 dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_14
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_frac51
		estadd scalar Bw = e(h_l)*100

	* Poly/ wide bandwidth
	reg immigrants_frac51 broad dist_netw dist_netw2 dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_15
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_immigrants_frac51_all
		estadd scalar Bw = 100

	* LLR with Controls
	rdrobust immigrants_frac61 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer) all
		est store tab_16
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum immigrants_frac61 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_frac61 = r(mean)
		estadd scalar Mean = mean_out_llr2_frac61
		estadd scalar Bw = e(h_l)*100

	* Semi with Optimal band
	reg immigrants_frac61 broad##c.(dist_netw) dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_17
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_frac61
		estadd scalar Bw = e(h_l)*100

	* Poly/ wide bandwidth
	reg immigrants_frac61 broad##c.(dist_netw dist_netw2 dist_netw3) dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_18
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_immigrants_frac61_all
		estadd scalar Bw = 100



* export results to latex table
	estout tab_1 tab_2 tab_3 tab_7 tab_8 tab_9 tab_13 tab_14 tab_15 ///
	using "$dir\latex\temp_census51.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad 1.broad)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	
	
* export results to latex table
	estout tab_4 tab_5 tab_6 tab_10 tab_11 tab_12 tab_16 tab_17 tab_18 ///
	using "$dir\latex\temp_census61.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad 1.broad)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	
	
