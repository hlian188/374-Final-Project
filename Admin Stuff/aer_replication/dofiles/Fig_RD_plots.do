*======================================================================
* Purpose: Do-file creates RDplots
* Outcome: 
* Figure 2:  Cholera Deaths and BSP Boundary (1854)
* Figure 3:  RD plots for Main Outcomes (in logs)
* Figure B1: Covariate RD Plots (1853)
* Figure B2: Histogram and Density of Forcing Variable (Distance to BSP boundary)
* Figure B3: RD Plots for Residential Mobility Outcome
* Figure B4: RD Plots for House Occupancy Outcomes
* Figure B5: RD Plots for Socioeconomic Outcomes
*======================================================================

clear all
set more off



*******************************************************************************
*  Figure 2a, 2b: Cholera Deaths and BSP Boundary (1854)
*******************************************************************************
* RD Program
capture program drop myrdplot
program define myrdplot
args outcome 

	* large sample 
	local width = 20
	local hwidth = 10
	local limit = 100 - `width'
	local gr_limit = `limit'+`width'
	local gr_width = `gr_limit'/4
	local poly = 3
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) /*ylabel(3.5(0.2)4.2)*/ xtitle(Distance to boundary) ///
		  graphregion(color(white)) 
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

use "$dir\data\19th\final_deaths_byhouse.dta", clear 

foreach var in death_ind deaths {
  	myrdplot `var'
 	graph export "$dir\latex\rdplot_`var'.eps", replace
 	graph export "$dir\latex\rdplot_`var'.png", replace
}




*******************************************************************************
*  Figure 2c: Cholera Deaths and BSP Boundary (1854)
*******************************************************************************
* Qtr block visited
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) /*ylabel(3.5(0.2)4.2)*/ xtitle(Distance to boundary) ///
		  graphregion(color(white)) 
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

use "$dir\data\19th\Merged_1853_1864_data.dta", clear

gen qtr_block = (visited_per_block>=0.25 & visited_per_block<.) // GR: Second expression added so that missing observations are not part of the indicator variable

myrdplot qtr_block
graph export "$dir\latex\rdplot_qtr_block.eps", replace
graph export "$dir\latex\rdplot_qtr_block.png", replace




*******************************************************************************
*  Figure 3a, 3b: RD plots for Main Outcomes (1853, 1864)
*******************************************************************************
* RD Program
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) /*ylabel(3.5(0.2)4.2)*/ xtitle(Distance to boundary) ///
		  graphregion(color(white)) 
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end


use "$dir\data\19th\Merged_1853_1864_data.dta", clear

foreach var in log_rentals_1853 log_rentals_1864 {
		  	myrdplot `var'
		 	graph export "$dir\latex\rdplot_`var'.eps", replace
		 	graph export "$dir\latex\rdplot_`var'.png", replace
		  }



*******************************************************************************
*  Figure 3c: RD plots for Main Outcomes (1894)
*******************************************************************************
* RD Program
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end


use "$dir\data\19th\Merged_1846_1894_data.dta", clear

foreach var in log_rentals_1846 log_rentals_1894 {
	myrdplot `var'
	graph export "$dir\latex\rdplot_`var'.eps", replace
}



*******************************************************************************
*  Figure 3d: RD plots for Main Outcomes (1936)
*******************************************************************************
* RD Program
capture program drop myrdplot
program define myrdplot
args outcome 

	* large sample 
	local width = 20
	local hwidth = 10
	local limit = 100 - `width'
	local gr_limit = `limit'+`width'
	local gr_width = `gr_limit'/4
	local poly = 1
	local polybw = 200
	local kernel triangle

	* Scatter with smaller bins
	local width2 = 5
	local hwidth2 = 2.5
	local limit2 = 100 - `width'
	
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) mcolor(gs3) msize(large)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

use "$dir\data\20th\houses_1936_final.dta", clear

replace dist_netw=100*dist_netw
myrdplot lnrentals
graph export "$dir\latex\rdplot_1936.eps", replace



*******************************************************************************
*  Figure 3e: RD plots for Main Outcomes (Zoopla and House prices)
*******************************************************************************
* Zoopla + House sales
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
	local width2 = 10
	local hwidth2 = 5
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

