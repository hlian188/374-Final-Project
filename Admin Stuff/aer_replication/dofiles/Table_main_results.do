************************************************************************************
* File Purpose: BSP effect on rental outcomes (1853, 1864, 1894, 1936)
* Output: Table 3: Boundary Effects on Rental Prices
************************************************************************************


* globals set in Master file

	clear all
	set more off




*************************************************************************************
* Table 3, Panel A: Log Rental Prices (1853)
*************************************************************************************

	use "$dir\data\19th\Merged_1853_1864_data.dta", clear


* Set negative values for the distances to the boundary that are outside the BSP perimeter


	gen temp=dist_netw/100
	replace temp=-dist_netw/100 if broad==0


	
* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al (2014))

	local outcomes log_rentals_1853 log_rentals_1864
				 
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
	sum rentals_53 if broad == 0 & dist_netw<hopt_log_rentals_1853
	scalar mean_out_rentals_53 = r(mean)  
	
	sum rentals_64 if broad == 0 & dist_netw<hopt_log_rentals_1864
	scalar mean_out_rentals_64 = r(mean)  

	sum rentals_53 if broad == 0 & dist_netw<1
	scalar mean_out_rentals_53_all = r(mean)  
	
	sum rentals_64 if broad == 0 & dist_netw<1
	scalar mean_out_rentals_64_all = r(mean) 	


	* Column 1: LLR
	rdrobust log_rentals_1853 dist_2, vce(nncluster block) all
		est store tab2_1a 
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_rentals_53
		estadd scalar Bw = e(h_l)*100

	* Column 2: LLR with Controls
	rdrobust log_rentals_1853 dist_2, vce(nncluster block) covs(dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake) all
		est store tab2_2a
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum rentals_53 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_53 = r(mean)
		estadd scalar Mean = mean_out_llr2_53
		estadd scalar Bw = e(h_l)*100

	* Column 3: Semi: Polynomial and bandwidth
	reg log_rentals_1853 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<hopt_log_rentals_1853, cl(block)
		est store tab2_3a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_53
		estadd scalar Bw = hopt_log_rentals_1853*100

	* Column 4: Polynomial and Wide bandwidth
	reg log_rentals_1853 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<1, cl(block)
		est store tab2_4a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_53_all
		estadd scalar Bw = 100

	* Column 5: Segment FE
	areg log_rentals_1853 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<1, a(seg_5) cl(block) 
		est store tab2_5a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_53_all
		estadd scalar Bw = 100

* export results to latex table
	estout tab2_1a tab2_2a tab2_3a tab2_4a tab2_5a ///
	using "$dir\latex\temp_rentals_1853.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	





*************************************************************************************
* Table 3, Panel B: Log Rental Prices (1864)
*************************************************************************************
	* Column 1: LLR
	rdrobust log_rentals_1864 dist_2, vce(nncluster block) all
		est store tab2_1b
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_rentals_64
		estadd scalar Bw = e(h_l)*100

	* Column 2: LLR with Controls
	rdrobust log_rentals_1864 dist_2, vce(nncluster block) covs(dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake) all
		est store tab2_2b
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum rentals_64 if broad==0 & dist_netw<=e(h_l)		
		scalar mean_out_llr2_64 = r(mean)
		estadd scalar Mean = mean_out_llr2_64
		estadd scalar Bw = e(h_l)*100

	* Column 3: Semi: Polynomial and bandwidth
	reg log_rentals_1864 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<hopt_log_rentals_1864, cl(block)
		est store tab2_3b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_64
		estadd scalar Bw = 100*hopt_log_rentals_1864

	* Column 4: Polynomial and wide bandwidth
	reg log_rentals_1864 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<1, cl(block)
		est store tab2_4b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_64_all
		estadd scalar Bw = 100

	* Column 5: Segment FE
	areg log_rentals_1864 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<1, a(seg_5) cl(block) 
		est store tab2_5b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_64_all
		estadd scalar Bw = 100

* export results to latex table
	estout tab2_1b tab2_2b tab2_3b tab2_4b tab2_5b ///
	using "$dir\latex\temp_rentals_1864.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad) ///
	order() ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	





*************************************************************************************
* Table 3, Panel C: Log Rental Prices (1894)
*************************************************************************************

use "$dir\data\19th\Merged_1846_1894_data.dta", clear
	
	gen temp=dist_netw/100
	replace temp=-dist_netw/100 if broad==0
	
* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))

	local outcomes log_rentals_1894

* change distance scale	 
	replace dist_netw = dist_netw/100
	replace dist_netw2 = dist_netw^2
	replace dist_netw3 = dist_netw^3

	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0	
	gen dist_2_2=dist_2^2

	foreach var of local outcomes {
		qui: rdbwselect `var' temp, vce(nncluster block)
		scalar hopt_`var'=round(e(h_mserd), 0.00001) 
	}
	
* Calculate the means outside the Braod Street area for log variables
	sum rentals_94 if broad == 0 & dist_netw<hopt_log_rentals_1894
	scalar mean_out_rentals_94 = r(mean)   

	sum rentals_94 if broad == 0 & dist_netw<1
	scalar mean_out_rentals_94_all = r(mean)  
 

	* Column 1: LLR
	rdrobust log_rentals_1894 dist_2, vce(nncluster block) all
		est store tab2_1d
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_rentals_94
		estadd scalar Bw = e(h_l)*100

	* Column 2: LLR with Controls
	rdrobust log_rentals_1894 dist_2, all vce(nncluster block) covs(dist_cent dist_square dist_bank dist_vent dist_pit_f)
		est store tab2_2d
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum rentals_94 if broad==0 & dist_netw<=e(h_l)		
		scalar mean_out_llr2_94 = r(mean)
		estadd scalar Mean = mean_out_llr2_94
		estadd scalar Bw = e(h_l)*100

	* Column 3: Semi: Polynomial and bandwidth
	reg log_rentals_1894 broad dist_netw dist_netw2 dist_cent dist_square ///
	if dist_netw<hopt_log_rentals_1894, cl(block)
		est store tab2_3d
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_94
		estadd scalar Bw = 100*hopt_log_rentals_1894

	* Column 4: Polynomial and wide bandwidth
	reg log_rentals_1894 broad dist_netw dist_netw2 dist_cent dist_square ///
	if dist_netw<1, cl(block)
		est store tab2_4d
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_94_all
		estadd scalar Bw = 100

	* Column 5: Segment FE
	areg log_rentals_1894 broad dist_netw dist_netw2 dist_cent dist_square ///
	if dist_netw<1, a(seg_5) cl(block) 
		est store tab2_5d
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_94_all
		estadd scalar Bw = 100

* export results to latex table
	estout tab2_1d tab2_2d tab2_3d tab2_4d tab2_5d ///
	using "$dir\latex\temp_rentals_1894.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	




*************************************************************************************
* Table 3, Panel D: Log Rental Prices (1936)
*************************************************************************************
use "$dir\data\20th\houses_1936_final.dta", clear

* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))

	gen temp=dist_netw
	replace temp=-dist_netw if broad==0

	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0	


* Optimal bandwidth (Calonico et al. (2014))

	foreach var in lnrentals {
		qui: rdbwselect `var' temp, vce(nncluster block)
		scalar hopt_`var'=round(e(h_mserd), 0.0001) 
	}



* Calculate the means outside the Broad Street area for log variable log_rentals_1853
	sum rentals if broad == 0 & dist_netw<hopt_lnrentals
	scalar mean_out_rentals_36 = r(mean)
	
	sum rentals if broad == 0 & dist_netw<1
	scalar mean_out_rentals_36_all = r(mean)

	 
	* Column 1: LLR
	rdrobust lnrentals dist_2, vce(nncluster block) all
		est store tab2_1c
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_rentals_36
		estadd scalar Bw = e(h_l)*100

	* Column 2: LLR with Controls
	rdrobust lnrentals dist_2, all vce(nncluster block) covs(dist_cent dist_square dist_thea ///
	dist_pub dist_church dist_bank) h(0.373)
		est store tab2_2c
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum rentals if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_36 = r(mean)
		estadd scalar Mean = mean_out_llr2_36
		estadd scalar Bw = e(h_l)*100

	* Column 3: Semi: Polynomial and bandwidth
	reg lnrentals broad dist_netw dist_netw2 dist_cent dist_square dist_thea ///
	dist_school dist_pub dist_church dist_bank length width if dist_netw<hopt_lnrentals, cl(block)
		est store tab2_3c
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_36
		estadd scalar Bw = 100*hopt_lnrentals

	* Column 4: Polynomial with Wide Bandwidth
	reg lnrentals broad dist_netw dist_netw2 dist_cent dist_square dist_thea ///
	dist_school dist_pub dist_church dist_bank length width if dist_netw<1, cl(block)
		est store tab2_4c
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_36_all
		estadd scalar Bw = 100

	* Column 5: Segment FE
	areg lnrentals broad dist_netw dist_netw2 dist_cent dist_square dist_thea ///
	dist_school dist_pub dist_church dist_bank length width if dist_netw<1, a(seg_5) cl(block) 
		est store tab2_5c
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_36_all
		estadd scalar Bw = 100

* export results to latex table
	estout tab2_1c tab2_2c tab2_3c tab2_4c tab2_5c ///
	using "$dir\latex\temp_rentals_1936.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	




