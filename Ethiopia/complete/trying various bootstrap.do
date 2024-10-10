
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_heckman15.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_heckman15.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Real_price21.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\complete\Nominal_price21.dta", clear


tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr informal_save pry_edu finish_pry finish_sec net_seller net_buyer 


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer  region

sum real_tpricefert_cens_mrk, detail

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}





capture program drop myboot	
program define myboot, rclass
** CRE-TOBIT
 preserve 


heckman real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr land_holding attend_sch femhead formal_credit informal_credit ext_acess i.zones  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer i.region  i.year) twostep


predict yhat, xb


gen lyhat = log(yhat)



gen ltotal_qty_w = log(total_qty_w + 1)

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit ltotal_qty_w mrk_dist_w lyhat real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_ltotal_qty_w TAvg_mrk_dist_w TAvg_lyhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer i.region i.year, ll(0)





margins, predict(ystar(0,.)) dydx(*) post

restore
end
bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot














***********************************************************
*Tobit Bootstrap
***********************************************************
capture program drop myboot
program define myboot, rclass
** CRE-TOBIT
preserve 

heckman real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr land_holding attend_sch femhead formal_credit informal_credit ext_acess i.zones  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer i.region  i.year) twostep


predict yhat, xb


*sum yhat [aw= weight], detail

local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

tobit total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr net_seller net_buyer num_mem hh_headage real_hhvalue worker land_holding femhead formal_credit informal_credit ext_acess attend_sch  safety_net soil_qty_rev2 TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_safety_net TAvg_soil_qty_rev2 TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_net_seller TAvg_net_buyer i.region i.year, ll(0)





margins, predict(ystar(0,.)) dydx(*) post
restore
end

bootstrap, reps(100) seed(123) cluster(hhid) idcluster(newid): myboot

tabstat total_qty_w mrk_dist_w yhat real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
