
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






local time_avg "total_qty_w subsidy_qty_w mrk_dist_w real_tpricefert_cens_mrk num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  subsidy_dummy femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


heckman real_tpricefert_cens_mrk subsidy_qty_w  mrk_dist_w real_maize_price_mr real_rice_price_mr  land_holding ext_acess attend_sch i.zone  i.year, select (commercial_dummy= subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 i.zone  i.year) twostep


predict price, xb


tab price, missing

sum price [aw= weight], detail


tabstat total_qty_w subsidy_qty_w mrk_dist_w price num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding [aweight = weight], statistics( mean median sd min max ) columns(statistics)


local time_avg "price"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}

** CRE-TOBIT 
*tobit total_qty_w price subsidy_qty_w mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding  femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_price TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)

*margins, predict(ystar(0,.)) dydx(*) post


****************************************************************









capture program drop boot_tobit
program define boot_tobit, rclass
    tobit total_qty_w subsidy_qty_w price mrk_dist_w num_mem hh_headage real_hhvalue worker real_maize_price_mr real_rice_price_mr land_holding femhead informal_save formal_credit informal_credit ext_acess attend_sch pry_edu finish_pry finish_sec safety_net net_seller net_buyer soil_qty_rev2 TAvg_total_qty_w TAvg_subsidy_qty_w TAvg_mrk_dist_w TAvg_price TAvg_num_mem TAvg_hh_headage TAvg_real_hhvalue TAvg_worker TAvg_real_maize_price_mr TAvg_real_rice_price_mr TAvg_land_holding TAvg_femhead TAvg_informal_save TAvg_formal_credit TAvg_informal_credit TAvg_ext_acess TAvg_attend_sch TAvg_pry_edu TAvg_finish_pry TAvg_finish_sec TAvg_safety_net TAvg_net_seller TAvg_net_buyer TAvg_soil_qty_rev2 i.zone i.year, ll(0)
    
    * Save coefficients
    matrix b = e(b)
    
    * Store coefficients in return list
    forvalues i = 1 / `=colsof(b)' {
        return scalar b`i' = b[1,`i']
    }
end

* Bootstrap the Tobit model
bootstrap b1 = r(b1) b2 = r(b2) b3 = r(b3) b4 = r(b4) b5 = r(b5) b6 = r(b6) b7 = r(b7) b8 = r(b8) b9 = r(b9) b10 = r(b10) b11 = r(b11) b12 = r(b12) b13 = r(b13) b14 = r(b14) b15 = r(b15) b16 = r(b16) b17 = r(b17) b18 = r(b18) b19 = r(b19) b20 = r(b20) b21 = r(b21) b22 = r(b22) b23 = r(b23) b24 = r(b24) b25 = r(b25) b26 = r(b26) b27 = r(b27) b28 = r(b28) b29 = r(b29) b30 = r(b30) b31 = r(b31) b32 = r(b32) b33 = r(b33) b34 = r(b34) b35 = r(b35) b36 = r(b36) b37 = r(b37) b38 = r(b38) b39 = r(b39) b40 = r(b40) b41 = r(b41) b42 = r(b42) b43 = r(b43) b44 = r(b44) b45 = r(b45) b46 = r(b46) b47 = r(b47) b48 = r(b48) b49 = r(b49) b50 = r(b50) b51 = r(b51) b52 = r(b52), reps(250) seed(12345): boot_tobit

* Save the results to the specified directory
save "C:\Users\obine\Music\Documents\Project\codes\boot_results.dta", replace







* Load the bootstrap results
use "C:\Users\obine\Music\Documents\Project\codes\boot_results", clear

* Assuming the original data is still in memory
*use mydata.dta, clear

* Create a new variable for the predicted margin
gen margin = .

* Define the number of bootstrap replications
local reps = _N  // Total number of observations in the bootstrap results

