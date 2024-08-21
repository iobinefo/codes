

use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\complete\Real_Price_median13.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\complete\Nominal_Price_median13.dta", clear

use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\complete\Real_Price_median18.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\complete\Nominal_Price_median18.dta", clear



tabstat total_qty_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

misstable summarize femhead  ext_acess attend_sch    total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer safety_net



*formal_credit informal_credit safety_net

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer safety_net num_mem hh_headage real_hhvalue worker land_holding femhead  ext_acess attend_sch soil_qty_rev2 "

foreach x in `time_avg' {

	bysort HHID : egen TAvg_`x' = mean(`x')

}



** CRE-TOBIT 
tobit total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer safety_net num_mem hh_headage real_hhvalue worker land_holding femhead ext_acess attend_sch  soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer TAvg_safety_net   i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)




*2018


** CRE-TOBIT 
tobit total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer safety_net num_mem hh_headage real_hhvalue worker land_holding femhead ext_acess attend_sch  soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer TAvg_safety_net i.region  i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)





****************************
*Commercial Analysis
****************************

	
//% of HHs that bought commercial fertilizer by each survey wave
bysort year : tabstat commercial_dummy [w=weight], stat(mean sem)

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort HHID : egen sum_4waves_com_fer_bin = sum(commercial_dummy) 

















************************** descriptive statistics of  variables in second survey (2018)
preserve

keep if year ==2010
tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



************************** descriptive statistics of  variables in second survey (2023)
preserve

keep if year ==2011
tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore

preserve

keep if year ==2013
tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore







/*

************************************
*cpi
********************************
  wbopendata, language(en - English) country() topics() indicator(fp.cpi.totl) clear
*save a copy for use off-line
  *save "wbopendata_cpi_timeseries.dta", replace

*use "wbopendata_cpi_timeseries.dta", clear

*keep SSA
keep if inlist(region,"SSF")
	*does the same thing: keep if regioncode=="SSF"

*keep our study countries
keep if inlist(countrycode,"UGA")
	* does the same thing: drop if !(inlist(countrycode,"TZA"))


*drop very old years
drop yr1960-yr1989

*take a look at recent values (note these all use 2010 as base year)
l countrycode yr2004-yr2017

*rebase to 2015
gen baseyear = yr2018
forvalues i=1990(1)2018 {
	replace yr`i' = yr`i'/baseyear
}
forvalues i=1990(1)2018 {
	di "year is: `i'" 
}


*reformat to match panel structure 
reshape long yr, i(countrycode) j(year)
rename yr cpi
keep countrycode countryname year cpi
order countrycode countryname year cpi
la var year "Year"
la var cpi "CPI (base=2018)"


*save for use in analysis
*save "tza_cpi_b2019.dta", replace


*/


