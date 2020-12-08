************************************************************************************
* File Purpose: Pre-trends in house rentals (1846 and 1853 data)
* Output: Figure SA5 "Mean Log Rental Prices in 1846 and 1853 by BSP status"
************************************************************************************


* globals set in Master file

	clear
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

*===================================================
* Figure SA5a: All observations
*===================================================
preserve
drop if broad==.
drop if year==.
collapse log_rentals, by(broad year)

gr tw (connected log_rentals year if broad==1) ///
	  (connected log_rentals year if broad==0), /// 
	  scheme(plotplainblind) ytitle("Log Rental Prices") ///
	  legend(pos(6) cols(2) label(1 "Inside BSP area") label(2 "Outside BSP area")) ///
	  xlabel(1846(7)1853, nogrid) ylabel(3.5(0.05)3.8, nogrid)
	  graph export "$dir\latex\pre_trend_all.eps", replace
	  graph export "$dir\latex\pre_trend_all.png", replace
restore




*=========================================================
* Figure SA5a: Restricted to within 30m of BSP boundary
*=========================================================
preserve
drop if broad==.
drop if year==.
gen dist_ind = (dist_netw<=0.3)
collapse log_rentals, by(dist_ind broad year)

gr tw (connected log_rentals year if broad==1) ///
	  (connected log_rentals year if broad==0) ///
	  if dist_ind==1, scheme(plotplainblind) ytitle("Log Rental Prices") ///
	  legend(pos(6) cols(2) label(1 "Inside BSP area") label(2 "Outside BSP area")) ///
	  xlabel(1846(7)1853, nogrid) ylabel(3.5(0.05)3.8, nogrid)
	  graph export "$dir\latex\pre_trend.eps", replace
	  graph export "$dir\latex\pre_trend.png", replace
restore






