********************************************************************************
* Purpose: Analyze Bandwidth sensitivity
* Output: Figure SA4 "Bandwidth Sensitivity"
********************************************************************************


* globals set in Master file

		clear all
		set more off




*************************************************************
** 1853-1864 houses ******
*************************************************************
use "$dir\data\19th\Merged_1853_1864_data.dta", clear

	tempname coeff
	postfile `coeff' bw broad_53 se_53 df_53 broad_64 se_64 df_64 using "$dir\data\19th\coeff_53_64.dta", replace
		{
		
		forvalues i=10(1)100 {

		quiet reg log_rentals_1853 broad dist_netw dist_netw2 dist_cent dist_square /// 
		dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
		no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
		if dist_netw<`i', cl(block) 
		matrix b_53=e(b)
		matrix v_53=e(V)
		local se_53=sqrt(v_53[1,1])
		local df_53=e(df_r)

		quiet reg log_rentals_1864 broad dist_netw dist_netw2 dist_cent dist_square /// 
		dist_fire dist_thea dist_polic dist_urinal dist_pub dist_church dist_bank ///
		no_sewer old_sewer dist_vent dist_pump dist_pit_fake ///
		if dist_netw<`i', cl(block) 
		matrix b_64=e(b)
		matrix v_64=e(V)
		local se_64=sqrt(v_64[1,1])
		local df_64=e(df_r)
		
		post `coeff' (`i') (b_53[1,1]) (`se_53') (`df_53') (b_64[1,1]) (`se_64') (`df_64') /* Values that you want to post in your postfile*/

		}
	}
	postclose `coeff'


*************************************************************
********* 1894 houses ******
*************************************************************
use "$dir\data\19th\Merged_1846_1894_data.dta", clear

	tempname coeff

	postfile `coeff' bw broad_b broad_se df using "$dir\data\19th\coeff_94.dta", replace
		{
		forvalues i=10(1)100 {

		quiet reg log_rentals_1894 broad dist_netw dist_netw2 dist_cent dist_square ///
		if dist_netw<=`i', cl(block)

		matrix b=e(b)
		matrix v=e(V)
		local se=sqrt(v[1,1])
		local df=e(df_r)
		post `coeff' (`i') (b[1,1]) (`se') (`df') /* Values that you want to post in your postfile*/

		}
	}
  
	postclose `coeff'


*************************************************************
* 1936 houses 
*************************************************************
use "$dir\data\20th\houses_1936_final.dta", clear //data created in step 1

gen temp=dist_netw*100

gen dist_2=dist_netw
replace dist_2=-dist_netw if broad==0
replace dist_2=dist_2*100


	tempname coeff
	postfile `coeff' bw broad_b broad_se df using "$dir\data\20th\coeff_36.dta", replace
		{
		forvalues i=10(1)100 {

		quiet reg lnrentals broad dist_netw dist_netw2 dist_netw3 dist_cent dist_square ////
		dist_thea dist_police dist_school dist_pub dist_church dist_bank length width if temp<=`i', cl(block)

		matrix b=e(b)
		matrix v=e(V)
		local se=sqrt(v[1,1])
		local df=e(df_r)
		post `coeff' (`i') (b[1,1]) (`se') (`df') 

		}
	}
	postclose `coeff'


*************************************************************
* Current houses 
*************************************************************
use "$dir\data\current\houses_current_final.dta", clear //data created in step 1

drop if price==1073 //obvious typo
drop if source==1 //Zoopla modes

egen pcode = group(post_code)
tab source, gen(source)

// Exponentials for RD
forvalues i=1(1)4 {
	gen dist_netw`i'=dist_netw^`i'
}

gen temp=dist_netw*100

	tempname coeff
	postfile `coeff' bw broad_all se_all df_all broad_z se_z df_z using "$dir\data\current\coeff_now.dta", replace
		{
		forvalues i=10(1)100 {

		* House sales and Zoopla combined
		quiet reg lnprice broad dist_netw dist_netw2 dist_cent flat dist_bomb year source2 ///
		if temp<`i', cl(pcode)
		matrix b=e(b)
		matrix v=e(V)
		local se=sqrt(v[1,1])
		local df=e(df_r)

		* Zoopla only
		quiet reg lnprice broad dist_netw dist_netw2 dist_netw3 dist_cent bed bath recep flat dist_bomb year source2 ///
		if temp<`i', cl(pcode)
		matrix b_zoopla=e(b)
		matrix v_zoopla=e(V)
		local se_zoopla=sqrt(v_zoopla[1,1])
		local df_zoopla=e(df_r)

		post `coeff' (`i') (b[1,1]) (`se') (`df') (b_zoopla[1,1]) (`se_zoopla') (`df_zoopla')
		}
	}
	postclose `coeff'


*************************************************************
* House Rentals
*************************************************************
use "$dir\data\current\current_rentals_final.dta", clear
drop temp

egen pcode = group(post_code)

gen temp=dist_netw*100

	tempname coeff
	postfile `coeff' bw broad_b broad_se df using "$dir\data\current\coeff_now_rentals.dta", replace
		{
		forvalues i=10(1)100 {

		quiet reg lnrentals broad dist_netw dist_netw2 dist_bomb month_rented year bedrooms ///
		if temp<=`i', cl(pcode)

		matrix b=e(b)
		matrix v=e(V)
		local se=sqrt(v[1,1])
		local df=e(df_r)
		post `coeff' (`i') (b[1,1]) (`se') (`df') 

		}
	}
	postclose `coeff'


*************************************************************
* Deaths 
*************************************************************
use "$dir\data\19th\Merged_1853_1864_data.dta", clear

	tempname coeff
	postfile `coeff' bw broad_d se_d df_d broad_ind se_ind df_ind using "$dir\data\19th\coeff_death.dta", replace
		{
		forvalues i=10(1)100 {

		* House sales and Zoopla combined
		quiet reg deaths broad dist_netw dist_netw2 dist_cent dist_urinal no_sewer old_sewer if dist_netw<`i', cl(block)
		matrix b_d=e(b)
		matrix v_d=e(V)
		local se_d=sqrt(v_d[1,1])
		local df_d=e(df_r)

		* Zoopla only
		quiet reg death_ind broad dist_netw dist_netw2 dist_cent dist_urinal no_sewer old_sewer if dist_netw<`i', cl(block)
		matrix b_ind=e(b)
		matrix v_ind=e(V)
		local se_ind=sqrt(v_ind[1,1])
		local df_ind=e(df_r)

		post `coeff' (`i') (b_d[1,1]) (`se_d') (`df_d') (b_ind[1,1]) (`se_ind') (`df_ind')
		}
	}
	postclose `coeff'

*************************************************************
**** Moved ****
*************************************************************
use "$dir\data\19th\Merged_1853_1864_data.dta", clear

	tempname coeff
	postfile `coeff' bw broad_b broad_se df using "$dir\data\19th\coeff_moved.dta", replace
		{
		forvalues i=10(1)100 {

		quiet reg moved broad dist_netw dist_netw2 dist_netw3 no_sewer old_sewer dist_vent dist_urinal if dist_netw<`i', cl(block)

		matrix b=e(b)
		matrix v=e(V)
		local se=sqrt(v[1,1])
		local df=e(df_r)
		post `coeff' (`i') (b[1,1]) (`se') (`df') 

		}
	}
	postclose `coeff'

*************************************************************
**** Census-Population ****
*************************************************************
use "$dir\data\19th\Data_census.dta", clear
replace dist_netw=dist_netw*100
keep if house_pop51!=.&house_pop61!=.

	tempname coeff
	postfile `coeff' bw broad_51 se_51 df_51 broad_61 se_61 df_61 using "$dir\data\19th\coeff_census.dta", replace
		{
		forvalues i=10(1)100 {

		quiet reg house_pop51 broad##c.(dist_netw dist_netw2) dist_urinal old_sewer no_sewer if dist_netw<`i', cl(block)
		matrix b_51=e(b)
		matrix v_51=e(V)
		local se_51=sqrt(v_51[2,2])
		local df_51=e(df_r)

		quiet reg house_pop61 broad##c.(dist_netw dist_netw2) dist_urinal old_sewer no_sewer if dist_netw<`i', cl(block)
		matrix b_61=e(b)
		matrix v_61=e(V)
		local se_61=sqrt(v_61[2,2])
		local df_61=e(df_r)

		post `coeff' (`i') (b_51[1,2]) (`se_51') (`df_51') (b_61[1,2]) (`se_61') (`df_61')

		}
	}
	postclose `coeff'

*************************************************************
**** Census-Immigrant families ****
*************************************************************
use "$dir\data\19th\Data_census.dta", clear
replace dist_netw=dist_netw*100


	tempname coeff
	postfile `coeff' bw broad_51 se_51 df_51 broad_61 se_61 df_61 using "$dir\data\19th\coeff_immigrant.dta", replace
		{
		forvalues i=10(1)100 {

		quiet reg far_immigrants51 broad dist_netw dist_netw2 dist_urinal old_sewer no_sewer if dist_netw<`i', cl(block)
		matrix b_51=e(b)
		matrix v_51=e(V)
		local se_51=sqrt(v_51[1,1])
		local df_51=e(df_r)

		quiet reg far_immigrants61 broad dist_netw dist_netw2 dist_urinal old_sewer no_sewer if dist_netw<`i', cl(block)
		matrix b_61=e(b)
		matrix v_61=e(V)
		local se_61=sqrt(v_61[1,1])
		local df_61=e(df_r)

		post `coeff' (`i') (b_51[1,1]) (`se_51') (`df_51') (b_61[1,1]) (`se_61') (`df_61')

		}
	}
	postclose `coeff'

*************************************************************
**** Census-Immigrant families fraction ****
*************************************************************
use "$dir\data\19th\Data_census.dta", clear
replace dist_netw=dist_netw*100


	tempname coeff
	postfile `coeff' bw broad_51 se_51 df_51 broad_61 se_61 df_61 using "$dir\data\19th\coeff_immigrant_frac.dta", replace
		{
		forvalues i=10(1)100 {

		quiet reg immigrants_frac51 broad##c.(dist_netw dist_netw2) dist_urinal old_sewer no_sewer if dist_netw<`i', cl(block)
		matrix b_51=e(b)
		matrix v_51=e(V)
		local se_51=sqrt(v_51[2,2])
		local df_51=e(df_r)

		quiet reg immigrants_frac61 broad##c.(dist_netw dist_netw2) dist_urinal old_sewer no_sewer if dist_netw<`i', cl(block)
		matrix b_61=e(b)
		matrix v_61=e(V)
		local se_61=sqrt(v_61[2,2])
		local df_61=e(df_r)

		post `coeff' (`i') (b_51[1,2]) (`se_51') (`df_51') (b_61[1,2]) (`se_61') (`df_61')

		}
	}
	postclose `coeff'


*************************************************************
**** Booth data ****
*************************************************************
use "$dir\data\19th\final_booth_RG.dta", clear
* Set distance network
foreach i in 2 3 {
	gen dist_netw`i'=dist_netw^`i'
}

* Indicator variable for socio-economic status
gen vpoor=(class_99=="a"|class_99=="b")
gen poor=(class_99=="c"|class_99=="d")
gen working=(class_99=="e")
gen middle=(class_99=="f"|class_99=="g")


	tempname coeff
	postfile `coeff' bw broad_v se_v df_v broad_p se_p df_p ///
					    broad_w se_w df_w broad_m se_m df_m ///
					    using "$dir\data\19th\coeff_booth.dta", replace
		{
		
		forvalues i=10(1)100 {

		quiet reg vpoor broad##c.(dist_netw) dist_cent dist_square dist_thea ///
		dist_police dist_bank if dist_netw<=`i', cluster(block)
		matrix b_v=e(b)
		matrix v_v=e(V)
		local se_v=sqrt(v_v[2,2])
		local df_v=e(df_r)

		quiet reg poor broad##c.(dist_netw) dist_cent dist_square dist_thea ///
		dist_police dist_bank if dist_netw<=`i', cluster(block)
		matrix b_p=e(b)
		matrix v_p=e(V)
		local se_p=sqrt(v_p[2,2])
		local df_p=e(df_r)

		quiet reg working broad##c.(dist_netw) dist_cent dist_square dist_thea ///
		dist_police dist_bank if dist_netw<=`i', cluster(block)
		matrix b_w=e(b)
		matrix v_w=e(V)
		local se_w=sqrt(v_w[2,2])
		local df_w=e(df_r)

		quiet reg middle broad##c.(dist_netw) dist_cent dist_square dist_thea ///
		dist_police dist_bank if dist_netw<=`i', cluster(block)
		matrix b_m=e(b)
		matrix v_m=e(V)
		local se_m=sqrt(v_m[2,2])
		local df_m=e(df_r)

		post `coeff' (`i') (b_v[1,2]) (`se_v') (`df_v') (b_p[1,2]) (`se_p') (`df_p') ///
						   (b_w[1,2]) (`se_w') (`df_w') (b_m[1,2]) (`se_m') (`df_m')

		}
	}
	postclose `coeff'



*************************************************************
* Figure SA4a, SA4b: Graphs 1853 and 1864
*************************************************************	  
	use "$dir\data\19th\coeff_53_64.dta", clear
	foreach var in 53 64 {
		gen upper_`var' = broad_`var' + invttail(df_`var',0.05)*se_`var'
		gen lower_`var' = broad_`var' - invttail(df_`var',0.05)*se_`var'
		gen upper_`var'_95 = broad_`var' + invttail(df_`var',0.025)*se_`var'
		gen lower_`var'_95 = broad_`var' - invttail(df_`var',0.025)*se_`var'

		graph twoway (line broad_`var' bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_`var' bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_`var' bw, lpattern(dash) lcolor(gray)) ///
				 (line upper_`var'_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_`var'_95 bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0) ylabel(-0.40(0.1)0.2)
				  graph export "$dir\latex\bw_`var'.eps", replace
	}

