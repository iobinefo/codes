





clear

global Ethiopia_GHS_W5_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2021_ESPS-W5_v01_M_Stata"
global Ethiopia_GHS_W5_created_data     "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Ethiopia_wave5"





********************************************************************************
* AG FILTER *
********************************************************************************

use "${Ethiopia_GHS_W5_raw_data}\sect3_pp_w5.dta",clear  

ren household_id hhid
gen ag_rainy_21 = (s3q03==1)

collapse (max) ag_rainy_21, by (hhid)
tab ag_rainy_21
save  "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", replace



*merge m:1 hhid using "${Nigeria_GHS_W2_created_data}/ag_rainy_12.dta", gen(filter)

*keep if ag_rainy_12==1

/*
********************************************************************************
*Maize_filter
********************************************************************************

use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Planting Wave 2\Agriculture\sect11e_plantingw2.dta" , clear

gen maize_12 = 1 if cropcode==1080
replace maize_12=0 if maize_12 ==.

tab maize_12
collapse (max)  maize_12, by (hhid)



save  "${Nigeria_GHS_W2_created_data}/maize_12.dta", replace








************************
*Geodata Variables
************************

use "${Nigeria_GHS_W2_raw_data}\Geodata Wave 2\NGA_PlotGeovariables_Y2.dta", clear

merge m:1 hhid using "${Nigeria_GHS_W2_created_data}/ag_rainy_12.dta", gen(filter)

keep if ag_rainy_12==1

merge m:1 hhid using "${Nigeria_GHS_W2_created_data}/maize_12.dta", gen(maize)

keep if maize_12==1

ren srtmslp_nga plot_slope
ren srtm_nga  plot_elevation
ren twi_nga   plot_wetness

tab1 plot_slope plot_elevation plot_wetness, missing

/*egen med_slope = median( plot_slope)
egen med_elevation = median( plot_elevation)
egen med_wetness = median( plot_wetness)

replace plot_slope= med_slope if plot_slope==.
replace plot_elevation= med_elevation if plot_elevation==.
replace plot_wetness= med_wetness if plot_wetness==.*/

collapse (sum) plot_slope plot_elevation plot_wetness, by (hhid)
sort hhid
la var plot_slope "slope of plot"
la var plot_elevation "Elevation of plot"
la var plot_wetness "Potential wetness index of plot"
save "${Nigeria_GHS_W2_created_data}\geodata_2012.dta", replace

*/





*********************************************** 
*Purchased Fertilizer
***********************************************

use "${Ethiopia_GHS_W5_raw_data}\sect3_pp_w5.dta",clear  

ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1


*s3q21c   	qty commercial urea
*s3q21d 		value commercial urea

*s3q22c   	qty commercial DAP
*s3q22d  	value commercial DAP

*pp_s3q20c  	value commercial urea

sum s3q21c, detail
sum s3q21d, detail

sum s3q22c, detail
sum s3q22d, detail


***fertilzer total quantity, total value & total price****


egen total_qty = rowtotal(s3q21c s3q22c s3q23c s3q24c) // all are already in kg (Urea & DAP), questionnaire doesn't ask how much other inorg fert was used on the field, but only 30 plots used other fert (3,771 used Urea and 5,047 used DAP) 
tab  total_qty, missing
sum total_qty, detail

egen total_valuefert = rowtotal(s3q21d s3q22d s3q23d s3q24c)
tab total_valuefert,missing
sum total_valuefert, detail


gen tpricefert = total_valuefert/total_qty
tab tpricefert
sum tpricefert, detail



gen tpricefert_cens = tpricefert
replace tpricefert_cens = 80 if tpricefert_cens > 80 & tpricefert_cens < . //winzorizing at bottom 1%
replace tpricefert_cens = 1 if tpricefert_cens < 1
tab tpricefert_cens, missing  //winzorizing at top 1%

*replace tpricefert_cens= 0 if tpricefert_cens==.
*tab tpricefert_cens, missing 

*sum tpricefert_cens, detail
*gen tpricefert_cens_mrk = tpricefert_cens



************generating the median age**************

list ea_id if real(ea_id) == .
gen ea = real(regexr(ea_id, "[^0-9.]", ""))

list saq03 if real(saq03) == .
gen woreda = real(regexr(saq03, "[^0-9.]", ""))

list saq02 if real(saq02) == .
gen zones = real(regexr(saq02, "[^0-9.]", ""))

ren saq01 region



