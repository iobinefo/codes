
**********************************************

*Heckman Log
use  "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Real_heckman.dta" , clear
use  "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Nominal_heckman.dta" , clear

*we decided to go with the one withiout p

*import excel "C:\Users\obine\Music\Documents\Project\codes\Malawi\maize_prices.xlsx", sheet("Sheet1") firstrow clear
*save "C:\Users\obine\Music\Documents\Project\codes\Malawi\maize", replace

merge m:1 year using "C:\Users\obine\Music\Documents\Project\codes\Malawi\maize", gen (average)
tab average
drop average


egen med_slop = median(plot_slope)
replace plot_slope = med_slop if plot_slope==.
egen med_eve = median(plot_elevation)
replace plot_elevation = med_eve if plot_elevation==.
egen med_wet = median(plot_wetness)
replace plot_wetness = med_wet if plot_wetness==.
egen med_annual = median(annual_precipitation)
replace annual_precipitation = med_annual if annual_precipitation==.
egen med_temp = median(annual_mean_temp)
replace annual_mean_temp = med_temp if annual_mean_temp==.

replace region =1 if region == 100
replace region =2 if region == 200
replace region =3 if region == 300
gen region_north = (region==1)
gen region_central = (region==2)
gen region_south = (region==3)




gen good_soil = (soil_qty_rev2==1)
gen fair_soil = (soil_qty_rev2==2)



tabstat total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker avg_maize_pr maize_price_mr hhasset_value_w land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


misstable summarize subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker maize_price_mr hhasset_value_w land_holding region plot_slope plot_elevation plot_wetness annual_precipitation annual_mean_temp org_fert

proportion subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2



sum real_tpricefert_cens_mrk, detail

gen lland_holding = log(land_holding)
gen lhhasset_value_w = log(hhasset_value_w)

local time_avg "total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker avg_maize_pr maize_price_mr lhhasset_value_w hhasset_value_w land_holding subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 lland_holding plot_slope plot_elevation plot_wetness annual_precipitation annual_mean_temp org_fert"

foreach x in `time_avg' {

	bysort HHID : egen TAvg_`x' = mean(`x')

}

*safety_net num_mem TAvg_num_mem ext_access TAvg_ext_access TAvg_annual_precipitation TAvg_annual_mean_temp


**********************************************
*First Stage Regression
**********************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert   i.year, select (commercial_dummy=  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert  good_soil fair_soil   i.year) twostep
predict yhat, xb
predict inm, mills

sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert        TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_lland_holding TAvg_lhhasset_value_w  TAvg_org_fert  inm i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert   i.year, select (commercial_dummy=  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb
predict inm, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert       TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_lland_holding TAvg_lhhasset_value_w  TAvg_org_fert inm i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

tabstat total_qty_w subsidy_qty_w  yhat num_mem hh_headage  [aweight = weight], statistics( mean median sd min max ) columns(statistics)




**********************************************
*Second Stage Regression
**********************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem  i.year, select (commercial_dummy=  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem good_soil fair_soil   i.year) twostep
predict yhat, xb
predict inm, mills

sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem       TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_lland_holding TAvg_lhhasset_value_w  TAvg_org_fert TAvg_hh_headage_mrk  TAvg_attend_sch TAvg_femhead TAvg_num_mem inm i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem  i.year, select (commercial_dummy=  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem good_soil fair_soil   i.year) twostep
predict yhat, xb
predict inm, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem       TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_lland_holding TAvg_lhhasset_value_w  TAvg_org_fert TAvg_hh_headage_mrk  TAvg_attend_sch TAvg_femhead TAvg_num_mem inm i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

tabstat total_qty_w subsidy_qty_w  yhat num_mem hh_headage  [aweight = weight], statistics( mean median sd min max ) columns(statistics)





**********************************************
*Third Stage Regression
**********************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem formal_credit  i.year, select (commercial_dummy=  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem formal_credit good_soil fair_soil   i.year) twostep
predict yhat, xb
predict inm, mills

sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem formal_credit       TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_lland_holding TAvg_lhhasset_value_w  TAvg_org_fert TAvg_hh_headage_mrk  TAvg_attend_sch TAvg_femhead TAvg_num_mem TAvg_formal_credit inm i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem formal_credit  i.year, select (commercial_dummy=  subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem formal_credit good_soil fair_soil   i.year) twostep
predict yhat, xb
predict inm, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_admarc_w maize_price_mr lland_holding lhhasset_value_w org_fert hh_headage_mrk attend_sch femhead num_mem formal_credit       TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_lland_holding TAvg_lhhasset_value_w  TAvg_org_fert TAvg_hh_headage_mrk  TAvg_attend_sch TAvg_femhead TAvg_num_mem TAvg_formal_credit inm i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

tabstat total_qty_w subsidy_qty_w  yhat num_mem hh_headage  [aweight = weight], statistics( mean median sd min max ) columns(statistics)





*******************************************************Instrumental Variables*******************************************************************************
*************************************************************************************************************************************************************
*informal_save 
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w subsidy_qty_w maize_price_mr lland_holding informal_save  formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead worker num_mem safety_net lhhasset_value_w org_fert i.year, select (commercial_dummy= subsidy_qty_w dist_admarc_w maize_price_mr lland_holding informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead  worker num_mem safety_net lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb
predict inm, mills

sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem   org_fert  annual_precipitation annual_mean_temp formal_credit informal_credit  informal_save TAvg_annual_precipitation TAvg_annual_mean_temp  TAvg_org_fert  TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_ext_access TAvg_femhead TAvg_attend_sch TAvg_safety_net TAvg_lhhasset_value_w TAvg_lland_holding TAvg_hh_headage_mrk TAvg_worker TAvg_num_mem TAvg_formal_credit TAvg_informal_credit TAvg_informal_save inm i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Log_real_heckman_original2.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Log_nominal_heckman2.doc", replace word





**********************************************
*Level__heckman
**********************************************
*
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w subsidy_qty_w maize_price_mr lland_holding informal_save  formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead worker num_mem safety_net lhhasset_value_w org_fert i.year, select (commercial_dummy= subsidy_qty_w dist_admarc_w maize_price_mr lland_holding informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead  worker num_mem safety_net lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb
predict inm, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem   org_fert  annual_precipitation annual_mean_temp formal_credit informal_credit informal_save  TAvg_annual_precipitation TAvg_annual_mean_temp  TAvg_org_fert  TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_ext_access TAvg_femhead TAvg_attend_sch TAvg_safety_net TAvg_lhhasset_value_w TAvg_lland_holding TAvg_hh_headage_mrk TAvg_worker TAvg_num_mem TAvg_formal_credit TAvg_informal_credit TAvg_informal_save inm i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Level__heckman2.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Level__nominal_heckman2.doc", replace word


tabstat total_qty_w subsidy_qty_w  yhat num_mem hh_headage  [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************



******************************Using organic and soil quality as Instrumental Variables***********************************************************************
*************************************************************************************************************************************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

  
heckman real_tpricefert_cens_mrk dist_admarc_w subsidy_qty_w maize_price_mr lland_holding  informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead worker num_mem safety_net lhhasset_value_w  i.year, select (commercial_dummy= subsidy_qty_w dist_admarc_w maize_price_mr lland_holding informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead  worker num_mem safety_net lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb

sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem     annual_precipitation annual_mean_temp formal_credit informal_credit informal_save  TAvg_annual_precipitation TAvg_annual_mean_temp    TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_ext_access TAvg_femhead TAvg_attend_sch TAvg_safety_net TAvg_lhhasset_value_w TAvg_lland_holding TAvg_hh_headage_mrk TAvg_worker TAvg_num_mem TAvg_formal_credit TAvg_informal_credit TAvg_informal_save i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Log_real_heckman_organic2.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Log_nominal_heckman_organic2.doc", replace word





**********************************************
*Level__heckman
**********************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w subsidy_qty_w maize_price_mr lland_holding  informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead worker num_mem safety_net lhhasset_value_w i.year, select (commercial_dummy= subsidy_qty_w dist_admarc_w maize_price_mr lland_holding informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead  worker num_mem safety_net lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb

local time_avg "yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem  annual_precipitation annual_mean_temp formal_credit informal_credit   TAvg_annual_precipitation TAvg_annual_mean_temp  TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_ext_access TAvg_femhead TAvg_attend_sch TAvg_safety_net TAvg_lhhasset_value_w TAvg_lland_holding TAvg_hh_headage_mrk TAvg_worker TAvg_num_mem TAvg_formal_credit TAvg_informal_credit  i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Level__heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Level__nominal_heckman_organic2.doc", replace word


tabstat total_qty_w subsidy_qty_w  yhat num_mem hh_headage  [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*************************************************************************************************************************************************************
*************************************************************************************************************************************************************






******************************Using OLS Regression***********************************************************************************************************
*************************************************************************************************************************************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

  
heckman real_tpricefert_cens_mrk dist_admarc_w subsidy_qty_w maize_price_mr lland_holding  informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead worker num_mem safety_net lhhasset_value_w  i.year, select (commercial_dummy= subsidy_qty_w dist_admarc_w maize_price_mr lland_holding informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead  worker num_mem safety_net lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb

sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg ltotal_qty_w lyhat subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem     annual_precipitation annual_mean_temp formal_credit informal_credit  i.year,  fe i(HHID)
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Log_real_heckman_organic.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Log_nominal_heckman_organic.doc", replace word





**********************************************
*Level__heckman
**********************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w subsidy_qty_w maize_price_mr lland_holding  informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead worker num_mem safety_net lhhasset_value_w i.year, select (commercial_dummy= subsidy_qty_w dist_admarc_w maize_price_mr lland_holding informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead  worker num_mem safety_net lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb

local time_avg "yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg total_qty_w yhat subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem  annual_precipitation annual_mean_temp formal_credit informal_credit i.year,  fe i(HHID)
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Level__heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Heckman\complete\Level__nominal_heckman_organic.doc", replace word


tabstat total_qty_w subsidy_qty_w  yhat num_mem hh_headage  [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*************************************************************************************************************************************************************
*************************************************************************************************************************************************************







******************************OLS Regression with org_fert*************************************************************************************
*************************************************************************************************************************************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

  
heckman real_tpricefert_cens_mrk dist_admarc_w subsidy_qty_w maize_price_mr lland_holding  informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead worker num_mem safety_net lhhasset_value_w org_fert  i.year, select (commercial_dummy= subsidy_qty_w dist_admarc_w maize_price_mr lland_holding informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead  worker num_mem safety_net lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb

sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg ltotal_qty_w lyhat subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem org_fert    annual_precipitation annual_mean_temp formal_credit informal_credit  i.year,  fe i(HHID)
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot





**********************************************
*Level__heckman
**********************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk dist_admarc_w subsidy_qty_w maize_price_mr lland_holding  informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead worker num_mem safety_net lhhasset_value_w org_fert i.year, select (commercial_dummy= subsidy_qty_w dist_admarc_w maize_price_mr lland_holding informal_save formal_credit informal_credit ext_access attend_sch hh_headage_mrk femhead  worker num_mem safety_net lhhasset_value_w org_fert good_soil fair_soil   i.year) twostep
predict yhat, xb

local time_avg "yhat"
foreach x in `time_avg' {
	bysort HHID : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg total_qty_w yhat subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem org_fert annual_precipitation annual_mean_temp formal_credit informal_credit i.year,  fe i(HHID)
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot


tabstat total_qty_w subsidy_qty_w  yhat num_mem hh_headage  [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*************************************************************************************************************************************************************
*************************************************************************************************************************************************************









*Median
use  "C:\Users\obine\Music\Documents\Project\codes\Malawi\complete\Real_median.dta" , clear
use "C:\Users\obine\Music\Documents\Project\codes\Malawi\complete\Nominal_median.dta", clear





merge m:1 year using "C:\Users\obine\Music\Documents\Project\codes\Malawi\maize", gen (average)
tab average
drop average


egen med_slop = median(plot_slope)
replace plot_slope = med_slop if plot_slope==.
egen med_eve = median(plot_elevation)
replace plot_elevation = med_eve if plot_elevation==.
egen med_wet = median(plot_wetness)
replace plot_wetness = med_wet if plot_wetness==.
egen med_annual = median(annual_precipitation)
replace annual_precipitation = med_annual if annual_precipitation==.
egen med_temp = median(annual_mean_temp)
replace annual_mean_temp = med_temp if annual_mean_temp==.

replace region =1 if region == 100
replace region =2 if region == 200
replace region =3 if region == 300
gen region_north = (region==1)
gen region_central = (region==2)
gen region_south = (region==3)



tabstat total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker avg_maize_pr maize_price_mr hhasset_value_w land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


misstable summarize subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker maize_price_mr hhasset_value_w land_holding region plot_slope plot_elevation plot_wetness annual_precipitation annual_mean_temp org_fert

proportion subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2



sum real_tpricefert_cens_mrk, detail


gen lland_holding = log(land_holding)
gen lhhasset_value_w = log(hhasset_value_w)


local time_avg "total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker maize_price_mr lhhasset_value_w land_holding subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 avg_maize_pr lland_holding plot_slope plot_elevation plot_wetness annual_precipitation annual_mean_temp org_fert"

foreach x in `time_avg' {

	bysort HHID : egen TAvg_`x' = mean(`x')

}




gen lreal_tpricefert_cens_mrk = log(real_tpricefert_cens_mrk)

gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lreal_tpricefert_cens_mrk ltotal_qty_w"

foreach x in `time_avg' {

	bysort HHID : egen TAvg_`x' = mean(`x')

}





*log org_fert org_fert
** OLS with HH fixed effects
xtreg ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem     annual_precipitation annual_mean_temp formal_credit informal_credit i.region i.year, fe i(HHID) cluster(HHID)

** OLS with HH fixed effects
xtreg total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem  formal_credit informal_credit  annual_precipitation annual_mean_temp i.region i.year, fe i(HHID) cluster(HHID)

tabstat total_qty_w real_tpricefert_cens_mrk [aweight = weight], statistics( mean median sd min max ) columns(statistics)






***********************************with org_fert******************************************************************************
*************************************************************************************************************************************************************


*log
** OLS with HH fixed effects
xtreg ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem org_fert    annual_precipitation annual_mean_temp formal_credit informal_credit i.region i.year, fe i(HHID) cluster(HHID)

** OLS with HH fixed effects
xtreg total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem org_fert formal_credit informal_credit  annual_precipitation annual_mean_temp i.region i.year, fe i(HHID) cluster(HHID)

tabstat total_qty_w real_tpricefert_cens_mrk [aweight = weight], statistics( mean median sd min max ) columns(statistics)








*************************************************************************************************************************************************************
*************************************************************************************************************************************************************




*************************************************************************************************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
preserve 
tobit total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem org_fert formal_credit informal_credit  annual_precipitation annual_mean_temp   TAvg_annual_precipitation TAvg_annual_mean_temp  TAvg_org_fert  TAvg_total_qty_w TAvg_real_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_ext_access TAvg_femhead TAvg_attend_sch TAvg_safety_net TAvg_lhhasset_value_w TAvg_lland_holding TAvg_hh_headage_mrk TAvg_worker TAvg_num_mem TAvg_formal_credit TAvg_informal_credit  i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\complete\Level_real_median_original.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\complete\Level_nominal_median.doc", replace word



tabstat total_qty_w subsidy_qty_w  real_tpricefert_cens_mrk [aweight = weight], statistics( mean median sd min max ) columns(statistics)





*Log

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
tobit ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem   org_fert  annual_precipitation annual_mean_temp formal_credit informal_credit   TAvg_annual_precipitation TAvg_annual_mean_temp  TAvg_org_fert  TAvg_ltotal_qty_w TAvg_lreal_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_ext_access TAvg_femhead TAvg_attend_sch TAvg_safety_net TAvg_lhhasset_value_w TAvg_lland_holding TAvg_hh_headage_mrk TAvg_worker TAvg_num_mem TAvg_formal_credit TAvg_informal_credit  i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\complete\Log_real_median_original.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\Malawi\complete\Log_nominal_median.doc", replace word

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************






********************************************without org_fert**************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
preserve 
tobit total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem formal_credit informal_credit  annual_precipitation annual_mean_temp   TAvg_annual_precipitation TAvg_annual_mean_temp  TAvg_total_qty_w TAvg_real_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_ext_access TAvg_femhead TAvg_attend_sch TAvg_safety_net TAvg_lhhasset_value_w TAvg_lland_holding TAvg_hh_headage_mrk TAvg_worker TAvg_num_mem TAvg_formal_credit TAvg_informal_credit  i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot

tabstat total_qty_w subsidy_qty_w  real_tpricefert_cens_mrk [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*Log

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
tobit ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_admarc_w maize_price_mr ext_access attend_sch femhead safety_net  lland_holding lhhasset_value_w hh_headage_mrk worker num_mem  annual_precipitation annual_mean_temp formal_credit informal_credit   TAvg_annual_precipitation TAvg_annual_mean_temp  TAvg_ltotal_qty_w TAvg_lreal_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_admarc_w TAvg_maize_price_mr TAvg_ext_access TAvg_femhead TAvg_attend_sch TAvg_safety_net TAvg_lhhasset_value_w TAvg_lland_holding TAvg_hh_headage_mrk TAvg_worker TAvg_num_mem TAvg_formal_credit TAvg_informal_credit  i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(HHID) idcluster(newid): myboot
*************************************************************************************************************************************************************
*************************************************************************************************************************************************************



****************************
*Commercial Analysis
****************************

	
//% of HHs that bought commercial fertilizer by each survey wave
bysort year : tabstat commercial_dummy [w=weight], stat(mean sem)

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort hhid : egen sum_4waves_com_fer_bin = sum(commercial_dummy) 



bysort year : tabstat subsidy_dummy [w=weight], stat(mean sem)

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort hhid : egen sum_4waves_sub_fer_bin = sum(subsidy_dummy) 





************************** descriptive statistics of  variables in second survey (2018)
preserve

keep if year ==2010
tabstat total_qty_w subsidy_qty_w yhat dist_admarc_w num_mem hh_headage_mrk hhasset_value_w worker maize_price_mr  land_holding femhead formal_credit informal_credit ext_access attend_sch safety_net informal_save good_soil fair_soil org_fert  annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore


preserve

keep if year ==2013
tabstat total_qty_w subsidy_qty_w yhat dist_admarc_w num_mem hh_headage_mrk hhasset_value_w worker maize_price_mr  land_holding femhead formal_credit informal_credit ext_access attend_sch safety_net informal_save good_soil fair_soil org_fert  annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore


preserve

keep if year ==2016
tabstat total_qty_w subsidy_qty_w yhat dist_admarc_w num_mem hh_headage_mrk hhasset_value_w worker maize_price_mr  land_holding femhead formal_credit informal_credit ext_access attend_sch safety_net informal_save good_soil fair_soil org_fert  annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore



preserve

keep if year ==2019
tabstat total_qty_w subsidy_qty_w yhat dist_admarc_w num_mem hh_headage_mrk hhasset_value_w worker maize_price_mr  land_holding femhead formal_credit informal_credit ext_access attend_sch safety_net informal_save good_soil fair_soil org_fert  annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore




************Median*************** 


preserve

keep if year ==2010
tabstat total_qty_w subsidy_qty_w real_tpricefert_cens_mrk dist_admarc_w num_mem hh_headage_mrk hhasset_value_w worker maize_price_mr  land_holding femhead formal_credit informal_credit ext_access attend_sch safety_net informal_save good_soil fair_soil org_fert  annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore


preserve

keep if year ==2013
tabstat total_qty_w subsidy_qty_w real_tpricefert_cens_mrk dist_admarc_w num_mem hh_headage_mrk hhasset_value_w worker maize_price_mr  land_holding femhead formal_credit informal_credit ext_access attend_sch safety_net informal_save good_soil fair_soil org_fert  annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore


preserve

keep if year ==2016
tabstat total_qty_w subsidy_qty_w real_tpricefert_cens_mrk dist_admarc_w num_mem hh_headage_mrk hhasset_value_w worker maize_price_mr  land_holding femhead formal_credit informal_credit ext_access attend_sch safety_net informal_save good_soil fair_soil org_fert  annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



preserve

keep if year ==2019
tabstat total_qty_w subsidy_qty_w real_tpricefert_cens_mrk dist_admarc_w num_mem hh_headage_mrk hhasset_value_w worker maize_price_mr  land_holding femhead formal_credit informal_credit ext_access attend_sch safety_net informal_save good_soil fair_soil org_fert  annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



***********************************************************************************
*Real result
***********************************************************************************

                                            *********************************************************
											*Estimation Based on Region
											*********************************************************
use "C:\Users\obine\Music\Documents\Project\codes\without_median\complete_files.dta", clear


gen dummy = 1

collapse (sum) dummy, by (hhid)
tab dummy
keep if dummy==4
sort hhid

save "C:\Users\obine\Music\Documents\Project\codes\without_median/subset_complete_files", replace


merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete_files.dta"

drop if _merge==2




gen year_2010 = (year==2010)
gen year_2012 = (year==2012)
gen year_2015 = (year==2015)
gen year_2018 = (year==2018)

gen commercial_dummy = (total_qty_w>0)

tab commercial_dummy


tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)





/*
gen region = 1 if zone== 2 | zone==3 //north 
replace region =2 if zone== 1  //central
replace region =3 if zone== 4 | zone==5 | zone==6  //south

tab land_group  region, column
*/


preserve  //north

keep if zone== 2 | zone==3 | zone==1




restore




preserve  //south

keep if  zone== 4 | zone==5 | zone==6	