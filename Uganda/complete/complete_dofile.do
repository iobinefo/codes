


use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\complete\Real_Price_heckman18.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\complete\Nominal_Price_heckman18.dta", clear



tabstat total_qty_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

misstable summarize femhead  ext_acess attend_sch total_qty_w  real_tpricefert_cens_mrk mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer safety_net formal_credit informal_credit



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

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 lland_holding lreal_hhvalue"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}




********************************************
*Using Functional Forms
********************************************


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr attend_sch land_holding ext_acess formal_credit informal_credit i.year, select (commercial_dummy= mrk_dist_w hh_headage  num_mem worker lreal_hhvalue  femhead ext_acess attend_sch  land_holding safety_net soil_qty_rev2 real_maize_price_mr formal_credit informal_credit num_mem worker i.year) twostep

predict yhat, xb


gen lyhat = log(yhat)



gen ltotal_qty_w = log(total_qty_w + 1)

*histogram total_qty_w, width(50) frequency normal
*histogram ltotal_qty_w, width(5) frequency normal

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit ltotal_qty_w mrk_dist_w lyhat real_maize_price_mr hh_headage lreal_hhvalue land_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2  formal_credit informal_credit num_mem worker TAvg_ltotal_qty_w TAvg_mrk_dist_w TAvg_lyhat  TAvg_hh_headage TAvg_lreal_hhvalue   TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr  TAvg_land_holding TAvg_formal_credit TAvg_informal_credit  TAvg_num_mem TAvg_worker i.year, ll(0)



margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Log_real_heckman_original.doc",  replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Log_nominal_heckman.doc", replace word






***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot
program define myboot, rclass
** CRE-TOBIT
preserve 


heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr attend_sch land_holding ext_acess formal_credit informal_credit i.year, select (commercial_dummy= mrk_dist_w hh_headage  num_mem worker lreal_hhvalue  femhead ext_acess attend_sch  land_holding safety_net soil_qty_rev2 real_maize_price_mr formal_credit informal_credit num_mem worker i.year) twostep




predict yhat, xb

*sum yhat [aw= weight], detail

local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

tobit total_qty_w mrk_dist_w yhat real_maize_price_mr hh_headage lreal_hhvalue land_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2  formal_credit informal_credit num_mem worker TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat  TAvg_hh_headage TAvg_lreal_hhvalue   TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr  TAvg_land_holding TAvg_formal_credit TAvg_informal_credit  TAvg_num_mem TAvg_worker i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Level_real_heckman_original.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Level_nominal_heckman.doc", replace word



*outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Leveltrying_nominal_heckman.doc", title (Table 3: Elasticity) ctitle(OLS) se dec(2) label replace


tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)












*****************2013 model

use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\complete\Real_Price_heckman13.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\complete\Nominal_Price_heckman13.dta", clear



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




********************************************
*Using Functional Forms
********************************************


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr attend_sch lland_holding ext_acess i.year, select (commercial_dummy= mrk_dist_w hh_headage  num_mem worker lreal_hhvalue  femhead ext_acess attend_sch  lland_holding safety_net soil_qty_rev2 real_maize_price_mr num_mem worker i.year) twostep

predict yhat, xb


gen lyhat = log(yhat)



gen ltotal_qty_w = log(total_qty_w + 1)

*histogram total_qty_w, width(50) frequency normal
*histogram ltotal_qty_w, width(5) frequency normal

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit ltotal_qty_w mrk_dist_w lyhat real_maize_price_mr hh_headage lreal_hhvalue lland_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2  num_mem worker TAvg_ltotal_qty_w TAvg_mrk_dist_w TAvg_lyhat  TAvg_hh_headage TAvg_lreal_hhvalue   TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr  TAvg_lland_holding TAvg_num_mem TAvg_worker i.year, ll(0)



margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Log_real_heckman_original13.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Log_nominal_heckman13.doc", replace word






***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot
program define myboot, rclass
** CRE-TOBIT
preserve 


heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr attend_sch land_holding ext_acess i.year, select (commercial_dummy= mrk_dist_w hh_headage  num_mem worker lreal_hhvalue  femhead ext_acess attend_sch  land_holding safety_net soil_qty_rev2 real_maize_price_mr num_mem worker i.year) twostep




predict yhat, xb

*sum yhat [aw= weight], detail

local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

tobit total_qty_w mrk_dist_w yhat real_maize_price_mr hh_headage lreal_hhvalue land_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2 num_mem worker TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat  TAvg_hh_headage TAvg_lreal_hhvalue   TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr  TAvg_land_holding  TAvg_num_mem TAvg_worker i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Level_real_heckman_original13.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Uganda\results\Level_nominal_heckman13.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace word


tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)






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