egen medianfert_pr_ea = median(tpricefert_cens), by (ea)
egen num_fert_pr_ea = count(tpricefert_cens), by (ea)

egen medianfert_pr_woreda = median(tpricefert_cens), by (woreda)
egen num_fert_pr_woreda = count(tpricefert_cens), by (woreda)

egen medianfert_pr_zone = median(tpricefert_cens), by (zone)
egen num_fert_pr_zone = count(tpricefert_cens), by (zone)

egen medianfert_pr_region = median(tpricefert_cens), by (region)
egen num_fert_pr_region = count(tpricefert_cens), by (region)




tab medianfert_pr_ea
tab medianfert_pr_woreda
tab medianfert_pr_zone
tab medianfert_pr_region



tab num_fert_pr_ea
tab num_fert_pr_woreda
tab num_fert_pr_zone
tab num_fert_pr_region

gen tpricefert_cens_mrk = tpricefert_cens

replace tpricefert_cens_mrk = medianfert_pr_ea if tpricefert_cens_mrk ==. & num_fert_pr_ea >= 75

tab tpricefert_cens_mrk,missing


replace tpricefert_cens_mrk = medianfert_pr_woreda if tpricefert_cens_mrk ==. & num_fert_pr_woreda >= 376

tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_zone if tpricefert_cens_mrk ==. & num_fert_pr_zone >= 306

tab tpricefert_cens_mrk,missing


replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. 

tab tpricefert_cens_mrk,missing
*/
ren pw_w5 weight

collapse region zone woreda ea (sum) total_qty total_valuefert (max) weight tpricefert_cens_mrk, by(hhid)


merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1


sum tpricefert_cens_mrk, detail

