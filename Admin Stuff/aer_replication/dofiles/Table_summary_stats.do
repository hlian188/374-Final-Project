*************************************************************************************
* File description: 1853 house characterstics without and with Conley SE 
* Output:
* Table 1: House Characteristics (1853)
* Table B1: House Characteristics (1853), Conley (1999)
*************************************************************************************


* globals set in Master file

	clear all
	set more off



*************************************************************************************
* Prepare and clean data
*************************************************************************************

	use "$dir\data\19th\houses_1853_final.dta", clear


* Define locals for block cluster and street fixed effects
	local cl block


* Set negative values for the distances to the boundary that are outside the BSP perimeter
	gen temp=dist_netw
	replace temp=-dist_netw if broad==0
	replace temp=temp



* Generate indicator variable for missing rental observations.
	gen exon = (rentals==.)



* Define local for control variables
	local controls "lnrentals lntax exon sewer1 sewer2 sewer4 dist_pump dist_cent dist_pit_fake dist_square dist_church dist_police dist_fire dist_thea dist_pub dist_urinal dist_vent dist_school dist_bank"


* Calculate optimal bandwith (hopt_`var') using "rdbwselect" command (Calonico et al (2014))
		  
	foreach var of local controls {
		qui: rdbwselect `var' temp
		scalar hopt_`var'=e(h_mserd)
	}

scalar list 
* Average of all bandwidths is 0.297m


*************************************************************************************
* Table 1 "House characterstics (1853)"
* columns (1) - (6) "full sample" and "within 100 m" means inside and outside BSP area
* columns (7) - (8) RD analysis on covariates
*************************************************************************************
	capture erase "$dir\output\tables\covariate_balance.xls"
	capture erase "$dir\output\tables\covariate_balance.txt"

	foreach var of local controls {
		foreach i of numlist 100 1 {
			qui: reg `var' broad if dist_netw<=`i', cluster(`cl')
			matrix b=e(b)
			local avein = b[1,2]+b[1,1]
			local aveout = b[1,2]
			sum `var' if broad==0 & dist_netw<=`i'	// summary statistics for broad = 0 
			scalar n_out`var'=r(N)
			sum `var' if broad==1 & dist_netw<=`i'	// summary statistics for broad = 1
			scalar n_in`var'=r(N)
		outreg2 using "$dir\output\tables\covariate_balance.xls", ///
		keep(broad) asterisk(se) addstat(bw, `i', avein, `avein', aveout, `aveout', Obs_in, n_in`var', Obs_out, n_out`var' ) dec(3) append
		}
			qui:rdrobust `var' temp, h(0.297 0.297) vce(cluster `cl')
		outreg2 using "$dir\output\tables\covariate_balance.xls", addstat(bw, 0.297) dec(3) append
	}


*************************************************************************************
* Table B1 "House characterstics (1853) with Conley (1999) SE"
* columns (1) - (6) "full sample" and "within 100 m" means inside and outside BSP area
*************************************************************************************

	capture erase "$dir\output\tables\covariate_balance_conley.xls"
	capture erase "$dir\output\tables\covariate_balance_conley.txt"


* generate constant 
	gen const=1

* Define local for control variables
* Distance window of 53 meters (0.053km)
	local controls "lnrentals lntax exon sewer1 sewer2 sewer4 dist_pump dist_cent dist_pit_fake dist_square dist_church dist_police dist_fire dist_thea dist_pub dist_urinal dist_vent dist_school dist_bank"

	foreach var of local controls {
		 foreach i of numlist 100 1 {
		 	cd "$dir\dofiles\spatial_HAC"
			ols_spatial_HAC `var' broad const if dist_netw<=`i', lat(lat) lon(lon) t(block) p(block) dist(0.053) lag(0)
			matrix b=e(b)
			local avein = b[1,2]+b[1,1]
			local aveout = b[1,2]
		outreg2 using "$dir\output\tables\covariate_balance_conley.xls", ///
		keep(broad) bracket asterisk(se) addstat(bw, `i', avein, `avein', aveout, `aveout') dec(3) append
		}
	}

