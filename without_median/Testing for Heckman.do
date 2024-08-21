




*use "C:\Users\obine\Music\Documents\Project\codes\without_median\Real_heckman.dta", clear

use "C:\Users\obine\Music\Documents\Project\codes\without_median\Nominal_heckman.dta", clear


gen dummy = 1

collapse (sum) dummy, by (hhid)
tab dummy
keep if dummy==4
sort hhid

*save "C:\Users\obine\Music\Documents\Project\codes\without_median/subset_Real_heckman", replace
save "C:\Users\obine\Music\Documents\Project\codes\without_median/subset_Nominal_heckman", replace


*merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\without_median\Real_heckman.dta"
merge 1:m hhid using "C:\Users\obine\Music\Documents\Project\codes\without_median\Nominal_heckman.dta"

drop if _merge==2

*save "C:\Users\obine\Music\Documents\Project\codes\without_median\Real_heckman.dta", replace
save "C:\Users\obine\Music\Documents\Project\codes\without_median\Nominal_heckman.dta", replace


gen year_2010 = (year==2010)
gen year_2012 = (year==2012)
gen year_2015 = (year==2015)
gen year_2018 = (year==2018)

gen commercial_dummy = (total_qty_w>0)

tab commercial_dummy


tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
misstable summarize total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2


sum real_tpricefert_cens_mrk, detail




*save "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Real_heckman.dta", replace
save "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Nominal_heckman.dta", replace





*use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Real_heckman.dta", clear
use  "C:\Users\obine\Music\Documents\Project\codes\without_median\complete\Nominal_heckman.dta", clear






tabstat total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)
misstable summarize total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2

sum real_tpricefert_cens_mrk, detail


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk subsidy_qty_w  mrk_dist_w real_maize_price_mr real_rice_price_mr  land_holding ext_acess attend_sch i.zone  i.year, select (commercial_dummy= subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 i.zone  i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail



*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w subsidy_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*/






*********************************
*Bootstrapping
*********************************
capture program drop APEboot
program define APEboot, rclass
	preserve
	
	

heckman real_tpricefert_cens_mrk subsidy_qty_w  mrk_dist_w real_maize_price_mr real_rice_price_mr  land_holding ext_acess attend_sch i.zone  i.year, select (commercial_dummy= subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 i.zone  i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}



	craggit commercial_dummy yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 year_2010 year_2012 year_2015 year_2018, second(total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_yhat TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 year_2010 year_2012 year_2015 year_2018) cluster(hhid)




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
	restore
end
bootstrap crowd_out_est = r(ape_xj), reps(250) cluster(hhid) idcluster(newid): APEboot

*/












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


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk subsidy_qty_w  mrk_dist_w real_maize_price_mr real_rice_price_mr  land_holding ext_acess attend_sch i.zone  i.year, select (commercial_dummy= subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 i.zone  i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail


tabstat total_qty_w subsidy_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post



restore




preserve  //south

keep if  zone== 4 | zone==5 | zone==6


local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk subsidy_qty_w  mrk_dist_w real_maize_price_mr real_rice_price_mr  land_holding ext_acess attend_sch i.zone  i.year, select (commercial_dummy= subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 i.zone  i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail


tabstat total_qty_w subsidy_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w yhat subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post




restore