************winzonrizing total_qty
foreach v of varlist  total_qty  {
	_pctile `v' [aw=weight] , p(1 99) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}


tab total_qty
tab total_qty_w, missing
sum total_qty total_qty_w, detail


/*

************winzonrizing fertilizer market price
foreach v of varlist  tpricefert_cens_mrk  {
	_pctile `v' [aw=weight] , p(5 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}

*/
tab tpricefert_cens_mrk, missing
gen rea_tpricefert_cens_mrk = tpricefert_cens_mrk
gen real_tpricefert_cens_mrk = rea_tpricefert_cens_mrk
tab real_tpricefert_cens_mrk
sum real_tpricefert_cens_mrk, detail


keep hhid region zone woreda ea total_qty_w total_valuefert real_tpricefert_cens_mrk



label var total_qty_w "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var real_tpricefert_cens_mrk "price of commercial fertilizer purchased in naira"
sort hhid
save "${Ethiopia_GHS_W5_created_data}\purchased_fert_2021.dta", replace


/*
************************************************
*Savings 
************************************************

use "${Ethiopia_GHS_W4_raw_data}/sect5a_hh_w4.dta", clear



ren household_id2 hhid
merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1
*s4aq1  1= formal bank
*s4aq9b s4aq9d s4aq9f  types of formal fin institute used to save money
*s4aq10 1= informal saving



ren s4aq1 formal_bank
tab formal_bank, missing
replace formal_bank =0 if formal_bank ==2 | formal_bank ==.
tab formal_bank, nolabel
tab formal_bank,missing

 gen formal_save = 1 if s4aq9b !=. | s4aq9d !=.| s4aq9f !=.
 tab formal_save, missing
 replace formal_save = 0 if formal_save ==.
 tab formal_save, missing

 ren s4aq10 informal_save
 tab informal_save, missing
 replace informal_save =0 if informal_save ==2 | informal_save ==.
 tab informal_save, missing

 collapse (max) formal_bank formal_save informal_save, by (hhid)
 la var formal_bank "=1 if respondent have an account in bank"
 la var formal_save "=1 if used formal saving group"
 la var informal_save "=1 if used informal saving group"
save "${Nigeria_GHS_W2_created_data}\savings_2012.dta", replace
*/




************************************************
*Credit Access
************************************************


use "${Ethiopia_GHS_W5_raw_data}/sect7_pp_w5.dta", clear

*s7q07  types of formal fin institute used to borrow money
ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1
tab s7q06  //=1 yes 
tab s7q07  //where you got it
tab s7q07 , nolabel

gen formal_credit =1 if s7q07 ==1 |  s7q07 ==2
tab formal_credit,missing
replace formal_credit =0 if formal_credit ==.
tab formal_credit,missing

gen informal_credit = 1 if s7q07==3 |  s7q07==4 |s7q07==5 
tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
tab informal_credit,missing

collapse (max) formal_credit informal_credit, by (hhid)
tab informal_credit,missing
tab formal_credit,missing
la var formal_credit "=1 if borrowed from formal credit group"
la var informal_credit "=1 if borrowed from informal credit group"
save "${Ethiopia_GHS_W5_created_data}\credit_2021.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${Ethiopia_GHS_W5_raw_data}/sect3_pp_w5.dta", clear

merge m:m household_id using "${Ethiopia_GHS_W5_raw_data}/sect7_pp_w5.dta", nogen

tab s3q16
tab s7q04

gen ext_acess=0
replace ext_acess=1 if s3q16==1 | s7q04==1
ren household_id hhid
collapse (max) ext_acess, by (hhid)
lab var ext_acess "1= Household reached by extention services"

merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1
tab ext_acess

save "${Ethiopia_GHS_W5_created_data}\extension_visit_2021.dta", replace












********************************************************************************
*market_distance
********************************************************************************


use "${Ethiopia_GHS_W5_raw_data}\sect04_com_w5.dta", clear


*cs4q15   distance to nearest weekly market in km
sum  cs4q15, detail
ren cs4q15 mrk_dist 
tab mrk_dist,missing

ren ea_id ea
ren saq03 woreda
ren saq02 zones
ren saq01 region



egen median_ea = median(mrk_dist), by (region zones woreda ea)
egen median_woreda = median(mrk_dist), by (region zones woreda)

egen median_zones = median(mrk_dist), by (region zones)
egen median_region = median(mrk_dist), by (region)


replace mrk_dist = median_ea if mrk_dist==. 
replace mrk_dist = median_woreda if mrk_dist==.
replace mrk_dist = median_zones if mrk_dist==. 
replace mrk_dist = median_region if mrk_dist==. 

tab mrk_dist, missing



sort region zones woreda ea
collapse (max) median_ea median_woreda median_zones median_region mrk_dist, by (region zones woreda ea)

tab mrk_dist, missing
sum mrk_dist, detail
la var mrk_dist "=distance to the market"

save "${Ethiopia_GHS_W5_created_data}\market_distance.dta", replace 






*********************************
*Demographics 
*********************************

use "${Ethiopia_GHS_W5_raw_data}\sect1_hh_w5.dta",clear 

ren ea_id ea
ren saq03 woreda
ren saq02 zones
ren saq01 region

merge 1:1 household_id individual_id using "${Ethiopia_GHS_W5_raw_data}\sect2_hh_w5.dta", gen(household)

merge m:1 region zones woreda ea using "${Ethiopia_GHS_W5_created_data}\market_distance.dta", keepusing (median_ea median_woreda median_zones median_region mrk_dist)

ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1

**************
*market distance
*************
tab mrk_dist, missing

egen median_dist = median(mrk_dist)

replace mrk_dist = median_dist if mrk_dist==.
tab mrk_dist, missing


*s1q02   sex
*s1q01    relationship to hhead
*s1q03a    age in years
*s2q04   attend_sch dummy
*s2q06  highest level of education
 
tab s1q02
tab s1q01
sum s1q03a, detail
tab s2q04
tab s2q06
gen num_mem = 1



******** female head****

gen femhead = 0
replace femhead = 1 if s1q02== 2 & s1q01==1
tab femhead,missing

********Age of HHead***********
ren s1q03a hh_age
gen hh_headage = hh_age if s1q01 ==1

tab hh_headage
sum hh_headage, detail

tab hh_headage, missing

************generating the median age**************



egen medianhh_pr_ea = median(hh_headage), by (ea)
egen num_hh_pr_ea = count(hh_headage), by (ea)


egen medianhh_pr_woreda = median(hh_headage), by (woreda)
egen num_hh_pr_woreda = count(hh_headage), by (woreda)

egen medianhh_pr_zone = median(hh_headage), by (zone)
egen num_hh_pr_zone = count(hh_headage), by (zone)

egen medianhh_pr_region = median(hh_headage), by (region)
egen num_hh_pr_region = count(hh_headage), by (region)


tab medianhh_pr_ea
tab medianhh_pr_woreda
tab medianhh_pr_zone
tab medianhh_pr_region



tab num_hh_pr_ea
tab num_hh_pr_woreda
tab num_hh_pr_zone
tab num_hh_pr_region



replace hh_headage = medianhh_pr_ea if hh_headage ==. & num_hh_pr_ea >= 11

tab hh_headage,missing


replace hh_headage = medianhh_pr_woreda if hh_headage ==. & num_hh_pr_woreda >= 239

tab hh_headage,missing



replace hh_headage = medianhh_pr_zone if hh_headage ==. & num_hh_pr_zone >= 132

tab hh_headage,missing


replace hh_headage = medianhh_pr_region if hh_headage ==. 

tab hh_headage,missing

sum hh_headage, detail


********************Education****************************************************

*s1q01    relationship to hhead
*s2q04   attend_sch dummy
*s2q06  highest level of education
 
 
tab s2q04


gen attend_sch = 1 if s2q04==1 & s1q01==1
replace attend_sch =0 if attend_sch==.
tab attend_sch, missing

tab attend_sch, nolabel
*tab s1q4 if s2q7==.



/*
replace s2q8= 0 if attend_sch==0
tab s2q8
tab s1q3 if _merge==1

tab s2q8 if s1q3==1
replace s2q8 = 16 if s2q8==. &  s1q3==1

*** Education Dummy Variable*****

 label list S2Q8

gen pry_edu = 1 if s2q8 >= 1 & s2q8 < 16 & s1q3==1
gen finish_pry = 1 if s2q8 >= 16 & s2q8 < 26 & s1q3==1
gen finish_sec = 1 if s2q8 >= 26 & s2q8 < 43 & s1q3==1

replace pry_edu =0 if pry_edu==. & s1q3==1
replace finish_pry =0 if finish_pry==. & s1q3==1
replace finish_sec =0 if finish_sec==. & s1q3==1
tab pry_edu if s1q3==1 , missing
tab finish_pry if s1q3==1 , missing 
tab finish_sec if s1q3==1 , missing
*/

ren pw_w5 weight
collapse (sum) num_mem (max) attend_sch weight mrk_dist hh_headage femhead , by (hhid)
 *pry_edu finish_pry finish_sec

merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1



tab mrk_dist
************winzonrizing distance to market
foreach v of varlist  mrk_dist  {
	_pctile `v' [aw=weight] , p(1 99) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}


tab mrk_dist
tab mrk_dist_w, missing
sum mrk_dist mrk_dist_w, detail



/*
tab attend_sch, missing
egen mid_attend= median(attend_sch)
replace attend_sch = mid_attend if attend_sch==.

tab pry_edu, missing
tab finish_pry, missing
tab finish_sec, missing

egen mid_pry_edu= median(pry_edu)
egen mid_finish_pry= median(finish_pry)
egen mid_finish_sec= median(finish_sec)

replace pry_edu = mid_pry_edu if pry_edu==.
replace finish_pry = mid_finish_pry if finish_pry==.
replace finish_sec = mid_finish_sec if finish_sec==.
*/


la var num_mem "household size"
la var mrk_dist_w "distance to the nearest market in km"
la var femhead "=1 if head is female"
la var hh_headage "age of household head in years"
la var attend_sch "=1 if respondent attended school"
*la var pry_edu "=1 if household head attended pry school"
*la var finish_pry "=1 if household head finished pry school"
*la var finish_sec "=1 if household head finished sec school"
save "${Ethiopia_GHS_W5_created_data}\demographics_2021.dta", replace

********************************* 
*Labor Age 
*********************************
use "${Ethiopia_GHS_W5_raw_data}\sect1_hh_w5.dta",clear 

ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1


*s1q03a    age in years

ren s1q03a hh_age

gen worker = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort hhid worker
collapse (sum) worker, by (hhid)
la var worker "number of members age 15 and older and less than 65"
sort hhid
tab worker,missing
save "${Ethiopia_GHS_W5_created_data}\labor_age_2021.dta", replace


********************************
*Safety Net
********************************

use "${Ethiopia_GHS_W5_raw_data}\sect14_hh_w5.dta",clear 





merge m:m household_id using "${Ethiopia_GHS_W5_raw_data}\sect13_hh_w5", gen(safety)
ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1
tab s14q01 , nolabel
tab s13q01 , nolabel


gen safety_net =1  if s14q01==1 | s13q01 ==1 
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (hhid)










tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${Ethiopia_GHS_W5_created_data}\safety_net_2021.dta", replace

/*
**************************************
*Food Prices
**************************************
use "${Nigeria_GHS_W2_raw_data}\Post Harvest Wave 2\Community\sectc8_harvestw2.dta", clear



gen maize_price=c8q2 if item_cd==3
tab maize_price,missing
sum maize_price,detail
tab maize_price

replace maize_price = 900 if maize_price >900 & maize_price<.  //bottom 2%
*replace maize_price = 10 if maize_price< 10        ////top 5%



egen median_pr_ea = median(maize_price), by (ea)
egen median_pr_lga = median(maize_price), by (lga)
egen median_pr_state = median(maize_price), by (state)
egen median_pr_zone = median(maize_price), by (zone)

egen num_pr_ea = count(maize_price), by (ea)
egen num_pr_lga = count(maize_price), by (lga)
egen num_pr_state = count(maize_price), by (state)
egen num_pr_zone = count(maize_price), by (zone)

tab num_pr_ea
tab num_pr_lga
tab num_pr_state
tab num_pr_zone


gen maize_price_mr = maize_price

replace maize_price_mr = median_pr_ea if maize_price_mr==. & num_pr_ea>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_lga if maize_price_mr==. & num_pr_lga>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_state if maize_price_mr==. & num_pr_state>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_zone if maize_price_mr==. & num_pr_zone>=2
tab maize_price_mr,missing



****************
*rice price
***************


gen rice_price=c8q2 if item_cd==7
tab rice_price,missing
sum rice_price,detail
tab rice_price

replace rice_price = 750 if rice_price >750 & rice_price<.   //bottom 2%
*replace rice_price = 25 if rice_price< 25   //top 3%
tab rice_price,missing



egen median_rice_ea = median(rice_price), by (ea)
egen median_rice_lga = median(rice_price), by (lga)
egen median_rice_state = median(rice_price), by (state)
egen median_rice_zone = median(rice_price), by (zone)

egen num_rice_ea = count(rice_price), by (ea)
egen num_rice_lga = count(rice_price), by (lga)
egen num_rice_state = count(rice_price), by (state)
egen num_rice_zone = count(rice_price), by (zone)

tab num_rice_ea
tab num_rice_lga
tab num_rice_state
tab num_rice_zone


gen rice_price_mr = rice_price

replace rice_price_mr = median_rice_ea if rice_price_mr==. & num_rice_ea>=2
tab rice_price_mr,missing

replace rice_price_mr = median_rice_lga if rice_price_mr==. & num_rice_lga>=2
tab rice_price_mr,missing

replace rice_price_mr = median_rice_state if rice_price_mr==. & num_rice_state>=2
tab rice_price_mr,missing

replace rice_price_mr = median_rice_zone if rice_price_mr==. & num_rice_zone>=2
tab rice_price_mr,missing


sort zone state ea
collapse (max) maize_price_mr rice_price_mr , by (zone state lga sector ea)


save "${Nigeria_GHS_W2_created_data}\food_prices.dta", replace




**************
*Net Buyers and Sellers
***************
use "${Ethiopia_GHS_W5_raw_data}\sect6a_hh_w5.dta",clear 

merge m:1 zone state lga sector ea using "${Nigeria_GHS_W5_created_data}\food_prices.dta", keepusing ( maize_price_mr rice_price_mr)

ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1



**********
*maize
*********
egen median_pr_ea = median(maize_price), by (ea)
egen median_pr_lga = median(maize_price), by (lga)
egen median_pr_state = median(maize_price), by (state)
egen median_pr_zone = median(maize_price), by (zone)

egen num_pr_ea = count(maize_price), by (ea)
egen num_pr_lga = count(maize_price), by (lga)
egen num_pr_state = count(maize_price), by (state)
egen num_pr_zone = count(maize_price), by (zone)

tab num_pr_ea
tab num_pr_lga
tab num_pr_state
tab num_pr_zone



replace maize_price_mr = median_pr_ea if maize_price_mr==. & num_pr_ea>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_lga if maize_price_mr==. & num_pr_lga>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_state if maize_price_mr==. & num_pr_state>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_zone if maize_price_mr==. & num_pr_zone>=2
tab maize_price_mr,missing


****************
*rice price
***************


egen median_rice_ea = median(rice_price), by (ea)
egen median_rice_lga = median(rice_price), by (lga)
egen median_rice_state = median(rice_price), by (state)
egen median_rice_zone = median(rice_price), by (zone)

egen num_rice_ea = count(rice_price), by (ea)
egen num_rice_lga = count(rice_price), by (lga)
egen num_rice_state = count(rice_price), by (state)
egen num_rice_zone = count(rice_price), by (zone)

tab num_rice_ea
tab num_rice_lga
tab num_rice_state
tab num_rice_zone



replace rice_price_mr = median_rice_ea if rice_price_mr==. & num_rice_ea>=2
tab rice_price_mr,missing

replace rice_price_mr = median_rice_lga if rice_price_mr==. & num_rice_lga>=2
tab rice_price_mr,missing

replace rice_price_mr = median_rice_state if rice_price_mr==. & num_rice_state>=2
tab rice_price_mr,missing

replace rice_price_mr = median_rice_zone if rice_price_mr==. & num_rice_zone>=2
tab rice_price_mr,missing






**************
*Net Buyers and Sellers
***************

*s7bq5a from purchases
*s7bq6a from own production

tab s7bq5a
tab s7bq6a

replace s7bq5a = 0 if s7bq5a<=0 |s7bq5a==.
tab s7bq5a,missing
replace s7bq6a = 0 if s7bq6a<=0 |s7bq6a==.
tab s7bq6a,missing

gen net_seller = 1 if s7bq6a > s7bq5a
tab net_seller,missing
replace net_seller=0 if net_seller==.
tab net_seller,missing

gen net_buyer = 1 if s7bq6a < s7bq5a
tab net_buyer,missing
replace net_buyer=0 if net_buyer==.
tab net_buyer,missing

collapse  (max) net_seller net_buyer maize_price_mr rice_price_mr, by(hhid)

gen rea_maize_price_mr = maize_price_mr/0.5179256
gen real_maize_price_mr = rea_maize_price_mr
tab real_maize_price_mr
sum real_maize_price_mr, detail
gen rea_rice_price_mr = rice_price_mr/0.5179256
gen real_rice_price_mr = rea_rice_price_mr
tab real_rice_price_mr
sum real_rice_price_mr, detail

la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"
label var real_maize_price_mr "commercial price of maize in naira"
label var real_rice_price_mr "commercial price of rice in naira"
sort hhid
save "${Nigeria_GHS_W5_created_data}\food_prices_2021.dta", replace
*/





*****************************
*Household Assests
****************************

*Total Value
use "${Ethiopia_GHS_W5_raw_data}\sect7b_hh_w5.dta",clear  
tab s7q04 
ren pw_w5 weight
collapse (max) weight (sum) s7q04, by (household_id)
sum s7q04, detail
save "${Ethiopia_GHS_W5_created_data}\monthly_asset.dta", replace


use "${Ethiopia_GHS_W5_raw_data}\sect7a_hh_w5.dta",clear  //household asset
sum s7q02  


collapse (sum) s7q02, by (household_id)
sum s7q02, detail

merge 1:1 household_id using "${Ethiopia_GHS_W5_created_data}\monthly_asset.dta", gen (asset)


egen hhasset_value = rowtotal(s7q02 s7q04)



ren household_id hhid


merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1

replace hhasset_value = 0 if hhasset_value==.
tab hhasset_value,missing
sum hhasset_value,detail


foreach v of varlist  hhasset_value  {
	_pctile `v' [aw=weight] , p(1 99) 
	gen `v'_w=`v'
	replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}


tab hhasset_value
tab hhasset_value_w, missing
sum hhasset_value hhasset_value_w, detail


gen real_hhvalue = hhasset_value_w
sum hhasset_value_w real_hhvalue, detail


la var real_hhvalue "total value of household asset"
save "${Ethiopia_GHS_W5_created_data}\asset_value_2021.dta", replace




 
********************************************************************************
*FARM SIZE
*******************************************************************************

use "${Ethiopia_GHS_W5_raw_data}/sect3_pp_w5.dta", clear
ren s3q02a  area 
ren s3q02b local_unit 
*ren s3q07  //=1 is gps measurement
ren s3q08 area_sqmeters_gps 
ren saq01 region

list ea_id if real(ea_id) == .
gen ea = real(regexr(ea_id, "[^0-9.]", ""))

list saq03 if real(saq03) == .
gen woreda = real(regexr(saq03, "[^0-9.]", ""))

list saq02 if real(saq02) == .
gen zone = real(regexr(saq02, "[^0-9.]", ""))

ren pw_w5 weight


*replace area_sqmeters_gps=. if area_sqmeters_gps<0
*replace area_sqmeters_gps=. if area_sqmeters_gps==0  		
keep household_id parcel_id holder_id field_id area local_unit area_sqmeters_gps region zone woreda local_unit weight s3q07
*merge m:1 household_id2 using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_hhids.dta", nogen keep(1 3)
merge m:1 region zone woreda local_unit using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2018_ESS_v03_M_Stata\ET_local_area_unit_conversion.dta" , nogen keep(1 3)

sum area, detail
tab local_unit
gen area_est_hectares = area if local_unit==1
replace area_est_hectares = (area/10000) if local_unit==2
*replace area_est_hectares = (area*conversion/10000) if (local_unit!=1 & local_unit!=2 & local_unit!=7 & local_unit!=8)

replace area_est_hectares = (area*conversion/10000) if !inlist(local_unit,1,2) & local_unit!=.

tab area_est_hectares, missing
sum area_est_hectares, detail
*merge m:1 region zone local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_zone.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_zone/10000)) if local_unit!=11 & area_est_hectares==. & obs_zone>=10
*merge m:1 region local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_region.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_region/10000)) if local_unit!=11 & area_est_hectares==. & obs_region>=10
*merge m:1 local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_country.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_country/10000)) if local_unit!=11 & area_est_hectares==.

