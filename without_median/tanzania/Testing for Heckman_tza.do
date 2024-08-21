

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

** OLS **
*reg total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 i.region i.year







heckman real_tpricefert_cens_mrk subsidy_qty_w  dist_cens_w real_maize_price_mr real_rice_price_mr  field_size_ha_w ext_acess attend_sch i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2  i.year) twostep


predict yhat, xb


*tab yhat, missing

sum yhat [aw= weight], detail



*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_yhat TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_subsidy_dummy TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w subsidy_qty_w dist_cens_w yhat num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)




*median
** CRE-TOBIT 
tobit total_qty_w real_tpricefert_cens_mrk  subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_subsidy_dummy TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)


********************************************
*Using Functional Forms
********************************************



gen lyhat = log(yhat)
replace total_qty_w =1 if total_qty_w==0
gen ltotal_qty_w = log(total_qty_w)

local time_avg "lyhat ltotal_qty_w"

foreach x in `time_avg' {

	bysort UPHI : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit ltotal_qty_w lyhat subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_ltotal_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_lyhat TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_subsidy_dummy TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post









*
****************************
*Commercial Analysis
****************************

	
//% of HHs that bought commercial fertilizer by each survey wave
bysort year : tabstat commercial_dummy [w=weight], stat(mean sem)

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort hhid : egen sum_4waves_com_fer_bin = sum(commercial_dummy) 







*********************************
*Bootstrapping
*********************************


capture program drop APEboot
program define APEboot, rclass
	preserve
	
heckman real_tpricefert_cens_mrk subsidy_qty_w  dist_cens_w real_maize_price_mr real_rice_price_mr  field_size_ha_w ext_acess attend_sch i.year, select (commercial_dummy= subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2  i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail


tabstat total_qty_w subsidy_qty_w dist_cens_w yhat num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}	


** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_yhat TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_subsidy_dummy TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post
	
return scalar ape_xj =r(mean)
	restore
end
bootstrap crowd_out_est = r(ape_xj), reps(250) cluster(UPHI) idcluster(newid): APEboot




	craggit commercial_dummy yhat subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_yhat TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020, second(total_qty_w yhat subsidy_qty_w dist_cens_w num_mem hh_headage_mrk real_hhvalue worker real_maize_price_mr real_rice_price_mr  field_size_ha_w femhead formal_save formal_bank formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_dist_cens_w TAvg_yhat TAvg_num_mem TAvg_hh_headage_mrk TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_field_size_ha_w TAvg_femhead TAvg_formal_save TAvg_formal_bank TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 TAvg_soil_qty_rev2 year_2010 year_2012 year_2014 year_2020) cluster(UPHI)

	predict bsx1g, eq(Tier1)
	predict bsx2b, eq(Tier2)
	predict  bssigma , eq(sigma)
	generate bsIMR = normalden(bsx2b/bssigma)/normal(bsx2b/bssigma)
	generate bsdEy_dxj = 												///
				[Tier1]_b[yhat]*normalden(bsx1g)*(bsx2b+bssigma*bsIMR) ///
				+[Tier2]_b[yhat]*normal(bsx1g)*(1-bsIMR*(bsx2b/bssigma+bsIMR))
	summarize bsdEy_dxj
	
	return scalar ape_xj =r(mean)
	matrix ape_xj=r(ape_xj)




	
	
	
	
	
	
	
	
	
	



************************** descriptive statistics of  variables in first survey (2010)
preserve

keep if year ==2010
tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



************************** descriptive statistics of  variables in second survey (2012)
preserve

keep if year ==2012
tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)



restore





************************** descriptive statistics of  variables in first survey (2014)
preserve

keep if year ==2014
tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore



************************** descriptive statistics of  variables in second survey (20202)
preserve

keep if year ==2020
tabstat total_qty_w subsidy_qty_w dist_cens_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker real_maize_price_mr real_rice_price_mr real_hhvalue field_size_ha_w [aweight = weight], statistics( mean median sd min max ) columns(statistics)


restore