* Loop through each bootstrap replication to compute the margin
forvalues i = 1/`reps' {
    * Extract the coefficients from the saved results
    quietly {
        local b1 = b1[`i']
        local b2 = b2[`i']
        local b3 = b3[`i']
        local b4 = b4[`i']
        local b5 = b5[`i']
        local b6 = b6[`i']
        local b7 = b7[`i']
        local b8 = b8[`i']
        local b9 = b9[`i']
        local b10 = b10[`i']
        local b11 = b11[`i']
        local b12 = b12[`i']
        local b13 = b13[`i']
        local b14 = b14[`i']
        local b15 = b15[`i']
        local b16 = b16[`i']
        local b17 = b17[`i']
        local b18 = b18[`i']
        local b19 = b19[`i']
        local b20 = b20[`i']
        local b21 = b21[`i']
        local b22 = b22[`i']
        local b23 = b23[`i']
        local b24 = b24[`i']
        local b25 = b25[`i']
        local b26 = b26[`i']
        local b27 = b27[`i']
        local b28 = b28[`i']
        local b29 = b29[`i']
        local b30 = b30[`i']
        local b31 = b31[`i']
        local b32 = b32[`i']
        local b33 = b33[`i']
        local b34 = b34[`i']
        local b35 = b35[`i']
        local b36 = b36[`i']
        local b37 = b37[`i']
        local b38 = b38[`i']
        local b39 = b39[`i']
        local b40 = b40[`i']
        local b41 = b41[`i']
        local b42 = b42[`i']
        local b43 = b43[`i']
        local b44 = b44[`i']
        local b45 = b45[`i']
        local b46 = b46[`i']
        local b47 = b47[`i']
        local b48 = b48[`i']
        local b49 = b49[`i']
        local b50 = b50[`i']
        local b51 = b51[`i']
        local b52 = b52[`i']
    }

    * Compute the linear prediction using the coefficients
    quietly {
        gen yhat = `b1' + `b2'*subsidy_qty_w + `b3'*mrk_dist_w + `b4'*num_mem + `b5'*hh_headage + `b6'*real_hhvalue + `b7'*worker + `b8'*real_maize_price_mr + `b9'*real_rice_price_mr + `b10'*land_holding + `b11'*femhead + `b12'*informal_save + `b13'*formal_credit + `b14'*informal_credit + `b15'*ext_acess + `b16'*attend_sch + `b17'*pry_edu + `b18'*finish_pry + `b19'*finish_sec + `b20'*safety_net + `b21'*net_seller + `b22'*net_buyer + `b23'*soil_qty_rev2 + `b24'*TAvg_total_qty_w + `b25'*TAvg_subsidy_qty_w + `b26'*TAvg_mrk_dist_w + `b27'*TAvg_price + `b28'*TAvg_num_mem + `b29'*TAvg_hh_headage + `b30'*TAvg_real_hhvalue + `b31'*TAvg_worker + `b32'*TAvg_real_maize_price_mr + `b33'*TAvg_real_rice_price_mr + `b34'*TAvg_land_holding + `b35'*TAvg_femhead + `b36'*TAvg_informal_save + `b37'*TAvg_formal_credit + `b38'*TAvg_informal_credit + `b39'*TAvg_ext_acess + `b40'*TAvg_attend_sch + `b41'*TAvg_pry_edu + `b42'*TAvg_finish_pry + `b43'*TAvg_finish_sec + `b44'*TAvg_safety_net + `b45'*TAvg_net_seller + `b46'*TAvg_net_buyer + `b47'*TAvg_soil_qty_rev2 + /* Add remaining coefficients and their corresponding variables */
                `b48'.zone + `b49'.year

        * Calculate the mean of the predictions
        summarize yhat, meanonly
    }
    replace margin = r(mean) in `i'
}

* Summarize the bootstrapped margins
summarize margin, detail







use "C:\Users\obine\Music\Documents\Project\codes\boot_results", clear
describe
list in 1/10








