************************************************************************************
* File Purpose: Analysis of house price data, 1995-2015
* Output: Table 8: Boundary Effects on House Prices, Zoopla House Value Estimates, and Rental Prices 1995-2013, 2015
************************************************************************************


* globals set in Master file

	clear all
	set more off

use "$dir\data\current\houses_current_final.dta", clear


drop if price==1073 //typo in price of house
drop if source==1 //Zoopla modes 

// Exponentials for RD
forvalues i=1(1)4 {
	gen dist_netw`i'=dist_netw^`i'
}

* Set negative values for the distances to the boundary that are outside the BSP perimeter
	gen temp=dist_netw
	replace temp=-dist_netw if broad==0

	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0
	
	egen pcode = group(post_code)
	tab source, gen(source)


* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))
* price data, all
	rdbwselect lnprice temp, vce(nncluster pcode) 
	scalar hopt_lnprice=round(e(b_mserd), 0.0001) 

* price data, zoopla	
	rdbwselect lnprice temp if source!=2, vce(nncluster pcode)
	scalar hopt_lnprice_zoopla=round(e(b_mserd), 0.0001)

*  price data, prices only	
	rdbwselect lnprice temp if source==2, vce(nncluster pcode) 
	scalar hopt_lnprice_price=round(e(b_mserd), 0.0001)

* rental data, all
	rdbwselect lnrental temp, vce(nncluster pcode)
	scalar hopt_lnrental=round(e(b_mserd), 0.0001)

	
	
* Calculate the means outside the Broad Street area for variables

* price data, all
	sum price if broad == 0 & dist_netw<hopt_lnprice
	scalar mean_out_price = r(mean)

	sum price if broad == 0 & dist_netw<1
	scalar mean_out_price_all = r(mean)
		
* price data, zoopla				
	sum price if broad == 0 & dist_netw<hopt_lnprice_zoopla & source!=2
	scalar mean_out_price_zoopla = r(mean)
		
	sum price if broad == 0 & dist_netw<1 & source!=2
	scalar mean_out_price_zoopla_all = r(mean)

*  price data, prices only		
	sum price if broad == 0 & dist_netw<hopt_lnprice_price & source==2
	scalar mean_out_price_price = r(mean)	
	
	sum price if broad == 0 & dist_netw<1 & source==2
	scalar mean_out_price_price_all = r(mean)


************************************************************************************
* Table 8: House sales and Zoopla combined (Columns 1-3) 
************************************************************************************

	* Column 1: LLR with Controls
	rdrobust lnprice dist_2, vce(nncluster pcode) covs(dist_cent flat dist_bomb year source2) all h(0.266)
		est store tab10_1
		estadd scalar Obs = e(N_b_l) + e(N_b_r)
		estadd scalar Mean = mean_out_price
		estadd scalar Bw = e(b_l)*100

	* Column 2: Semi: Polynomial and bandwidth
	* Poly order: 1 
	reg lnprice broad dist_netw dist_cent flat dist_bomb year source2 ///
	if dist_netw<hopt_lnprice, cl(pcode)
		est store tab10_2
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_price
		estadd scalar Bw = 100*hopt_lnprice

	* Column 3: Polynomial and Controls
	* Poly order: 2 
	reg lnprice broad dist_netw dist_netw2 dist_cent flat dist_bomb year source2 ///
	if dist_netw<1, cl(pcode)
		est store tab10_3
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_price_all
		estadd scalar Bw = 100


************************************************************************************
* Table 8: Zoopla only (Columns 4-6) 
************************************************************************************

	* Column 4: LLR with Controls
	rdrobust lnprice dist_2, vce(nncluster pcode) covs(dist_cent flat dist_bomb bed bath recep) all 
		est store tab10_4
		estadd scalar Obs = e(N_b_l) + e(N_b_r)
		estadd scalar Mean = mean_out_price_zoopla
		estadd scalar Bw = e(b_l)*100

	* Column 5: Semi: Polynomial and bandwidth
	* Poly order: 3
	reg lnprice broad dist_netw dist_netw2 dist_cent bed bath recep flat dist_bomb year source2 ///
	if dist_netw<hopt_lnprice_zoopla, cl(pcode)
		est store tab10_5
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_price_zoopla
		estadd scalar Bw = 100*hopt_lnprice_zoopla

	* Column 6: Polynomial and Controls
	* Poly order: 3
	reg lnprice broad dist_netw dist_netw2 dist_netw3 dist_cent bed bath recep flat dist_bomb year source2 ///
	if dist_netw<1, cl(pcode)
		est store tab10_6
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_price_zoopla_all
		estadd scalar Bw = 100



************************************************************************************
* Table 8: House rentals (Columns 7-9) 
************************************************************************************

use "$dir\data\current\current_rentals_final.dta", clear

	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0

	egen pcode = group(post_code)

	rdbwselect lnrental temp, covs(dist_bomb month_rented year bedrooms) vce(nncluster pcode)
	scalar hopt_lnrental=round(e(b_mserd), 0.0001)
	scalar list
	* hopt_lnrental = 0.491

* price data, all
	sum rentals_current if broad == 0 & dist_netw<hopt_lnrental
	scalar mean_out_lnrental = r(mean)

	sum rentals_current if broad == 0 & dist_netw<1
	scalar mean_out_lnrental_all = r(mean)
		

	* Column 7: LLR with Controls
	rdrobust lnrentals dist_2, vce(nncluster pcode) covs(dist_bomb month_rented year bedrooms) all h(0.491)
		est store tab10_7
		estadd scalar Obs = e(N_b_l) + e(N_b_r)
		estadd scalar Mean = mean_out_lnrental
		estadd scalar Bw = e(b_l)*100

	* Column 8: Semi: Polynomial and bandwidth
	* Poly order: 2 
	reg lnrentals broad dist_netw dist_netw2 dist_bomb month_rented year bedrooms ///
	if dist_netw<0.491, cl(pcode)
		est store tab10_8
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_lnrental
		estadd scalar Bw = 100*hopt_lnrental

	* Column 9: Polynomial and Controls
	* Poly order: 1
	reg lnrentals broad##c.(dist_netw) dist_bomb month_rented year bedrooms ///
	if dist_netw<=1, cl(pcode)
		est store tab10_9
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_lnrental_all
		estadd scalar Bw = 100

* export results to latex table
	estout tab10_1 tab10_2 tab10_3 tab10_4 tab10_5 tab10_6 tab10_7 tab10_8 tab10_9 ///
	using "$dir\latex\temp_current_rentals.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad 1.broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	

