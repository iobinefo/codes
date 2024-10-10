
*Median*
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014\panell\complete_panel5.dta", clear
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\tza_wave2014\panell\Nominal_panel5.dta", clear



*Heckman*
use "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\complete_panel5.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\without_median\tanzania\Nominal_panel5.dta", clear













tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)


misstable summarize subsidy_dummy femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w

sum real_tpricefert_cens_mrk, detail

local time_avg "total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w  subsidy_dummy femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}







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
 

heckman real_tpricefert_cens_mrk subsidy_qty_w  dist_cens_w real_maize_price_mr real_rice_price_mr  field_size_ha_w ext_acess attend_sch i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2  i.year) twostep



predict double xb if e(sample), xb
gen double yhat = `depvar' - xb if e(sample)

local time_avg "yhat"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}

tobit total_qty_w yhat subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_yhat TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_subsidy_dummy TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.year, ll(0)



keep if e(sample)


margins, predict(ystar(0,.)) dydx(*)
restore
end

bootstrap, reps(100) seed(123) cluster(UPHI) idcluster(newid): myboot
margins, predict(ystar(0,.)) dydx(*) post
