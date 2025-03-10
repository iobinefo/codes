
**********************************************
*Heckman*
use "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\complete_panel5.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\Nominal_panel5.dta", clear



tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)


misstable summarize subsidy_dummy femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w

replace hh_headage_mrk = 70 if hh_headage_mrk >70
gen lfield_size_ha_w = log(field_size_ha_w)
gen lreal_hhvalue = log(real_hhvalue)



sum real_tpricefert_cens_mrk, detail

local time_avg "total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w  subsidy_dummy femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 lfield_size_ha_w lreal_hhvalue org_fert"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}








*******************************************************Instrumental Variables*******************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue org_fert worker  i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank  formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue org_fert worker soil_qty_rev2  i.year) twostep

predict yhat, xb


gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}


** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net org_fert num_mem worker formal_credit informal_credit    TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr  TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_hh_headage_mrk TAvg_lreal_hhvalue TAvg_lfield_size_ha_w TAvg_safety_net TAvg_org_fert TAvg_num_mem TAvg_worker  TAvg_formal_credit TAvg_informal_credit   i.year, ll(0)



margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(UPHI) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Log_real_heckman_original_correct.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Log_nominal_heckman_correct.doc", replace word



********Level
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


heckman real_tpricefert_cens_mrk subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue org_fert worker  i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank  formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue org_fert worker soil_qty_rev2  i.year) twostep


predict yhat, xb


local time_avg "yhat"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}

 
** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net org_fert num_mem worker formal_credit informal_credit    TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr  TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_hh_headage_mrk TAvg_lreal_hhvalue TAvg_lfield_size_ha_w TAvg_safety_net TAvg_org_fert TAvg_num_mem TAvg_worker  TAvg_formal_credit TAvg_informal_credit   i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(UPHI) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Level_real_heckman_original_correct.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Level_nominal_heckman_correct.doc", replace word

tabstat total_qty_w subsidy_qty_w dist_cens_w yhat num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************


********************Using Organic and soil Quality as Instrumental Variables******************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue  worker  i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank  formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue org_fert worker soil_qty_rev2  i.year) twostep
predict yhat, xb


gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort UPHI : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net  num_mem worker formal_credit informal_credit    TAvg_ltotal_qty_w TAvg_lyhat TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr  TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_hh_headage_mrk TAvg_lreal_hhvalue TAvg_lfield_size_ha_w TAvg_safety_net  TAvg_num_mem TAvg_worker  TAvg_formal_credit TAvg_informal_credit   i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(UPHI) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Log_real_heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Log_nominal_heckman__organic.doc", replace word



*************************************
*Level
*************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue worker  i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank  formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue org_fert worker soil_qty_rev2  i.year) twostep
predict yhat, xb

local time_avg "yhat"
foreach x in `time_avg' {
	bysort UPHI : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net num_mem worker formal_credit informal_credit    TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr  TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_hh_headage_mrk TAvg_lreal_hhvalue TAvg_lfield_size_ha_w TAvg_safety_net TAvg_num_mem TAvg_worker  TAvg_formal_credit TAvg_informal_credit   i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(UPHI) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Level_real_heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Level_nominal_heckman_organic.doc", replace word

tabstat total_qty_w yhat field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************




***********************************************************Using OLS Regression******************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue  worker  i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank  formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue org_fert worker soil_qty_rev2  i.year) twostep
predict yhat, xb


gen lyhat = log(yhat)
gen ltotal_qty_w = log(total_qty_w + 1)
local time_avg "lyhat ltotal_qty_w yhat"
foreach x in `time_avg' {
	bysort UPHI : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg ltotal_qty_w lyhat subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net  num_mem worker formal_credit informal_credit i.year, fe i(UPHI)
restore
end
bootstrap, reps(100) seed(123) cluster(UPHI) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Log_real_heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Log_nominal_heckman__organic.doc", replace word



*************************************
*Level
*************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
heckman real_tpricefert_cens_mrk subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue worker  i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w real_maize_price_mr real_rice_price_mr lfield_size_ha_w formal_bank  formal_credit informal_credit  ext_acess attend_sch  hh_headage_mrk femhead num_mem safety_net lreal_hhvalue org_fert worker soil_qty_rev2  i.year) twostep
predict yhat, xb

local time_avg "yhat"
foreach x in `time_avg' {
	bysort UPHI : egen TAvg_`x' = mean(`x')
}
** CRE-TOBIT 
xtreg total_qty_w yhat subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net num_mem worker formal_credit informal_credit   i.year, fe i(UPHI)
restore
end
bootstrap, reps(100) seed(123) cluster(UPHI) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Level_real_heckman_organic.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Level_nominal_heckman_organic.doc", replace word

tabstat total_qty_w yhat field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************






*Median*
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014\panell\complete_panel5.dta", clear
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014\panell\Nominal_panel5.dta", clear




tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)


misstable summarize subsidy_dummy femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w

replace hh_headage_mrk = 70 if hh_headage_mrk >70
gen lfield_size_ha_w = log(field_size_ha_w)
gen lreal_hhvalue = log(real_hhvalue)



sum real_tpricefert_cens_mrk, detail

local time_avg "total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w  subsidy_dummy femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 lfield_size_ha_w lreal_hhvalue org_fert"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}


gen lreal_tpricefert_cens_mrk = log(real_tpricefert_cens_mrk)
gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lreal_tpricefert_cens_mrk ltotal_qty_w"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}