tab s3q07
sum area_sqmeters_gps, detail
gen area_meas_hectares = (area_sqmeters_gps/10000) //if s3q07==1
replace area_meas_hectares = area_est_hectares if area_meas_hectares==.
count if area!=. & area_meas_hectares==.
count if area_meas_hectares==.

sum area_meas_hectares, detail
*All areas are converted to hectares
*replace area_meas_hectares = 0 if area_meas_hectares == .



ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1

collapse (max) weight (sum) area_meas_hectares, by (hhid)

merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1

count if area_meas_hectares==.
sum area_meas_hectares, detail

ren area_meas_hectares field_size
foreach v of varlist  field_size  {
	_pctile `v' [aw=weight] , p(5 99) 
	gen `v'_w=`v'
	replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top 5% & bottom 1%"
}

tab field_size_w, missing
sum field_size field_size_w, detail



sort hhid
ren field_size_w land_holding
keep hhid land_holding
label var land_holding "land holding in hectares"
save "${Ethiopia_GHS_W5_created_data}\land_holding_2021.dta", replace










*******************************
*Soil Quality
*******************************

use "${Ethiopia_GHS_W5_raw_data}/sect3_pp_w5.dta", clear
ren s3q02a  area 
ren s3q02b local_unit 
*ren s3q07  //=1 is gps measurement
ren s3q08 area_sqmeters_gps 
ren saq01 region

