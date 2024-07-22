





clear

global Uganda_GHS_W8_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\Uganda\UGA_2019_UNPS_v03_M_STATA14\UGA_2019_UNPS_v03_M_STATA14"
global Uganda_GHS_W8_created_data   "C:\Users\obine\Music\Documents\Project\codes\Uganda\Uganda_wave8"


*tostring HHID, replace force format(%18.0f)



********************************************************************************
* AG FILTER *
********************************************************************************

use "${Uganda_GHS_W8_raw_data}\hh\gsec19.dta", clear

recast str17 hhid, force
save  "${Uganda_GHS_W8_created_data}/agrichouse.dta", replace


use "${Uganda_GHS_W8_raw_data}\agric\agsec1.dta", replace 
recast str17 hhid, force
save  "${Uganda_GHS_W8_created_data}/ag.dta", replace


use "${Uganda_GHS_W8_raw_data}\hh\gsec1.dta", clear

recast str17 hhid, force

merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/agrichouse.dta", gen(ag)
merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/ag.dta"

des

gen ag_rainy_19 = (s19q01==1)
tab ag_rainy_19

ren district pan

ren  dc_2018 district 
ren cc_2018  ea
ren regurb  stratum
ren hwgt_wc    weight

keep  region stratum district ea weight ag_rainy_19 hhid hhidold t0_hhid 


*collapse (max) ag_rainy_10, by (HHID)

save  "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", replace




/*
********************************************************************************
* Household  *
********************************************************************************

use "${Uganda_GHS_W3_raw_data}\GSEC1.dta",clear  

ren HHID hhidd

list hhidd if real(hhidd) == .
gen HHID = real(regexr(hhidd, "[^0-9.]", ""))



ren comm ea
encode  h1aq1, gen  (district)
ren mult  weight
ren sregion stratum

keep  region stratum district ea weight  HHID

*collapse (max) region stratum district ea (mean) weight, by (HHID)

save  "${Uganda_GHS_W4_created_data}/hhids.dta", replace
*/






*********************************************** 
*Purchased Fertilizer
***********************************************

use "${Uganda_GHS_W8_raw_data}\agric\agsec3b.dta",clear 
recast str17 hhid, force
duplicates report hhid pltid 

duplicates tag hhid pltid, generate(dup)
tab dup

duplicates drop hhid pltid , force


save "${Uganda_GHS_W8_created_data}/plotsb.dta", replace

use "${Uganda_GHS_W8_raw_data}\agric\agsec3a.dta",clear 
recast str17 hhid, force
duplicates report hhid pltid 

duplicates tag hhid pltid, generate(dup)
tab dup

duplicates drop hhid pltid , force


merge 1:1 hhid  pltid using "${Uganda_GHS_W8_created_data}/plotsb.dta", gen(fert)








merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if filter==3

keep if ag_rainy_19==1


*s3aq17  s3bq17  	qty commercial urea
*s3bq18  s3bq18	value commercial urea



sum s3aq17, detail
sum s3bq17, detail

sum s3aq18, detail
sum s3bq18, detail



***fertilzer total quantity, total value & total price****


gen total_qty = s3aq17
replace total_qty = s3bq17 if total_qty==.
replace total_qty = 0 if total_qty==.
tab  total_qty, missing

gen total_valuefert = s3aq18
replace total_valuefert = s3bq18 if total_valuefert==.
replace total_valuefert = 0 if total_valuefert==.
tab total_valuefert,missing

gen tpricefert = total_valuefert/total_qty
tab tpricefert
sum tpricefert, detail

gen tpricefert_cens = tpricefert
replace tpricefert_cens = 55000 if tpricefert_cens > 55000 & tpricefert_cens < . //winzorizing at bottom 10%
replace tpricefert_cens =500 if tpricefert_cens < 500
tab tpricefert_cens, missing  //winzorizing at top 1%

*replace tpricefert_cens=0 if tpricefert_cens==.
*tab tpricefert_cens, missing 

*sum tpricefert_cens, detail
*gen tpricefert_cens_mrk = tpricefert_cens



************generating the median age**************


*egen medianfert_pr_ea_id = median(tpricefert_cens), by (ea)
egen medianfert_pr_district  = median(tpricefert_cens), by (district )
egen medianfert_pr_stratum = median(tpricefert_cens), by (stratum )

egen medianfert_pr_region  = median(tpricefert_cens), by (region )


*egen num_fert_pr_ea_id = count(tpricefert_cens), by (ea)
egen num_fert_pr_region  = count(tpricefert_cens), by (region )
egen num_fert_pr_stratum = count(tpricefert_cens), by (stratum )
egen num_fert_pr_district  = count(tpricefert_cens), by (district)


*tab num_fert_pr_ea_id
tab num_fert_pr_district
tab num_fert_pr_stratum
tab num_fert_pr_region




