
log using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia2_log_file.smcl", append
*************************************************
*Heckman 2018

use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_price21p.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_price21p.dta", clear

*we decided to use p for ethiopia and uganda

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)



misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer  region dist_admarc_w plot_elevation plot_slope plot_wetness hh_elevation hh_slope hh_wetness org_fert informal_save formal_bank


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


gen good_soil = (soil_qty_rev2==1)
gen fair_soil = (soil_qty_rev2==2)

sum real_tpricefert_cens_mrk, detail

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 lland_holding lreal_hhvalue dist_admarc_w plot_elevation plot_slope plot_wetness hh_elevation hh_slope hh_wetness org_fert annual_mean_temp annual_precipitation informal_save formal_save formal_bank"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


*****************************************
*Variables for model

*subsidy_qty_w dist_cens_w  real_maize_price_mr  real_hhvalue field_size_ha_w org_fert

*subsidy_qty_w dist_cens_w  real_maize_price_mr real_hhvalue field_size_ha_w org_fert hh_headage_mrk attend_sch femhead 

*subsidy_qty_w dist_cens_w  real_maize_price_mr real_hhvalue field_size_ha_w org_fert hh_headage_mrk attend_sch femhead num_mem


*Additional Variables

*hh_headage_mrk worker real_rice_price_mr formal_save formal_bank ext_acess attend_sch safety_net net_seller net_buyer soil_qty_rev2


reg total_qty_w good fair
*****************************************
********************************************
*Stage one regression
********************************************
*********Significant for only nominal at the log form
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert  i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert good_soil fair_soil  i.year) twostep
predict yhat, xb
predict imr, mills

gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)

*histogram total_qty_w, width(50) frequency normal
*histogram ltotal_qty_w, width(5) frequency normal
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert  annual_mean_temp annual_precipitation   imr           TAvg_ltotal_qty_w TAvg_lyhat TAvg_dist_admarc_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_annual_mean_temp TAvg_annual_precipitation TAvg_org_fert i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

*Level
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert  i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert good_soil fair_soil  i.year) twostep
predict yhat, xb
predict imr, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert  annual_mean_temp annual_precipitation   imr           TAvg_total_qty_w TAvg_yhat TAvg_dist_admarc_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_annual_mean_temp TAvg_annual_precipitation TAvg_org_fert i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot



********************************************
*Stage two regression
********************************************
**********access to extension doesnt make it significant
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  good_soil fair_soil i.year) twostep
predict yhat, xb
predict imr, mills

gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)

*histogram total_qty_w, width(50) frequency normal
*histogram ltotal_qty_w, width(5) frequency normal
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead   num_mem  imr           TAvg_ltotal_qty_w TAvg_lyhat TAvg_dist_admarc_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue   TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

*Level
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem   i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem   good_soil fair_soil  i.year) twostep
predict yhat, xb
predict imr, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem     imr           TAvg_total_qty_w TAvg_yhat TAvg_dist_admarc_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue   TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w  yhat [aweight = weight], statistics( mean median sd min max ) columns(statistics)




******************************************************************Using OLS regression******************************************************************
*****************************************************************************************************************************************************

gen float hhid1 = real(hhid)


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem   i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem   good_soil fair_soil  i.year) twostep
predict yhat, xb
predict imr, mills


gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}


** CRE-TOBIT 
xtreg ltotal_qty_w lyhat dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead   num_mem  imr  i.year, fe i(hhid1)
restore
end
bootstrap, reps(100) seed(123) cluster(hhid1) idcluster(newid): myboot





**Level
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem   i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem   good_soil fair_soil  i.year) twostep
predict yhat, xb
predict imr, mills

*sum yhat, detail
local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}

  
** CRE-TOBIT 
xtreg total_qty_w yhat dist_admarc_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead   num_mem  imr  i.year, fe i(hhid1)
restore
end
bootstrap, reps(100) seed(123) cluster(hhid1) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_real_heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_nominal_heckman_organic.doc", replace word

tabstat total_qty_w  yhat [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*****************************************************************************************************************************************************
*****************************************************************************************************************************************************





********************************************
*Using Functional Forms
********************************************


********************************************Instrumental Variables*******************************************************************************************
*****************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr lland_holding  formal_credit informal_credit ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker org_fert  i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr  formal_credit informal_credit lland_holding ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker org_fert good_soil fair_soil  i.year) twostep
predict yhat, xb
predict imr, mills

sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)