list ea_id if real(ea_id) == .
gen ea = real(regexr(ea_id, "[^0-9.]", ""))

list saq03 if real(saq03) == .
gen woreda = real(regexr(saq03, "[^0-9.]", ""))

list saq02 if real(saq02) == .
gen zone = real(regexr(saq02, "[^0-9.]", ""))

ren pw_w5 weight


*replace area_sqmeters_gps=. if area_sqmeters_gps<0
*replace area_sqmeters_gps=. if area_sqmeters_gps==0  		
keep household_id parcel_id holder_id field_id area local_unit area_sqmeters_gps region zone woreda local_unit weight s3q07
*merge m:1 household_id2 using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_hhids.dta", nogen keep(1 3)

merge m:1 region zone woreda local_unit using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2018_ESS_v03_M_Stata\ET_local_area_unit_conversion.dta" , nogen keep(1 3)

gen area_est_hectares = area if local_unit==1
replace area_est_hectares = (area/10000) if local_unit==2
*replace area_est_hectares = (area*conversion/10000) if (local_unit!=1 & local_unit!=2 & local_unit!=7 & local_unit!=8)

replace area_est_hectares = (area*conversion/10000) if !inlist(local_unit,1,2) & local_unit!=.

tab area_est_hectares, missing
*merge m:1 region zone local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_zone.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_zone/10000)) if local_unit!=11 & area_est_hectares==. & obs_zone>=10
*merge m:1 region local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_region.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_region/10000)) if local_unit!=11 & area_est_hectares==. & obs_region>=10
*merge m:1 local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_country.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_country/10000)) if local_unit!=11 & area_est_hectares==.