*log
** OLS with HH fixed effects
xtreg ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net org_fert num_mem worker formal_credit informal_credit i.year, fe i(UPHI) cluster(UPHI)

** OLS with HH fixed effects
xtreg total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net org_fert num_mem worker formal_credit informal_credit  i.year, fe i(UPHI) cluster(UPHI)

tabstat total_qty_w real_tpricefert_cens_mrk [aweight = weight], statistics( mean median sd min max ) columns(statistics)




*************************************************************************************************************************************************************
*************************************************************************************************************************************************************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
preserve 
tobit total_qty_w real_tpricefert_cens_mrk subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net org_fert num_mem worker formal_credit informal_credit    TAvg_total_qty_w TAvg_real_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr  TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_hh_headage_mrk TAvg_lreal_hhvalue TAvg_lfield_size_ha_w TAvg_safety_net TAvg_org_fert TAvg_num_mem TAvg_worker  TAvg_formal_credit TAvg_informal_credit   i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Level_real_median_original.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Level_nominal_median.doc", replace word


tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)




*Log
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 

** CRE-TOBIT 
tobit ltotal_qty_w lreal_tpricefert_cens_mrk subsidy_qty_w dist_cens_w  real_maize_price_mr real_rice_price_mr ext_acess attend_sch femhead hh_headage_mrk lreal_hhvalue lfield_size_ha_w safety_net org_fert num_mem worker formal_credit informal_credit    TAvg_ltotal_qty_w TAvg_lreal_tpricefert_cens_mrk TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_maize_price_mr TAvg_real_rice_price_mr  TAvg_ext_acess TAvg_attend_sch TAvg_femhead TAvg_hh_headage_mrk TAvg_lreal_hhvalue TAvg_lfield_size_ha_w TAvg_safety_net TAvg_org_fert TAvg_num_mem TAvg_worker  TAvg_formal_credit TAvg_informal_credit   i.year, ll(0)
margins, predict(ystar(0,.)) dydx(*) post
restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Log_real_median_original.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\results\Log_nominal_median.doc", replace word


*************************************************************************************************************************************************************
*************************************************************************************************************************************************************











**********************************************************************
*Real Bootstrap correct
************************************************************************

***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
 

 
heckman real_tpricefert_cens_mrk subsidy_qty_w  dist_cens_w real_maize_price_mr real_rice_price_mr  field_size_ha_w formal_save formal_bank formal_credit informal_credit ext_acess  i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch safety_net net_seller net_buyer soil_qty_rev2  i.year) twostep


predict yhat, xb





local time_avg "yhat"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}

tobit total_qty_w yhat subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_yhat TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_subsidy_dummy TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.year, ll(0)


margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(UPHI) idcluster(newid): myboot




*
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




	

************************** descriptive statistics of  variables in first survey (2010) formal_bank
*************************************************************************************************************************************************************

preserve

keep if year ==2010
tabstat total_qty_w subsidy_qty_w  yhat dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_credit informal_credit ext_acess attend_sch safety_net  formal_save soil_qty_rev2 org_fert [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore


************************** descriptive statistics of  variables in second survey (2012)
preserve

keep if year ==2012
tabstat total_qty_w subsidy_qty_w  yhat dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_credit informal_credit ext_acess attend_sch safety_net  formal_save soil_qty_rev2 org_fert [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore





************************** descriptive statistics of  variables in first survey (2014)
preserve

keep if year ==2014
tabstat total_qty_w subsidy_qty_w  yhat dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_credit informal_credit ext_acess attend_sch safety_net  formal_save soil_qty_rev2 org_fert [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore



************************** descriptive statistics of  variables in second survey (20202)
preserve

keep if year ==2020
tabstat total_qty_w subsidy_qty_w  yhat dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_credit informal_credit ext_acess attend_sch safety_net  formal_save soil_qty_rev2 org_fert [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore

*************************************************************************************************************************************************************
*************************************************************************************************************************************************************









********************Median***************** 
*************************************************************************************************************************************************************

use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014\panell\complete_panel5.dta", clear
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014\panell\Nominal_panel5.dta", clear


************************** descriptive statistics of  variables in first survey (2010)
preserve

keep if year ==2010
tabstat total_qty_w subsidy_qty_w  real_tpricefert_cens_mrk dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_credit informal_credit ext_acess attend_sch safety_net  formal_save soil_qty_rev2 org_fert [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore



************************** descriptive statistics of  variables in second survey (2012)
preserve

keep if year ==2012
tabstat total_qty_w subsidy_qty_w  real_tpricefert_cens_mrk dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_credit informal_credit ext_acess attend_sch safety_net  formal_save soil_qty_rev2 org_fert [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore





************************** descriptive statistics of  variables in first survey (2014)
preserve

keep if year ==2014
tabstat total_qty_w subsidy_qty_w  real_tpricefert_cens_mrk dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_credit informal_credit ext_acess attend_sch safety_net  formal_save soil_qty_rev2 org_fert [aweight = weight], statistics( mean median sd min max ) columns(statistics)

restore



************************** descriptive statistics of  variables in second survey (20202)
preserve

keep if year ==2020
tabstat total_qty_w subsidy_qty_w  real_tpricefert_cens_mrk dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_credit informal_credit ext_acess attend_sch safety_net  formal_save soil_qty_rev2 org_fert [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore
*************************************************************************************************************************************************************
*************************************************************************************************************************************************************