gen tpricefert_cens_mrk = tpricefert_cens

*replace tpricefert_cens_mrk = medianfert_pr_ea_id if tpricefert_cens_mrk ==. & num_fert_pr_ea_id >= 8
*tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_district if tpricefert_cens_mrk ==. & num_fert_pr_district >= 8
tab tpricefert_cens_mrk ,missing

replace tpricefert_cens_mrk = medianfert_pr_stratum if tpricefert_cens_mrk ==. & num_fert_pr_stratum >= 48
tab tpricefert_cens_mrk ,missing

replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. 
tab tpricefert_cens_mrk,missing
*/



/*
egen mid_fert = median(tpricefert_cens)
replace tpricefert_cens_mrk = mid_fert if tpricefert_cens_mrk==.
tab tpricefert_cens_mrk,missing
*/
tab total_qty, missing

collapse (sum) total_qty total_valuefert (max) tpricefert_cens_mrk, by(hhid)


merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if filter==3
keep if ag_rainy_19==1

sum tpricefert_cens_mrk, detail
sum total_qty, detail
/*
************winzonrizing total_qty
foreach v of varlist  total_qty  {
	_pctile `v' [aw=weight] , p(1 99) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}

*/

tab total_qty, missing

gen total_qty_w = total_qty
tab total_qty_w
replace total_qty_w= 0 if total_qty_w ==.
*replace total_qty_w= 300 if total_qty_w >300
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
gen rea_tpricefert_cens_mrk = tpricefert_cens_mrk // / 0.9126678
gen real_tpricefert_cens_mrk = rea_tpricefert_cens_mrk
tab real_tpricefert_cens_mrk
sum real_tpricefert_cens_mrk, detail


keep hhid total_qty_w total_valuefert real_tpricefert_cens_mrk



label var total_qty_w "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var real_tpricefert_cens_mrk "price of commercial fertilizer purchased in naira"
sort hhid
save "${Uganda_GHS_W8_created_data}\purchased_fert_2019.dta", replace



************************************************
*Savings 
************************************************
use "${Uganda_GHS_W8_raw_data}\hh\gsec7_1.dta",clear 
recast str17 hhid, force

des


merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1



/*

*/


 gen formal_save = 1 if CB06B ==1 | CB06C==1 | CB06E ==1
 tab formal_save, missing
 replace formal_save = 0 if formal_save ==.
 tab formal_save, missing


 gen informal_save = 1 if CB06A  ==1 | CB06D==1 | CB06F==1 | CB06G==1 | CB06H==1 | CB06I==1 | CB06J==1 | CB06X==1 
 tab informal_save, missing
 replace informal_save = 0 if informal_save ==.
 tab informal_save, missing

 collapse (max)  formal_save informal_save, by (hhid)
 tab formal_save, missing
 tab informal_save, missing

 la var formal_save "=1 if used formal saving group"
 la var informal_save "=1 if used informal saving group"
save "${Uganda_GHS_W8_created_data}\savings_2019.dta", replace

*/


*******************************************************
*Credit access 
*******************************************************


use "${Uganda_GHS_W8_raw_data}\hh\GSEC7_4.dta",clear 
recast str17 hhid, force

des



merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1






gen formal_credit =1 if CB16__1 ==1  | CB16__3 ==1 | CB16__6 ==1  | CB16__9 == 1 | CB16__11  ==1 | CB16__12  ==1 | CB16__14  ==1
tab formal_credit,missing
replace formal_credit =0 if formal_credit ==.
tab formal_credit,missing

gen informal_credit = 1 if CB16__2 ==1  | CB16__4 ==1 | CB16__5 ==1 | CB16__7 ==1| CB16__8 ==1 | CB16__10 ==1 | CB16__11  ==1 | CB16__13  ==1 | CB16__96  ==1
tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
tab informal_credit,missing
la var formal_credit "=1 if borrowed from formal credit group"
la var informal_credit "=1 if borrowed from informal credit group"





collapse (max) formal_credit informal_credit , by (hhid)

save "${Uganda_GHS_W8_created_data}\credit_2019.dta", replace












******************************* 
*Extension Visit 
*******************************

use "${Uganda_GHS_W8_raw_data}\agric\agsec9a.dta", clear
recast str17 hhid, force
des

*h9q04a  which household




merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1

tab h9q04a 
tab h9q04b

replace h9q04a = h9q04b if h9q04a ==.
*replace h9q04a = h9q04c if h9q04a ==.

tab h9q04a


gen ext_acess = 1 if h9q04a !=.

tab ext_acess, missing
tab ext_acess, nolabel
replace ext_acess =0 if ext_acess ==.
*replace ext_acess =0 if ext_acess ==2
tab ext_acess, nolabel
tab ext_acess,missing



