





clear

global Ethiopia_GHS_W2_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2013_ESS_v03_M_STATA"
global Ethiopia_GHS_W2_created_data     "C:\Users\obine\Music\Documents\Project\codes\Ethiopia\Ethiopia_wave2"





********************************************************************************
* AG FILTER *
********************************************************************************

use "${Ethiopia_GHS_W2_raw_data}\sect3_pp_w2.dta",clear  

ren household_id2 hhid
gen ag_rainy_13 = (pp_s3q03==1)

collapse (max) ag_rainy_13, by (hhid)

save  "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", replace




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

use "${Ethiopia_GHS_W2_raw_data}\sect3_pp_w2.dta",clear  

ren household_id2 hhid
merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1


*pp_s3q16c  	qty commercial urea
*pp_s3q16d 		value commercial urea

*pp_s3q19c  	qty commercial DAP
*pp_s3q19d  	value commercial DAP

*pp_s3q20c  	value commercial urea

list ea_id2 if real(ea_id2) == .
gen ea = real(regexr(ea_id2, "[^0-9.]", ""))

ren saq03 woreda
ren saq02 zones
ren saq01 region

***fertilzer total quantity, total value & total price****


egen total_qty = rowtotal(pp_s3q16c pp_s3q19c) // all are already in kg (Urea & DAP), questionnaire doesn't ask how much other inorg fert was used on the field, but only 30 plots used other fert (3,771 used Urea and 5,047 used DAP) 
tab  total_qty, missing

egen total_valuefert = rowtotal(pp_s3q16d pp_s3q19d)
tab total_valuefert,missing

gen tpricefert = total_valuefert/total_qty
tab tpricefert

gen tpricefert_cens = tpricefert
replace tpricefert_cens = 674.7 if tpricefert_cens > 674.7 & tpricefert_cens < . //winzorizing at bottom 1%
*replace tpricefert_cens = 2 if tpricefert_cens < 2
tab tpricefert_cens, missing  //winzorizing at top 1%

replace tpricefert_cens=0 if tpricefert_cens==.
tab tpricefert_cens, missing 

sum tpricefert_cens, detail
gen tpricefert_cens_mrk = tpricefert_cens






/*
************generating the median age**************






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

replace tpricefert_cens_mrk = medianfert_pr_ea if tpricefert_cens_mrk ==. & num_fert_pr_ea >= 93

tab tpricefert_cens_mrk,missing


replace tpricefert_cens_mrk = medianfert_pr_woreda if tpricefert_cens_mrk ==. & num_fert_pr_woreda >= 641

tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_zone if tpricefert_cens_mrk ==. & num_fert_pr_zone >= 691

tab tpricefert_cens_mrk,missing


replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. 
*/
tab tpricefert_cens_mrk,missing
sum tpricefert_cens_mrk, detail

ren pw2 weight

collapse region zone woreda ea (sum) total_qty total_valuefert (max) weight tpricefert_cens_mrk, by(hhid)


merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1

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
gen rea_tpricefert_cens_mrk = tpricefert_cens_mrk // 0.9126678
gen real_tpricefert_cens_mrk = rea_tpricefert_cens_mrk
tab real_tpricefert_cens_mrk
sum real_tpricefert_cens_mrk, detail


keep hhid region zone woreda ea total_qty_w total_valuefert real_tpricefert_cens_mrk



label var total_qty_w "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var real_tpricefert_cens_mrk "price of commercial fertilizer purchased in naira"
sort hhid
save "${Ethiopia_GHS_W2_created_data}\purchased_fert_2013.dta", replace