tab s3q07
sum area_sqmeters_gps, detail
gen area_meas_hectares = (area_sqmeters_gps/10000) //if s3q07==1
replace area_meas_hectares = area_est_hectares if area_meas_hectares==.
count if area!=. & area_meas_hectares==.
count if area_meas_hectares==.

sum area_meas_hectares, detail



collapse (max) weight (sum) area_meas_hectares, by (household_id parcel_id)

ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter)

keep if ag_rainy_21==1

count if area_meas_hectares==.
sum area_meas_hectares, detail

ren area_meas_hectares field_size


count if field_size==.


ren hhid household_id



merge 1:m household_id parcel_id using "${Ethiopia_GHS_W5_raw_data}\sect2_pp_w5.dta"

ren household_id hhid
merge m:1 hhid using "${Ethiopia_GHS_W5_created_data}/ag_rainy_21.dta", gen(filter2)

keep if ag_rainy_21==1

tab s2q17

ren s2q17 soil_quality
tab soil_quality, missing



egen max_fieldsize = max(field_size), by (hhid)
replace max_fieldsize= . if max_fieldsize!= max_fieldsize
order field_size soil_quality hhid max_fieldsize
sort hhid
keep if field_size== max_fieldsize
sort hhid parcel_id field_size

duplicates report hhid