collapse (max) ext_acess, by (hhid)
tab ext_acess,missing


lab var ext_acess "1= Household reached by extention services"


save "${Uganda_GHS_W8_created_data}\extension_visit_2019.dta", replace










/*

********************************************************************************
*market_distance
********************************************************************************

use "${Uganda_GHS_W8_raw_data}\community\CSEC2.dta",clear 
recast str17 interview__id, force

save "${Uganda_GHS_W8_created_data}\communityst.dta", replace 


use "${Uganda_GHS_W8_raw_data}\community\CSEC1A.dta", clear

recast str17 interview__id, force

*csec4b.dta

merge m:1 Final_EA_code using  "${Uganda_GHS_W8_created_data}\communityst.dta"

des
ren service_avail~d  service_avail

gen mrk_dist = s2aq05 if service_avail ==16


tab mrk_dist, missing

ren c1aq01b district_code 

list c1aq02b if real(c1aq02b) == .
gen county_code = real(regexr(c1aq02b, "[^0-9.]", ""))

list c1aq03b  if real(c1aq03b ) == .
gen subcounty_code = real(regexr(c1aq03b , "[^0-9.]", ""))

list s1aq04b if real(s1aq04b) == .
gen parish_code = real(regexr(s1aq04b, "[^0-9.]", ""))




*EA_code


collapse (max) mrk_dist, by (  district_code county_code subcounty_code parish_code)

duplicates report district_code county_code subcounty_code parish_code

sum mrk_dist , detail

save "${Uganda_GHS_W8_created_data}\market.dta", replace 



use "${Uganda_GHS_W8_raw_data}\hh\GSEC1.dta",clear 
des 
recast str17 hhid, force
merge m:1  district_code county_code subcounty_code parish_code using "${Uganda_GHS_W8_created_data}\market.dta", gen(mrk)

keep if mrk==3



merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1




tab mrk_dist,missing



*egen median_ea = median(mrk_dist), by (ea)
egen median_district  = median(mrk_dist), by (district )
egen median_stratum = median(mrk_dist), by (stratum )

egen median_region  = median(mrk_dist), by (region )


*egen num_ea = count(mrk_dist), by (ea)
egen num_region  = count(mrk_dist), by (region )
egen num_stratum = count(mrk_dist), by (stratum )
egen num_district  = count(mrk_dist), by (district)


*tab num_ea
tab num_district
tab num_stratum
tab num_region


*replace mrk_dist = median_ea if mrk_dist==.  & num_ea >= 13
replace mrk_dist = median_district if mrk_dist==. & num_district >= 52
replace mrk_dist = median_stratum if mrk_dist==. & num_stratum >= 348
replace mrk_dist = median_region if mrk_dist==. 

tab mrk_dist, missing


collapse (max) mrk_dist, by (hhid)



merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1

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

la var mrk_dist_w "=distance to the market"

save "${Uganda_GHS_W8_created_data}\market_distance.dta", replace 

*/




*********************************
*Demographics 
*********************************

use "${Uganda_GHS_W8_raw_data}\hh\GSEC4.dta",clear 
recast str17 hhid, force
save "${Uganda_GHS_W8_created_data}/housethins.dta", replace


use "${Uganda_GHS_W8_raw_data}\hh\GSEC2.dta", clear
recast str17 hhid, force

merge 1:1 hhid pid using "${Uganda_GHS_W8_created_data}/housethins.dta", gen(household) 



des


merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1
keep if filter==3


*h2q3   sex
*h2q4   relationship to hhead
*h2q8    age in years

tab h2q3
tab h2q3, nolabel
tab h2q4
tab h2q4, nolabel
sum h2q8, detail
 
gen num_mem = 1



******** female head****

gen femhead = 0
replace femhead = 1 if h2q3== 2 & h2q4==1
tab femhead,missing

********Age of HHead***********
ren h2q8 hh_age
gen hh_headage = hh_age if h2q4 ==1

tab hh_headage
sum hh_headage, detail

tab hh_headage, missing

************generating the median age**************

*egen medianhh_pr_ea = median(hh_headage), by (ea)
egen medianhh_pr_district  = median(hh_headage), by (district )
egen medianhh_pr_stratum = median(hh_headage), by (stratum )

egen medianhh_pr_region  = median(hh_headage), by (region )


*egen num_hh_ea = count(hh_headage), by (ea)
egen num_hh_region  = count(hh_headage), by (region )
egen num_hh_stratum = count(hh_headage), by (stratum )
egen num_hh_district  = count(hh_headage), by (district)


*tab num_hh_ea
tab num_hh_district
tab num_hh_stratum
tab num_hh_region






*replace hh_headage = medianhh_pr_ea if hh_headage ==. & num_hh_ea >= 21

*tab hh_headage,missing


