************************************************************************************
* File Purpose: Pre-trends in house rental data (1846,1853)
* Output: Table SA2 "Evaluating Evidence of Pre-Trends in Log Rental Prices (1846, 1853)"
************************************************************************************


* globals set in Master file

clear all
set more off


use "$dir\data\19th\Merged_1846_1894_data.dta", clear
	


* Preparing data
bys id: gen temp_n=_n
gen uid = id*1000 + temp_n 
reshape long log_rentals_, i(uid) j(year)
rename log_rentals_ log_rentals
keep if year==1846|year==1853

* change distance scale	 
	replace dist_netw = dist_netw/100
	replace dist_netw2 = dist_netw^2
	replace dist_netw3 = dist_netw^3
gen dist_2 = dist_netw
replace dist_2=-dist_netw if broad==0

gen t53 = (year==1853)
gen int_broad = t53*broad


* Column 1: DID, entire sample
reg log_rentals broad t53 int_broad, cl(block)
		est store tab2_1 
		estadd scalar Obs = e(N)
		estadd scalar Bw = .


* Column 2: DID, within 100m of boundary
reg log_rentals broad t53 int_broad if dist_netw<=1, cl(block)
		est store tab2_2 
		estadd scalar Obs = e(N)
		estadd scalar Bw = 100


* Column 3: DID, within RD optimal bandwidth
reg log_rentals broad t53 int_broad if dist_netw<=0.2955, cl(block)
		est store tab2_3 
		estadd scalar Obs = e(N)
		estadd scalar Bw = 29.55


* Column 4: RD, LLR (1846)
rdrobust log_rentals dist_2 if year==1846, vce(nncluster block) all
		est store tab2_4 
		estadd scalar Obs = e(N_h_l) + e(N_h_r)
		estadd scalar Bw = e(h_l)*100


* Column 5: RD, polynomial (1846)
reg log_rentals broad dist_netw dist_netw2 dist_netw3 if year==1846 & dist_netw<=1
		est store tab2_5 
		estadd scalar Obs = e(N)
		estadd scalar Bw = 100



* export results to latex table
	estout tab2_1 tab2_2 tab2_3 tab2_4 tab2_5 ///
	using "$dir\latex\temp_pre_trends.tex", replace style(tex) ///
	label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
	keep(broad t53 int_broad Conventional) ///
	mlabels(, none) collabels(, none) eqlabels(, none) ///
	stats(Obs Bw, labels("Observations" "Bandwidth (meters)") )
	
