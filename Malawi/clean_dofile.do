
*Heckman
*use "C:\Users\obine\Music\Documents\Project\codes\without_median\Real_heckman.dta", clear

*use "C:\Users\obine\Music\Documents\Project\codes\without_median\Nominal_heckman.dta", clear















*Median
use "C:\Users\obine\Music\Documents\Project\codes\Malawi\Malawi_complete_data.dta", clear
use "C:\Users\obine\Music\Documents\Project\codes\Malawi\Malawi_complete_datan.dta", clear


gen dummy = 1

collapse (sum) dummy, by (HHID)
tab dummy
keep if dummy==4
sort HHID

*save "C:\Users\obine\Music\Documents\Project\codes\Malawi\subset_Real_median", replace
save "C:\Users\obine\Music\Documents\Project\codes\Malawi\subset_Nominal_median", replace



*merge 1:m HHID using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Malawi_complete_data.dta", gen(clean)

merge 1:m HHID using "C:\Users\obine\Music\Documents\Project\codes\Malawi\Malawi_complete_datan.dta", gen(clean)
drop if clean==2

*save "C:\Users\obine\Music\Documents\Project\codes\Malawi\Real_median.dta", replace
save "C:\Users\obine\Music\Documents\Project\codes\Malawi\Nominal_median.dta", replace


gen year_2010 = (year==2010)
gen year_2013 = (year==2013)
gen year_2016 = (year==2016)
gen year_2019 = (year==2019)

gen commercial_dummy = (total_qty_w>0)

tab commercial_dummy



tabstat total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker maize_price_mr hhasset_value_w land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


misstable summarize subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 total_qty_w subsidy_qty_w dist_admarc_w real_tpricefert_cens_mrk num_mem hh_headage_mrk worker maize_price_mr hhasset_value_w land_holding

proportion subsidy_dummy femhead informal_save formal_credit informal_credit ext_access attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2



sum real_tpricefert_cens_mrk, detail




*save "C:\Users\obine\Music\Documents\Project\codes\Malawi\complete\Real_median.dta", replace
save "C:\Users\obine\Music\Documents\Project\codes\Malawi\complete\Nominal_median.dta", replace