duplicates tag hhid, generate(dup)
tab dup
list field_size soil_quality dup


list hhid parcel_id field_size soil_quality dup if dup>0

egen soil_qty_rev = min(soil_quality) 
gen soil_qty_rev2 = soil_quality

replace soil_qty_rev2 = soil_qty_rev if dup>0

list hhid parcel_id  field_size soil_quality soil_qty_rev soil_qty_rev2 dup if dup>0



ren saq03 woreda
ren saq02 zones
ren saq01 region

egen med_soil = median(soil_qty_rev2)

egen med_soil_ea = median(soil_qty_rev2), by (ea)
egen med_soil_woreda = median(soil_qty_rev2), by (woreda)
egen med_soil_zone = median(soil_qty_rev2), by (zone)
egen med_soil_region = median(soil_qty_rev2), by (region)

replace soil_qty_rev2= med_soil_ea if soil_qty_rev2==.
tab soil_qty_rev2, missing
replace soil_qty_rev2= med_soil_woreda if soil_qty_rev2==.
tab soil_qty_rev2, missing
replace soil_qty_rev2= med_soil_zone if soil_qty_rev2==.
tab soil_qty_rev2, missing
replace soil_qty_rev2= med_soil_region if soil_qty_rev2==.
tab soil_qty_rev2, missing


