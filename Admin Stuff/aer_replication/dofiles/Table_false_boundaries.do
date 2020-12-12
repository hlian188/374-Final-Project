*************************************************************************************
* Purpose: This do-file import data performs RD for falsification data
* Output: Table B3: False Treatment Boundary Tests
*************************************************************************************


* globals set in Master file

	clear all
	set more off


	use "$dir\data\other\falsification_final.dta", clear




*************************************************************************************
 * Panel A: Fake boundary 1  (Columns (1) - (6))
*************************************************************************************

* Set negative values for the distances to the boundary that are outside the BSP perimeter
	gen temp=dist_fake1
	replace temp=-dist_fake1 if fake1==0



* Calculate optimal bandwith (hopt_`var') using "rdbwselect command (Calonico et al. (2014))

foreach var in log_rentals_1853 log_rentals_1864 deaths death_ind moved log_rentals_1894 {
	rdbwselect `var' temp if broad==0, vce(nncluster block)
	scalar hopt_`var'=round(e(h_mserd), 0.01)
}


	local covariates "dist_cent dist_square dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake" 
	local i = 1


* Regressions
foreach var in log_rentals_1853 deaths death_ind log_rentals_1864 moved log_rentals_1894 {
	reg `var' fake1 dist_fake1 dist_fake1_2 `covariates' ///
	if dist_fake1<hopt_`var'& broad==0, cl(block) 
	est store tab11_a_`i'
	estadd scalar Obs = e(N)
	estadd scalar Bw = hopt_`var'*100
	local i=`i'+1
}



	* export results to latex table
	estout  tab11_a_1 tab11_a_2 tab11_a_3 tab11_a_4 tab11_a_5 tab11_a_6  ///
	using "$dir\latex\falsification1.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a2))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(fake1)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Bw, labels("Observations"  "Bandwidth (meters)") )


	drop temp



*************************************************************************************
 * Panel B: Fake boundary 2  (Columns (1) - (6))
*************************************************************************************

* Set negative values for the distances to the boundary that are outside the BSP perimeter

	gen temp=dist_fake2
	replace temp=-dist_fake2 if fake2==0



* Calculate optimal bandwith (hopt_`var') using "rdbwselect command (Calonico et al (2014))

foreach var in log_rentals_1853 log_rentals_1864 deaths death_ind moved log_rentals_1894 {
	rdbwselect `var' temp if broad==0, vce(nncluster block)
	scalar hopt_`var'=round(e(h_mserd), 0.01)
}



	local covariates "dist_cent dist_square dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake" 
	local i = 1

	
foreach var in log_rentals_1853 deaths death_ind log_rentals_1864 moved log_rentals_1894 {
	reg `var' fake2 dist_fake2 dist_fake2_2 `covariates' ///
	if dist_fake2<hopt_`var'& broad==0 & fid_fake2!=2, cl(block)
	est store tab11_b_`i'
	estadd scalar Obs = e(N)
	estadd scalar Bw = hopt_`var'*100
	local i=`i'+1
}


* export results to latex table
	estout  tab11_b_1 tab11_b_2 tab11_b_3 tab11_b_4 tab11_b_5 tab11_b_6  ///
	using "$dir\latex\falsification2.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(fake2)  ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Bw, labels("Observations"  "Bandwidth (meters)") )
	
	

drop temp




*************************************************************************************
 * Panel C: Fake boundary 3  (Columns (1) - (6))
*************************************************************************************

* Set negative values for the distances to the boundary that are outside the BSP perimeter
	gen temp=dist_fake3
	replace temp=-dist_fake3 if fake3==0


* Calculate optimal bandwith (hopt_`var') using "rdbwselect command (Calonico et al (2014))

	foreach var in log_rentals_1853 deaths death_ind log_rentals_1864 moved log_rentals_1894 {
		rdbwselect `var' temp if broad==0, vce(nncluster block)
		scalar hopt_`var'=round(e(h_mserd), 0.01)
	}
*


	local covariates "dist_cent dist_square dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank no_sewer old_sewer dist_vent dist_pump dist_pit_fake" 
	local i = 1

		
	foreach var in log_rentals_1853 deaths death_ind log_rentals_1864 moved log_rentals_1894 {
		reg `var' fake3 dist_fake3 dist_fake3_2 `covariates' ///
		if dist_fake3<hopt_`var' & broad==0, cl(block)
		est store tab11_c_`i'
		estadd scalar Obs = e(N)
		estadd scalar Bw = hopt_`var'*100
		local i=`i'+1
	}
	

	* export results to latex table
		estout  tab11_c_1 tab11_c_2 tab11_c_3 tab11_c_4 tab11_c_5 tab11_c_6  ///
		using "$dir\latex\falsification3.tex", replace style(tex) ///
		label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
		keep(fake3)  ///
		mlabels(, none) collabels(, none) eqlabels(, none) ///
		stats(Obs Bw, labels("Observations"  "Bandwidth (meters)") )
		
	drop temp





*************************************************************************************
 * Panel B: Fake boundary 2  (Columns (7) - (8))
*************************************************************************************

	use "$dir\data\current\houses_current_final.dta", clear
	drop if price==1073 //typo in house price
	drop if source==1 //Zoopla modes

// Exponentials for RD
* higher orders
	foreach i in 1 2  {
		foreach j in 2 3 {
			gen dist_fake`i'_`j' = dist_fake`i'^`j'
		}
	}
	egen pcode = group(post_code)
	tab source, gen(source)



* Set negative values for the distances to the boundary that are outside the BSP perimeter

	gen temp=dist_fake1
	replace temp=-dist_fake1 if fake1==0


* Calculate optimal bandwith (hopt_`var') using "rdbwselect command (Calonico et al (2014))
		rdbwselect lnprice temp if source==0, vce(nncluster pcode)
		scalar hopt_zoopla=round(e(h_mserd), 0.01)

		rdbwselect lnprice temp, vce(nncluster pcode)
		scalar hopt_zoopla_sales=round(e(h_mserd), 0.01)


* Column 7: All (sale + zoopla)
	reg lnprice fake1 dist_fake1 dist_fake1_2 dist_fake1_3 dist_cent flat dist_bomb year source2 ///
	if dist_fake1<=hopt_zoopla_sales & broad==0, cluster(pcode)
	est store tab11_d_1
	estadd scalar Obs = e(N)
	estadd scalar Bw = hopt_zoopla_sales*100

	
	
* Column 8: Zoopla only
	reg lnprice fake1 dist_fake1 dist_fake1_2 dist_fake1_3 dist_cent bed bath recep flat dist_bomb year source2 ///
	if dist_fake1<=hopt_zoopla & broad==0, cluster(pcode)
	est store tab11_d_2
	estadd scalar Obs = e(N)
	estadd scalar Bw = hopt_zoopla*100
	
	
	
* export results to latex table
	estout tab11_d_1 tab11_d_2  ///
	using "$dir\latex\falsification4.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(fake1) extracols(1,1,1,1,1,1) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Bw, labels("Observations"  "Bandwidth (meters)") )
	
	
	
	drop temp

	
	
*************************************************************************************
 * Panel D: Fake boundary 4  (Columns (7) - (8))
*************************************************************************************


* Set negative values for the distances to the boundary that are outside the BSP perimeter

	gen temp=dist_fake2
	replace temp=-dist_fake2 if fake2==0


* Calculate optimal bandwith using "rdbwselect command (Calonico et al (2014))
		rdbwselect lnprice temp if source==0, vce(nncluster pcode)
		scalar hopt_zoopla=round(e(b_mserd), 0.01)



* Column 7: All (sale + zoopla)
	reg lnprice fake2 dist_fake2 dist_fake2_2 dist_fake2_3 dist_cent flat dist_bomb year source2 ///
	if dist_fake2<=hopt_zoopla & broad==0, cluster(pcode)
		est store tab11_a_7
		estadd scalar Obs = e(N)
		estadd scalar Bw = hopt_zoopla*100
		
	
* Column 8: Only zoopla
	reg lnprice fake2 dist_fake2 dist_fake2_2 dist_fake2_3 dist_cent bed bath recep flat dist_bomb year source2 ///
	if dist_fake2<=hopt_zoopla & broad==0, cluster(pcode)
		est store tab11_a_8
		estadd scalar Obs = e(N)
		estadd scalar Bw = hopt_zoopla*100


	* export results to latex table
	estout tab11_a_7 tab11_a_8  ///
	using "$dir\latex\falsification1b.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(fake2) extracols(1,1,1,1,1,1) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Bw, labels("Observations"  "Bandwidth (meters)") )
	
	drop temp


