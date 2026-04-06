********************************************************************************
* PSID Wealth Trajectories — Descriptive Analysis
* Produces age-profile charts for income, savings, and wealth by birth cohort.
*
* Data:  longfam[version]_ig.dta  (PSID long-format family file, cleaned)
* Output: xtline charts overlaid by birth cohort
********************************************************************************

clear all

*--- Globals/locals for paths and version ---*
local version  2023
local data_path "R:\mfa\raon\datasets\psid\clean_data"
local results_path "R:\mfa\raon\datasets\psid\results"
use "`data_path'\longfam`version'_ig.dta"

xtset rauid year
set scheme gg_hue


********************************************************************************
* 1. SAMPLE RESTRICTION
* Keep household heads only; retain survey years with consistent wealth modules.
* PSID switched to biennial collection in 1997, so we keep 1984, 1989, 1994,
* and all years ≥1999.
********************************************************************************

keep if rhead == 1 & inlist(year, 1984, 1989, 1994) | (rhead == 1 & year >= 1999)


********************************************************************************
* 2. BIRTH COHORT AND AGE-BIN CONSTRUCTION
********************************************************************************

*--- Birth year of household head ---*
gen rbyearhd = year - ragehd

*--- 5-year birth cohorts (cohort 1 covers a wider pre-war range) ---*
gen cohort = .
replace cohort =  1 if inrange(rbyearhd, 1900, 1940)
replace cohort =  2 if inrange(rbyearhd, 1941, 1945)
replace cohort =  3 if inrange(rbyearhd, 1946, 1950)
replace cohort =  4 if inrange(rbyearhd, 1951, 1955)
replace cohort =  5 if inrange(rbyearhd, 1956, 1960)
replace cohort =  6 if inrange(rbyearhd, 1961, 1965)
replace cohort =  7 if inrange(rbyearhd, 1966, 1970)
replace cohort =  8 if inrange(rbyearhd, 1971, 1975)
replace cohort =  9 if inrange(rbyearhd, 1976, 1980)
replace cohort = 10 if inrange(rbyearhd, 1981, 1985)
replace cohort = 11 if inrange(rbyearhd, 1986, 1990)
replace cohort = 12 if inrange(rbyearhd, 1991, 1995)
replace cohort = 13 if inrange(rbyearhd, 1996, 2000)
replace cohort = 14 if inrange(rbyearhd, 2001, 2005)

label define cohort_lbl  ///
     1 "1900–1940"  2 "1941–1945"  3 "1946–1950"  4 "1951–1955" ///
     5 "1956–1960"  6 "1961–1965"  7 "1966–1970"  8 "1971–1975" ///
     9 "1976–1980" 10 "1981–1985" 11 "1986–1990" 12 "1991–1995" ///
    13 "1996–2000" 14 "2001–2005"
label values cohort cohort_lbl

*--- 5-year age bins for head of household ---*
gen agebin = .
replace agebin =  1 if inrange(ragehd,  17,  20)
replace agebin =  2 if inrange(ragehd,  21,  25)
replace agebin =  3 if inrange(ragehd,  26,  30)
replace agebin =  4 if inrange(ragehd,  31,  35)
replace agebin =  5 if inrange(ragehd,  36,  40)
replace agebin =  6 if inrange(ragehd,  41,  45)
replace agebin =  7 if inrange(ragehd,  46,  50)
replace agebin =  8 if inrange(ragehd,  51,  55)
replace agebin =  9 if inrange(ragehd,  56,  60)
replace agebin = 10 if inrange(ragehd,  61,  65)
replace agebin = 11 if inrange(ragehd,  66,  70)
replace agebin = 12 if inrange(ragehd,  71,  75)
replace agebin = 13 if inrange(ragehd,  76,  80)
replace agebin = 14 if inrange(ragehd,  81, 100)

label define agebin_lbl  ///
     1  "17–20"   2  "21–25"   3  "26–30"   4  "31–35" ///
     5  "36–40"   6  "41–45"   7  "46–50"   8  "51–55" ///
     9  "56–60"  10  "61–65"  11  "66–70"  12  "71–75" ///
    13  "76–80"  14  "81–100"
label values agebin agebin_lbl


********************************************************************************
* 3. VARIABLE CONSTRUCTION
********************************************************************************

*--- Total inheritance received in a given wave (up to three inheritances) ---*
egen rvalinherit = rowtotal(rvalinherit_one rvalinherit_two rvalinherit_three)