/*
************************************************
*Savings 
************************************************

use "${Nigeria_GHS_W2_raw_data}\Post Planting Wave 2\Household\sect4a_plantingw2.dta",clear  


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


*******************************************************
*Credit access 
*******************************************************
*use "${Ethiopia_GHS_W2_raw_data}\sect14a_hh_w2.dta ",clear
*use "${Ethiopia_GHS_W2_raw_data}\sect14c_hh_w2.dta",clear

*use "${Ethiopia_GHS_W2_raw_data}\sect11b_hh_w2.dta",clear

use "${Ethiopia_GHS_W2_raw_data}/sect14b_hh_w2.dta", clear

*hh_s14q02_b types of formal fin institute used to borrow money
ren household_id2 hhid
merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1
tab hh_s14q02_b, nolabel

gen formal_credit =1 if hh_s14q02_b==7 |  hh_s14q02_b==8
tab formal_credit,missing
replace formal_credit =0 if formal_credit ==.
tab formal_credit,missing

gen informal_credit = 1 if hh_s14q02_b==1 |  hh_s14q02_b==6 |hh_s14q02_b==2 |  hh_s14q02_b==3 |hh_s14q02_b==4 |  hh_s14q02_b==5  |hh_s14q02_b==9 |  hh_s14q02_b==10
tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
tab informal_credit,missing

collapse (max) formal_credit informal_credit, by (hhid)
tab informal_credit,missing
tab formal_credit,missing
la var formal_credit "=1 if borrowed from formal credit group"
la var informal_credit "=1 if borrowed from informal credit group"
save "${Ethiopia_GHS_W2_created_data}\credit_2013.dta", replace













******************************* 
*Extension Visit 
*******************************



use "${Ethiopia_GHS_W2_raw_data}/sect3_pp_w2.dta", clear

merge m:m household_id2 using "${Ethiopia_GHS_W2_raw_data}/sect5_pp_w2.dta", nogen
merge m:m household_id2 using "${Ethiopia_GHS_W2_raw_data}/sect7_pp_w2.dta", nogen



gen ext_acess=0
replace ext_acess=1 if pp_s3q11==1 | pp_s7q04==1 | pp_s5q02==4
ren household_id2 hhid
collapse (max) ext_acess, by (hhid)
lab var ext_acess "1= Household reached by extention services"

merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1

save "${Ethiopia_GHS_W2_created_data}\extension_visit_2013.dta", replace












********************************************************************************
*market_distance
********************************************************************************


use "${Ethiopia_GHS_W2_raw_data}\sect4_com_w2.dta", clear


*cs4q15  distance to nearest weekly market in km

ren cs4q15 mrk_dist 
tab mrk_dist,missing

ren ea_id2 ea
ren sa1q03 woreda
ren sa1q02 zones
ren sa1q01 region



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

la var mrk_dist "=distance to the market"

save "${Ethiopia_GHS_W2_created_data}\market_distance.dta", replace 






*********************************
*Demographics 
*********************************

use "${Ethiopia_GHS_W2_raw_data}\sect1_hh_w2.dta",clear 

ren ea_id2 ea
ren saq03 woreda
ren saq02 zones
ren saq01 region

merge 1:1 household_id2 individual_id2 using "${Ethiopia_GHS_W2_raw_data}\sect2_hh_w2.dta", gen(household)

merge m:1 region zones woreda ea using "${Ethiopia_GHS_W2_created_data}\market_distance.dta", keepusing (median_ea median_woreda median_zones median_region mrk_dist)

ren household_id2 hhid


merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1

**************
*market distance
*************
tab mrk_dist, missing




*hh_s1q03   sex
*hh_s1q02   relationship to hhead
*hh_s1q04_a    age in years


 
gen num_mem = 1



******** female head****

gen femhead = 0
replace femhead = 1 if hh_s1q03== 2 & hh_s1q02==1
tab femhead,missing

********Age of HHead***********
ren hh_s1q04_a hh_age
gen hh_headage = hh_age if hh_s1q02 ==1

tab hh_headage
sum hh_headage, detail

tab hh_headage, missing

************generating the median age**************
ren ea st
list ea_id2 if real(ea_id2) == .
gen ea = real(regexr(ea_id2, "[^0-9.]", ""))


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



replace hh_headage = medianhh_pr_ea if hh_headage ==. & num_hh_pr_ea >= 36

tab hh_headage,missing


replace hh_headage = medianhh_pr_woreda if hh_headage ==. & num_hh_pr_woreda >= 440

tab hh_headage,missing



replace hh_headage = medianhh_pr_zone if hh_headage ==. & num_hh_pr_zone >= 351

tab hh_headage,missing


replace hh_headage = medianhh_pr_region if hh_headage ==. 

tab hh_headage,missing

sum hh_headage, detail



********************Education****************************************************

*hh_s1q02    relationship to hhead
*hh_s2q03   attend_sch dummy
*hh_s2q05  highest level of education
 


gen attend_sch = 1 if hh_s2q03==1 & hh_s1q02==1
replace attend_sch =0 if attend_sch==.
tab attend_sch, missing

tab attend_sch, nolabel



/*
ren s2q5 attend_sch
tab attend_sch
replace attend_sch = 0 if attend_sch ==2
tab attend_sch, nolabel
*tab s1q4 if s2q7==.

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

ren pw2 weight
collapse (sum) num_mem (max) weight mrk_dist hh_headage femhead attend_sch , by (hhid)
 

merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1



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


keep hhid mrk_dist_w num_mem femhead hh_headage attend_sch  weight

/*

pry_edu finish_pry finish_sec


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
save "${Ethiopia_GHS_W2_created_data}\demographics_2013.dta", replace

********************************* 
*Labor Age 
*********************************
use "${Ethiopia_GHS_W2_raw_data}\sect1_hh_w2.dta",clear 

ren household_id2 hhid


merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1


*hh_s1q04_a    age in years

ren hh_s1q04_a hh_age

gen worker = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort hhid worker
collapse (sum) worker, by (hhid)
la var worker "number of members age 15 and older and less than 65"
sort hhid

save "${Ethiopia_GHS_W2_created_data}\labor_age_2013.dta", replace


********************************
*Safety Net
********************************

use "${Ethiopia_GHS_W2_raw_data}\sect12_hh_w2.dta",clear 





merge m:m household_id2 using "${Ethiopia_GHS_W2_raw_data}\sect13_hh_w2.dta", gen(safety)
ren household_id2 hhid
merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1
tab hh_s12q01 , nolabel
tab hh_s13q01 , nolabel


gen safety_net =1  if hh_s12q01==1 | hh_s13q01 ==1 
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (hhid)


tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${Ethiopia_GHS_W2_created_data}\safety_net_2013.dta", replace


**************************************
*Food Prices
**************************************
use "${Ethiopia_GHS_W2_raw_data}/sect10a2_com_w2.dta", clear






tab cs10a2q02 if cs10a2q02==4
tab cs10a2q02 if cs10a2q02==5


tab cs10a2q03_a if cs10a2q02==4 //maize
tab cs10a2q03_a if cs10a2q02==4, nolabel
tab cs10a2q03_a if cs10a2q02==5  //sorghum
tab cs10a2q03_a if cs10a2q02==5, nolabel


sum cs10a2q05 if cs10a2q02==4, detail








gen maize_price=cs10a2q05  if  cs10a2q02==4 & cs10a2q03_a==20
*replace maize_price=cs10a2q05 /1000 if cs10a2q02==4 & cs10a2q03_a==1

*br maize_price cs10a2q05 cs10a2q03_a cs10a2q02 if cs10a2q02==4 

*/


tab maize_price,missing
sum maize_price,detail
tab maize_price

*replace maize_price = 700 if maize_price >700 & maize_price<.  //bottom 2%
*replace maize_price = 10 if maize_price< 10        ////top 5%


************generating the median age**************


egen median_maize = median(maize_price)



list ea_id2 if real(ea_id2) == .
gen ea = real(regexr(ea_id2, "[^0-9.]", ""))

ren sa1q03  woreda
ren sa1q02 zones
ren sa1q01 region



egen medianhh_pr_ea = median(maize_price), by (ea)
egen num_hh_pr_ea = count(maize_price), by (ea)


egen medianhh_pr_woreda = median(maize_price), by (woreda)
egen num_hh_pr_woreda = count(maize_price), by (woreda)

egen medianhh_pr_zone = median(maize_price), by (zone)
egen num_hh_pr_zone = count(maize_price), by (zone)

egen medianhh_pr_region = median(maize_price), by (region)
egen num_hh_pr_region = count(maize_price), by (region)


tab medianhh_pr_ea
tab medianhh_pr_woreda
tab medianhh_pr_zone
tab medianhh_pr_region



tab num_hh_pr_ea
tab num_hh_pr_woreda
tab num_hh_pr_zone
tab num_hh_pr_region



replace maize_price = medianhh_pr_ea if maize_price ==. & num_hh_pr_ea >= 6

tab maize_price,missing


replace maize_price = medianhh_pr_woreda if maize_price ==. & num_hh_pr_woreda >= 25

tab maize_price,missing



replace maize_price = medianhh_pr_zone if maize_price ==. & num_hh_pr_zone >= 26

tab maize_price,missing


replace maize_price = medianhh_pr_region if maize_price ==. 

tab maize_price,missing

sum maize_price, detail
replace maize_price = median_maize if maize_price ==. 

tab maize_price,missing

sum maize_price, detail




****************
*rice price
***************
tab cs10a2q03_a if cs10a2q02==5  //sorghum
tab cs10a2q03_a if cs10a2q02==5, nolabel


sum cs10a2q05 if cs10a2q02==5, detail








gen rice_price=cs10a2q05  if  cs10a2q02==5 & cs10a2q03_a==20

*/


tab rice_price,missing
sum rice_price,detail
tab rice_price

replace rice_price = 900 if rice_price >900 & rice_price<.  //bottom 2%
*replace rice_price = 10 if rice_price< 10        ////top 5%


************generating the median age**************
egen median_rice = median(rice_price)

egen medianri_pr_ea = median(rice_price), by (ea)
egen num_ri_pr_ea = count(rice_price), by (ea)


egen medianri_pr_woreda = median(rice_price), by (woreda)
egen num_ri_pr_woreda = count(rice_price), by (woreda)

egen medianri_pr_zone = median(rice_price), by (zone)
egen num_ri_pr_zone = count(rice_price), by (zone)

egen medianri_pr_region = median(rice_price), by (region)
egen num_ri_pr_region = count(rice_price), by (region)


tab medianri_pr_ea
tab medianri_pr_woreda
tab medianri_pr_zone
tab medianri_pr_region



tab num_ri_pr_ea
tab num_ri_pr_woreda
tab num_ri_pr_zone
tab num_ri_pr_region



replace rice_price = medianri_pr_ea if rice_price ==. & num_ri_pr_ea >= 6

tab rice_price,missing


replace rice_price = medianri_pr_woreda if rice_price ==. & num_ri_pr_woreda >= 19

tab rice_price,missing



replace rice_price = medianri_pr_zone if rice_price ==. & num_ri_pr_zone >= 21

tab rice_price,missing


replace rice_price = medianri_pr_region if rice_price ==. 

tab rice_price,missing



replace rice_price = median_rice if rice_price ==. 

tab rice_price,missing

sum rice_price, detail




duplicates report  region zone woreda ea
sort region zone woreda ea
collapse (max) maize_price rice_price , by (region zone woreda ea)


save "${Ethiopia_GHS_W2_created_data}\food_prices.dta", replace




**************
*Net Buyers and Sellers
***************
use "${Ethiopia_GHS_W2_raw_data}/sect5a_hh_w2.dta", clear


list ea_id2 if real(ea_id2) == .
gen ea = real(regexr(ea_id2, "[^0-9.]", ""))
ren saq03 woreda
ren saq02 zones
ren saq01 region


merge m:1 region zone woreda ea using  "${Ethiopia_GHS_W2_created_data}\food_prices.dta", keepusing ( maize_price rice_price)

ren household_id2 hhid
merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1



**********
*maize
*********

egen median_maize = median(maize_price)

egen medianhh_pr_ea = median(maize_price), by (ea)
egen num_hh_pr_ea = count(maize_price), by (ea)


egen medianhh_pr_woreda = median(maize_price), by (woreda)
egen num_hh_pr_woreda = count(maize_price), by (woreda)

egen medianhh_pr_zone = median(maize_price), by (zone)
egen num_hh_pr_zone = count(maize_price), by (zone)

egen medianhh_pr_region = median(maize_price), by (region)
egen num_hh_pr_region = count(maize_price), by (region)


tab medianhh_pr_ea
tab medianhh_pr_woreda
tab medianhh_pr_zone
tab medianhh_pr_region



tab num_hh_pr_ea
tab num_hh_pr_woreda
tab num_hh_pr_zone
tab num_hh_pr_region



replace maize_price = medianhh_pr_ea if maize_price ==. & num_hh_pr_ea >= 6

