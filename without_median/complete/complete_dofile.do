log using "C:\Users\obine\Music\Documents\Project\codes\Nigeria_log_file.smcl", append
*************************************************************************************************************************************************************
***********First Stage Regression
xtreg total_qty_w good_soil fair_soil i.year,  fe i(hhid)

*Heckman Log
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Real_heckman.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Nominal_heckman.dta", clear

tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
egen med_zone = median (zone)
replace zone = med_zone if zone ==.
misstable summarize total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 zone year plot_elevation plot_slope plot_wetness dist_market_w annual_mean_temp annual_precipitation org_fert


*replace hh_headage = 72 if hh_headage >72
gen lland_holding = log(land_holding)
gen lreal_hhvalue = log(real_hhvalue + 1)


sum real_tpricefert_cens_mrk, detail

gen good_soil = (soil_qty_rev2==1)
gen fair_soil = (soil_qty_rev2==2)


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit  attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 lland_holding lreal_hhvalue plot_elevation plot_slope plot_wetness annual_mean_temp ext_acess annual_precipitation org_fert dist_market_w formal_bank formal_save"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}



*****************************************
*Variables for model

*subsidy_qty_w dist_cens_w  real_maize_price_mr  real_hhvalue field_size_ha_w org_fert

*subsidy_qty_w dist_cens_w  real_maize_price_mr  real_hhvalue field_size_ha_w org_fert hh_headage_mrk attend_sch femhead num_mem formal_credit

*Additional Variables

*hh_headage_mrk TAvg_hh_headage_mrk attend_sch TAvg_attend_sch femhead num_mem   TAvg_femhead TAvg_num_mem

*****************************************

****************************************
*First Stage Regression
****************************************
*************ext_acess annual_mean_temp annual_precipitation

*********formal_credit informal_credit   hh_headage attend_sch femhead num_mem safety_net  worker ext_acess
********* TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem TAvg_safety_net TAvg_ext_acess     TAvg_worker 

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding  org_fert  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding  org_fert   good_soil  i.year) twostep
predict yhat, xb
predict imr, mills

gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}

** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding  org_fert TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding  TAvg_org_fert imr i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot
**************LEVEL


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding  org_fert  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr lland_holding  org_fert good_soil  i.year) twostep
predict yhat, xb
predict imr, mills


local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}

************winzonrizing fertilizer market price
foreach v of varlist  yhat  {
	_pctile `v' [aw=weight] , p(1 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}


local time_avg "yhat_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}


** CRE-TOBIT 
tobit total_qty_w yhat_w subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding  org_fert  TAvg_total_qty_w TAvg_yhat_w TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding  TAvg_org_fert imr i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w yhat yhat_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)




***************************************
*Second Stage Regression
****************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem good_soil  i.year) twostep
predict yhat, xb
predict imr, mills

************winzonrizing fertilizer market price
foreach v of varlist  yhat  {
	_pctile `v' [aw=weight] , p(1 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}


gen lyhat = log(yhat_w)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}

** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem imr i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot
**************LEVEL


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem good_soil  i.year) twostep
predict yhat, xb
predict imr, mills

sum yhat, detail

************winzonrizing fertilizer market price
foreach v of varlist  yhat  {
	_pctile `v' [aw=weight] , p(1 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}


local time_avg "yhat_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat_w subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem   TAvg_total_qty_w TAvg_yhat_w TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem  imr i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w yhat yhat_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)






***************************************
*Third Stage Regression
****************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem good_soil  i.year) twostep
predict yhat, xb
predict imr, mills

************winzonrizing fertilizer market price
foreach v of varlist  yhat  {
	_pctile `v' [aw=weight] , p(1 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}


gen lyhat = log(yhat_w)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}

** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem annual_mean_temp annual_precipitation  TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem  TAvg_annual_mean_temp TAvg_annual_precipitation imr i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot
**************LEVEL


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem good_soil  i.year) twostep
predict yhat, xb
predict imr, mills