*histogram total_qty_w, width(50) frequency normal
*histogram ltotal_qty_w, width(5) frequency normal
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat dist_admarc_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net lland_holding lreal_hhvalue hh_headage  num_mem  worker formal_credit informal_credit org_fert  annual_mean_temp annual_precipitation   imr           TAvg_ltotal_qty_w TAvg_lyhat TAvg_dist_admarc_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_safety_net TAvg_lland_holding TAvg_lreal_hhvalue TAvg_hh_headage  TAvg_num_mem TAvg_annual_mean_temp TAvg_annual_precipitation TAvg_worker TAvg_formal_credit TAvg_informal_credit TAvg_org_fert i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_real_heckman_original.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_nominal_heckman.doc", replace word



**Level

capture program drop myboot	
program define myboot, rclass
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr lland_holding  formal_credit informal_credit ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker org_fert  i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr  formal_credit informal_credit lland_holding ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker org_fert good_soil fair_soil  i.year) twostep
predict yhat, xb
predict imr, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat dist_admarc_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net lland_holding lreal_hhvalue hh_headage  num_mem  worker formal_credit informal_credit org_fert  annual_mean_temp annual_precipitation  imr            TAvg_total_qty_w TAvg_yhat TAvg_dist_admarc_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_safety_net TAvg_lland_holding TAvg_lreal_hhvalue TAvg_hh_headage  TAvg_num_mem TAvg_annual_mean_temp TAvg_annual_precipitation TAvg_worker TAvg_formal_credit TAvg_informal_credit TAvg_org_fert i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w  yhat [aweight = weight], statistics( mean median sd min max ) columns(statistics)

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_real_heckman_original.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_nominal_heckman.doc", replace word


*****************************************************************************************************************************************************
*****************************************************************************************************************************************************





******************************Using Organic and Soil Quality as Instrumental Variables***************************************************************
*****************************************************************************************************************************************************


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr lland_holding informal_save  formal_credit informal_credit ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue worker  i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr informal_save  formal_credit informal_credit lland_holding ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker org_fert good_soil fair_soil   i.year) twostep 
predict yhat, xb

sum yhat, detail


gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}



** CRE-TOBIT 
tobit ltotal_qty_w lyhat dist_admarc_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net lland_holding lreal_hhvalue hh_headage  num_mem  worker formal_credit informal_credit   annual_mean_temp annual_precipitation              TAvg_ltotal_qty_w TAvg_lyhat TAvg_dist_admarc_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_safety_net TAvg_lland_holding TAvg_lreal_hhvalue TAvg_hh_headage  TAvg_num_mem TAvg_annual_mean_temp TAvg_annual_precipitation TAvg_worker TAvg_formal_credit TAvg_informal_credit  i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_real_heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_nominal_heckman_organic.doc", replace word



