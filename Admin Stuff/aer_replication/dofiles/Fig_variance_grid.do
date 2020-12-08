
****************************************************************************
* Purpose: This do-file analyzes discontinuities in randomly selected areas of London
* Output: Figure 4 "Difference in Log House Prices for Neighboring Cells, London 1995-2013"
****************************************************************************

clear all
set more off


global data = "$dir\data\variance_grid"



use "$data\grid_houses_final.dta", clear
keep block_id cell_id rprice lprice
expand 5
sort block_id cell_id
gen id=cell_id

bys cell_id: gen n=_n

* Creating identifier for neighboring cells of a given cell
replace id=cell_id - 1 if n==2
replace id=cell_id + 1 if n==3
replace id=cell_id - 1390 if n==4
replace id=cell_id + 1390 if n==5

rename id cell_id_merge //so that merge can be done on cell_id
rename rprice rprice_p
rename lprice lprice_p
save "$data\cell_pair_index.dta", replace



use "$data\cell_pair_index.dta", clear
merge m:1 block_id cell_id_merge using "$data\grid_houses_final.dta"
drop if n==1 //This is the pair between a cell and itself which doesnt count
keep if _merge==3 //only keep the ones with pairs
drop _merge num_cell

rename cell_id_merge pair_id
sort block_id cell_id pair_id


* random numbers to randomize which pairs to keep in cases of more than one pair
set seed 06012012
bys cell_id: gen rand=uniform()
sort cell_id rand
bys cell_id: gen temp=_n
keep if temp==1 //only keep one pair per cell
drop temp rand

* create random treatment indicator
gen treated=0
set seed 06012012
bys block_id: gen rand = uniform()
bys block_id: replace treated=1 if rand>=0.5 //1 indicates that cell_id is treated, pair_id is control
drop rand
* Creating variable with difference
gen diff=(rprice-rprice_p)/rprice_p if treated==1
replace diff=(rprice_p-rprice)/rprice if treated==0

gen diff2=lprice-lprice_p if treated==1
replace diff2=lprice_p-lprice if treated==0

bys block_id: egen n_pairs=count(cell_id)
save "$data\cell_pairs_final.dta", replace


* sampling the pairs by block
use "$data\cell_pairs_final.dta", clear
bsample 40 if n_pair>=40, strata(block_id)
collapse diff diff2, by(block_id)

sum diff2, d
local p10 = `r(p10)'
local p5 = `r(p5)'

* Histogram of results
kdensity diff2, addplot(pci 0 `p10' 8 `p10', lpattern(dash) || pci 0 `p5' 8 `p5', lpattern(dash) || ///
	pci 0 -0.3 8 -0.3) xtitle("Price difference (percent)") xlabel(-0.4(0.1)0.4) ///
	title("") legend(order(2 "10/5th percentile" 4 "BSP Price Difference") cols(2)) scheme(tufte)
	graph export "$dir\latex\difference.png", replace

	
	

* Histogram for houses within range observed in BSP bandwidth
preserve
use "$dir\data\current\houses_current_final.dta", clear
drop if price==1073 //obvious typo
keep if source==2 //house price data
su lnprice if dist_netw<=0.435
local min=`r(min)'
local max=`r(max)'
restore
	
* sampling the pairs by block
use "$data\cell_pairs_final.dta", clear
keep if lprice>=`r(min)' & lprice<=`r(max)'
bys block_id: egen n_pair_r = count(cell_id)
bsample 40 if n_pair_r>=40, strata(block_id)
collapse diff diff2, by(block_id)

sum diff2, d
local p10r = `r(p10)'
local p5r = `r(p5)'

* histogram of results
kdensity diff2, addplot(pci 0 `p10r' 8 `p10r', lpattern(dash) || pci 0 `p5r' 8 `p5r', lpattern(dash) || ///
	pci 0 -0.3 8 -0.3) xtitle("Price difference (percent)") xlabel(-0.4(0.1)0.4) ///
	title("") legend(order(2 "10/5th percentile" 4 "BSP Price Difference") cols(2)) scheme(tufte)
	graph export "$dir\latex\difference_r.png", replace
	