replace hh_headage = medianhh_pr_district if hh_headage ==. & num_hh_district >= 66

tab hh_headage,missing



replace hh_headage = medianhh_pr_stratum if hh_headage ==. & num_hh_stratum >= 584

tab hh_headage,missing


replace hh_headage = medianhh_pr_region if hh_headage ==. 

tab hh_headage,missing

sum hh_headage, detail



********************Education****************************************************

*h2q3   sex
*h2q4   relationship to hhead
*s4q05   attend_sch dummy
*s4q07   highest level of education

tab s4q05
tab s4q05, nolabel
tab s4q05

gen attend_sch = 1 if (s4q05==2 | s4q05==3)  & h2q4==1
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

collapse (sum) num_mem (max)  hh_headage femhead attend_sch , by (hhid)
*mrk_dist

merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1




keep hhid  num_mem femhead hh_headage attend_sch  weight


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
la var femhead "=1 if head is female"
la var hh_headage "age of household head in years"
la var attend_sch "=1 if respondent attended school"
*la var pry_edu "=1 if household head attended pry school"
*la var finish_pry "=1 if household head finished pry school"
*la var finish_sec "=1 if household head finished sec school"
save "${Uganda_GHS_W8_created_data}\demographics_2019.dta", replace

********************************* 
*Labor Age 
*********************************
use "${Uganda_GHS_W8_raw_data}\hh\GSEC2.dta",clear 
recast str17 hhid, force




merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1


*h2q8    age in years

ren h2q8 hh_age

gen worker = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing

collapse (sum) worker, by (hhid)
la var worker "number of members age 15 and older and less than 65"
sort hhid
tab worker,missing
 
save "${Uganda_GHS_W8_created_data}\labor_age_2019.dta", replace

/*
********************************
*Safety Net
********************************

*use "${Uganda_GHS_W8_raw_data}\hh\GSEC7_1.dta",clear 
use "${Uganda_GHS_W8_raw_data}\hh\GSEC7_2.dta",clear 
recast str17 hhid, force

merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1


*h11q6 received remmitance
tab hh_s12q01 , nolabel
tab hh_s13q01 , nolabel


gen safety_net =1  if hh_s12q01==1 | hh_s13q01 ==1 
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (hhid)


tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${Uganda_GHS_W8_created_data}\safety_net_2019.dta", replace
*/
/*
**************************************
*Food Prices
**************************************
use "${Uganda_GHS_W8_raw_data}\GSEC15b.dta", clear
recast str17 hhid, force

use "${Uganda_GHS_W8_raw_data}\GSEC15c.dta", clear
recast str17 hhid, force
use "${Uganda_GHS_W8_raw_data}\GSEC15d.dta", clear
recast str17 hhid, force

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


save "${Uganda_GHS_W8_created_data}\food_prices.dta", replace




**************
*Net Buyers and Sellers
***************
use "${Uganda_GHS_W8_raw_data}\hh\GSEC15B.dta", clear
recast str17 hhid, force
use "${Uganda_GHS_W8_raw_data}\hh\GSEC15E.dta", clear

recast str17 hhid, force
merge m:1 zone state lga sector ea using "${Uganda_GHS_W5_created_data}\food_prices.dta", keepusing ( maize_price_mr rice_price_mr)


merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1



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
save "${Uganda_GHS_W8_created_data}\food_prices_2019.dta", replace

*/



*****************************
*Household Assests
****************************


*Total Value
use "${Uganda_GHS_W8_raw_data}\hh\GSEC14.dta",clear  
recast str17 hhid, force

*"${Uganda_GHS_W6_raw_data}\GSEC14B.dta"
*h14q04   = number of household asset owned
*h14q05   = total estimated value of the asset
des

merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1

tab h14q04
tab h14q05
gen hhasset_value = h14q04 * h14q05

sum hhasset_value, detail
collapse  (sum) hhasset_value, by (hhid)


merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1




sum hhasset_value, detail



replace hhasset_value = 0 if hhasset_value==.
tab hhasset_value,missing
sum hhasset_value,detail


foreach v of varlist  hhasset_value  {
	_pctile `v' [aw=weight] , p(5 95) 
	gen `v'_w=`v'
	replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 5%"
}


tab hhasset_value
tab hhasset_value_w, missing
sum hhasset_value hhasset_value_w, detail


gen real_hhvalue = hhasset_value_w  // / 0.9126678
sum hhasset_value_w real_hhvalue, detail


la var real_hhvalue "total value of household asset"
save "${Uganda_GHS_W8_created_data}\asset_value_2019.dta", replace




 
********************************************************************************
*FARM SIZE
*******************************************************************************



use "${Uganda_GHS_W8_raw_data}\agric\AGSEC2A.dta", clear 
recast str17 hhid, force
save "${Uganda_GHS_W8_created_data}\a.dta", replace

