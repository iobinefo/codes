


use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\complete\Real_Price_median18p.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\complete\Nominal_Price_median18p.dta", clear



tabstat total_qty_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

misstable summarize femhead  ext_acess attend_sch total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer safety_net formal_credit informal_credit



sum real_hhvalue, detail
sum land_holding, detail
*replace hh_headage = 66 if hh_headage >66 //bottom 90%
*replace land_holding = 1.626838  if land_holding >1.626838  //bottom 90%
 
*replace real_hhvalue = 0 if real_hhvalue <=0 //bottom 90%
gen lland_holding = log(land_holding + 1)
gen lreal_hhvalue = log(real_hhvalue)

*histogram lreal_hhvalue, width(5) frequency normal
*histogram land_holding, width(5) frequency normal
*histogram hh_headage, width(5) frequency normal

sum lland_holding, detail


gen good_soil = (soil_qty_rev2==1)
gen fair_soil = (soil_qty_rev2==2)
 
sum real_tpricefert_cens_mrk, detail

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 lland_holding lreal_hhvalue org_fert"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


gen lreal_tpricefert_cens_mrk = log(real_tpricefert_cens_mrk)



gen ltotal_qty_w = log(total_qty_w + 1)

*histogram total_qty_w, width(50) frequency normal
*histogram ltotal_qty_w, width(5) frequency normal

local time_avg "lreal_tpricefert_cens_mrk ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

gen hhid2 = substr(HHID, 2, .)


gen float hhid1 = real(hhid2)

duplicates report hhid1

sort hhid1 year

order hhid1


*log
** OLS with HH fixed effects
xtreg ltotal_qty_w lreal_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr ext_acess attend_sch femhead  safety_net land_holding lreal_hhvalue hh_headage  worker num_mem org_fert formal_credit informal_credit i.year, fe i(hhid1) cluster(hhid1)



** OLS with HH fixed effects
xtreg total_qty_w real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr ext_acess attend_sch femhead  safety_net land_holding lreal_hhvalue hh_headage  worker num_mem org_fert formal_credit informal_credit i.year, fe i(hhid1) cluster(hhid1)

tabstat total_qty_w real_tpricefert_cens_mrk  [aweight = weight], statistics( mean median sd min max ) columns(statistics)


********************************************
*Using Functional Forms
********************************************


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

** CRE-TOBIT 
tobit ltotal_qty_w lreal_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr ext_acess attend_sch femhead  safety_net land_holding lreal_hhvalue hh_headage  worker num_mem org_fert formal_credit informal_credit  TAvg_ltotal_qty_w TAvg_lreal_tpricefert_cens_mrk TAvg_mrk_dist_w TAvg_real_maize_price_mr TAvg_ext_acess TAvg_attend_sch TAvg_femhead  TAvg_safety_net TAvg_land_holding TAvg_lreal_hhvalue TAvg_hh_headage  TAvg_worker TAvg_num_mem  TAvg_org_fert TAvg_formal_credit TAvg_informal_credit i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\results\Log_real_median_original.doc",  replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\results\Log_nominal_median.doc", replace word



****Level

***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot
program define myboot, rclass
** CRE-TOBIT
preserve 

tobit total_qty_w real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr ext_acess attend_sch femhead  safety_net land_holding lreal_hhvalue hh_headage  worker num_mem org_fert formal_credit informal_credit  TAvg_total_qty_w TAvg_real_tpricefert_cens_mrk TAvg_mrk_dist_w TAvg_real_maize_price_mr TAvg_ext_acess TAvg_attend_sch TAvg_femhead  TAvg_safety_net TAvg_land_holding TAvg_lreal_hhvalue TAvg_hh_headage  TAvg_worker TAvg_num_mem  TAvg_org_fert TAvg_formal_credit TAvg_informal_credit i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\results\Level_real_median_original.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\results\Level_nominal_median.doc", replace word



tabstat total_qty_w real_tpricefert_cens_mrk  [aweight = weight], statistics( mean median sd min max ) columns(statistics)



**********************************************Without org_fert**********************************************************
*****************************************************************************************************************************************************

*log
** OLS with HH fixed effects
xtreg ltotal_qty_w lreal_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr ext_acess attend_sch femhead  safety_net land_holding lreal_hhvalue hh_headage  worker num_mem formal_credit informal_credit i.year, fe i(hhid1) cluster(hhid1)



** OLS with HH fixed effects
xtreg total_qty_w real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr ext_acess attend_sch femhead  safety_net land_holding lreal_hhvalue hh_headage  worker num_mem formal_credit informal_credit i.year, fe i(hhid1) cluster(hhid1)