tab maize_price,missing


replace maize_price = medianhh_pr_woreda if maize_price ==. & num_hh_pr_woreda >= 25

tab maize_price,missing



replace maize_price = medianhh_pr_zone if maize_price ==. & num_hh_pr_zone >= 26

tab maize_price,missing


replace maize_price = medianhh_pr_region if maize_price ==. 

tab maize_price,missing

sum maize_price, detail
replace maize_price = median_maize if maize_price ==. 

tab maize_price,missing

sum maize_price, detail


****************
*rice price
***************


egen median_rice = median(rice_price)

egen medianri_pr_ea = median(rice_price), by (ea)
egen num_ri_pr_ea = count(rice_price), by (ea)


egen medianri_pr_woreda = median(rice_price), by (woreda)
egen num_ri_pr_woreda = count(rice_price), by (woreda)

egen medianri_pr_zone = median(rice_price), by (zone)
egen num_ri_pr_zone = count(rice_price), by (zone)

egen medianri_pr_region = median(rice_price), by (region)
egen num_ri_pr_region = count(rice_price), by (region)


tab medianri_pr_ea
tab medianri_pr_woreda
tab medianri_pr_zone
tab medianri_pr_region



tab num_ri_pr_ea
tab num_ri_pr_woreda
tab num_ri_pr_zone
tab num_ri_pr_region



replace rice_price = medianri_pr_ea if rice_price ==. & num_ri_pr_ea >= 6

tab rice_price,missing


replace rice_price = medianri_pr_woreda if rice_price ==. & num_ri_pr_woreda >= 19

tab rice_price,missing



replace rice_price = medianri_pr_zone if rice_price ==. & num_ri_pr_zone >= 21

tab rice_price,missing


replace rice_price = medianri_pr_region if rice_price ==. 

tab rice_price,missing



replace rice_price = median_rice if rice_price ==. 

tab rice_price,missing

sum rice_price, detail



gen maize_price_mr = maize_price
gen rice_price_mr = rice_price




**************
*Net Buyers and Sellers
***************

*s7bq5a from purchases
*s7bq6a from own production

tab hh_s5aq03_a 
tab hh_s5aq05_a 

replace hh_s5aq03_a = 0 if hh_s5aq03_a<=0 |hh_s5aq03_a==.
tab hh_s5aq03_a,missing
replace hh_s5aq05_a = 0 if hh_s5aq05_a<=0 |hh_s5aq05_a==.
tab hh_s5aq05_a,missing

gen net_seller = 1 if hh_s5aq05_a  > hh_s5aq03_a
tab net_seller,missing
replace net_seller=0 if net_seller==.
tab net_seller,missing

gen net_buyer = 1 if hh_s5aq05_a  < hh_s5aq03_a
tab net_buyer,missing
replace net_buyer=0 if net_buyer==.
tab net_buyer,missing

collapse  (max) net_seller net_buyer maize_price_mr rice_price_mr, by(hhid)

gen rea_maize_price_mr = maize_price_mr   // 0.9126678
gen real_maize_price_mr = rea_maize_price_mr
tab real_maize_price_mr
sum real_maize_price_mr, detail
gen rea_rice_price_mr = rice_price_mr   // 0.9126678
gen real_rice_price_mr = rea_rice_price_mr
tab real_rice_price_mr
sum real_rice_price_mr, detail

la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"
label var real_maize_price_mr "commercial price of maize in naira"
label var real_rice_price_mr "commercial price of rice in naira"
sort hhid
save "${Ethiopia_GHS_W2_created_data}\food_prices_2013.dta", replace

*/



*****************************
*Household Assests
****************************


*Total Value
use "${Ethiopia_GHS_W2_raw_data}\sect6a_hh_w2.dta",clear  
tab hh_s6aq0a 
ren pw2 weight
collapse (max) weight (sum) hh_s6aq02, by (household_id2)
sum hh_s6aq02, detail
save "${Ethiopia_GHS_W2_created_data}\monthly_asset.dta", replace


use "${Ethiopia_GHS_W2_raw_data}\sect6b_hh_w2.dta",clear  //household asset
tab hh_s6bq0a  


collapse (sum) hh_s6bq04, by (household_id2)
sum hh_s6bq04, detail