use "${Uganda_GHS_W8_raw_data}\agric\AGSEC2B.dta", clear 
recast str17 hhid, force
save "${Uganda_GHS_W8_created_data}\b.dta", replace




* plot area cultivated
use "${Uganda_GHS_W8_raw_data}\agric\AGSEC4A.dta", clear
recast str17 hhid, force
gen season = 1
append using "${Uganda_GHS_W8_raw_data}\agric\AGSEC4B.dta", gen (last)		
recast str17 hhid, force
replace season = 2 if last==1
label var season "Season = 1 if 2nd cropping season of 2017, 2 if 1st cropping season of 2018" // need to check again
ren cropID cropcode

gen plot_area = s4aq07 //values are in acres
replace plot_area = s4bq07 if plot_area==. //values are in acres
replace plot_area = plot_area * 0.404686 //conversion factor is 0.404686 ha = 1 acre.
ren plot_area ha_planted

gen percent_planted = s4aq09/100
replace percent_planted = s4bq09/100 if percent_planted==.
bys hhid parcelID pltid season : egen total_percent_planted = sum(percent_planted) 
duplicates tag hhid parcelID pltid season, g(dupes) 
gen missing_ratios = dupes > 0 & percent_planted == . 
bys hhid parcelID pltid season : egen total_missing = sum(missing_ratios) 
gen remaining_land = 1 - total_percent_planted if total_percent_planted < 1 
bys hhid parcelID pltid season : egen any_missing = max(missing_ratios)
*Fix monocropped plots
replace percent_planted = 1 if percent_planted == . & any_missing == 0 
*Fix plots with or without missing percentages that add up to 100% or more
replace percent_planted = 1/(dupes + 1) if any_missing == 1 & total_percent_planted >= 1 
replace percent_planted = percent_planted/total_percent_planted if total_percent_planted > 1
*Fix plots that add up to less than 100% and have missing percentages
replace percent_planted = remaining_land/total_missing if missing_ratios == 1 & percent_planted == . & total_percent_planted < 1 


*Bring everything together
collapse (max) ha_planted (sum) percent_planted, by(hhid parcelID pltid season)
gen plot_area = ha_planted / percent_planted
bys hhid parcelID season : egen total_plot_area = sum(plot_area)
gen plot_area_pct = plot_area/total_plot_area
keep hhid parcelID pltid season plot_area total_plot_area plot_area_pct ha_planted

merge m:1 hhid parcelID using "${Uganda_GHS_W8_created_data}\a.dta", nogen
merge m:1 hhid parcelID using "${Uganda_GHS_W8_created_data}\b.dta", nogen
*generating field_size
gen parcel_acre = s2aq4 //Used GPS estimation here to get parcel size in acres if we have it, but many parcels do not have GPS estimation
replace parcel_acre = s2aq04 if parcel_acre == . 
replace parcel_acre = s2aq5 if parcel_acre == . //replaced missing GPS values with farmer estimation, which is less accurate but has full coverage (and is also in acres)
replace parcel_acre = s2aq05 if parcel_acre == .
gen field_size = plot_area_pct*parcel_acre //using calculated percentages of plots (out of total plots per parcel) to estimate plot size using more accurate parcel measurements
replace field_size = field_size * 0.404686 //conversion factor is 0.404686 ha = 1 acre.
gen parcel_ha = parcel_acre * 0.404686
*cleaning up and saving the data
ren pltid plot_id
ren parcelID parcel_id
keep hhid parcel_id plot_id season field_size plot_area total_plot_area parcel_acre parcel_ha

sum field_size, detail

collapse (sum) field_size, by (hhid)


merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1

sum field_size, detail

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

ren field_size_w land_holding
keep hhid land_holding
label var land_holding "land holding in hectares"
save "${Uganda_GHS_W8_created_data}\land_holding_2019.dta", replace









/*
use "${Uganda_GHS_W8_raw_data}\agric\AGSEC2A.dta", clear

duplicates report hhid parcelID


*merge 1:1 hhid parcelID using "${Uganda_GHS_W8_raw_data}\agric\AGSEC2B.dta"


des


merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1

*s2aq4  size of parcel using GPS
*a2aq5 Size of parcel using farmer estimation


sum s2aq4, detail
sum s2aq5, detail



generate parcel_acre = s2aq4

 
replace parcel_acre = s2aq5 if parcel_acre == . 
gen area_meas_hectares = parcel_acre * 0.404686 //conversion factor is 0.404686 ha = 1 acre.
tab area_meas_hectares, missing
sum area_meas_hectares, detail




collapse (sum) area_meas_hectares, by (hhid)



merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)

keep if ag_rainy_19==1

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


ren field_size_w land_holding
keep HHID land_holding
label var land_holding "land holding in hectares"
save "${Uganda_GHS_W8_created_data}\land_holding_2019.dta", replace
*/







