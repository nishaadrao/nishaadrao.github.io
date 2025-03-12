** This file builds the Bartik shock at the CBSA level

** This file currently pools the data for the following years: 1975, 1980, 1990, 1994, 1998-2005, 2007(2)2017. 
** Years left: 1984-1989, 1991-1993, 1995-1997. 

** Note that Part 2, i.e. merge with 1994 shares and calculate growth rates is where you actually calculate the Bartik shock and this is missing for all years. Need to define a "rolling" decadal Bartik shock measure, i.e. 1989-1999, 1990-2000, 1991-2001, 1992-2002, ... 2009-2019. 


* MERGE WITH CBSA CROSSWALK AND COLLAPSE, THEN PREPARE WIDE CBSA FILE
clear
* PREPARE CBSA CROSSWALK FOR MERGE
import delimited "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw.txt", encoding(ISO-8859-2) clear 
rename msa cbsa
gen county = fipstate*1000 + fipscty
replace county = 12025 if county==12086 //adjust Miami, FL

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta", replace

/*

use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsatocountycrosswalk.dta"
duplicates drop fipscounty, force

destring fipscounty, gen(county)
destring cbsa, gen(cbsa_code)

keep county cbsa_code 
rename cbsa_code cbsa 

replace county = 12025 if county==12086 //adjust Miami, FL
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cw_cty_cbsa.dta", replace
*/

forval i=75(5)80{
	
	
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa19`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa19`i' = total(emp_cbsa19`i')
gen emp_sh_cbsa19`i' = emp_cbsa19`i'/tot_emp_cbsa19`i'

drop if cbsa==.
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp`i'cbsa_12naics_nocons.dta", replace
	
}



forval i=81/87{
	
	
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/new_cbp`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa19`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa19`i' = total(emp_cbsa19`i')
gen emp_sh_cbsa19`i' = emp_cbsa19`i'/tot_emp_cbsa19`i'

drop if cbsa==.
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp`i'cbsa_12naics_nocons.dta", replace
	
}

forval i=88/99{
	
	
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa19`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa19`i' = total(emp_cbsa19`i')
gen emp_sh_cbsa19`i' = emp_cbsa19`i'/tot_emp_cbsa19`i'

drop if cbsa==.
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp`i'cbsa_12naics_nocons.dta", replace
	
}

forval i=0/6{
	
	
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp0`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa200`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa200`i' = total(emp_cbsa200`i')
gen emp_sh_cbsa200`i' = emp_cbsa200`i'/tot_emp_cbsa200`i'

drop if cbsa==.
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp0`i'cbsa_12naics_nocons.dta", replace
	
}

forval i=7(2)9{
	
	
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp0`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa200`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa200`i' = total(emp_cbsa200`i')
gen emp_sh_cbsa200`i' = emp_cbsa200`i'/tot_emp_cbsa200`i'

drop if cbsa==.
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp0`i'cbsa_12naics_nocons.dta", replace
	
}


forval i=11(2)17{
	
	
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa20`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa20`i' = total(emp_cbsa20`i')
gen emp_sh_cbsa20`i' = emp_cbsa20`i'/tot_emp_cbsa20`i'

drop if cbsa==.
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp`i'cbsa_12naics_nocons.dta", replace
	
}


	
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp16co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa2016
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa2016 = total(emp_cbsa2016)
gen emp_sh_cbsa2016 = emp_cbsa2016/tot_emp_cbsa2016

drop if cbsa==.
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp16cbsa_12naics_nocons.dta", replace


/*




use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp94co_12naics.dta", clear
merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa1994
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa1994 = total(emp_cbsa1994)
gen emp_sh_cbsa1994 = emp_cbsa1994/tot_emp_cbsa1994

drop if cbsa==.
save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp94cbsa_12naics_nocons.dta", replace


use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp99co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa1999
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp99cbsa_12naics_nocons.dta", replace

forval i=1(2)9{

use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp0`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa200`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp0`i'cbsa_12naics_nocons.dta", replace


}

forval i=0(2)4{

use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp0`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)
rename emp_county emp_cbsa200`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp0`i'cbsa_12naics_nocons.dta", replace


}


forval i=11(2)17{

use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp`i'co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)

rename emp_county emp_cbsa20`i'
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp`i'cbsa_12naics_nocons.dta", replace


}

*NEW*

*1998
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp98co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp2012_naics (mean) naics12_code, by(cbsa naics12)

rename emp2012_naics emp_cbsa1998
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp98cbsa_12naics_nocons.dta", replace

