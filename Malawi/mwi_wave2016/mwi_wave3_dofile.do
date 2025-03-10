










clear



global mwi_GHS_W3_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\MWI_2010-2019_IHPS_v06_M_Stata (1)"
global mwi_GHS_W3_created_data  "C:\Users\obine\Music\Documents\Project\codes\Malawi\mwi_wave2016"





********************************************************************************
* AG FILTER *
********************************************************************************


use "${mwi_GHS_W3_raw_data}\ag_mod_a_16.dta", clear

keep y3_hhid ag_b101
rename (ag_b101) (ag_rainy_16)

tab ag_rainy_16
save "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", replace






************************
*Geodata Variables
************************

use "${mwi_GHS_W3_raw_data}\PlotGeovariablesIHPSY3_16.dta", clear

destring twi, replace force
recast byte twi



collapse (max) slope elevation twi, by (y3_hhid)

merge 1:m y3_hhid using  "${mwi_GHS_W3_raw_data}\HouseholdGeovariablesIHPSY3.dta"

merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren y3_hhid HHID

ren slope  plot_slope
ren elevation  plot_elevation
ren twi   plot_wetness
ren af_bio_12  annual_precipitation
ren af_bio_1  annual_mean_temp
ren dist_admarc dist_admarc



tab1 plot_slope plot_elevation plot_wetness, missing


sum annual_mean_temp, detail
sum annual_precipitation, detail
sum dist_admarc, detail

collapse (max) plot_slope plot_elevation plot_wetness annual_precipitation annual_mean_temp dist_admarc, by (HHID)
sort HHID

ren HHID y3_hhid
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen(hhids)
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

