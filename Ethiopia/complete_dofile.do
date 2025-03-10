

*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_heckman15.dta", clear
*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Nominal_heckman15.dta", clear


use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price21p.dta", clear
*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Nominal_price21p.dta", clear


sort hhid year
order hhid

gen dummy = 1

collapse (sum) dummy, by (hhid)

tab dummy
keep if dummy==2
sort hhid

*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_Real_heckman15.dta", replace
*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_Nominal_heckman15.dta", replace


save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_Real_price_21p.dta", replace
*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\subset_Nominal_price21p.dta", replace





*merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_heckman15.dta"
*merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Nominal_heckman15.dta"


merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price21p.dta"
*merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Nominal_price21p.dta"






drop if _merge==2
sort hhid year





*gen year_2013 = (year==2013)
*gen year_2015 = (year==2015)



gen year_2018 = (year==2018)
gen year_2021 = (year==2021)

gen commercial_dummy = (total_qty_w>0)



tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr informal_save pry_edu finish_pry finish_sec net_seller net_buyer 


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer dist_admarc_w plot_elevation plot_slope plot_wetness hh_elevation hh_slope hh_wetness org_fert informal_save

egen med_s = median(plot_slope)
egen med_w = median(plot_wetness)
egen med_e = median(plot_elevation)
egen med_ss = median(hh_slope)
egen med_ww = median(hh_wetness)
egen med_ee = median(hh_elevation)
egen med_d = median(dist_admarc_w)

replace plot_slope = med_s if plot_slope ==.
replace plot_wetness = med_w if plot_wetness ==.
replace plot_elevation = med_e if plot_elevation ==.
replace hh_slope = med_ss if hh_slope ==.
replace hh_wetness = med_ww if hh_wetness ==.
replace hh_elevation = med_ee if hh_elevation ==.
replace dist_admarc_w = med_d if dist_admarc_w ==.



*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_heckman15.dta", replace
*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_heckman15.dta", replace

save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_price21p.dta", replace
*save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_price21p.dta", replace










*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_heckman15.dta", clear
*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_heckman15.dta", clear

*use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_price21.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_price21.dta", clear



local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr land_holding attend_sch femhead formal_credit informal_credit ext_acess i.zones  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer i.region  i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail


tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post



tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

** CRE-TOBIT 
tobit total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post


tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)













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