merge 1:1 household_id2 using "${Ethiopia_GHS_W2_created_data}\monthly_asset.dta", gen(asset)

*Quantity
*use "${Ethiopia_GHS_W2_raw_data}\sect10_hh_w2.dta",clear 
egen hhasset_value = rowtotal(hh_s6aq02 hh_s6bq04)



ren household_id2 hhid

collapse (sum) hhasset_value (max) weight, by (hhid)
merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1

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


gen real_hhvalue = hhasset_value_w  // 0.9126678
sum hhasset_value_w real_hhvalue, detail


la var real_hhvalue "total value of household asset"
save "${Ethiopia_GHS_W2_created_data}\asset_value_2013.dta", replace




 
********************************************************************************
*FARM SIZE
*******************************************************************************

use "${Ethiopia_GHS_W2_raw_data}/sect3_pp_w2.dta", clear
ren pp_s3q02_a area 
ren pp_s3q02_c local_unit 
ren pp_s3q05_a area_sqmeters_gps 
ren saq01 region
ren saq02 zone
ren saq03 woreda
ren pw2 weight


*replace area_sqmeters_gps=. if area_sqmeters_gps<0
*replace area_sqmeters_gps=. if area_sqmeters_gps==0  		
keep household_id2 parcel_id holder_id field_id area local_unit area_sqmeters_gps region zone woreda local_unit weight
*merge m:1 household_id2 using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_hhids.dta", nogen keep(1 3)
merge m:1 region zone woreda local_unit using "${Ethiopia_GHS_W2_raw_data}/ET_local_area_unit_conversion.dta", nogen keep(1 3)
gen area_est_hectares = area if local_unit==1
replace area_est_hectares = (area/10000) if local_unit==2
replace area_est_hectares = (area*conversion/10000) if (local_unit!=1 & local_unit!=2 & local_unit!=7 & local_unit!=8)
*merge m:1 region zone local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_zone.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_zone/10000)) if local_unit!=11 & area_est_hectares==. & obs_zone>=10
*merge m:1 region local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_region.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_region/10000)) if local_unit!=11 & area_est_hectares==. & obs_region>=10
*merge m:1 local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_country.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_country/10000)) if local_unit!=11 & area_est_hectares==.
gen area_meas_hectares = (area_sqmeters_gps/10000)
replace area_meas_hectares = area_est_hectares if area_meas_hectares==.
count if area!=. & area_meas_hectares==.
count if area_meas_hectares==.

sum area_meas_hectares, detail
*All areas are converted to hectares
*replace area_meas_hectares = 0 if area_meas_hectares == .




ren household_id2 hhid


merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1

collapse (max) weight (sum) area_meas_hectares, by (hhid)

merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1

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
save "${Ethiopia_GHS_W2_created_data}\land_holding_2013.dta", replace










*******************************
*Soil Quality
*******************************


use "${Ethiopia_GHS_W2_raw_data}/sect3_pp_w2.dta", clear
ren pp_s3q02_a area 
ren pp_s3q02_c local_unit 
ren pp_s3q05_a area_sqmeters_gps 
ren saq01 region
ren saq02 zone
ren saq03 woreda
ren pw2 weight


*replace area_sqmeters_gps=. if area_sqmeters_gps<0
*replace area_sqmeters_gps=. if area_sqmeters_gps==0  		
keep household_id2 parcel_id holder_id field_id area local_unit area_sqmeters_gps region zone woreda local_unit weight ea_id2 
*merge m:1 household_id2 using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_hhids.dta", nogen keep(1 3)
merge m:1 region zone woreda local_unit using "${Ethiopia_GHS_W2_raw_data}/ET_local_area_unit_conversion.dta", nogen keep(1 3)
gen area_est_hectares = area if local_unit==1
replace area_est_hectares = (area/10000) if local_unit==2
replace area_est_hectares = (area*conversion/10000) if (local_unit!=1 & local_unit!=2 & local_unit!=7 & local_unit!=8)
*merge m:1 region zone local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_zone.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_zone/10000)) if local_unit!=11 & area_est_hectares==. & obs_zone>=10
*merge m:1 region local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_region.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_region/10000)) if local_unit!=11 & area_est_hectares==. & obs_region>=10
*merge m:1 local_unit using "${Ethiopia_ESS_W2_created_data}/Ethiopia_ESS_W2_area_lookup_country.dta", nogen
*replace area_est_hectares = (area*(sqmeters_per_unit_country/10000)) if local_unit!=11 & area_est_hectares==.
gen area_meas_hectares = (area_sqmeters_gps/10000)
replace area_meas_hectares = area_est_hectares if area_meas_hectares==.
count if area!=. & area_meas_hectares==.
count if area_meas_hectares==.

