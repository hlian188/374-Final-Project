************************************************************************************
* File Purpose: Robustness of results to dropping segments with sharp change in sewer status
* Output: Table SA3 "Analysis using Segments without Sharp Change in Sewage Status"
************************************************************************************


* globals set in Master file

	clear
	set more off


	use "$dir\data\19th\Merged_1853_1864_data.dta", clear




* Set negative values for the distances to the boundary that are outside the BSP perimeter


	gen temp=dist_netw/100
	replace temp=-dist_netw/100 if broad==0


	
* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al. (2014))
	local outcomes 	log_rentals_1853 log_rentals_1864

	 
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
	

* Segments of boundary where there could be a sharp discontinuity in no sewer
foreach i in 0 1 38 37 34 33 32 20 19 18 16 15 4 5 {
	drop if seg_40==`i'
}

* Segments of boundary where there could be a sharp discontinuity in new sewer
foreach i in 1 2 3 4 5 33 34 37 38 {
	drop if seg_40==`i'
}

foreach var of local outcomes {
	qui: rdbwselect `var' temp, vce(nncluster block)
	scalar hopt_`var'=round(e(h_mserd), 0.00001) 
}

drop temp



************************************************************************************
* Table SA3, Panel A (1853)
************************************************************************************
* Column 1	
	rdrobust log_rentals_1853 dist_2, vce(nncluster block) all
		est store tab2_1a 
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_rentals_53
		estadd scalar Bw = e(h_l)*100
	

* Column 2
	rdrobust log_rentals_1853 dist_2, vce(nncluster block) covs(dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake) all
		est store tab2_2a
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum rentals_53 if broad==0 & dist_netw<=e(h_l)
		scalar mean_out_llr2_53 = r(mean)
		estadd scalar Mean = mean_out_llr2_53
		estadd scalar Bw = e(h_l)*100


* Column 3
	reg log_rentals_1853 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<hopt_log_rentals_1853, cl(block)
		est store tab2_3a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_53
		estadd scalar Bw = hopt_log_rentals_1853*100
	

* Column 4
	reg log_rentals_1853 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<1, cl(block)
		est store tab2_4a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_53_all
		estadd scalar Bw = 100


* Column 5
	areg log_rentals_1853 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<1, a(seg_5) cl(block) 
		est store tab2_5a
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_53_all
		estadd scalar Bw = 100


* export results to latex table
	estout tab2_1a tab2_2a tab2_3a tab2_4a tab2_5a ///
	using "$dir\latex\temp_robust_sewer_1853.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	


************************************************************************************
* Table SA3, Panel B (1864)
************************************************************************************

* Column 1
	rdrobust log_rentals_1864 dist_2, vce(nncluster block) all
		est store tab2_1b
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Mean = mean_out_rentals_64
		estadd scalar Bw = e(h_l)*100


* Column 2
	rdrobust log_rentals_1864 dist_2, vce(nncluster block) covs(dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake) all
		est store tab2_2b
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		sum rentals_64 if broad==0 & dist_netw<=e(h_l)		
		scalar mean_out_llr2_64 = r(mean)
		estadd scalar Mean = mean_out_llr2_64
		estadd scalar Bw = e(h_l)*100


* Column 3
	reg log_rentals_1864 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<hopt_log_rentals_1864, cl(block)
		est store tab2_3b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_64
		estadd scalar Bw = 100*hopt_log_rentals_1864


* Column 4
	reg log_rentals_1864 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<1, cl(block)
		est store tab2_4b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_64_all
		estadd scalar Bw = 100


* Column 5
	areg log_rentals_1864 broad dist_netw dist_netw2 dist_cent dist_square /// 
	dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
	no_sewer old_sewer dist_vent dist_pump dist_pit_fake if dist_netw<1, a(seg_5) cl(block) 
		est store tab2_5b
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_out_rentals_64_all
		estadd scalar Bw = 100

* export results to latex table
	estout tab2_1b tab2_2b tab2_3b tab2_4b tab2_5b ///
	using "$dir\latex\temp_robust_sewer_1864.tex", replace style(tex) ///
	label cells(b(star fmt(a3)) se(par fmt(a3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(Conventional broad) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Mean Bw, labels("Observations" "Mean Outside BSP area" "Bandwidth (meters)") )
	


************************************************************************************
* Figure SA7 "RD Plots for Sewer Status: Restricted Sample"
************************************************************************************

* RD plot once segments are dropped
tab sewer, gen(sewer)
replace sewer2=1 if sewer3==1
drop sewer3

replace dist_netw=dist_netw*100

capture program drop myrdplot
program define myrdplot
args outcome 

	* large sample 
	local width = 20
	local hwidth = 10
	local limit = 100 - `width'
	local gr_limit = `limit'+`width'
	local gr_width = `gr_limit'/4
	local poly = 2
	local polybw = 200
	local kernel triangle

	* Scatter with smaller bins
	local width2 = 5
	local hwidth2 = 2.5
	local limit2 = 100 - `width2'
	
	qui {
	* Set negative values for the distances to the boundary that are outside the BSP perimeter
	gen temp_dist=dist_netw
	gen temp=dist_netw
	replace temp=-dist_netw if broad==0	
	* Calculate means,var in 20 m bins for continuous control variables 	  		  
	gen ind_bins=.
	gen hat_`outcome'=.
		forvalues i=0(`width')`limit' {
			reg `outcome' broad if temp_dist>`i'& temp_dist<=`i'+`width'
			predict _`outcome'_hat_`i' if e(sample)
			replace hat_`outcome'=_`outcome'_hat_`i' if hat_`outcome'==. 
			replace ind_bins=`i'+`hwidth' if _`outcome'_hat_`i'<. & ind_bins==.					
		}

	drop _*

	gen ind_bins2=.
	gen hat_`outcome'2=.
		forvalues i=0(`width2')`limit2' {
			reg `outcome' broad if temp_dist>`i'& temp_dist<=`i'+`width2'
			predict _`outcome'_hat_`i' if e(sample)
			replace hat_`outcome'2=_`outcome'_hat_`i' if hat_`outcome'2==. 
			replace ind_bins2=`i'+`hwidth2' if _`outcome'_hat_`i'<. & ind_bins2==.					
		}

	drop _* 
	* Set negative values for bins that are outside the BSP perimeter
	replace ind_bins=-ind_bins if broad==0
	replace ind_bins2=-ind_bins2 if broad==0
	* Plot the continuous control variables approaching from left and right
	gr tw (lpoly `outcome' temp if temp<=0 & temp>=-`limit'-`width', degree(`poly') ///
		  bwidth(`polybw') lpattern(solid) lcolor(gs1) kernel(`kernel')) ///
		  (lpoly `outcome' temp if temp>=0 & temp<=`limit'+`width', degree(`poly') ///
		  bwidth(`polybw') lpattern(solid) lcolor(gs1) kernel(`kernel')) ///
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs10)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) ylabel(0(0.2)1) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) xtitle(Distance to boundary) graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

foreach var in sewer2 sewer4 {
	  	myrdplot `var'
	 	graph export "$dir\latex\rdplot_`var'_robust.eps", replace
	 	graph export "$dir\latex\rdplot_`var'_robust.png", replace
}

