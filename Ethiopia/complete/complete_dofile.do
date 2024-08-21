


use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_heckman15.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_heckman15.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_price21.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_price21.dta", clear


tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr informal_save pry_edu finish_pry finish_sec net_seller net_buyer 


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer 

sum real_tpricefert_cens_mrk, detail

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr land_holding attend_sch femhead formal_credit informal_credit ext_acess i.zones  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer i.region  i.year) twostep


predict yhat, xb


*tab yhat, missing

sum yhat [aw= weight], detail



*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post



tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)







********************************************
*Using Functional Forms
********************************************



gen lyhat = log(yhat)
replace total_qty_w =1 if total_qty_w==0
gen ltotal_qty_w = log(total_qty_w)

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit ltotal_qty_w mrk_dist_w lyhat real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_ltotal_qty_w TAvg_mrk_dist_w TAvg_lyhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post





****************************
*Commercial Analysis
****************************

	
//% of HHs that bought commercial fertilizer by each survey wave
bysort year : tabstat commercial_dummy [w=weight], stat(mean sem)

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort hhid : egen sum_4waves_com_fer_bin = sum(commercial_dummy) 







************************** descriptive statistics of  variables in second survey (2018)
preserve

keep if year ==2018
tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



************************** descriptive statistics of  variables in second survey (2023)
preserve

keep if year ==2021
tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore







































************************** descriptive statistics of  variables in second survey (2012)
preserve

keep if year ==2013
tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore





************************** descriptive statistics of  variables in first survey (2015)
preserve

keep if year ==2015
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
keep if inlist(countrycode,"ETH")
	* does the same thing: drop if !(inlist(countrycode,"TZA"))


*drop very old years
drop yr1960-yr1989

*take a look at recent values (note these all use 2010 as base year)
l countrycode yr2004-yr2017

*rebase to 2015
gen baseyear = yr2021
forvalues i=1990(1)2021 {
	replace yr`i' = yr`i'/baseyear
}
forvalues i=1990(1)2021 {
	di "year is: `i'" 
}


*reformat to match panel structure 
reshape long yr, i(countrycode) j(year)
rename yr cpi
keep countrycode countryname year cpi
order countrycode countryname year cpi
la var year "Year"
la var cpi "CPI (base=2021)"


*save for use in analysis
*save "tza_cpi_b2019.dta", replace


*/