collapse (max) weight (sum) area_meas_hectares, by (household_id2 parcel_id)

ren household_id2 hhid
merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter)

keep if ag_rainy_13==1

count if area_meas_hectares==.
sum area_meas_hectares, detail

ren area_meas_hectares field_size


count if field_size==.


ren hhid household_id2



merge 1:m household_id2 parcel_id using "${Ethiopia_GHS_W2_raw_data}\sect2_pp_w2.dta"

ren household_id2 hhid
merge m:1 hhid using "${Ethiopia_GHS_W2_created_data}/ag_rainy_13.dta", gen(filter2)

keep if ag_rainy_13==1



ren pp_s2q15 soil_quality
tab soil_quality, missing



egen med_soil = median(soil_quality)

ren saq01 region
ren saq02 zone
ren saq03 woreda

egen med_soil_ea = median(soil_quality), by (ea_id)
egen med_soil_woreda = median(soil_quality), by (woreda)
egen med_soil_zone = median(soil_quality), by (zone)
egen med_soil_region = median(soil_quality), by (region)






replace soil_quality= med_soil_ea if soil_quality==.
tab soil_quality, missing
replace soil_quality= med_soil_woreda if soil_quality==.
tab soil_quality, missing
replace soil_quality= med_soil_zone if soil_quality==.
tab soil_quality, missing
replace soil_quality= med_soil_region if soil_quality==.
tab soil_quality, missing




replace soil_quality= 2 if soil_quality==1.5 
replace soil_quality= 2 if soil_quality==2.5 
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


tab soil_qty_rev2, missing



la define soil 1 "Good" 2 "fair" 3 "poor"

*la value soil soil_qty_rev2

collapse (mean) soil_qty_rev2 , by (hhid)
tab soil_qty_rev2, missing

la var soil_qty_rev2 "1=Good 2= fair 3=Bad "
save "${Ethiopia_GHS_W2_created_data}\soil_quality_2013.dta", replace




















************************* Merging Agricultural Datasets ********************

use "${Ethiopia_GHS_W2_created_data}\purchased_fert_2013.dta", replace


*******All observations Merged*****



*merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\savings_2012.dta"
*drop _merge
*sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\credit_2013.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\extension_visit_2013.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\demographics_2013.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\labor_age_2013.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\safety_net_2013.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\food_prices_2013.dta"
drop _merge
*sort hhid
*merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\geodata_2013.dta"
*drop _merge
*sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\soil_quality_2013.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\asset_value_2013.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Ethiopia_GHS_W2_created_data}\land_holding_2013.dta"
drop _merge
gen year = 2013
sort hhid




tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk real_maize_price_mr real_rice_price_mr num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

* informal_save pry_edu finish_pry finish_sec 



misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer 



*proportion femhead formal_credit informal_credit ext_acess attend_sch  safety_net  soil_qty_rev2 

egen median_mrk = median(mrk_dist_w)
replace mrk_dist_w= median_mrk if mrk_dist_w==.

*egen median_price = median(real_tpricefert_cens_mrk)
*replace real_tpricefert_cens_mrk= median_price if real_tpricefert_cens_mrk==.

egen median_age = median(hh_headage)
replace hh_headage= median_age if hh_headage==.

egen med_soil = median(soil_qty_rev2)
replace soil_qty_rev2= med_soil if soil_qty_rev2==.


misstable summarize femhead formal_credit informal_credit ext_acess attend_sch  safety_net  total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 real_maize_price_mr real_rice_price_mr net_seller net_buyer 

sum total_qty_w, detail


save "${Ethiopia_GHS_W2_created_data}\Ethiopia_wave2_complete_data.dta", replace