**Level
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w real_maize_price_mr real_rice_price_mr lland_holding informal_save formal_credit informal_credit ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker  i.year, select (commercial_dummy= dist_admarc_w real_maize_price_mr real_rice_price_mr informal_save formal_credit informal_credit lland_holding ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb

*sum yhat, detail
local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
  
** CRE-TOBIT 
tobit total_qty_w yhat dist_admarc_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net lland_holding lreal_hhvalue hh_headage  num_mem  worker formal_credit informal_credit  annual_mean_temp annual_precipitation              TAvg_total_qty_w TAvg_yhat TAvg_dist_admarc_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_safety_net TAvg_lland_holding TAvg_lreal_hhvalue TAvg_hh_headage  TAvg_num_mem TAvg_annual_mean_temp TAvg_annual_precipitation TAvg_worker TAvg_formal_credit TAvg_informal_credit i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_real_heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_nominal_heckman_organic.doc", replace word

tabstat total_qty_w  yhat [aweight = weight], statistics( mean median sd min max ) columns(statistics)




*****************************************************************************************************************************************************
*****************************************************************************************************************************************************







**********************************************Descriptive Statistics*******************************************************************************
*****************************************************************************************************************************************************


*************************************************
*Heckman 2018

use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_price21p.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_price21p.dta", clear


gen good_soil = (soil_qty_rev2==1)
gen fair_soil = (soil_qty_rev2==2)

misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding good_soil fair_soil  real_maize_price_mr real_rice_price_mr net_seller net_buyer  region

tabstat total_qty_w yhat mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save good_soil fair_soil  org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


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

tabstat total_qty_w yhat mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save good_soil fair_soil  org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



************************** descriptive statistics of  variables in second survey (2021)
preserve

keep if year ==2021
tabstat total_qty_w yhat mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save good_soil fair_soil  org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore
*****************************************************************************************************************************************************
*****************************************************************************************************************************************************


******************Median
*****************************************************************************************************************************************************

use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\median\complete\Real_median21p.dta", clear


gen good_soil = (soil_qty_rev2==1)
gen fair_soil = (soil_qty_rev2==2)

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding good_soil fair_soil  real_maize_price_mr real_rice_price_mr net_seller net_buyer  region


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


gen lreal_tpricefert_cens_mrk = log(real_tpricefert_cens_mrk)



gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lreal_tpricefert_cens_mrk ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

************************** descriptive statistics of  variables in second survey (2018) 
preserve

keep if year ==2018
tabstat total_qty_w real_tpricefert_cens_mrk mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save good_soil fair_soil  org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



************************** descriptive statistics of  variables in second survey (2021)
preserve

keep if year ==2021
tabstat total_qty_w real_tpricefert_cens_mrk mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save good_soil fair_soil  org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore


*****************************************************************************************************************************************************
*****************************************************************************************************************************************************






























*******************************2015
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_heckman15.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_heckman15.dta", clear

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


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

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 lland_holding lreal_hhvalue "

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

heckman real_tpricefert_cens_mrk mrk_dist_w real_maize_price_mr real_rice_price_mr lland_holding formal_credit informal_credit ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker  i.year, select (commercial_dummy= mrk_dist_w real_maize_price_mr real_rice_price_mr formal_credit informal_credit lland_holding ext_acess  attend_sch hh_headage femhead num_mem safety_net  lreal_hhvalue  worker soil_qty_rev2  i.year) twostep



predict yhat, xb


gen lyhat = log(yhat)



gen ltotal_qty_w = log(total_qty_w + 1)

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

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_real_heckman_original15.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Log_nominal_heckman15.doc",   replace word






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

tobit total_qty_w mrk_dist_w yhat real_maize_price_mr hh_headage lreal_hhvalue land_holding femhead ext_acess attend_sch  safety_net soil_qty_rev2  formal_credit informal_credit num_mem worker TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat  TAvg_hh_headage TAvg_lreal_hhvalue   TAvg_femhead TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr  TAvg_land_holding TAvg_formal_credit TAvg_informal_credit  TAvg_num_mem TAvg_worker i.year, ll(0)



margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_real_heckman_original15.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\results\Level_nominal_heckman15.doc", replace word


tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)




**********************************************Descriptive Statistics*******************************************************************************
*****************************************************************************************************************************************************


*************************************************
*Heckman 2018

use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_price21.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_price21.dta", clear


*******************************2015
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_heckman15.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_heckman15.dta", clear




tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)




tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)







misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer  region



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

tabstat total_qty_w yhat mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



************************** descriptive statistics of  variables in second survey (2021)
preserve

keep if year ==2021
tabstat total_qty_w yhat mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore
*****************************************************************************************************************************************************
*****************************************************************************************************************************************************


******************Median
*****************************************************************************************************************************************************

use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\median\complete\Real_median21p.dta", clear

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


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


gen lreal_tpricefert_cens_mrk = log(real_tpricefert_cens_mrk)



gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lreal_tpricefert_cens_mrk ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

************************** descriptive statistics of  variables in second survey (2018) 
preserve

keep if year ==2018
tabstat total_qty_w real_tpricefert_cens_mrk mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



************************** descriptive statistics of  variables in second survey (2021)
preserve

keep if year ==2021
tabstat total_qty_w real_tpricefert_cens_mrk mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore









************************** descriptive statistics of  variables in second survey (2012)
preserve

keep if year ==2013
tabstat total_qty_w yhat mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net soil_qty_rev2 [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore





************************** descriptive statistics of  variables in first survey (2015)
preserve

keep if year ==2015
tabstat total_qty_w yhat mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net soil_qty_rev2 [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore


*****************************************************************************************************************************************************
*****************************************************************************************************************************************************


******************Median
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\median\complete\Real_median15.dta", clear
preserve

keep if year ==2013
tabstat total_qty_w real_tpricefert_cens_mrk mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net soil_qty_rev2 [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore





************************** descriptive statistics of  variables in first survey (2015)
preserve

keep if year ==2015
tabstat total_qty_w real_tpricefert_cens_mrk mrk_dist_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net soil_qty_rev2 [aweight = weight], statistics( mean median sd min max ) columns(statistics)


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

















