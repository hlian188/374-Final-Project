************************************************************************************
* File Purpose: Decision to move by degree of cholera exposure in neighborhood
* Output: Table 5: Migration Patterns by Cholera Exposure
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
	local outcomes 	moved 
	 
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
	
* Calculate the means outside the Broad Street area for log variables
	foreach var of local outcomes {
		sum `var' if broad == 0 & dist_netw<hopt_`var'
		scalar mean_out_`var' = r(mean)  

		sum `var' if broad == 0 & dist_netw<1
		scalar mean_out_`var'_all = r(mean)  
	}


************************************************************************************
*** Table 6: "Migration Patterns by Cholera Exposure"
* neighborhood deaths  excluding the current household 
************************************************************************************

* Migration Patterns by Cholera Exposure


	sum moved if di_neighborhood_d ==0	
	scalar mean_moved_out_all = r(mean)


	sum moved if di_neighborhood_d ==0	& broad == 0
	scalar mean_moved_out_bsp = r(mean)




* Column 1
	dprobit  moved death_ind neighborhood_deaths_others di_neighborhood_d_others neighborhood_houses ///
	deaths log_Tax_1853 if broad==1, cl(block)
		est store tab6_1
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_moved_out_bsp
		
* Column 2
	dprobit  moved death_ind neighborhood_visited_others di_neighborhood_v_others neighborhood_houses ///
	deaths log_Tax_1853 if broad==1, cl(block)
		est store tab6_2
		estadd scalar Obs = e(N)
		estadd scalar Mean  = mean_moved_out_bsp
	
	

	
* export results to latex table
	estout tab6_1 tab6_2 ///
	using "$dir\latex\temp_migration.tex", replace style(tex)  margin(u) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(death_ind neighborhood_deaths_others di_neighborhood_d_others neighborhood_visited_others ///
	di_neighborhood_v_others neighborhood_houses deaths log_Tax_1853 )  ///
	order(death_ind neighborhood_deaths_others di_neighborhood_d_others neighborhood_visited_others ///
	di_neighborhood_v_others neighborhood_houses deaths log_Tax_1853 )  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean, labels("Observations" "Mean Outside BSP area") )
	

	