sum yhat, detail

************winzonrizing fertilizer market price
foreach v of varlist  yhat  {
	_pctile `v' [aw=weight] , p(1 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}


local time_avg "yhat_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat_w subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  annual_mean_temp annual_precipitation  TAvg_total_qty_w TAvg_yhat_w TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem TAvg_annual_mean_temp TAvg_annual_precipitation imr i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w yhat yhat_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)





















****************************************
*M Stage Regression
****************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem good_soil  i.year) twostep
predict yhat, xb
predict imr, mills

gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}

** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem annual_mean_temp annual_precipitation  TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem  TAvg_annual_mean_temp TAvg_annual_precipitation imr i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot
**************LEVEL


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr lland_holding lreal_hhvalue org_fert hh_headage attend_sch femhead num_mem good_soil  i.year) twostep
predict yhat, xb
predict imr, mills


local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem annual_mean_temp annual_precipitation  TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem  TAvg_annual_mean_temp TAvg_annual_precipitation imr i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w yhat [aweight = weight], statistics( mean median sd min max ) columns(statistics)









*********************************************************Using OLS Regression******************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue  org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem good_soil  i.year) twostep
predict yhat, xb
predict imr, mills


sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg ltotal_qty_w lyhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem i.year,  fe i(hhid)
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot




***************LEVEL************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem good_soil  i.year) twostep
predict yhat, xb
predict imr, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg total_qty_w yhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem i.year, fe i(hhid)
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w yhat [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************






********************************************************* OLS Regression with org_fert*******************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem org_fert good_soil  i.year) twostep
predict yhat, xb
predict imr, mills


sum yhat, detail
gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg ltotal_qty_w lyhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue  hh_headage attend_sch femhead num_mem i.year,  fe i(hhid)
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot




***************LEVEL************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.year, select (commercial_dummy= subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem org_fert good_soil  i.year) twostep
predict yhat, xb
predict imr, mills

local time_avg "yhat"
foreach x in `time_avg' {
	bysort hhid : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg total_qty_w yhat subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue  hh_headage attend_sch femhead num_mem i.year, fe i(hhid)
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w yhat [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************





*Median
use  "C:\Users\obine\Music\Documents\Project\codes\Nigeria_median\complete\Real_median.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Nigeria_median\complete\Nominal_median.dta", clear


foreach v of varlist  real_tpricefert_cens_mrk  {
	_pctile `v' [aw=weight] , p(1 99) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}


tab real_tpricefert_cens_mrk
tab real_tpricefert_cens_mrk_w, missing
sum real_tpricefert_cens_mrk real_tpricefert_cens_mrk_w, detail

tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
egen med_zone = median (zone)
replace zone = med_zone if zone ==.
misstable summarize total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 zone year


gen lland_holding = log(land_holding)
gen lreal_hhvalue = log(real_hhvalue + 1)


sum real_tpricefert_cens_mrk, detail


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 lland_holding lreal_hhvalue plot_elevation plot_slope plot_wetness annual_mean_temp annual_precipitation org_fert dist_market_w formal_bank formal_save"


foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


gen lreal_tpricefert_cens_mrk = log(real_tpricefert_cens_mrk)

gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lreal_tpricefert_cens_mrk ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

gen good_soil = (soil_qty_rev2==1)
gen fair_soil = (soil_qty_rev2==2)


*************First Stage Regression

reg total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net land_holding real_hhvalue hh_headage  num_mem   org_fert good_soil i.year


*log
** OLS with HH fixed effects
xtreg ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem   i.zone i.year, fe i(hhid) cluster(hhid)

** OLS with HH fixed effects
xtreg total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem  i.zone i.year, fe i(hhid) cluster(hhid)

tabstat total_qty_w real_tpricefert_cens_mrk [aweight = weight], statistics( mean median sd min max ) columns(statistics)



*************************************************************************************************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
preserve 
tobit total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem TAvg_total_qty_w TAvg_real_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Level_real_median_original.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Level_nominal_median.doc", replace word

tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*Log

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
tobit ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr land_holding real_hhvalue org_fert hh_headage attend_sch femhead num_mem TAvg_ltotal_qty_w TAvg_lreal_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue TAvg_org_fert TAvg_hh_headage TAvg_attend_sch TAvg_femhead TAvg_num_mem i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Log_real_median_original.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Log_nominal_median.doc", replace word



*************************************************************************************************************************************************************
*************************************************************************************************************************************************************



***************************************without org_fert***************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
preserve 
tobit total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net lland_holding lreal_hhvalue hh_headage  num_mem worker formal_credit informal_credit annual_mean_temp annual_precipitation  TAvg_total_qty_w TAvg_real_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_safety_net TAvg_lland_holding TAvg_lreal_hhvalue TAvg_hh_headage  TAvg_num_mem TAvg_worker  TAvg_annual_mean_temp TAvg_annual_precipitation TAvg_formal_credit TAvg_informal_credit i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Level_real_median_original.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Level_nominal_median.doc", replace word

tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*Log

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
tobit ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net lland_holding lreal_hhvalue hh_headage  num_mem worker formal_credit informal_credit annual_mean_temp annual_precipitation  TAvg_ltotal_qty_w TAvg_lreal_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_market_w  TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_safety_net TAvg_lland_holding TAvg_lreal_hhvalue TAvg_hh_headage  TAvg_num_mem TAvg_worker  TAvg_annual_mean_temp TAvg_annual_precipitation TAvg_formal_credit TAvg_informal_credit i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Log_real_median_original.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Log_nominal_median.doc", replace word



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
*************************************************************************************************************************************************************

preserve

keep if year ==2010
tabstat total_qty_w subsidy_qty_w yhat dist_market_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore


preserve

keep if year ==2012
tabstat total_qty_w subsidy_qty_w yhat dist_market_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore


preserve

keep if year ==2015
tabstat total_qty_w subsidy_qty_w yhat dist_market_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore



preserve

keep if year ==2018
tabstat total_qty_w subsidy_qty_w yhat dist_market_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore
*************************************************************************************************************************************************************
*************************************************************************************************************************************************************




************Median***************
use  "C:\Users\obine\Music\Documents\Project\codes\Nigeria_median\complete\Real_median.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Nigeria_median\complete\Nominal_median.dta", clear


preserve

keep if year ==2010
tabstat total_qty_w subsidy_qty_w real_tpricefert_cens_mrk dist_market_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore


preserve

keep if year ==2012
tabstat total_qty_w subsidy_qty_w real_tpricefert_cens_mrk dist_market_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore


preserve

keep if year ==2015
tabstat total_qty_w subsidy_qty_w real_tpricefert_cens_mrk dist_market_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



preserve

keep if year ==2018
tabstat total_qty_w subsidy_qty_w real_tpricefert_cens_mrk dist_market_w  num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead  formal_credit informal_credit ext_acess attend_sch safety_net informal_save soil_qty_rev2 org_fert annual_mean_temp annual_precipitation [aweight = weight], statistics( mean median sd min max ) columns(statistics)


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
*log
** OLS with HH fixed effects
xtreg ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net lland_holding lreal_hhvalue hh_headage  num_mem worker formal_credit informal_credit  org_fert annual_mean_temp annual_precipitation  i.zone i.year, fe i(hhid) cluster(hhid)

** OLS with HH fixed effects
xtreg total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_market_w real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead safety_net lland_holding lreal_hhvalue hh_headage  num_mem worker formal_credit informal_credit  org_fert annual_mean_temp annual_precipitation  i.zone i.year, fe i(hhid) cluster(hhid)

tabstat total_qty_w real_tpricefert_cens_mrk [aweight = weight], statistics( mean median sd min max ) columns(statistics)














*************************************************************************************************************************************************************