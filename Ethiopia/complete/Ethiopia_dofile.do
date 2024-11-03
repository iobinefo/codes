

*************************************************
*Heckman 2018

use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_price21.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_price21.dta", clear


tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr informal_save pry_edu finish_pry finish_sec net_seller net_buyer 


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer  region


*replace hh_headage = 66 if hh_headage >66 //bottom 90%
replace land_holding = 2.341905 if land_holding >2.341905 //bottom 90%
 
replace real_hhvalue = 0 if real_hhvalue <=0 //bottom 90%
gen lland_holding = log(land_holding)
gen lreal_hhvalue = log(real_hhvalue  + 1)

*histogram lreal_hhvalue, width(5) frequency normal
*histogram land_holding, width(5) frequency normal
sum real_hhvalue, detail
sum land_holding, detail
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


heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr attend_sch land_holding ext_acess formal_credit informal_credit year_2018  year_2021, select (commercial_dummy= mrk_dist_w hh_headage  num_mem worker lreal_hhvalue  femhead ext_acess attend_sch  land_holding safety_net soil_qty_rev2 real_maize_price_mr formal_credit informal_credit num_mem worker year_2018 year_2021) twostep



* formal_credit informal_credit formal_credit informal_credit TAvg_formal_credit TAvg_informal_credit land_holding lland_holding TAvg_land_holding 

*num_mem worker TAvg_num_mem TAvg_worker real_rice_price_mr TAvg_real_rice_price_mr


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
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_real_heckman_original.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_nominal_heckman.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace word


*outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Logtrying_nominal_heckman.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace




***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot
program define myboot, rclass
** CRE-TOBIT
preserve 


heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr attend_sch land_holding ext_acess formal_credit informal_credit year_2018  year_2021, select (commercial_dummy= mrk_dist_w hh_headage  num_mem worker lreal_hhvalue  femhead ext_acess attend_sch  land_holding safety_net soil_qty_rev2 real_maize_price_mr formal_credit informal_credit num_mem worker year_2018 year_2021) twostep



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

bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_real_heckman_original.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_nominal_heckman.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace word


tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)








*******************************2015
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_heckman15.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_heckman15.dta", clear

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr informal_save pry_edu finish_pry finish_sec net_seller net_buyer 


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer  region


replace hh_headage = 69 if hh_headage >69 //bottom 90%
replace real_hhvalue = 0 if real_hhvalue <=0 //bottom 90%
replace land_holding = 3.072941  if land_holding >3.072941  //bottom 90%
 
 
 
gen lland_holding = log(land_holding)
gen lreal_hhvalue = log(real_hhvalue)

tab hh_headage, missing
*histogram hh_headage, width(5) frequency normal
*histogram lreal_hhvalue, width(5) frequency normal
*histogram land_holding, width(5) frequency normal
sum real_hhvalue, detail
sum lland_holding, detail
tab land_holding






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


heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr attend_sch lland_holding ext_acess formal_credit informal_credit year_2013  year_2015, select (commercial_dummy= mrk_dist_w hh_headage  num_mem worker lreal_hhvalue  femhead ext_acess attend_sch  lland_holding safety_net soil_qty_rev2 real_maize_price_mr formal_credit informal_credit num_mem worker year_2013  year_2015) twostep


*soil_qty_rev2  lreal_hhvalue TAvg_soil_qty_rev2 TAvg_lreal_hhvalue

predict yhat, xb


gen lyhat = log(yhat)



gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit ltotal_qty_w mrk_dist_w lyhat real_maize_price_mr hh_headage  lland_holding femhead ext_acess attend_sch  safety_net formal_credit informal_credit num_mem worker TAvg_ltotal_qty_w TAvg_mrk_dist_w TAvg_lyhat  TAvg_hh_headage  TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net  TAvg_real_maize_price_mr  TAvg_lland_holding TAvg_formal_credit TAvg_informal_credit  TAvg_num_mem TAvg_worker i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_real_heckman_original15.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log2_nominal_heckman15.doc",   replace word






***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot
program define myboot, rclass
** CRE-TOBIT
preserve 


heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr attend_sch land_holding ext_acess formal_credit informal_credit year_2013  year_2015, select (commercial_dummy= mrk_dist_w hh_headage  num_mem worker lreal_hhvalue  femhead ext_acess attend_sch  land_holding safety_net soil_qty_rev2 real_maize_price_mr formal_credit informal_credit num_mem worker year_2013  year_2015) twostep


predict yhat, xb

*sum yhat [aw= weight], detail

local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

tobit total_qty_w mrk_dist_w yhat real_maize_price_mr hh_headage lreal_hhvalue land_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2  formal_credit informal_credit num_mem worker TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat  TAvg_hh_headage TAvg_lreal_hhvalue   TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr  TAvg_land_holding TAvg_formal_credit TAvg_informal_credit  TAvg_num_mem TAvg_worker i.region i.year, ll(0)



margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_real_heckman_original15.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_nominal_heckman15.doc", title (Table 3: Elasticity) ctitle(Tobit) se label replace word


tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)





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





***********************************************************From Darko
heckman real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr land_holding attend_sch femhead formal_credit informal_credit ext_acess i.zones  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer i.region  i.year) twostep


predict yhat, xb


*sum yhat [aw= weight], detail

local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}















***********************************************************************************
*Real result
***********************************************************************************


***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
 
heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr real_rice_price_mr land_holding attend_sch formal_credit informal_credit ext_acess  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer  i.year) twostep


predict yhat, xb

local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

tobit total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer i.region i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w subsidy_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)












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



* Step 1: Define the program for Tobit estimation and margins calculation
program define boot_tobite, rclass
    * Step 2: Fit the Tobit model
tobit total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer i.region i.year, ll(0)
   
    * Step 3: Calculate marginal effects
    margins, predict(ystar(0,.)) dydx(*) post
    
    * Step 4: Return the marginal effects for four variables
    return scalar dydx_yhat = _b[yhat]
    return scalar dydx_mrk_dist_w = _b[mrk_dist_w]
    return scalar dydx_num_mem = _b[num_mem]
    return scalar dydx_hh_headage = _b[hh_headage]
end

* Step 5: Use bootstrap to resample and calculate margins
bootstrap r(dydx_yhat) r(dydx_mrk_dist_w) r(dydx_num_mem) r(dydx_hh_headage), reps(100): boot_tobite