************winzonrizing fertilizer market price
foreach v of varlist  dist_admarc  {
	_pctile `v' [aw=weight] , p(5 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}

sum dist_admarc dist_admarc_w, detail

keep y3_hhid plot_slope plot_elevation plot_wetness annual_precipitation annual_mean_temp dist_admarc_w


la var plot_slope "slope of plot"
la var plot_elevation "Elevation of plot"
la var plot_wetness "Potential wetness index of plot"
save "${mwi_GHS_W3_created_data}\geodata_2016.dta", replace



********************************
*Subsidized Fertilizer (Coupon)
********************************
use "${mwi_GHS_W3_raw_data}\ag_mod_e2_16.dta",clear 
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1
ren y3_hhid HHID
*ag_e02 institution where they bought coupon
*ag_e08a quantity of subsidized fertilizer
*ag_e08b qty units (kg,g,50kg etc)
*ag_e15 cost of coupon used 
*ag_e16a ag_e16b institution where they bought coupon
*ag_e07 (input codes ) 1-6 is for fertilizer



*various types of input (inorganic fert, other chemicals)
*************Getting Subsidized quantity *******************
ren ag_e07 input_type  
tab input_type
gen subsidy_qty = ag_e08a if  input_type<=6
tab subsidy_qty,missing

*conversion  to kg

tab ag_e08b
tab ag_e08b,nolabel
replace subsidy_qty = 0.001*subsidy_qty if ag_e08b==1
tab subsidy_qty,missing
replace subsidy_qty = 2*subsidy_qty if ag_e08b==3
tab subsidy_qty,missing
replace subsidy_qty = 3*subsidy_qty if ag_e08b==4
tab subsidy_qty,missing
replace subsidy_qty = 5*subsidy_qty if ag_e08b==5
tab subsidy_qty,missing
replace subsidy_qty = 10*subsidy_qty if ag_e08b==6
tab subsidy_qty,missing
replace subsidy_qty = 50*subsidy_qty if ag_e08b==7
tab subsidy_qty,missing
replace subsidy_qty = 0 if subsidy_qty==.
tab subsidy_qty,missing
*checcking that the conversion is correct
*br ag_e08a ag_e08b subsidy_qty ag_e15 if  input_type<=6


*************Getting Subsidized Dummy Variable *******************


gen subsidy_dummy  = (subsidy_qty!=0 )
tab subsidy_dummy,missing



collapse (sum)subsidy_qty (max) subsidy_dummy, by (HHID)


ren HHID y3_hhid
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen(hhids)
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren y3_hhid HHID


************winzonrizing subsidy_qty
foreach v of varlist  subsidy_qty  {
	_pctile `v' [aw=weight] , p(1 99) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}

tab subsidy_qty
tab subsidy_qty_w, missing
sum subsidy_qty subsidy_qty_w, detail


keep HHID subsidy_dummy subsidy_qty_w

label var subsidy_qty_w  "Quantity of Fertilizer Purchased with coupon in kg"

label var subsidy_dummy "=1 if acquired any fertilizer using coupon"
save "${mwi_GHS_W3_created_data}\subsidized_fert_2016.dta", replace



/*
*****************************************************
*Dummy Variables for Fertilizer coupon by years
*****************************************************
use "${mwi_GHS_W3_raw_data}\ag_mod_e3_16.dta",clear 
ren y3_hhid HHID
*ag_e27a subsidy in 2012
*ag_e27b subsidy in 2013
*ag_e27c subsidy in 2014
*ag_e27d subsidy in 2015

gen subsidy_dummy_12 =1 if ag_e27a==1
replace subsidy_dummy_12 =0 if subsidy_dummy_12==.

gen subsidy_dummy_13 =1 if ag_e27b==1
replace subsidy_dummy_13 =0 if subsidy_dummy_13==.

gen subsidy_dummy_14 =1 if ag_e27c==1
replace subsidy_dummy_14 =0 if subsidy_dummy_14==.

gen subsidy_dummy_15 =1 if ag_e27d==1
replace subsidy_dummy_15 =0 if subsidy_dummy_15==.

tab subsidy_dummy_12,missing
tab subsidy_dummy_13,missing
tab subsidy_dummy_14,missing
tab subsidy_dummy_15,missing


collapse (max) subsidy_dummy_12 subsidy_dummy_13 subsidy_dummy_14 subsidy_dummy_15, by (HHID)
la var subsidy_dummy_12 "=1 if received subsidy from fertilizer in 2012"
la var subsidy_dummy_13 "=1 if received subsidy from fertilizer in 2013"
la var subsidy_dummy_14 "=1 if received subsidy from fertilizer in 2014"
la var subsidy_dummy_15 "=1 if received subsidy from fertilizer in 2015"
save "${mwi_GHS_W3_created_data}\subsidized_by_years.dta", replace

*/




**********************
*HH_ids
**********************



use "${mwi_GHS_W3_raw_data}\hh_mod_a_filt_16.dta",clear 


*ren hh_a02a ta
rename panelweight_2016 weight
rename region region
lab var region "1=North, 2=Central, 3=South"
gen rural = (reside==2)
lab var rural "1=Household lives in a rural area"
keep case_id y3_hhid region district ta ea_id rural weight  
sort y3_hhid region district ea_id
save "${mwi_GHS_W3_created_data}\hhids.dta", replace



********************
*Community Data
********************
use "${mwi_GHS_W3_raw_data}\com_cd_16.dta",clear 
duplicates report ea_id
sort ea_id
duplicates drop ea_id, force
sort ea_id
merge 1:m ea_id using  "${mwi_GHS_W3_created_data}\hhids.dta"


*com_cd16  distance to daily market   com_cd15 (1= market in commumity)
*com_cd16b  units of distance to daily market
*com_cd18a  distance to large weekly market  com_cd17 (1= market in commumity)
*com_cd18b  units of distance to weekly market


***daily market***
gen mrk_dist = com_cd16
tab mrk_dist,missing

replace mrk_dist = 0.001*mrk_dist if com_cd16b==1
*br com_cd16 com_cd16b mrk_dist
egen median_case = median(mrk_dist), by (region district  ea_id)
egen median_district = median(mrk_dist), by (region district )
egen median_region = median(mrk_dist), by (region)

replace mrk_dist =0 if mrk_dist==. & com_cd15==1
tab mrk_dist, missing

replace mrk_dist = median_case if mrk_dist==. 
replace mrk_dist = median_district if mrk_dist==. 
replace mrk_dist = median_region if mrk_dist==. 
tab mrk_dist, missing

*replace mrk_dist= 48 if mrk_dist>=48 & mrk_dist<. 
*tab mrk_dist, missing

***weekly market***
gen mrk2_dist = com_cd18a 
tab mrk2_dist,missing
replace mrk2_dist = 0.001*mrk2_dist if com_cd18b==1
*br com_cd16a com_cd16b mrk_dist

egen median2_case = median(mrk2_dist), by (region district  ea_id)
egen median2_district = median(mrk2_dist), by (region district )
egen median2_region = median(mrk2_dist), by (region )


replace mrk2_dist =0 if mrk2_dist==. & com_cd17==1
tab mrk2_dist, missing

replace mrk2_dist = median2_case if mrk2_dist==. 
replace mrk2_dist = median2_district if mrk2_dist==. 
replace mrk2_dist = median2_region if mrk2_dist==. 
tab mrk2_dist, missing


sort region district  ea_id
collapse (max) mrk2_dist, by (y3_hhid region district ea_id)
tab mrk2_dist, missing

la var mrk2_dist "=distance to the weekly market"


save "${mwi_GHS_W3_created_data}\community", replace





*********************************************** 
*Purchased Fertilizer
***********************************************

use "${mwi_GHS_W3_raw_data}\ag_mod_f_16.dta",clear 
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen (household)
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

*merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\community", keepusing ( mrk2_dist)


ren y3_hhid HHID
*ag_f15 source of comercial fertilzer purchase1
*ag_f25 source of comercial fertilzer purchase2
*ag_f35 source of comercial fertilzer purchase3

*ag_f16a qty purchased1
*ag_f26a qty purchased2
*ag_f36a qty purchased3
*ag_f44a qty organic fertilizer


*ag_f16b qty units1
*ag_f26b qty units2
*ag_f36b qty units3

*ag_f19 value of fert1
*ag_f29 value of fert2

*ag_f0c input type codes for commercial (<=5 for fertilizer)



*****Coversion of fertilizer's to kilogram using 
tab ag_f16b
tab ag_f16b,nolabel
tab ag_f26b
tab ag_f26b,nolabel


replace ag_f16a = 0.001*ag_f16a if ag_f16b==1 
replace ag_f16a = 2*ag_f16a if ag_f16b==3 
replace ag_f16a = 3*ag_f16a if ag_f16b==4
replace ag_f16a = 5*ag_f16a if ag_f16b==5
replace ag_f16a = 10*ag_f16a if ag_f16b==6
replace ag_f16a = 50*ag_f16a if ag_f16b==7
replace ag_f16a = 0.001*ag_f16a if ag_f16b==9
tab ag_f16a,missing

replace ag_f26a = 0.001*ag_f26a if ag_f26b==1 
replace ag_f26a = 2*ag_f26a if ag_f26b==3 
replace ag_f26a = 3*ag_f26a if ag_f26b==4
replace ag_f26a = 5*ag_f26a if ag_f26b==5
replace ag_f26a = 10*ag_f26a if ag_f26b==6
replace ag_f26a = 50*ag_f26a if ag_f26b==7
tab ag_f26a,missing



***fertilzer total quantity, total value & total price****

gen com_fert1_qty=  ag_f16a if ag_f0c>=1 &ag_f0c<=6
gen com_fert2_qty= ag_f26a if ag_f0c>=1 & ag_f0c<=6

gen com_fert1_val= ag_f19 if ag_f0c>=1 & ag_f0c<=6
gen com_fert2_val= ag_f29  if ag_f0c>=1 & ag_f0c<=6
tab com_fert1_qty

*br ag_f16a ag_f19 ag_f0c com_fert1_qty com_fert1_val if ag_f0c>6

egen total_qty = rowtotal(com_fert1_qty com_fert2_qty)
tab  total_qty, missing

egen total_valuefert  = rowtotal(com_fert1_val com_fert2_val)
tab total_valuefert ,missing

gen tpricefert  = total_valuefert /total_qty 
tab tpricefert 

gen tpricefert_cens  = tpricefert 
replace tpricefert_cens = 530 if tpricefert_cens > 530 & tpricefert_cens < .
replace tpricefert_cens = 100 if tpricefert_cens < 100
tab tpricefert_cens, missing



egen medianfert_pr_ea_id = median(tpricefert_cens), by (ea_id)
egen medianfert_pr_district  = median(tpricefert_cens), by (district )
egen medianfert_pr_case_id = median(tpricefert_cens), by (case_id)
egen medianfert_pr_region  = median(tpricefert_cens), by (region )



egen num_fert_pr_ea_id = count(tpricefert_cens), by (ea_id)
egen num_fert_pr_district  = count(tpricefert_cens), by (district )
egen num_fert_pr_case_id = count(tpricefert_cens), by (case_id)
egen num_fert_pr_region  = count(tpricefert_cens), by (region )



tab num_fert_pr_case_id
tab num_fert_pr_ea_id
tab num_fert_pr_district
tab num_fert_pr_region



gen tpricefert_cens_mrk = tpricefert_cens

replace tpricefert_cens_mrk = medianfert_pr_case_id if tpricefert_cens_mrk ==. & num_fert_pr_case_id >= 7
tab tpricefert_cens_mrk ,missing

replace tpricefert_cens_mrk = medianfert_pr_ea_id if tpricefert_cens_mrk ==. & num_fert_pr_ea_id >= 7
tab tpricefert_cens_mrk,missing

replace tpricefert_cens_mrk = medianfert_pr_district if tpricefert_cens_mrk ==. & num_fert_pr_district >= 7
tab tpricefert_cens_mrk ,missing


replace tpricefert_cens_mrk = medianfert_pr_region if tpricefert_cens_mrk ==. & num_fert_pr_region >= 7
tab tpricefert_cens_mrk,missing








***********
*organic fertilizer
***********
gen org_fert = 1 if ag_f43==1
tab org_fert,missing
replace org_fert =0 if org_fert==.
tab org_fert,missing






collapse (sum) total_qty  total_valuefert  (max) org_fert tpricefert_cens_mrk, by(HHID)

ren HHID y3_hhid
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen(hhids)
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren  y3_hhid HHID

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


gen rea_tpricefert_cens_mrk = tpricefert_cens_mrk   //0.8133064
gen real_tpricefert_cens_mrk = rea_tpricefert_cens_mrk
tab real_tpricefert_cens_mrk
sum real_tpricefert_cens_mrk, detail

keep HHID total_qty_w  total_valuefert org_fert real_tpricefert_cens_mrk





label var org_fert  "1= if used organic fertilizer"
label var total_qty_w "Total quantity of Commercial Fertilizer Purchased in kg"
label var total_valuefert "Total value of commercial fertilizer purchased in naira"
label var real_tpricefert_cens_mrk  "price of commercial fertilizer purchased in naira"
sort HHID


save "${mwi_GHS_W3_created_data}\commercial_fert_2016.dta", replace





************************************************
*Savings 
************************************************

use "${mwi_GHS_W3_raw_data}\hh_mod_t_16.dta",clear 
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren y3_hhid HHID

*hh_t08 1 &2 if you can build up savings or save a little

gen informal_save = 1 if hh_t08==1 | hh_t08==2
tab informal_save,missing
replace informal_save =0 if informal_save==.
tab informal_save,missing

collapse (max)informal_save, by (HHID)
la var informal_save "=1 if you were able to save up a little"
save "${mwi_GHS_W3_created_data}\informal_savings_2016.dta", replace



*******************************************************
*Credit access 
*******************************************************


use "${mwi_GHS_W3_raw_data}\hh_mod_s1_16.dta",clear
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1 
ren y3_hhid HHID
*hh_s01 borrowed on credit
*hh_s04 source of credit
tab hh_s01
tab hh_s04
tab hh_s04,nolabel
 gen formal_credit  =1 if hh_s01==1 & hh_s04 ==10 | hh_s04 ==11 | hh_s04 ==12
 tab formal_credit,missing
 replace formal_credit =0 if formal_credit ==.
 tab formal_credit,missing
 

 
 gen informal_credit  =1 if  hh_s01==1 & hh_s04 <=9 | hh_s04 ==13
 tab informal_credit,missing
replace informal_credit =0 if informal_credit ==.
 tab informal_credit,missing


 collapse (max) formal_credit informal_credit, by (HHID)
 la var formal_credit  "=1 if borrowed from formal credit group"
 la var informal_credit  "=1 if borrowed from informal credit group"
save "${mwi_GHS_W3_created_data}\credit_access_2016.dta", replace





******************************* 
*Extension Visit 
*******************************



use "${mwi_GHS_W3_raw_data}\ag_mod_t1_16.dta",clear 
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1
ren y3_hhid HHID
ren ag_t01 ext_access 

tab ext_access, missing
tab ext_access, nolabel

replace ext_access = 0 if ext_access==2 | ext_access==.
tab ext_access, missing
collapse (max) ext_access, by (HHID)
la var ext_access "=1 if received advise from extension services"
save "${mwi_GHS_W3_created_data}\Extension_access_2016.dta", replace




*********************************
*Demographics 
*********************************



use "${mwi_GHS_W3_raw_data}\hh_mod_b_16.dta",clear 


merge 1:1 y3_hhid PID using "${mwi_GHS_W3_raw_data}\hh_mod_c_16.dta", gen (household)
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta"
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren y3_hhid HHID
*hh_b03 sex 
*hh_b04 relationshiop to head
*hh_b05a age (years)
*hhsize actual hhsize

sort HHID PID 
 
gen num_mem  = 1


******** female head****

gen femhead  = 0
replace femhead = 1 if hh_b03== 2 & hh_b04==1
tab femhead,missing

********Age of HHead***********
ren hh_b05a hh_age
gen hh_headage  = hh_age if hh_b04==1

tab hh_headage

replace hh_headage = 90 if hh_headage > 90 & hh_headage < .
tab hh_headage
tab hh_headage, missing


************generating the median age**************

egen median_headage_ea_id = median(hh_headage), by (ea_id)
egen median_headage_district  = median(hh_headage), by (district )
egen median_headage_case_id  = median(hh_headage), by (case_id )
egen median_headage_region  = median(hh_headage), by (region )



egen num_headage_ea_id = count(hh_headage), by (ea_id)
egen num_headage_district  = count(hh_headage), by (district )
egen num_headage_case_id = count(hh_headage), by (case_id )
egen num_headage_region  = count(hh_headage), by (region )


tab num_headage_case_id
tab num_headage_ea_id
tab num_headage_district
tab num_headage_region



gen hh_headage_mrk  = hh_headage

replace hh_headage_mrk = median_headage_case_id if hh_headage_mrk ==. & num_headage_case_id >= 7
tab hh_headage_mrk,missing

replace hh_headage_mrk = median_headage_ea_id if hh_headage_mrk ==. & num_headage_ea_id >= 7
tab hh_headage_mrk,missing

replace hh_headage_mrk = median_headage_district if hh_headage_mrk ==. & num_headage_district >= 7
tab hh_headage_mrk,missing

replace hh_headage_mrk = median_headage_region if hh_headage_mrk ==. & num_headage_region >=7
tab hh_headage_mrk,missing




********************Education****************************************************
*hh_c06 attend_school
*hh_c08 highest_education qualification



ren  hh_c06 attend_sch 
tab attend_sch
replace attend_sch = 0 if attend_sch ==2
tab attend_sch, nolabel


replace hh_c08= 0 if attend_sch==0
tab hh_c08
tab hh_b04 if _merge==1



 label list hh_c08
tab hh_c08 if hh_b04==1
replace hh_c08 = 2 if hh_c08==. &  hh_b04==1

*** Education Dummy Variable*****
 label list hh_c08

gen pry_edu  = 1 if hh_c08 < 8 & hh_b04==1
tab pry_edu ,missing
gen finish_pry = 1 if hh_c08 >= 8 & hh_c08 < 14 & hh_b04==1
tab finish_pry ,missing
gen finish_sec = 1 if hh_c08 >= 14 & hh_b04==1
tab finish_sec ,missing

replace pry_edu =0 if pry_edu==. & hh_b04==1
replace finish_pry =0 if finish_pry==. & hh_b04==1
replace finish_sec =0 if finish_sec==. & hh_b04==1
tab pry_edu  if hh_b04==1 , missing
tab finish_pry if hh_b04==1 , missing 
tab finish_sec if hh_b04==1 , missing

collapse (sum) num_mem (max) region weight hh_headage_mrk femhead  attend_sch  pry_edu  finish_pry  finish_sec, by (HHID)
la var num_mem "household size"
la var femhead  "=1 if head is female"
la var hh_headage_mrk  "age of household head in years"
la var attend_sch "=1 if respondent attended school"
la var pry_edu "=1 if household head attended pry school"
la var finish_pry  "=1 if household head finished pry school"
la var finish_sec "=1 if household head finished sec school"
save "${mwi_GHS_W3_created_data}\demographics_2016.dta", replace

********************************* 
*Labor Age 
*********************************

use "${mwi_GHS_W3_raw_data}\hh_mod_b_16.dta",clear 

merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren y3_hhid HHID
ren hh_b05a hh_age

gen worker = 1
replace worker = 0 if hh_age < 15 | hh_age > 65

tab worker,missing
sort HHID
collapse (sum) worker, by (HHID)
la var worker "number of members age 15 and older and less than 65"
sort HHID

save "${mwi_GHS_W3_created_data}\labor_age_2016.dta", replace


********************************
*Safety Net
********************************

use "${mwi_GHS_W3_raw_data}\hh_mod_r_16.dta",clear 
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1
ren y3_hhid HHID
*hh_r01 received assistance
gen safety_net =1 if hh_r01==1 
tab safety_net,missing
replace safety_net =0 if safety_net==.
tab safety_net,missing
collapse (max) safety_net, by (HHID)
tab safety_net
la var safety_net "=1 if received cash transfer, cash for work, food for work or other assistance"
save "${mwi_GHS_W3_created_data}\safety_net_2016.dta", replace


**************************************
*Food Prices
**************************************
use "${mwi_GHS_W3_raw_data}\hh_mod_g1_16.dta",clear 
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta"
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren y3_hhid HHID
*hh_g04a   qty purchased by household (7days)
*hh_g04b hh_g04b_os     units purchased by household (7days)
*hh_g05    cost of purchase by household (7days)




*********Getting the price for maize only**************
* one congo is 1.5kg
*one derica is half a congo (0.75kg)
*one mudu is 1.5kg/5 (one congo is 5times one mudu) (0.3kg)
//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//2. 50kg     	    50
//3. 90kg     	    90
//4,5congo(pail)    1.5
//17.derica(tin)    0.75
//19.millitre       0.001
//9. pieces	        0.35

gen conversion =1
replace conversion=1 if hh_g04b=="1" | hh_g04b =="15"
gen food_size=1 //This makes it easy for me to copy-paste existing code rather than having to write a new block
replace conversion = food_size*50 if hh_g04b=="2" 
replace conversion = food_size*90 if hh_g04b=="3" 
replace conversion = food_size*0.001 if hh_g04b=="18" |hh_g04b=="19" 
replace conversion = food_size*1.5 if hh_g04b=="4" |	hh_g04b=="5"
replace conversion = food_size*0.75 if hh_g04b=="17"
replace conversion = food_size*0.35 if hh_g04b=="9"			
tab conversion, missing

label list hh_g02

gen food_price_maize = hh_g04a* conversion if hh_g02==104

gen maize_price  = hh_g05/food_price_maize if hh_g02==104

*br hh_g04b conversion hh_g04a hh_g05 food_price_maize maize_price hh_g02 if hh_g02<=500

sum maize_price,detail
tab maize_price

*replace maize_price = 600 if maize_price >600 & maize_price<.
*replace maize_price = 50 if maize_price< 50
tab maize_price,missing

egen median_pr_ea_id = median(maize_price), by (ea_id)
egen median_pr_district  = median(maize_price), by (district )
egen median_pr_case_id = median(maize_price), by (case_id )
egen median_pr_region  = median(maize_price), by (region )


egen num_pr_ea_id = count(maize_price), by (ea_id)
egen num_pr_district  = count(maize_price), by (district )
egen num_pr_case_id = count(maize_price), by (case_id )
egen num_pr_region = count(maize_price), by (region )





tab num_pr_ea_id
tab num_pr_district
tab num_pr_case_id
tab num_pr_region


gen maize_price_mr  = maize_price

replace maize_price_mr = median_pr_case_id if maize_price_mr==.  & num_pr_case_id>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_ea_id if maize_price_mr==. & num_pr_ea_id >= 2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_district if maize_price_mr==. & num_pr_district>=2
tab maize_price_mr,missing

replace maize_price_mr = median_pr_region if maize_price_mr==. & num_pr_region>=2
tab maize_price_mr,missing



*********Getting the price for rice only**************
* one congo is 1.5kg
*one derica is half a congo (0.75kg)
*one mudu is 1.5kg/5 (one congo is 5times one mudu) (0.3kg)
//   Unit           Conversion Factor for maize
//1. Kilogram       1
//18.gram        	0.001
//15.litre     		1
//2. 50kg     	    50
//3. 90kg     	    90
//4,5congo(pail)    1.5
//17.derica(tin)    0.75
//19.millitre       0.001
//9. pieces	        0.35




gen food_price_rice = hh_g04a* conversion if hh_g02==106

gen rice_price = hh_g05/food_price_rice if hh_g02==106

*br hh_g04b conversion hh_g04a hh_g05 food_price_rice rice_price hh_g02 if hh_g02<=500

sum rice_price,detail
tab rice_price

replace rice_price = 1000 if rice_price >1000 & rice_price<.
replace rice_price = 25 if rice_price< 25
tab rice_price,missing


egen medianr_pr_ea_id = median(rice_price), by (ea_id)
egen medianr_pr_district  = median(rice_price), by (district )
egen medianr_pr_case_id  = median(rice_price), by (case_id )
egen medianr_pr_region  = median(rice_price), by (region )


egen numr_pr_ea_id = count(rice_price), by (ea_id)
egen numr_pr_district  = count(rice_price), by (district )
egen numr_pr_case_id = count(rice_price), by (case_id )
egen numr_pr_region = count(rice_price), by (region )





tab numr_pr_ea_id
tab numr_pr_district
tab numr_pr_case_id
tab numr_pr_region


gen rice_price_mr  = rice_price

replace rice_price_mr = medianr_pr_case_id if rice_price_mr==.  & numr_pr_case_id >= 5
tab rice_price_mr,missing

replace rice_price_mr = medianr_pr_ea_id if rice_price_mr==. & numr_pr_ea_id >= 5
tab rice_price_mr,missing

replace rice_price_mr = medianr_pr_district if rice_price_mr==. & numr_pr_district>= 5
tab rice_price_mr,missing

replace rice_price_mr = medianr_pr_region if rice_price_mr==. & numr_pr_region>= 5
tab rice_price_mr,missing



**************
*Net Buyers and Sellers
***************
*hh_g04a from purchases
*hh_g06a from own production

//They are using the same conversion
*br hh_g04a hh_g04b hh_g06a hh_g06b if (hh_g04a !=. & hh_g04a !=0) & (hh_g06a !=. & hh_g06a !=0)
tab hh_g04a
tab hh_g06a

replace hh_g04a = 0 if hh_g04a<=0 |hh_g04a==.
tab hh_g04a,missing
replace hh_g06a = 0 if hh_g06a<=0 |hh_g06a==.
tab hh_g06a,missing

gen net_seller = 1 if hh_g06a > hh_g04a
tab net_seller,missing
replace net_seller=0 if net_seller==.
tab net_seller,missing

gen net_buyer = 1 if hh_g06a < hh_g04a
tab net_buyer,missing
replace net_buyer=0 if net_buyer==.
tab net_buyer,missing

ren maize_price_mr real_maize_price

gen maize_price_mr = real_maize_price // 0.8133064


ren rice_price_mr real_rice_price

gen rice_price_mr = real_rice_price // 0.8133064






collapse  (max) net_seller net_buyer maize_price_mr  rice_price_mr, by(HHID)
la var net_seller "1= if respondent is a net seller"
la var net_buyer "1= if respondent is a net buyer"
label var maize_price_mr  "commercial price of maize in naira"
label var rice_price_mr "commercial price of rice in naira"
sort HHID
save "${mwi_GHS_W3_created_data}\food_prices_2016.dta", replace






*****************************
*Household Assests
****************************


use "${mwi_GHS_W3_raw_data}\hh_mod_l_16.dta",clear 
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta"
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren y3_hhid HHID
*hh_l03 qty of items
*hh_l05 scrap value of items

gen hhasset_value  = hh_l03*hh_l05
tab hhasset_value,missing
sum hhasset_value,detail
replace hhasset_value = 1000000 if hhasset_value > 1000000 & hhasset_value <.
*replace hhasset_value = 50 if hhasset_value <50
tab hhasset_value

************generating the mean vakue**************
egen mean_val_ea_id = mean(hhasset_value), by (ea_id)
egen mean_val_district  = mean(hhasset_value), by (district )
egen mean_val_case_id  = mean(hhasset_value), by (case_id )
egen mean_val_region = mean(hhasset_value), by (region)


egen num_val_ea_id = count(hhasset_value), by (ea_id)
egen num_val_district  = count(hhasset_value), by (district )
egen num_val_case_id  = count(hhasset_value), by (case_id )
egen num_val_region = count(hhasset_value), by (region)


tab num_val_ea_id
tab num_val_district
tab num_val_case_id
tab num_val_region



replace hhasset_value = mean_val_case_id if hhasset_value ==. & num_val_case_id >= 30
tab hhasset_value,missing
replace hhasset_value = mean_val_ea_id if hhasset_value ==. & num_val_ea_id >= 30
tab hhasset_value,missing
replace hhasset_value = mean_val_district if hhasset_value ==. & num_val_district >= 30
tab hhasset_value,missing

replace hhasset_value = mean_val_region if hhasset_value ==. & num_val_region >= 30
tab hhasset_value,missing



collapse (sum) hhasset_value, by (HHID)

ren HHID y3_hhid
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen(hhids)
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren  y3_hhid HHID



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


*Winzorized variables**

*winsor2 hhasset_value, suffix(_s) cuts(5 95) 

*summarize  hhasset_value_w hhasset_value_s , detail

gen rea_hhvalue = hhasset_value_w   //0.8133064
gen real_hhvalue = rea_hhvalue/1000
sum hhasset_value_w real_hhvalue, detail
keep HHID hhasset_value_w

la var hhasset_value_w "total value of household asset"

save "${mwi_GHS_W3_created_data}\hhasset_value_2016.dta", replace





 ********************************************************************************
* PLOT AREAS *
********************************************************************************


use "${mwi_GHS_W3_raw_data}\ag_mod_c_16.dta",clear 
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen (household)
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1
gen season=0 //rainy
ren plotid plot_id
* Counting acreage
gen area_acres_est = ag_c04a if ag_c04b == 1 										//Self-report in acres - rainy season 
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==.	//Self-report in square meters
 									

* GPS MEASURE
gen area_acres_meas = ag_c04c														//GPS measure - rainy

gen field_size= area_acres_meas
tab field_size, missing
tab area_acres_est, missing
replace field_size = area_acres_est  if field_size==.
tab field_size, missing

sum field_size, detail
replace field_size = 0.66 if field_size==.
tab field_size, missing


gen field_size_ha = field_size* (1/2.47105)
tab field_size_ha, missing


ren y3_hhid HHID
collapse (sum) field_size_ha, by (HHID)


ren HHID y3_hhid
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen(hhids)
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1

ren  y3_hhid HHID

foreach v of varlist  field_size_ha  {
	_pctile `v' [aw=weight] , p(5 99) 
	gen `v'_w=`v'
	replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top 5% & bottom 1%"
}

tab field_size_ha
tab field_size_ha_w, missing
sum field_size_ha field_size_ha_w, detail



sort HHID
ren field_size_ha_w land_holding 
label var land_holding  "land holding in hectares"
save "${mwi_GHS_W3_created_data}\land_holding_2016.dta", replace





*******************************
*Soil Quality
*******************************

********************************************************************************


use "${mwi_GHS_W3_raw_data}\ag_mod_c_16.dta",clear 
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen (household)
merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1
gen season=0 //rainy
ren plotid plot_id
* Counting acreage
gen area_acres_est = ag_c04a if ag_c04b == 1 										//Self-report in acres - rainy season 
replace area_acres_est = (ag_c04a*2.47105) if ag_c04b == 2 & area_acres_est ==.		//Self-report in hectares
replace area_acres_est = (ag_c04a*0.000247105) if ag_c04b == 3 & area_acres_est ==.	//Self-report in square meters
 									

* GPS MEASURE
gen area_acres_meas = ag_c04c														//GPS measure - rainy

gen field_size= area_acres_meas
tab field_size, missing
tab area_acres_est, missing
replace field_size = area_acres_est  if field_size==.
tab field_size, missing

sum field_size, detail
replace field_size = 0.66 if field_size==.
tab field_size, missing


gen field_size_ha = field_size* (1/2.47105)
tab field_size_ha, missing





ren y3_hhid HHID
*egen any = rowmiss(plot_id)

*drop if any==1

sort HHID
save "${mwi_GHS_W3_created_data}\field_size.dta", replace






use "${mwi_GHS_W3_raw_data}\ag_mod_d_16.dta" , clear
merge m:1 y3_hhid using  "${mwi_GHS_W3_created_data}\hhids.dta", gen (household)

merge m:1 y3_hhid using "${mwi_GHS_W3_created_data}\ag_rainy_16.dta", gen(filte)

keep if ag_rainy_16==1
ren plotid plot_id
ren y3_hhid HHID


merge m:1 HHID gardenid plot_id using "${mwi_GHS_W3_created_data}\field_size.dta"

ren ag_d22 soil_quality


*how to get them my max fieldsize
egen max_fieldsize = max(field_size_ha), by (HHID)
replace max_fieldsize= . if max_fieldsize!= max_fieldsize
order field_size_ha soil_quality HHID max_fieldsize
sort HHID
keep if field_size_ha== max_fieldsize
sort HHID plot_id field_size

duplicates report HHID

duplicates tag HHID, generate(dup)
tab dup
list field_size_ha soil_quality dup


list HHID plot_id  field_size_ha soil_quality dup if dup>0

egen soil_qty_rev = min(soil_quality) 
gen soil_qty_rev2 = soil_quality

replace soil_qty_rev2 = soil_qty_rev if dup>0

list HHID plot_id  field_size_ha soil_quality soil_qty_rev soil_qty_rev2 dup if dup>0
tab soil_qty_rev2, missing


**************should we give missing values the median?
collapse (mean) soil_qty_rev2 , by (HHID)
la define soil 1 "Good" 2 "fair" 3 "poor"

la values soil soil_qty_rev2
la var soil_qty_rev2 "1=Good 2= fair 3=poor "
save "${mwi_GHS_W3_created_data}\soil_quality_2016.dta", replace






use "${mwi_GHS_W3_created_data}\commercial_fert_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\commercial_fert_2016.dta", replace

use "${mwi_GHS_W3_created_data}\subsidized_fert_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\subsidized_fert_2016.dta", replace

use "${mwi_GHS_W3_created_data}\informal_savings_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\informal_savings_2016.dta", replace


use "${mwi_GHS_W3_created_data}\credit_access_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\credit_access_2016.dta", replace

use "${mwi_GHS_W3_created_data}\Extension_access_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\Extension_access_2016.dta", replace

use "${mwi_GHS_W3_created_data}\demographics_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\demographics_2016.dta", replace

use "${mwi_GHS_W3_created_data}\labor_age_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\labor_age_2016.dta", replace

use "${mwi_GHS_W3_created_data}\safety_net_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\safety_net_2016.dta", replace

use "${mwi_GHS_W3_created_data}\food_prices_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\food_prices_2016.dta", replace

use "${mwi_GHS_W3_created_data}\soil_quality_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\soil_quality_2016.dta", replace

use "${mwi_GHS_W3_created_data}\hhasset_value_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\hhasset_value_2016.dta", replace

use "${mwi_GHS_W3_created_data}\land_holding_2016.dta", replace
ren HHID y3_hhid
save "${mwi_GHS_W3_created_data}\land_holding_2016.dta", replace









************************* Merging Agricultural Datasets ********************

use "${mwi_GHS_W3_created_data}\commercial_fert_2016.dta", replace


*******All observations Merged*****


merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\subsidized_fert_2016.dta", gen (subsidized)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\informal_savings_2016.dta", gen (savings)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\credit_access_2016.dta", gen (credit)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\Extension_access_2016.dta", gen (extension)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\demographics_2016.dta", gen (demographics)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\labor_age_2016.dta", gen (labor)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\safety_net_2016.dta", gen (safety)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\food_prices_2016.dta", gen (foodprices)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\geodata_2016.dta", gen (geodata)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\soil_quality_2016.dta", gen (soil)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\hhasset_value_2016.dta", gen (asset)
sort y3_hhid
merge 1:1 y3_hhid using "${mwi_GHS_W3_created_data}\land_holding_2016.dta", gen (land)
sort y3_hhid

merge 1:1 y3_hhid using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\analyzed_data\complete_files"

gen year = 2016
sort y3_hhid

keep if _merge==3







tabstat total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker maize_price_mr hhasset_value_w land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


misstable summarize subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker maize_price_mr hhasset_value_w land_holding

proportion subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2




save "${mwi_GHS_W3_created_data}\Malawi_wave3_completedata_2016n.dta", replace

