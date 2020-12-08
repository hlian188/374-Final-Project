************************************************************************************
* File Purpose: BSP effect on rental prices (Fuzzy RD, 1864)
* Output: Appendix Table B2: Fuzzy RD and IV Estimates of Boundary Effects on Rental Prices, 1864
************************************************************************************


* globals set in Master file

	clear all
	set more off


	use "$dir\data\19th\Merged_1853_1864_data.dta", clear


* Set negative values for the distances to the boundary that are outside the BSP perimeter


	gen temp=dist_netw/100
	replace temp=-dist_netw/100 if broad==0

	
* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))

	local outcomes log_rentals_1864 moved

* change distance scale	 
	replace dist_netw = dist_netw/100
	replace dist_netw2 = dist_netw^2
	replace dist_netw3 = dist_netw^3

	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0	
	gen dist_2_2 = dist_2^2
	gen dist_2_3 = dist_2^3

	foreach var of local outcomes {
		qui: rdbwselect `var' temp, vce(nncluster block)
		scalar hopt_`var'=round(e(h_mserd), 0.01) 
	}
	
* Calculate the means outside the Braod Street area for log variables 
	sum rentals_64 if broad == 0 & dist_netw<hopt_log_rentals_1864
	scalar mean_out_rentals_64 = r(mean)   
	
	sum rentals_64 if broad == 0 & dist_netw<1
	scalar mean_out_rentals_64_all = r(mean) 	
 

************************************************************************************
* Table B2: Fuzzy RD (Columns 1-3)
************************************************************************************

	* Column 1: LLR + Controls
	rdrobust log_rentals_1864 dist_2, fuzzy(death_ind) vce(nncluster block) ///
	covs(dist_cent dist_urinal old_sewer dist_pump) all
		est store tab2_1
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum rentals_64 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr_64 = r(mean)
		estadd scalar Mean = mean_out_llr_64
		estadd scalar Bw = e(h_l)*100
		scalar pred=exp(e(tau_cl))-1
		estadd scalar Tau=pred

	* Column 2: Polynomial using bandwidth from LLR
	* Order: 3	
	rdrobust log_rentals_1864 dist_2, fuzzy(death_ind) vce(nncluster block) ///
	covs(dist_cent dist_urinal old_sewer dist_pump) ///
	all p(3) h(0.33)
		est store tab2_2
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_llr_64
		estadd scalar Bw = e(h_l)*100
		scalar pred=exp(e(tau_cl))-1
		estadd scalar Tau=pred

	* Column 3: Polynomial Wide bandwidth
	* Order: 2
	rdrobust log_rentals_1864 dist_2, fuzzy(death_ind) vce(nncluster block) ///
	covs(dist_cent dist_urinal old_sewer dist_pump) all p(2) h(1)
		est store tab2_3
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_rentals_64_all
		estadd scalar Bw = 100
		scalar pred=exp(e(tau_cl))-1
		estadd scalar Tau=pred


************************************************************************************
* Table B2: IV (Columns 4-5)
************************************************************************************
	* Column 4: IV intrumenting likelihood of death
	ivreg2 log_rentals_1864 (death_ind = broad##c.dist_broad) dist_urinal old_sewer dist_pump if dist_netw<=0.292, cl(block)
		est store tab2_4
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr_64
		estadd scalar Bw = e(h_l)*100
		estadd scalar Fstat = e(cdf)
		estadd scalar pval = e(jp)
		matrix b=e(b)
		scalar pred=exp(b[1,1])-1
		estadd scalar Tau=pred

	* Column 5: IV instrumenting number of deaths
	ivreg2 log_rentals_1864 (deaths = broad##c.dist_broad) dist_urinal old_sewer dist_pump if dist_netw<=0.292, cl(block)
		est store tab2_5
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_llr_64
		estadd scalar Bw = e(h_l)*100
		estadd scalar Fstat = e(cdf)
		estadd scalar pval = e(jp)
		matrix b=e(b)
		scalar pred=exp(b[1,1])-1
		estadd scalar Tau=pred




* export results to latex table
	estout tab2_1 tab2_2 tab2_3 tab2_4 tab2_5 ///
	using "$dir\latex\temp_rentals_fuzzy.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional death_ind deaths) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw Fstat pval Tau, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)" "First-stage F-stat" "Sargan-Hansen p-value") )
	