/*

*******************************
*Soil Quality
*******************************

use "${Uganda_GHS_W8_raw_data}\agric\AGSEC2A.dta", clear 
recast str17 hhid, force
save "${Uganda_GHS_W8_created_data}\a.dta", replace

use "${Uganda_GHS_W8_raw_data}\agric\AGSEC2B.dta", clear 
recast str17 hhid, force
save "${Uganda_GHS_W8_created_data}\b.dta", replace




* plot area cultivated
use "${Uganda_GHS_W8_raw_data}\agric\AGSEC4A.dta", clear
recast str17 hhid, force
gen season = 1
append using "${Uganda_GHS_W8_raw_data}\agric\AGSEC4B.dta", gen (last)		
recast str17 hhid, force
replace season = 2 if last==1
label var season "Season = 1 if 2nd cropping season of 2017, 2 if 1st cropping season of 2018" // need to check again
ren cropID cropcode

gen plot_area = s4aq07 //values are in acres
replace plot_area = s4bq07 if plot_area==. //values are in acres
replace plot_area = plot_area * 0.404686 //conversion factor is 0.404686 ha = 1 acre.
ren plot_area ha_planted

gen percent_planted = s4aq09/100
replace percent_planted = s4bq09/100 if percent_planted==.
bys hhid parcelID pltid season : egen total_percent_planted = sum(percent_planted) 
duplicates tag hhid parcelID pltid season, g(dupes) 
gen missing_ratios = dupes > 0 & percent_planted == . 
bys hhid parcelID pltid season : egen total_missing = sum(missing_ratios) 
gen remaining_land = 1 - total_percent_planted if total_percent_planted < 1 
bys hhid parcelID pltid season : egen any_missing = max(missing_ratios)
*Fix monocropped plots
replace percent_planted = 1 if percent_planted == . & any_missing == 0 
*Fix plots with or without missing percentages that add up to 100% or more
replace percent_planted = 1/(dupes + 1) if any_missing == 1 & total_percent_planted >= 1 
replace percent_planted = percent_planted/total_percent_planted if total_percent_planted > 1
*Fix plots that add up to less than 100% and have missing percentages
replace percent_planted = remaining_land/total_missing if missing_ratios == 1 & percent_planted == . & total_percent_planted < 1 


*Bring everything together
collapse (max) ha_planted (sum) percent_planted, by(hhid parcelID pltid season)
gen plot_area = ha_planted / percent_planted
bys hhid parcelID season : egen total_plot_area = sum(plot_area)
gen plot_area_pct = plot_area/total_plot_area
keep hhid parcelID pltid season plot_area total_plot_area plot_area_pct ha_planted

merge m:1 hhid parcelID using "${Uganda_GHS_W8_created_data}\a.dta", nogen
merge m:1 hhid parcelID using "${Uganda_GHS_W8_created_data}\b.dta", nogen
*generating field_size
gen parcel_acre = s2aq4 //Used GPS estimation here to get parcel size in acres if we have it, but many parcels do not have GPS estimation
replace parcel_acre = s2aq04 if parcel_acre == . 
replace parcel_acre = s2aq5 if parcel_acre == . //replaced missing GPS values with farmer estimation, which is less accurate but has full coverage (and is also in acres)
replace parcel_acre = s2aq05 if parcel_acre == .
gen field_size = plot_area_pct*parcel_acre //using calculated percentages of plots (out of total plots per parcel) to estimate plot size using more accurate parcel measurements
replace field_size = field_size * 0.404686 //conversion factor is 0.404686 ha = 1 acre.
gen parcel_ha = parcel_acre * 0.404686
*cleaning up and saving the data
ren pltid plot_id
*ren parcelID parcel_id
keep hhid parcelID plot_id season field_size plot_area total_plot_area parcel_acre parcel_ha

sum field_size, detail



collapse (sum) field_size, by (hhid parcelID)








count if field_size==.

save "${Uganda_GHS_W8_created_data}/parcelID.dta", replace


use "${Uganda_GHS_W8_raw_data}\agric\AGSEC2A.dta", replace
recast str17 hhid, force

sort hhid parcelID
duplicates report hhid parcelID
*duplicates drop HHID parcelID, force // 180 observations drop

merge 1:1 hhid parcelID using "${Uganda_GHS_W8_created_data}/parcelID.dta"




merge m:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta", gen(filter)


keep if ag_rainy_19==1

count if field_size==.


tab s2aq17
tab s2aq17, nolabel

ren s2aq17 soil_quality
tab soil_quality, missing
*replace soil_quality = 3 if soil_quality==5
tab soil_quality, missing

************generating the median soil quality**************

*egen median_soil_ea = median(soil_quality), by (ea)
egen median_soil_district  = median(soil_quality), by (district )
egen median_soil_stratum = median(soil_quality), by (stratum )
egen median_soil_region  = median(soil_quality), by (region )

egen med_soil = median(soil_quality)


*egen num_ea = count(soil_quality), by (ea)
egen num_region  = count(soil_quality), by (region )
egen num_stratum = count(soil_quality), by (stratum )
egen num_district  = count(soil_quality), by (district)


*tab num_ea
tab num_district
tab num_stratum
tab num_region




*replace soil_quality= median_soil_ea if soil_quality==.  & num_ea >= 40
*tab soil_quality, missing

replace soil_quality= median_soil_district if soil_quality==.  & num_district >= 55
tab soil_quality, missing


replace soil_quality= median_soil_stratum if soil_quality==.  & num_stratum >= 251
tab soil_quality, missing


replace soil_quality= median_soil_region if soil_quality==.  
tab soil_quality, missing


*replace soil_quality = med_soil if soil_quality ==. 

*tab soil_quality,missing



egen max_fieldsize = max(field_size), by (hhid)
replace max_fieldsize= . if max_fieldsize!= max_fieldsize
order field_size soil_quality hhid max_fieldsize
sort hhid
keep if field_size== max_fieldsize
sort hhid parcelID field_size

duplicates report hhid 

duplicates tag hhid, generate(dup)
tab dup
list field_size soil_quality dup


list hhid parcelID field_size soil_quality dup if dup>0

egen soil_qty_rev = min(soil_quality) 
gen soil_qty_rev2 = soil_quality

replace soil_qty_rev2 = soil_qty_rev if dup>0

list hhid parcelID  field_size soil_quality soil_qty_rev soil_qty_rev2 dup if dup>0



tab soil_qty_rev2, missing


/*
************generating the median soil quality**************

egen median_soil_ea = median(soil_qty_rev2), by (ea)
egen median_soil_district  = median(soil_qty_rev2), by (district )
egen median_soil_stratum = median(soil_qty_rev2), by (stratum )
egen median_soil_region  = median(soil_qty_rev2), by (region )

egen med_soil = median(soil_qty_rev2)


egen num_ea = count(soil_qty_rev2), by (ea)
egen numregion  = count(soil_qty_rev2), by (region )
egen num_stratum = count(soil_qty_rev2), by (stratum )
egen num_district  = count(soil_qty_rev2), by (district)


tab num_ea
tab num_district
tab num_stratum
tab num_region




replace soil_qty_rev2= median_soil_ea if soil_qty_rev2==.  & num_ea >= 13
tab soil_qty_rev2, missing

replace soil_qty_rev2= median_soil_district if soil_qty_rev2==.  & num_district >= 13
tab soil_qty_rev2, missing


replace soil_qty_rev2= median_soil_stratum if soil_qty_rev2==.  & num_stratum >= 13
tab soil_qty_rev2, missing


replace soil_qty_rev2= median_soil_region if soil_qty_rev2==.  
tab soil_qty_rev2, missing


replace soil_qty_rev2 = med_soil if soil_qty_rev2 ==. 

tab soil_qty_rev2,missing
*/