*1980
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp80co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp2012_naics (mean) naics12_code, by(cbsa naics12)

rename emp2012_naics emp_cbsa1980
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa1980 = total(emp_cbsa1980)
gen emp_sh_cbsa1980 = emp_cbsa1980/tot_emp_cbsa1980



drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp80cbsa_12naics_nocons.dta", replace

*1975
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp75co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp2012_naics (mean) naics12_code, by(cbsa naics12)

rename emp2012_naics emp_cbsa1975
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

bysort cbsa: egen tot_emp_cbsa1975 = total(emp_cbsa1975)
gen emp_sh_cbsa1975 = emp_cbsa1975/tot_emp_cbsa1975


drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp75cbsa_12naics_nocons.dta", replace

*1990
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp90co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp2012_naics (mean) naics12_code, by(cbsa naics12)

rename emp2012_naics emp_cbsa1990
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp90cbsa_12naics_nocons.dta", replace

*2016
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbp16co_12naics.dta", clear
replace county=12025 if county==12086 //adjust Miami, FL

merge m:1 county using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa_county_cbp_cw_clean.dta" //cw_cty_cbsa.dta"

collapse (sum) emp_county (mean) naics12_code, by(cbsa naics12)

rename emp_county emp_cbsa2016
drop if naics12_code<200
drop if naics12_code>230 & naics12_code<240

drop if cbsa==.

save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp16cbsa_12naics_nocons.dta", replace

*END NEW*
*/
clear 
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp17cbsa_12naics_nocons.dta"


joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp16cbsa_12naics_nocons.dta", unm(b)
drop _merge


forval i=11(2)15{
joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp`i'cbsa_12naics_nocons.dta", unm(b)
drop _merge
}

forval i=7(2)9{
joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp0`i'cbsa_12naics_nocons.dta", unm(b)
drop _merge

}

forval i=0/6{
joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp0`i'cbsa_12naics_nocons.dta", unm(b)
drop _merge

}


forval i=81/99{
joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp`i'cbsa_12naics_nocons.dta", unm(b)
drop _merge

}


forval i=75(5)80{
joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp`i'cbsa_12naics_nocons.dta", unm(b)
drop _merge

}

/*
joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp99cbsa_12naics_nocons.dta", unm(b)
drop _merge

joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp94cbsa_12naics_nocons.dta", unm(b)
drop _merge

joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp80cbsa_12naics_nocons.dta", unm(b)
drop _merge

joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp98cbsa_12naics_nocons.dta", unm(b)
drop _merge

joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp90cbsa_12naics_nocons.dta", unm(b)
drop _merge


joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp75cbsa_12naics_nocons.dta", unm(b)
drop _merge

joinby cbsa naics12_code using "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbp16cbsa_12naics_nocons.dta", unm(b)
drop _merge
*/


save "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbpcbsa_wide_nocons.dta", replace



* MERGE WITH USA DATA AND 1994 SHARES AND CALCULATE GROWTH RATES

* (2) CBSA:
use "/Users/nishaadrao/Documents/bartik/cbp/data/county/cbsa/cbpcbsa_wide_nocons.dta", clear

merge m:1 naics12 using "/Users/nishaadrao/Documents/bartik/cbp/data/us/cbpusa_wide_nocons.dta"

forval i=1980/2006{
	gen natemp_loo`i' = emp_usa`i' - emp_cbsa`i'
}
forval i=2007(2)2017{
	gen natemp_loo`i' = emp_usa`i' - emp_cbsa`i'
}

*gen natemp_loo1980 = emp_usa1980 - emp_cbsa1980

gen natemp_loo2016 = emp_usa2016 - emp_cbsa2016

/*
forval i=1975(5)1980{
	gen natemp_loo`i' = emp_usa`i' - emp_cbsa`i'
}
*/
forval i = 1999(2)2017{
//gen natemp_loo`i' = emp_usa`i' - emp_cbsa`i'

local j = `i'-2
gen natemp_gr_loo`i' = (natemp_loo`i' - natemp_loo`j')/natemp_loo`j'
gen bartik_nocons_cbsa`i' = natemp_gr_loo`i'*emp_sh_cbsa1994 

}
gen natemp_gr9917_loo = (natemp_loo2017 - natemp_loo1999)/natemp_loo1999
gen bartik9917_nocons_cbsa_ld = natemp_gr9917_loo*emp_sh_cbsa1994 