tabstat total_qty_w real_tpricefert_cens_mrk  [aweight = weight], statistics( mean median sd min max ) columns(statistics)





*************First Stage Regression

reg total_qty_w real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr ext_acess attend_sch femhead  safety_net land_holding lreal_hhvalue hh_headage  worker num_mem org_fert formal_credit informal_credit soil_qty_rev2 i.year 

reg total_qty_w real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr ext_acess attend_sch femhead  safety_net land_holding lreal_hhvalue hh_headage  worker num_mem org_fert formal_credit informal_credit good_soil fair_soil i.year 
















*****************2013 model

use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\complete\Real_Price_median13.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\complete\Nominal_Price_median13.dta", clear



tabstat total_qty_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

misstable summarize femhead  ext_acess attend_sch total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer safety_net



sum real_hhvalue, detail
sum land_holding, detail
tab land_holding, missing
tab hh_headage, missing
*replace hh_headage = 66 if hh_headage >66 //bottom 90%
*replace land_holding = 1.626838  if land_holding >1.626838  //bottom 90%
 
*replace real_hhvalue = 0 if real_hhvalue <=0 //bottom 90%
gen lland_holding = log(land_holding + 1)
gen lreal_hhvalue = log(real_hhvalue)

*histogram lreal_hhvalue, width(5) frequency normal
*histogram land_holding, width(5) frequency normal
*histogram hh_headage, width(5) frequency normal

sum lland_holding, detail



sum real_tpricefert_cens_mrk, detail

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2 lland_holding lreal_hhvalue"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

gen lreal_tpricefert_cens_mrk = log(real_tpricefert_cens_mrk)



gen ltotal_qty_w = log(total_qty_w + 1)

*histogram total_qty_w, width(50) frequency normal
*histogram ltotal_qty_w, width(5) frequency normal

local time_avg "lreal_tpricefert_cens_mrk ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}




********************************************
*Using Functional Forms
********************************************


capture program drop myboot	
program define myboot, rclass
 preserve 

** CRE-TOBIT 
tobit ltotal_qty_w mrk_dist_w lreal_tpricefert_cens_mrk real_maize_price_mr hh_headage lreal_hhvalue lland_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2  num_mem worker TAvg_ltotal_qty_w TAvg_mrk_dist_w TAvg_lreal_tpricefert_cens_mrk  TAvg_hh_headage TAvg_lreal_hhvalue   TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr  TAvg_lland_holding TAvg_num_mem TAvg_worker i.year, ll(0)



margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\results\Log_real_median_original13.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\results\Log_nominal_median13.doc", replace word






***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot
program define myboot, rclass
** CRE-TOBIT
preserve 

tobit total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr hh_headage lreal_hhvalue lland_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2  num_mem worker TAvg_total_qty_w TAvg_mrk_dist_w TAvg_real_tpricefert_cens_mrk  TAvg_hh_headage TAvg_lreal_hhvalue   TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr  TAvg_lland_holding TAvg_num_mem TAvg_worker i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\results\Level_real_median_original13.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\median\results\Level_nominal_median13.doc", replace word


tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)














****************************
*Commercial Analysis
****************************

	
//% of HHs that bought commercial fertilizer by each survey wave
bysort year : tabstat commercial_dummy [w=weight], stat(mean sem)

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort HHID : egen sum_4waves_com_fer_bin = sum(commercial_dummy) 














************************** descriptive statistics of  variables in second survey (2018)



************Median***********************
preserve

keep if year ==2010
tabstat total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding  real_maize_price_mr real_rice_price_mr femhead  ext_acess attend_sch soil_qty_rev2  safety_net [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore


preserve

keep if year ==2011
tabstat total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding  real_maize_price_mr real_rice_price_mr femhead  ext_acess attend_sch soil_qty_rev2  safety_net [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore

preserve

keep if year ==2013
tabstat total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding  real_maize_price_mr real_rice_price_mr femhead  ext_acess attend_sch soil_qty_rev2  safety_net [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



preserve

keep if year ==2015
tabstat total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding  real_maize_price_mr real_rice_price_mr femhead  ext_acess attend_sch soil_qty_rev2  safety_net formal_credit informal_credit [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore



preserve

keep if year ==2018
tabstat total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding  real_maize_price_mr real_rice_price_mr femhead  ext_acess attend_sch soil_qty_rev2  safety_net formal_credit informal_credit [aweight = weight], statistics( mean median sd min max ) columns(statistics)



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