*replace soil_qty_rev2= 2 if soil_qty_rev2== 2.5
*tab soil_qty_rev2, missing

la define soil 1 "Good" 2 "fair" 3 "poor"

*la value soil soil_qty_rev2

collapse (mean) soil_qty_rev2 , by (hhid)
tab soil_qty_rev2, missing

la var soil_qty_rev2 "1=Good 2= fair 3=Bad "
save "${Uganda_GHS_W8_created_data}\soil_quality_2019.dta", replace

*/


















************************* Merging Agricultural Datasets ********************

use "${Uganda_GHS_W8_created_data}\purchased_fert_2019.dta", replace


*******All observations Merged*****



*merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\market_distance.dta"
*drop _merge
sort hhid


merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\savings_2019.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\credit_2019.dta"
*drop if _merge==2
drop _merge

sort hhid
merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\extension_visit_2019.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\demographics_2019.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\labor_age_2019.dta"
drop _merge
sort hhid
*merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\safety_net_2019.dta"
*drop _merge
sort hhid
*merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\food_prices_2019.dta"
*drop _merge
*sort hhid
*merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\geodata_2019.dta"
*drop _merge
*sort hhid
*merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\soil_quality_2019.dta"
*drop _merge
sort hhid
merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\asset_value_2019.dta"
drop _merge
sort hhid
merge 1:1 hhid using "${Uganda_GHS_W8_created_data}\land_holding_2019.dta"
drop _merge
sort hhid

 
merge 1:1 hhid using "${Uganda_GHS_W8_created_data}/ag_rainy_19.dta"
drop _merge
 
keep if ag_rainy_19==1
sort hhid
gen year = 2019




