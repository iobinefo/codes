

*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price_heckman21.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price_median21.dta", clear
*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\completed21.dta", clear
*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\completed21.dta", clear


sort hhid year
order hhid

gen dummy = 1

collapse (sum) dummy, by (hhid)

tab dummy
keep if dummy==2
sort hhid

*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_Real_price_heckman21.dta", replace
save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_Real_price_median21.dta", replace
*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_Real_price_heckman21.dta", replace
*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_Real_price_heckman21.dta", replace


*merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price_heckman21.dta"
merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price_median21.dta"
*merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price_heckman21.dta"
*merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price_heckman21.dta"


drop if _merge==2
sort hhid year
order hhid year




gen year_2018 = (year==2018)
gen year_2021 = (year==2021)

gen commercial_dummy = (total_qty_w>0)


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2



local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk  land_holding ext_acess attend_sch formal_credit informal_credit i.zones  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 i.region  i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail


tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


** CRE-TOBIT 
tobit total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post


tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)












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


************************************************************************************************************************************************************


use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\completed15.dta", clear


sort hhid year
order hhid

gen dummy = 1

collapse (sum) dummy, by (hhid)

tab dummy
keep if dummy==2
sort hhid

save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_completed15.dta", replace


merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\completed15.dta"

drop if _merge==2
sort hhid year





gen year_2013 = (year==2013)
gen year_2015 = (year==2015)

gen commercial_dummy = (total_qty_w>0)


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2



local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk  land_holding attend_sch femhead formal_credit informal_credit ext_acess i.zones  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 i.zone  i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail


tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 i.zones i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post



** CRE-TOBIT 
tobit total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 i.zones i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post














****************************
*Commercial Analysis
****************************

	
//% of HHs that bought commercial fertilizer by each survey wave
bysort year : tabstat commercial_dummy [w=weight], stat(mean sem)

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort hhid : egen sum_4waves_com_fer_bin = sum(commercial_dummy) 

































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


