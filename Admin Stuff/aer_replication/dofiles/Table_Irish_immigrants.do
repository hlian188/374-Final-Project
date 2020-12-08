************************************************************************************
* File Purpose: Household characteristics (Irish Immigrants, 1851, 1861)
* Output: Table SA4 "Boundary Effects on House Occupancy Characteristics: Irish Immigrants"
************************************************************************************


* globals set in Master file

	clear all
	set more off


use "$dir\data\19th\Data_census.dta", clear


* Create Irish indicators
forv i=1(1)6 {
	gen irish`i'_51=1 if origin`i'51=="Ireland" 
	gen irish`i'_61=1 if origin`i'61=="Ireland" 
}

egen irish_51 = rowtotal(irish1_51 irish2_51 irish3_51 irish4_51 irish5_51 irish6_51)
egen irish_61 = rowtotal(irish1_61 irish2_61 irish3_61 irish4_61 irish5_61 irish6_61)
replace irish_51=. if far_immigrants51==.
replace irish_61=. if far_immigrants61==.

forv i=1(1)6 {
	drop irish`i'_51 irish`i'_61
}


gen irish_frac51 = .
replace irish_frac51 = irish_51 / num_heads51
replace irish_frac51 = 0 if num_heads51==0

gen irish_frac61 = .
replace irish_frac61 = irish_61 / num_heads61
replace irish_frac61 = 0 if num_heads61==0



* Calculate the means outside the Broad Street area for log variables
	foreach var in irish_51 irish_frac51 irish_61 irish_frac61 {
		sum `var' if broad == 0 & dist_netw<=1
		scalar mean_out_`var'_all = r(mean)  
	}



	* Panel A, column 1: LLR with Controls
	rdrobust irish_51 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer)  all
		est store tab_7
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum irish_51 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_far51 = r(mean)
		estadd scalar Mean = mean_out_llr2_far51
		estadd scalar Bw = e(h_l)*100



	* Panel A, column 2: Semi with Optimal band
	reg irish_51 broad##c.(dist_netw) dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_8
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_far51
		estadd scalar Bw = e(h_l)*100



	* Panel A, column 3: Poly/ wide bandwidth
	reg irish_51 broad dist_netw dist_netw2 dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_9
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_irish_51_all
		estadd scalar Bw = 100



	* Panel B, column 1: LLR with Controls
	rdrobust irish_61 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer) all
		est store tab_10
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum irish_61 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_far61 = r(mean)
		estadd scalar Mean = mean_out_llr2_far61
		estadd scalar Bw = e(h_l)*100



	* Panel B, column 2: Semi with Optimal band
	reg irish_61 broad dist_netw dist_netw2 dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_11
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_far61
		estadd scalar Bw = e(h_l)*100



	* Panel B, column 3: Poly/ wide bandwidth
	reg irish_61 broad##c.(dist_netw) dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_12
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_irish_61_all
		estadd scalar Bw = 100




	* Panel A, column 4: LLR with Controls
	rdrobust irish_frac51 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer)  all
		est store tab_13
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum irish_frac51 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_frac51 = r(mean)
		estadd scalar Mean = mean_out_llr2_frac51
		estadd scalar Bw = e(h_l)*100



	* Panel A, column 5: Semi with Optimal band
	reg irish_frac51 broad##c.(dist_netw dist_netw2) dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_14
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_frac51
		estadd scalar Bw = e(h_l)*100



	* Panel A, column 6: Poly/ wide bandwidth
	reg irish_frac51 broad##c.(dist_netw dist_netw2) dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_15
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_irish_frac51_all
		estadd scalar Bw = 100



	* Panel B, column 4: LLR with Controls
	rdrobust irish_frac61 dist_2, vce(nncluster block) covs(dist_urinal old_sewer no_sewer) all
		est store tab_16
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum irish_frac61 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_frac61 = r(mean)
		estadd scalar Mean = mean_out_llr2_frac61
		estadd scalar Bw = e(h_l)*100



	* Panel B, column 5: Semi with Optimal band
	reg irish_frac61 broad##c.(dist_netw) dist_urinal ///
	old_sewer no_sewer if dist_netw<e(h_l), cl(block)
		est store tab_17
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr2_frac61
		estadd scalar Bw = e(h_l)*100



	* Panel B, column 6: Poly/ wide bandwidth
	reg irish_frac61 broad dist_netw dist_netw2 dist_netw3 dist_urinal ///
	old_sewer no_sewer if dist_netw<1, cl(block)
		est store tab_18
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_irish_frac61_all
		estadd scalar Bw = 100


* export results to latex table
	estout tab_7 tab_8 tab_9 tab_13 tab_14 tab_15 ///
	using "$dir\latex\temp_irish51.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad 1.broad)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, fmt(0 3 2) labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	
	
* export results to latex table
	estout tab_10 tab_11 tab_12 tab_16 tab_17 tab_18 ///
	using "$dir\latex\temp_irish61.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad 1.broad)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, fmt(0 3 2) labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	