use "$dir\data\current\houses_current_final.dta", clear
drop if price==1073 //obvious typo
replace dist_netw=100*dist_netw
keep if source==0|source==2
myrdplot lnprice
graph export "$dir\latex\rdplot_zoopla_house_sales.eps", replace




*******************************************************************************
*  Figure 3f: RD plots for Main Outcomes (Zoopla only)
*******************************************************************************
* RD program
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
	local width2 = 10
	local hwidth2 = 5
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

* Zoopla only
use "$dir\data\current\houses_current_final.dta", clear
drop if price==1073 //obvious typo
replace dist_netw=100*dist_netw
keep if source==0
myrdplot lnprice
graph export "$dir\latex\rdplot_zoopla_only.eps", replace





*******************************************************************************
*  Figure 3g: RD plots for Main Outcomes (House rentals)
*******************************************************************************
* RD program
capture program drop myrdplot
program define myrdplot
args outcome 

	* large sample 
	local width = 20
	local hwidth = 10
	local limit = 100 - `width'
	local gr_limit = `limit'+`width'
	local gr_width = `gr_limit'/4
	local poly = 1
	local polybw = 200
	local kernel triangle

	* Scatter with smaller bins
	local width2 = 10
	local hwidth2 = 5
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

* Rentals
use "$dir\data\current\current_rentals_final.dta", clear
drop temp

replace dist_netw=100*dist_netw
myrdplot lnrental
graph export "$dir\latex\rdplot_house_rentals.eps", replace





*******************************************************************************
*  Figure B1: Covariate RD Plots (1853)--Continuous covariates
********************************************************************************
* RD program
capture program drop myrdplot
program define myrdplot
args outcome 

	* large sample 
	local width = 20
	local hwidth = 10
	local limit = 100 - `width'
	local gr_limit = `limit'+`width'
	local gr_width = `gr_limit'/4
	local poly = 3
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
		  xline(0) ylabel(0(100)600) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) xtitle(Distance to boundary) graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

use "$dir\data\19th\Merged_1853_1864_data.dta", clear
foreach var in dist_pump dist_cent dist_pit_fake dist_square  dist_police ///
		  dist_fire dist_thea dist_pub dist_urinal dist_vent dist_bank {
		  	myrdplot `var'
		 	graph export "$dir\latex\rdplot_`var'.eps", replace
		 	graph export "$dir\latex\rdplot_`var'.png", replace
		  }


*******************************************************************************
* Figure B1: Covariate RD Plots (1853)--Discrete covaraites
********************************************************************************
* RD program
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

use "$dir\data\19th\Merged_1853_1864_data.dta", clear

tab sewer, gen(sewer)
replace sewer2=1 if sewer3==1
drop sewer3
gen exon = (rentals_53==.)
foreach var in sewer1 sewer2 sewer4 exon {
		  	myrdplot `var'
		 	graph export "$dir\latex\rdplot_`var'.eps", replace
		 	graph export "$dir\latex\rdplot_`var'.png", replace
		  }



********************************************************************************
* Figure B2: Histogram and Density of Forcing Variable (Distance to BSP boundary)
********************************************************************************

use "$dir\data\19th\houses_1853_final.dta", clear

* Distance variables
	foreach var of varlist dist_* {
		replace `var'=`var'*100
	}

* Set negative values for the distances to the boundary that are outside the BSP perimeter

	gen dist_2=dist_netw
	replace dist_2=-dist_netw if broad==0


*	(a) Histogram of distance (forcing variable)

	hist dist_2, addplot(pci 0 0 0.008 0) width(15) ///
	  legend(off) xtitle(Distance to boundary) start(-300) ///
	  graphregion(color(white)) 
	  graph export "$dir\latex\hist_BSP.eps", replace
	  graph export "$dir\latex\hist_BSP.png", replace


*	(b) McCrary (2008) test for break in the density of forcing variable

	capture cd "$dir\dofiles\mccrary's ado"

		DCdensity dist_2, breakpoint(0) generate(Xj Yj r0 fhat se_fhat)   ///
				  graphname(hist_mccrary_BSP.eps)
					drop Xj Yj r0 fhat se_fhat /* No evidence of break*/
					graph export "$dir\latex\mccrary_BSP.eps", replace
					graph export "$dir\latex\mccrary_BSP.png", replace