*gen natemp_loo2016 = emp_usa2016 - emp_cbsa2016

gen natemp_gr9916_loo = (natemp_loo2016 - natemp_loo1999)/natemp_loo1999
gen bartik9916_nocons_cbsa_ld = natemp_gr9916_loo*emp_sh_cbsa1994 

/*
gen natemp_loo1998 = emp_usa1998 - emp_cbsa1998
gen natemp_loo1990 = emp_usa1990 - emp_cbsa1990
*/

gen natemp_gr8099_loo = (natemp_loo1998 - natemp_loo1980)/natemp_loo1980
gen bartik8099_nocons_cbsa_ld = natemp_gr8099_loo*emp_sh_cbsa1975

gen natemp_gr8090_loo = (natemp_loo1990 - natemp_loo1980)/natemp_loo1980
gen bartik8090_nocons_cbsa_ld = natemp_gr8090_loo*emp_sh_cbsa1975



forval i=1999(2)2017{
	
	local h = `i'-6
	local j = `i'-10
	local k = `i'-15
	local p = `i'-11
	gen natemp_gr_loo_10yr`i' = (natemp_loo`i' - natemp_loo`j')/natemp_loo`j'
	//gen bartik_nocons_cbsa_roll`i' = natemp_gr_loo_10yr`i'*emp_sh_cbsa`k'
	gen bartik_nocons_cbsa10yr_roll`i' = natemp_gr_loo_10yr`i'*emp_sh_cbsa`p'
	
	gen natemp_gr_loo_6yr`i' = (natemp_loo`i' - natemp_loo`h')/natemp_loo`h'
	gen bartik_nocons_cbsa6yr_roll`i' = natemp_gr_loo_6yr`i'*emp_sh_cbsa`p'
	
	gen bartik_nocons_cbsa2yr_roll`i' = natemp_gr_loo`i'*emp_sh_cbsa`p'
	
}

forval i=1990/2007{
	cap gen natemp_gr_loo_10yr`i' = (natemp_loo`i' - natemp_loo`j')/natemp_loo`j'
	gen bartik_cbsa10yr_roll`i' = natemp_gr_loo_10yr`i'*emp_sh_cbsa1975

}

forval i=2009(2)2017{
	gen bartik_cbsa10yr_roll`i' = natemp_gr_loo_10yr`i'*emp_sh_cbsa1975
}
*gen emp9917_gr_nocons_cbsa = (emp_cbsa2017 - emp_cbsa1999)/emp_cbsa1999

collapse (sum) bartik_nocons_cbsa* bartik_cbsa10yr* bartik9917_nocons_cbsa_ld bartik9916_nocons_cbsa_ld bartik8099_nocons_cbsa_ld bartik8090_nocons_cbsa_ld, by(cbsa)

drop if cbsa==.
drop if bartik_nocons_cbsa2001==0 & bartik_nocons_cbsa2003==0 & bartik_nocons_cbsa2005==0 & bartik_nocons_cbsa2007==0 & bartik_nocons_cbsa2009==0 & bartik_nocons_cbsa2011==0 & bartik_nocons_cbsa2013==0 & bartik_nocons_cbsa2015==0 & bartik_nocons_cbsa2017==0

save "/Users/nishaadrao/Documents/bartik/cbp/clean_data/bartik_cbsa_wide_nocons.dta", replace
reshape long bartik_cbsa10yr_roll bartik_nocons_cbsa bartik_nocons_cbsa10yr_roll bartik_nocons_cbsa6yr_roll bartik_nocons_cbsa2yr_roll, i(cbsa) j(year)

save "/Users/nishaadrao/Documents/bartik/cbp/clean_data/bartik_cbsa_long_nocons.dta", replace

bysort year: egen bartik_nocons_cbsa10yr_roll_std = std(bartik_nocons_cbsa10yr_roll)
bysort year: egen bartik_cbsa10yr_roll_std = std(bartik_cbsa10yr_roll)
bysort year: egen bartik_nocons_cbsa6yr_roll_std = std(bartik_nocons_cbsa6yr_roll)
bysort year: egen bartik_nocons_cbsa2yr_roll_std = std(bartik_nocons_cbsa2yr_roll)

//bysort year: egen bartik_nocons_cbsa2_roll_std = std(bartik_nocons_cbsa2_roll)

bysort year: egen bartik_nocons_cbsa_std = std(bartik_nocons_cbsa)

save "/Users/nishaadrao/Documents/bartik/cbp/clean_data/bartik_cbsa_long_nocons.dta", replace