*************************************************************
* Figure SA4c: Graphs 1894
*************************************************************
	use "$dir\data\19th\coeff_94.dta", clear
	gen upper = broad_b + invttail(df,0.05)*broad_se
	gen lower = broad_b - invttail(df,0.05)*broad_se
	gen upper_95 = broad_b + invttail(df,0.025)*broad_se
	gen lower_95 = broad_b - invttail(df,0.025)*broad_se

	graph twoway (line broad_b bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line upper bw, lpattern(dash) lcolor(gray)) ///
				 (line lower bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0) 
				  graph export "$dir\latex\bw_94.eps", replace


*************************************************************
* Figure SA4d: Graphs 1936
*************************************************************
	use "$dir\data\20th\coeff_36.dta", clear
	gen upper = broad_b + invttail(df,0.05)*broad_se
	gen lower = broad_b - invttail(df,0.05)*broad_se
	gen upper_95 = broad_b + invttail(df,0.025)*broad_se
	gen lower_95 = broad_b - invttail(df,0.025)*broad_se

	graph twoway (line broad_b bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line upper bw, lpattern(dash) lcolor(gray)) ///
				 (line lower bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0) 
				  graph export "$dir\latex\bw_36.eps", replace


*************************************************************
* Figure SA4e, SA4f: Graphs current data
*************************************************************
	use "$dir\data\current\coeff_now.dta", clear
	foreach var in all z {
		gen upper_`var' = broad_`var' + invttail(df_`var',0.05)*se_`var'
		gen lower_`var' = broad_`var' - invttail(df_`var',0.05)*se_`var'
		gen upper_`var'_95 = broad_`var' + invttail(df_`var',0.025)*se_`var'
		gen lower_`var'_95 = broad_`var' - invttail(df_`var',0.025)*se_`var'

		gr tw (line broad_`var' bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_`var'_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_`var'_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line upper_`var' bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_`var' bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0) ylabel(-0.6(0.2)0.2)
				  graph export "$dir\latex\bw_now_`var'.eps", replace
	}			  
				  
	
*************************************************************
* Figure SA4g: Graphs current data
*************************************************************
	use "$dir\data\current\coeff_now_rentals.dta", clear
	gen upper = broad_b + invttail(df,0.05)*broad_se
	gen lower = broad_b - invttail(df,0.05)*broad_se
	gen upper_95 = broad_b + invttail(df,0.025)*broad_se
	gen lower_95 = broad_b - invttail(df,0.025)*broad_se

	graph twoway (line broad_b bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line upper bw, lpattern(dash) lcolor(gray)) ///
				 (line lower bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0) 
				  graph export "$dir\latex\bw_now_rentals.eps", replace


*************************************************************
* Figure SA4h: Graphs death results
*************************************************************
	use "$dir\data\19th\coeff_death.dta", clear
	foreach var in d ind {
		gen upper_`var' = broad_`var' + invttail(df_`var',0.05)*se_`var'
		gen lower_`var' = broad_`var' - invttail(df_`var',0.05)*se_`var'
		gen upper_`var'_95 = broad_`var' + invttail(df_`var',0.025)*se_`var'
		gen lower_`var'_95 = broad_`var' - invttail(df_`var',0.025)*se_`var'
	}

		gr tw (line broad_d bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_d_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_d_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line upper_d bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_d bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0) ylabel(0(0.2)1)
				  graph export "$dir\latex\bw_death_d.eps", replace			  
		
		gr tw (line broad_ind bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_ind_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_ind_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line upper_ind bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_ind bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0) ylabel(0(0.1)0.4)
				  graph export "$dir\latex\bw_death_ind.eps", replace


*************************************************************
* Figure SA4i: Moved
*************************************************************
	use "$dir\data\19th\coeff_moved.dta", clear
	gen upper = broad_b + invttail(df,0.05)*broad_se
	gen lower = broad_b - invttail(df,0.05)*broad_se
	gen upper_95 = broad_b + invttail(df,0.025)*broad_se
	gen lower_95 = broad_b - invttail(df,0.025)*broad_se

	graph twoway (line broad_b bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line upper bw, lpattern(dash) lcolor(gray)) ///
				 (line lower bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0) 
				  graph export "$dir\latex\bw_moved.eps", replace


*************************************************************
* Figure SA4j, SA4k, SA4l: Census graphs
*************************************************************	  
	use "$dir\data\19th\coeff_census.dta", clear
		gr tw (line broad_51 bw, lwidth(medthick) graphregion(margin(r+1) color(white))) ///
			  (line broad_61 bw, lwidth(medthick) graphregion(margin(r+1) color(white))), ///
			   legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
			   ytitle(RD coeff) yline(0)
			   graph export "$dir\latex\bw_pop.eps", replace
	
	use "$dir\data\19th\coeff_immigrant.dta", clear
		gr tw (line broad_51 bw, lwidth(medthick) graphregion(margin(r+1) color(white))) ///
			  (line broad_61 bw, lwidth(medthick) graphregion(margin(r+1) color(white))), ///
			   legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
			   ytitle(RD coeff) yline(0) ylabel(0(0.2)0.6)
			   graph export "$dir\latex\bw_immigrant.eps", replace

	use "$dir\data\19th\coeff_immigrant_frac.dta", clear
		gr tw (line broad_51 bw, lwidth(medthick) graphregion(margin(r+1) color(white))) ///
			  (line broad_61 bw, lwidth(medthick) graphregion(margin(r+1) color(white))), ///
			   legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
			   ytitle(RD coeff) yline(0)
			   graph export "$dir\latex\bw_immigrant_frac.eps", replace

*************************************************************
* Figure SA4m, SA4n, SA4o, SA4p: Graphs Booth results
*************************************************************
	use "$dir\data\19th\coeff_booth.dta", clear
	foreach var in v p w m  {
		gen upper_`var' = broad_`var' + invttail(df_`var',0.05)*se_`var'
		gen lower_`var' = broad_`var' - invttail(df_`var',0.05)*se_`var'
		gen upper_`var'_95 = broad_`var' + invttail(df_`var',0.025)*se_`var'
		gen lower_`var'_95 = broad_`var' - invttail(df_`var',0.025)*se_`var'

		gr tw (line broad_`var' bw, lwidth(medthick) graphregion(color(white))) ///
				 (line upper_`var'_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_`var'_95 bw, lpattern(dash) lcolor(gray)) ///
				 (line upper_`var' bw, lpattern(dash) lcolor(gray)) ///
				 (line lower_`var' bw, lpattern(dash) lcolor(gray)), ///
				  legend(off) xlabel(0(20)100) xtitle(Bandwidth (meters)) ///
				  ytitle(RD coeff) yline(0)
				  graph export "$dir\latex\bw_booth_`var'.eps", replace
	}			  
		