********************************************************************************
* Figure B3: RD Plots for Residential Mobility Outcome
********************************************************************************
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
	local width2 = 10
	local hwidth2 = 5
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) msize(large) mcolor(gs3)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) /*ylabel(3.5(0.2)4.2)*/ xtitle(Distance to boundary) ///
		  graphregion(color(white)) 
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

use "$dir\data\19th\Merged_1853_1864_data.dta", clear
keep if (log_rentals_1853!=. & log_rentals_1864!=.)

myrdplot moved
graph export "$dir\latex\rdplot_moved.eps", replace



*******************************************************************************
* Figure B4a, B4b: RD Plots for House Occupancy Outcomes 
********************************************************************************
* RD Program
capture program drop myrdplot
program define myrdplot
args outcome 

	* large sample 
	local width = 20
	local hwidth = 10
	local limit = 100 - `width'
	local gr_limit = `limit'+`width'
	local gr_width = `gr_limit'/4
	local poly = 1
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) mcolor(gs3) msize(large)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) ylabel(0(5)25) xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

use "$dir\data\19th\Data_census.dta", clear
replace dist_netw=dist_netw*100
drop temp //variable named temp already in dataset

* Household size
foreach var in house_pop51 house_pop61 {
		  	myrdplot `var'
		 	graph export "$dir\latex\rdplot_`var'.eps", replace
		 	graph export "$dir\latex\rdplot_`var'.png", replace
		  }


*******************************************************************************
* Figure B4c, B4d: RD Plots for House Occupancy Outcomes 
********************************************************************************
* Number of immigrants
capture program drop myrdplot
program define myrdplot
args outcome 

	* large sample 
	local width = 20
	local hwidth = 10
	local limit = 100 - `width'
	local gr_limit = `limit'+`width'
	local gr_width = `gr_limit'/4
	local poly = 1
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) mcolor(gs3) msize(large)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) ylabel(0(0.5)1.62) xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end


foreach var in far_immigrants51 far_immigrants61 {
		  	myrdplot `var'
		 	graph export "$dir\latex\rdplot_`var'.eps", replace
		 	graph export "$dir\latex\rdplot_`var'.png", replace
		  }


*******************************************************************************
* Figure B4e, B4f: RD Plots for House Occupancy Outcomes 
********************************************************************************
* Fraction of household is immigrant
capture program drop myrdplot
program define myrdplot
args outcome 

	* large sample 
	local width = 20
	local hwidth = 10
	local limit = 100 - `width'
	local gr_limit = `limit'+`width'
	local gr_width = `gr_limit'/4
	local poly = 1
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) mcolor(gs3) msize(large)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) ylabel(0(0.1)0.32) xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

foreach var in immigrants_frac51 immigrants_frac61  {
		  	myrdplot `var'
		 	graph export "$dir\latex\rdplot_`var'.eps", replace
		 	graph export "$dir\latex\rdplot_`var'.png", replace
		  }





*******************************************************************************
* Figure B5: RD Plots for Socioeconomic Outcomes
********************************************************************************
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
	local polybw = 100
	local kernel rectangle

	* Scatter with smaller bins
	local width2 = 10
	local hwidth2 = 5
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
		  (scatter hat_`outcome'2 ind_bins2, msymbol(Oh) mcolor(gs13)) ///
		  (scatter hat_`outcome' ind_bins, msymbol(circle) mcolor(gs3) msize(large)), ///
		  xline(0) xlabel(-`gr_limit'(`gr_width')`gr_limit', nogrid) ///
		  sch(s2mono) leg(off) ylabel() xtitle(Distance to boundary) ///
		  graphregion(color(white))
	drop ind_bins ind_bins2 hat_* temp temp_dist 
	}
end

use "$dir\data\19th\final_booth_RG.dta", clear

* Indicator variable for socio-economic status
	gen vpoor=(class_99=="a"|class_99=="b")
	gen poor=(class_99=="c"|class_99=="d")
	gen working=(class_99=="e")
	gen middle=(class_99=="f"|class_99=="g")
	egen class = group(class_99)

foreach var in vpoor poor working middle {
		  	myrdplot `var'
		 	graph export "$dir\latex\rdplot_`var'.eps", replace
		 	graph export "$dir\latex\rdplot_`var'.png", replace
		  }