tabstat total_qty_w real_tpricefert_cens_mrk  num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr  pry_edu finish_pry finish_sec net_seller net_buyer safety_net mrk_dist_w



misstable summarize femhead  ext_acess attend_sch  informal_credit formal_credit  total_qty_w  real_tpricefert_cens_mrk  num_mem hh_headage real_hhvalue worker land_holding 

*credit formal_save informal_save mrk_dist_w
*proportion femhead credit formal_save informal_save ext_acess attend_sch  safety_net  soil_qty_rev2



*egen median_mrk = median(mrk_dist_w)
*replace mrk_dist_w= median_mrk if mrk_dist_w==.

*egen median_price = median(real_tpricefert_cens_mrk)
*replace real_tpricefert_cens_mrk= median_price if real_tpricefert_cens_mrk==.

*egen median_age = median(hh_headage)
*replace hh_headage= median_age if hh_headage==.


egen median_qty = median(total_qty_w)
replace total_qty_w= median_qty if total_qty_w==.

*egen median_soil = median(soil_qty_rev2)
*replace soil_qty_rev2= median_soil if soil_qty_rev2==.


misstable summarize femhead  ext_acess attend_sch informal_credit formal_credit  formal_save informal_save total_qty_w  real_tpricefert_cens_mrk  num_mem hh_headage real_hhvalue worker land_holding 

*credit formal_save informal_save safety_net soil_qty_rev2 mrk_dist_w
sum total_qty_w, detail
sum real_tpricefert_cens_mrk, detail
ren t0_hhid HHID 

save "${Uganda_GHS_W8_created_data}\Uganda_wave8_complete_data.dta", replace













*****************Appending all Nigeria Datasets*****************
use  "C:\Users\obine\Music\Documents\Project\codes\Uganda\Uganda_wave6\Uganda_wave6_complete_data.dta"  ,clear
append using "C:\Users\obine\Music\Documents\Project\codes\Uganda\Uganda_wave5\Uganda_wave5_complete_data.dta"
append using "C:\Users\obine\Music\Documents\Project\codes\Uganda\Uganda_wave8\Uganda_wave8_complete_data.dta"

order year




tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)

*real_maize_price_mr real_rice_price_mr informal_save pry_edu finish_pry finish_sec net_seller net_buyer 

misstable summarize femhead  ext_acess attend_sch    total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 formal_credit informal_credit

* safety_net

save "C:\Users\obine\Music\Documents\Project\codes\Uganda\completed18.dta", replace






use "C:\Users\obine\Music\Documents\Project\codes\Uganda\completed18.dta", clear




sort HHID year
order HHID

gen dummy = 1

collapse (sum) dummy, by (HHID)

tab dummy
keep if dummy==2
sort HHID


save "C:\Users\obine\Music\Documents\Project\codes\Uganda\subset_completed18.dta", replace


merge 1:m HHID using "C:\Users\obine\Music\Documents\Project\codes\Uganda\completed18.dta"




drop if _merge==2
sort HHID year
order HHID year




gen year_2015 = (year==2015)
gen year_2018 = (year==2018)

gen commercial_dummy = (total_qty_w>0)


misstable summarize femhead  ext_acess attend_sch    total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding soil_qty_rev2 formal_credit informal_credit

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


*formal_credit informal_credit safety_net

local time_avg "total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding femhead  ext_acess attend_sch soil_qty_rev2 formal_credit informal_credit"

foreach x in `time_avg' {

	bysort HHID : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk  land_holding ext_acess attend_sch  i.year, select (commercial_dummy= mrk_dist_w num_mem hh_headage real_hhvalue worker land_holding femhead ext_acess attend_sch soil_qty_rev2 formal_credit informal_credit  i.region i.year) twostep


predict yhat, xb


tab yhat, missing

sum yhat [aw= weight], detail




*gen lyhat = log(yhat)


local time_avg "yhat"

foreach x in `time_avg' {

	bysort HHID : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
tobit total_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker land_holding femhead ext_acess attend_sch soil_qty_rev2  formal_credit informal_credit TAvg_total_qty_w TAvg_mrk_dist_w TAvg_yhat TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_ext_acess TAvg_attend_sch  TAvg_soil_qty_rev2 TAvg_formal_credit TAvg_informal_credit i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w mrk_dist_w yhat num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


** CRE-TOBIT 
tobit total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding femhead ext_acess attend_sch soil_qty_rev2  formal_credit informal_credit TAvg_total_qty_w TAvg_mrk_dist_w TAvg_real_tpricefert_cens_mrk TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_land_holding TAvg_femhead TAvg_ext_acess TAvg_attend_sch  TAvg_soil_qty_rev2 TAvg_formal_credit TAvg_informal_credit i.region i.year, ll(0)

margins, predict(ystar(0,.)) dydx(*) post

tabstat total_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


























