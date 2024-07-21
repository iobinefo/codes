
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2011_ERSS_v02_M_Stata8\sect3_pp_w1.dta" , clear

collapse (mean) saq01, by (household_id)


merge 1:m household_id using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2013_ESS_v03_M_STATA\sect3_pp_w2.dta" 

collapse (mean) saq01, by (household_id)



merge 1:m household_id using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2015_ESS_v03_M_STATA\Post-Planting\sect3_pp_w3.dta" 

collapse (mean) saq01, by (household_id)



merge 1:m household_id using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2018_ESS_v03_M_Stata\sect3_pp_w4.dta"


collapse (mean) saq01, by (household_id)


merge 1:m household_id using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\Ethiopia\ETH_2021_ESPS-W5_v01_M_Stata\sect3_pp_w5.dta" 