
*Heckman
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Real_heckman.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Nominal_heckman.dta", clear



*Median
use  "C:\Users\obine\Music\Documents\Project\codes\Nigeria\complete\Real_median.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\Nigeria\complete\Nominal_median.dta", clear




tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
egen med_zone = median (zone)
replace zone = med_zone if zone ==.
misstable summarize total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 zone year





sum real_tpricefert_cens_mrk, detail


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


****************************************************************



capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


 heckman real_tpricefert_cens_mrk subsidy_qty_w  mrk_dist_w real_maize_price_mr real_rice_price_mr  land_holding femhead informal_save formal_credit informal_credit ext_acess  i.year, select (commercial_dummy= mrk_dist_w subsidy_qty_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch safety_net net_seller net_buyer soil_qty_rev2 i.year) twostep


predict yhat, xb


gen lyhat = log(yhat)
*replace total_qty_w = 1 if total_qty_w==0
gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w mrk_dist_w hh_headage real_hhvalue real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch safety_net net_seller net_buyer soil_qty_rev2 TAvg_ltotal_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_lyhat TAvg_hh_headage TAvg_real_hhvalue TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot



tobit total_qty_w yhat subsidy_qty_w mrk_dist_w   femhead  ext_acess attend_sch TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_yhat mrk_dist_w TAvg_femhead TAvg_ext_acess TAvg_attend_sch  i.year, ll(0)


tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)






**********************************************

*Heckman Log
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Real_heckman.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Nominal_heckman.dta", clear






tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
egen med_zone = median (zone)
replace zone = med_zone if zone ==.
misstable summarize total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 zone year


replace hh_headage = 72 if hh_headage >72
gen lland_holding = log(land_holding)
gen lreal_hhvalue = log(real_hhvalue + 1)


sum real_tpricefert_cens_mrk, detail


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 lland_holding lreal_hhvalue"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

*************Model sig



capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


 heckman real_tpricefert_cens_mrk subsidy_qty_w hh_headage mrk_dist_w real_maize_price_mr real_rice_price_mr lland_holding ext_acess   year_2010 year_2012 year_2015 year_2018, select (commercial_dummy= mrk_dist_w subsidy_qty_w  hh_headage lreal_hhvalue real_maize_price_mr real_rice_price_mr lland_holding femhead ext_acess attend_sch safety_net soil_qty_rev2  year_2010 year_2012 year_2015 year_2018) twostep


predict yhat, xb


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
tobit ltotal_qty_w lyhat subsidy_qty_w mrk_dist_w  ext_acess attend_sch safety_net femhead real_rice_price_mr lland_holding lreal_hhvalue soil_qty_rev2 hh_headage TAvg_ltotal_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_lyhat TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_femhead  TAvg_real_rice_price_mr TAvg_lland_holding TAvg_lreal_hhvalue TAvg_soil_qty_rev2 TAvg_hh_headage i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Log3_real_heckman_original.doc", replace word

outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Log3_nominal_heckman.doc", replace word



tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)



**********************************************

*Heckman level
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Real_heckman.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Nominal_heckman.dta", clear






tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
egen med_zone = median (zone)
replace zone = med_zone if zone ==.
misstable summarize total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 zone year


gen lland_holding = log(land_holding)
gen lreal_hhvalue = log(real_hhvalue + 1)


sum real_tpricefert_cens_mrk, detail


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 lland_holding lreal_hhvalue"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

*************Model sig



capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


 heckman real_tpricefert_cens_mrk subsidy_qty_w hh_headage mrk_dist_w real_maize_price_mr real_rice_price_mr lland_holding ext_acess   year_2010 year_2012 year_2015 year_2018, select (commercial_dummy= mrk_dist_w subsidy_qty_w  hh_headage lreal_hhvalue real_maize_price_mr real_rice_price_mr lland_holding femhead ext_acess attend_sch safety_net soil_qty_rev2  year_2010 year_2012 year_2015 year_2018) twostep


predict yhat, xb


*sum yhat, detail

local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w mrk_dist_w  ext_acess attend_sch safety_net femhead real_rice_price_mr lland_holding lreal_hhvalue TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_femhead  TAvg_real_rice_price_mr TAvg_lland_holding TAvg_lreal_hhvalue i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot


outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Level__heckman.doc", replace word
outreg2 using "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Level1__nominal_heckman.doc", replace word


tabstat total_qty_w subsidy_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


/*
est drop _all
reg treat age female education_dummy hhsize hhsize04 hhsickeye incomehh_w biofknow breadl7dbuyprice breadl7dbuynum ikotunmkt, robust
est store m1
esttab m* using "C:\Users\USER\OneDrive\Desktop\OFSP 11\Table01.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f))) 
estat ovtest

*export table
esttab m* using "C:\Users\USER\OneDrive\Desktop\OFSP 11\Table33.regression.rtf", label replace cells(b(star fmt(%9.0f)) se(par fmt(%9.0f)))

*/

tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)































































***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 
 
 heckman real_tpricefert_cens_mrk subsidy_qty_w  mrk_dist_w real_maize_price_mr real_rice_price_mr  land_holding femhead informal_save formal_credit informal_credit ext_acess  i.year, select (commercial_dummy= mrk_dist_w subsidy_qty_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch safety_net net_seller net_buyer soil_qty_rev2 i.year) twostep