replace soil_qty_rev2= 1 if soil_qty_rev2==1.5
tab soil_qty_rev2, missing

la define soil 1 "Good" 2 "fair" 3 "poor"

*la value soil soil_qty_rev2

collapse (mean) soil_qty_rev2 , by (hhid)
la var soil_qty_rev2 "1=Good 2= fair 3=Bad "
save "${Ethiopia_GHS_W5_created_data}\soil_quality_2021.dta", replace





















************************* Merging Agricultural Datasets ********************

use "${Ethiopia_GHS_W5_created_data}\purchased_fert_2021.dta", replace


*******All observations Merged*****



*merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\savings_2012.dta"
*drop _merge
*sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W5_created_data}\credit_2021.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W5_created_data}\extension_visit_2021.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W5_created_data}\demographics_2021.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W5_created_data}\labor_age_2021.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W5_created_data}\safety_net_2021.dta"
drop _merge
sort hhid
*merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\food_prices_2013.dta"
*drop _merge
*sort hhid
*merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\geodata_2013.dta"
*drop _merge
*sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W5_created_data}\soil_quality_2021.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W5_created_data}\asset_value_2021.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W5_created_data}\land_holding_2021.dta"
drop _merge
gen year = 2021
sort hhid




tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr informal_save pry_edu finish_pry finish_sec net_seller net_buyer 

misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2
proportion femhead formal_credit informal_credit ext_acess attend_sch  safety_net  soil_qty_rev2


egen median_price = median(real_tpricefert_cens_mrk)
replace real_tpricefert_cens_mrk= median_price if real_tpricefert_cens_mrk==.

egen median_age = median(hh_headage)
replace hh_headage= median_age if hh_headage==.

egen median_soil = median(soil_qty_rev2)
replace soil_qty_rev2= median_soil if soil_qty_rev2==.
misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2


save "${Ethiopia_GHS_W5_created_data}\Ethiopia_wave5_complete_data.dta", replace







*****************Appending all Nigeria Datasets*****************
use "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Ethiopia_wave4\Ethiopia_wave4_complete_data.dta",clear
append using "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Ethiopia_wave5\Ethiopia_wave5_complete_data.dta" 

order year




tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr informal_save pry_edu finish_pry finish_sec net_seller net_buyer 

misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2



save "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Real_price_median21.dta", replace




