*--- Cumulative lifetime inheritance (running sum within household) ---*
bysort rauid (year): gen rvalinherit_life = sum(rvalinherit)

*--- Non-equity debt ---*
* Pre-2011: PSID reports a single total-debt variable.
* Post-2011: PSID disaggregates debt; we sum the components.
gen rdebt_noeq_post2011 = .
replace rdebt_noeq_post2011 = rbusdebt + rothredebt + rccdebt + rstuddebt ///
                             + rlegdebt + rfamdebt + rothdebt if year >= 2011

gen rdebt_noeq = .
replace rdebt_noeq = ralldebt             if year <  2011
replace rdebt_noeq = rdebt_noeq_post2011  if year >= 2011

gen rnetbus_post2013 = . 
replace rnetbus_post2013 = rbus - rbusdebt

replace rnetbus = rnetbus_post2013 if year>=2013 

gen rnetothre_post2013 = . 
replace rnetothre_post2013 = rothre - rothredebt

replace rnetothre = rnetothre_post2013 if year>=2013 

*--- Checking account and Bonds ---*
* Pre-2019: PSID reports a single "wealth in checking accounts, treasury bonds, etc." variable.
* Post-2019: PSID disaggregates into checking/savings and bonds; we sum the components.
gen rcheck_post2019 = .
replace rcheck_post2019 = rcheck + rbonds if year >= 2019

gen rcheckbonds = .
replace rcheckbonds = rcheck             if year <  2019
replace rcheckbonds = rcheck_post2019  if year >= 2019

*--- Mortgage balance = home value − home equity ---*
gen     requity_neg = -requity
egen    rmortgage   = rowtotal(rhomevalue requity_neg)

*--- Total debt (including mortgage) and total assets ---*
egen rdebt_eq   = rowtotal(rdebt_noeq rmortgage)
egen rassets_eq = rowtotal(rwealth_eq rdebt_eq)

*--- Non-equity assets ---*
egen rassets_noeq = rowtotal(rwealth_noeq rdebt_noeq)

*--- Annual family savings = income − total expenditure ---*
* Expenditure data only available from 1999 onwards.
gen rtot_exp_neg = -rtot_exp
egen rsavings    = rowtotal(rfaminc rtot_exp_neg)
replace rsavings = . if year < 1999

*--- Home equity for owners only (missing for renters) ---*
gen requity_owners = requity
replace requity_owners = . if rhomeowner == 0

gen rmortgage_owners = rmortgage
replace rmortgage_owners = . if rhomeowner == 0

gen rhomevalue_owners = rhomevalue
replace rhomevalue_owners = . if rhomeowner == 0

gen rstocks_stockowners = rstocks
replace rstocks_stockowners = . if rstocks==0
 
********************************************************************************
* 4. KEEP ONLY NEEDED VARIABLES AND SCALE
********************************************************************************

local varlist "rfaminc rlabinchd rtransfer_inc rwealth_eq rwealth_noeq requity requity_owners rdebt_eq rassets_eq rdebt_noeq rassets_noeq rmortgage rmortgage_owners rhomevalue rhomevalue_owners rstocks rstocks_stockowners rvalinherit rvalinherit_life rsavings rtot_exp rvalveh rbus rnetbus rbusdebt rcheck rothre rnetothre rothredebt rothdebt rira rccdebt rstuddebt rmeddebt rlegdebt rfamdebt rbonds rothas rcheckbonds"

keep rauid year rfamweight ragehd rbyearhd cohort agebin cpi_u rhomeowner  rnumfu rnumkidsfu rracehd_bl rgenderhd_fem rmarstat_mar redhd rcurrstate rpsidstate rstate_grewup rsplitoff rfamcompch `varlist'

*--- Convert to thousands and deflate to real values in a single loop ---*
* All monetary variables are divided by 1,000 and then multiplied by cpi_u
* to express them in thousands of constant (2017) dollars.
foreach var of local varlist {
    replace `var'      = `var' / 1000
    gen     real_`var' = `var' * cpi_u
}

*--- Build the real-variable list for collapsing ---*
local real_varlist ""
foreach var of local varlist {
    local real_varlist "`real_varlist' real_`var'"
}

*--- Drop observations missing either classifier ---*
drop if missing(agebin) | missing(cohort)

compress 

save "`data_path'\long_psid_selected_data.dta", replace 

export delimited using R:\mfa\raon\datasets\psid\clean_data\long_psid_selected_data.csv, replace 