predict yhat, xb



local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w subsidy_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)







tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)













************************working on ************************

*Heckman
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Real_heckman.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Nominal_heckman.dta", clear






tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
egen med_zone = median (zone)
replace zone = med_zone if zone ==.
misstable summarize total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 zone year





sum real_tpricefert_cens_mrk, detail


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


***********************************************************
*Tobit Bootstrap
***********************************************************




capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


 heckman real_tpricefert_cens_mrk subsidy_qty_w hh_headage mrk_dist_w real_maize_price_mr real_rice_price_mr land_holding ext_acess   year_2010 year_2012 year_2015 year_2018, select (commercial_dummy= mrk_dist_w subsidy_qty_w  hh_headage real_hhvalue real_maize_price_mr real_rice_price_mr land_holding femhead ext_acess attend_sch safety_net soil_qty_rev2  year_2010 year_2012 year_2015 year_2018) twostep


predict yhat, xb



local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w mrk_dist_w  ext_acess attend_sch safety_net femhead real_rice_price_mr land_holding TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_femhead  TAvg_real_rice_price_mr TAvg_land_holding i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w subsidy_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)




***********3*******************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


 heckman real_tpricefert_cens_mrk subsidy_qty_w hh_headage mrk_dist_w real_maize_price_mr real_rice_price_mr land_holding ext_acess   year_2010 year_2012 year_2015 year_2018, select (commercial_dummy= mrk_dist_w subsidy_qty_w  hh_headage real_hhvalue real_maize_price_mr real_rice_price_mr land_holding femhead ext_acess attend_sch safety_net soil_qty_rev2  year_2010 year_2012 year_2015 year_2018) twostep


predict yhat, xb



local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w mrk_dist_w  ext_acess attend_sch safety_net femhead real_rice_price_mr land_holding real_hhvalue TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_femhead  TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot




***********four*******************

capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


 heckman real_tpricefert_cens_mrk subsidy_qty_w hh_headage mrk_dist_w real_maize_price_mr real_rice_price_mr real_hhvalue land_holding ext_acess   year_2010 year_2012 year_2015 year_2018, select (commercial_dummy= mrk_dist_w subsidy_qty_w  hh_headage real_hhvalue real_maize_price_mr real_rice_price_mr land_holding femhead ext_acess attend_sch safety_net soil_qty_rev2  year_2010 year_2012 year_2015 year_2018) twostep


predict yhat, xb



local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w mrk_dist_w  ext_acess attend_sch safety_net femhead real_rice_price_mr land_holding real_hhvalue TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_femhead  TAvg_real_rice_price_mr TAvg_land_holding TAvg_real_hhvalue i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot



tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)




























































































































*Median
** CRE-TOBIT 
tobit total_qty_w real_tpricefert_cens_mrk subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)











****************************
*Commercial Analysis
****************************

	
//% of HHs that bought commercial fertilizer by each survey wave
bysort year : tabstat commercial_dummy [w=weight], stat(mean sem)

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort hhid : egen sum_4waves_com_fer_bin = sum(commercial_dummy) 






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







**********************
*Bootstraping more than one variable  (Correct!)
************************
* Modified Tobit model bootstrapping program with 4 marginal effects

* Step 1: Define the program for Tobit estimation and margins calculation
capture program drop boot_tobit	
program define boot_tobit, rclass
    * Step 2: Fit the Tobit model
tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)
   
    * Step 3: Calculate marginal effects
    margins, predict(ystar(0,.)) dydx(*) post
    
    * Step 4: Return the marginal effects for four variables
    return scalar dydx_yhat = _b[yhat]
    return scalar dydx_mrk_dist_w = _b[mrk_dist_w]
    return scalar dydx_num_mem = _b[num_mem]
    return scalar dydx_hh_headage = _b[hh_headage]
end

* Step 5: Use bootstrap to resample and calculate margins
bootstrap r(dydx_yhat) r(dydx_mrk_dist_w) r(dydx_num_mem) r(dydx_hh_headage), reps(100) seed(123) cluster(hhid) idcluster(newid) saving(bootstrap_results, replace): boot_tobit

tabstat total_qty_w subsidy_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)



































*************Model sig


capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


 heckman real_tpricefert_cens_mrk subsidy_qty_w hh_headage mrk_dist_w real_maize_price_mr real_rice_price_mr land_holding ext_acess   year_2010 year_2012 year_2015 year_2018, select (commercial_dummy= mrk_dist_w subsidy_qty_w hh_headage real_hhvalue real_maize_price_mr real_rice_price_mr land_holding femhead ext_acess attend_sch safety_net net_seller net_buyer soil_qty_rev2  year_2010 year_2012 year_2015 year_2018) twostep


predict yhat, xb


sum yhat, detail


gen lyhat = log(yhat)
*replace total_qty_w = 1 if total_qty_w==0
gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w mrk_dist_w  ext_acess attend_sch safety_net TAvg_ltotal_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_lyhat TAvg_ext_acess TAvg_attend_sch TAvg_safety_net i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot
