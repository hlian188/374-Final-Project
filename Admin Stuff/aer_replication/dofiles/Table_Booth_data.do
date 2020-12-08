*************************************************************************************
* Purpose: This do-file analyzes Booth data for analysis
* Output: Table 7: Boundary Effects on House Socioeconomic Status (1899)
*************************************************************************************


* globals set in Master file

	clear all
	set more off


	use "$dir\data\19th\final_booth_RG.dta", clear




* Set distance polynomials
	replace dist_netw=dist_netw/100
	foreach i in 2 3 4 {
		gen dist_netw`i'=dist_netw^`i'
	}


	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0	


// Dependent variables

* Indicator variable for socio-economic status
	gen vpoor=(class_99=="a"|class_99=="b")
	gen poor=(class_99=="c"|class_99=="d")
	gen working=(class_99=="e")
	gen middle=(class_99=="f"|class_99=="g")
	egen class = group(class_99)
	
	
* Set negative values for the distances to the boundary that are outside the BSP perimeter

	gen temp=dist_netw
	replace temp=-dist_netw if broad==0


// outcome vars
	local outcomes class vpoor poor working middle 
	
	
* Calculate optimal bandwith (hopt_`var') using "rd" command (Calonico et al. (2014))
	
foreach var of local outcomes {
	qui: rdbwselect `var' temp, vce(nncluster block)
	scalar hopt_`var'=round(e(h_mserd), 0.0001) 
	
	sum `var' if broad == 0 & dist_netw<hopt_`var'
	scalar mean_out_`var' = r(mean)

	sum `var' if broad == 0 & dist_netw<=1
	scalar mean_out_`var'_all = r(mean)
}	



************************************************************************************
* Table 7: Very Poor (Columns 1-3) 
************************************************************************************

* Column 1: LLR with controls
rdrobust vpoor dist_2, covs(dist_cent dist_square dist_thea ///
	dist_police dist_bank) vce(nncluster block) all
		est store tab_1 
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum vpoor if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_vpoor = r(mean)
		estadd scalar Mean = mean_out_llr2_vpoor
		estadd scalar Bw = e(h_l)*100

* Column 2: Semi:Polynomial and bandwidth
reg vpoor broad##c.(dist_netw) dist_cent dist_square dist_thea ///
	dist_police dist_bank if dist_netw<=hopt_vpoor, cluster(block)
		est store tab_2
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_vpoor
		estadd scalar Bw = hopt_vpoor*100

* Column 3: Polynomial and controls
rdrobust vpoor dist_2, covs(dist_cent dist_square dist_thea ///
	dist_police dist_bank) vce(nncluster block) all p(2) kernel(uniform) h(1)
		est store tab_3
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_vpoor_all
		estadd scalar Bw = 100




************************************************************************************
* Table 7: Poor (Columns 4-6) 
************************************************************************************

* Column 4: LLR with controls
rdrobust poor dist_2, covs(dist_cent dist_square dist_thea ///
	dist_police dist_bank) vce(nncluster block) all
		est store tab_4 
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum poor if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_poor = r(mean)
		estadd scalar Mean = mean_out_llr2_poor
		estadd scalar Bw = e(h_l)*100

* Column 5: Semi: Polynomial and bandwidth
reg poor broad dist_netw dist_netw2 dist_cent dist_square dist_thea ///
	dist_police dist_bank if dist_netw<=hopt_poor, cluster(block)
		est store tab_5
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_poor
		estadd scalar Bw = hopt_poor*100

* Column 6: Polynomial and controls
rdrobust poor dist_2, covs(dist_cent dist_square dist_thea ///
	dist_police dist_bank) vce(nncluster block) all p(2) kernel(uniform) h(1)
		est store tab_6
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_poor_all
		estadd scalar Bw = 100




************************************************************************************
* Table 7: Working class (Columns 7-9) 
************************************************************************************

* Column 7: LLR with controls
rdrobust working dist_2, covs(dist_cent dist_square dist_thea ///
	dist_police dist_bank) vce(nncluster block) all
		est store tab_7
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum working if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_working = r(mean)
		estadd scalar Mean = mean_out_llr2_working
		estadd scalar Bw = e(h_l)*100

* Column 8: Semi: Polynomial and bandwidth
reg working broad##c.(dist_netw) dist_cent dist_square dist_thea ///
	dist_police dist_bank if dist_netw<=hopt_working, cluster(block)
		est store tab_8
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_working
		estadd scalar Bw = hopt_working*100

* Column 9: Polynomial and controls
rdrobust working dist_2, covs(dist_cent dist_square dist_thea ///
	dist_police dist_bank) vce(nncluster block) all p(2) kernel(uniform) h(1)
		est store tab_9
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_working_all
		estadd scalar Bw = 100



************************************************************************************
* Table 7: Middle class (Columns 10-12) 
************************************************************************************

* Column 10: LLR with controls
rdrobust middle dist_2, covs(dist_cent dist_square dist_thea ///
	dist_police dist_bank) vce(nncluster block) all
		est store tab_10 
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum middle if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_middle = r(mean)
		estadd scalar Mean = mean_out_llr2_middle
		estadd scalar Bw = e(h_l)*100

* Column 11: Semi: Polynomial and bandwidth
reg middle broad##c.(dist_netw) dist_cent dist_square dist_thea ///
	dist_police dist_bank if dist_netw<=hopt_middle, cluster(block)
		est store tab_11
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_middle
		estadd scalar Bw = hopt_middle*100

* Column 12: Polynomial and controls
rdrobust middle dist_2, covs(dist_cent dist_square dist_thea ///
	dist_police dist_bank) vce(nncluster block) all p(3) kernel(uniform) h(1)
		est store tab_12
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_middle_all
		estadd scalar Bw = 100



* export results to latex table
	estout tab_1 tab_2 tab_3 tab_4 tab_5 tab_6 tab_7 tab_8 tab_9 tab_10 tab_11 tab_12     ///
	using "$dir\latex\temp_booth.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad 1.broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, fmt(0 3 2) labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	
