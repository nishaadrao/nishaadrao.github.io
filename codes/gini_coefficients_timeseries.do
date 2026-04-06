

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

keep if rhead == 1 
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
********************************************************************************
* 4. KEEP ONLY NEEDED VARIABLES AND SCALE
********************************************************************************

local varlist "rfaminc rlabinchd rtransfer_inc rwealth_eq rwealth_noeq requity requity_owners rdebt_eq rassets_eq rdebt_noeq rassets_noeq rmortgage rmortgage_owners rhomevalue rhomevalue_owners rvalinherit rvalinherit_life rsavings rtot_exp"

keep rauid year rfamweight ragehd cpi_u rhomeowner `varlist'

*--- Convert to thousands and deflate to real values in a single loop ---*
* All monetary variables are divided by 1,000 and then multiplied by cpi_u
* to express them in thousands of constant (2017) dollars.
foreach var of local varlist {
    replace `var'      = `var' / 1000
    gen     real_`var' = `var' * cpi_u
	gen pos_`var' = `var' if `var'>0
	gen pos_real_`var' = real_`var' if real_`var'>0
}



* Years you want: 1984, 1989, 1994, and 1999,2001,...,2023
*local years 1984 1989 1994

forvalues y = 1984/1997{
	local years `years' `y'
}
forvalues y = 1999(2)2023 {
    local years `years' `y'
}

*----------------------------
* 2) Variables to compute Gini for (add more here)
*----------------------------
local ginivars pos_rlabinchd rwealth_eq rwealth_noeq requity_owners

*----------------------------
* 3) Compute Ginís with ineqdec0 (zeros/negatives allowed)
*    Store results long: year x variable
*----------------------------
tempfile gini_long
tempname posth
postfile `posth' int year str32 varname double gini using `gini_long', replace

foreach y of local years {
    foreach v of local ginivars {

        * Only run if there is any nonmissing data (and positive weights)
        count if year==`y' & !missing(`v') & rfamweight>0
        if r(N) > 0 {
            quietly ineqdec0 `v' [aw=rfamweight] if year==`y'
            local g = r(gini)
        }
        else {
            local g = .
        }

        post `posth' (`y') ("`v'") (`g')
    }
}
postclose `posth'

use `gini_long', clear
format gini %9.4f
sort year varname

*----------------------------
* 4) Optional: reshape to wide "table" (one row per year)
*----------------------------
reshape wide gini, i(year) j(varname) string
order year, first
list, noobs sep(0)