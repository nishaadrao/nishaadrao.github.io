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

keep rauid year rfamweight ragehd rbyearhd cohort agebin cpi_u rhomeowner `varlist'

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


********************************************************************************
* 5. COLLAPSE TO AGE-BIN × COHORT CELLS (MEAN, MEDIAN, 75th PERCENTILE)
********************************************************************************

* We run three separate collapses and merge them back together.
* Each is saved as a tempfile. Assertions guard against unexpected mismatches.

*--- 5a. Cell means ---*
preserve
    collapse (mean) `varlist' `real_varlist' rhomeowner [aw = rfamweight], by(agebin cohort)
    rename (r*) (r*_mean)                 // suffix all vars for clarity after merge
    tempfile allmeans
    save `allmeans'
restore

*--- 5b. Cell medians ---*
preserve
    collapse (p50) `varlist' `real_varlist' [aw = rfamweight], by(agebin cohort)
    rename (r*) (r*_p50)
    tempfile allp50
    save `allp50'
restore

*--- 5c. Cell 75th percentiles ---*
collapse (p75) `varlist' `real_varlist' [aw = rfamweight], by(agebin cohort)
rename (r*) (r*_p75)

*--- Merge all three statistic files ---*
merge 1:1 agebin cohort using `allmeans'
assert _merge == 3         // all cells should match across collapses
drop _merge

merge 1:1 agebin cohort using `allp50'
assert _merge == 3
drop _merge

xtset cohort agebin


********************************************************************************
* 6. CHARTS
* xtline with overlay plots each cohort as a separate connected line.
* x-axis shows every other age bin label to reduce crowding.
********************************************************************************

local xlab_opt "xlab(1(2)13, valuelabel)"
local xti      "xtitle(Age Group)"

*--- Homeownership ---*
xtline rhomeowner_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Homeownership %")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\homeownership_mean.pdf", as(pdf) replace

*--- REAL Total family income ---*
xtline real_rfaminc_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Total Family Income (000s of 2017$)")        ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\income\real_faminc_mean.pdf", as(pdf) replace

xtline real_rfaminc_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Total Family Income (000s of 2017$)")         ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\income\real_faminc_p50.pdf", as(pdf) replace

*--- NOMINAL Total family income ---*
xtline rfaminc_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Total Family Income (000s of $)")        ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\income\nom_faminc_mean.pdf", as(pdf) replace

xtline rfaminc_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Total Family Income (000s of $)")         ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\income\nom_faminc_p50.pdf", as(pdf) replace

*--- REAL Family savings ---*
xtline real_rsavings_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Family Savings (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\savings\real_savings_mean.pdf", as(pdf) replace

xtline real_rsavings_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Family Savings (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\savings\real_savings_p50.pdf", as(pdf) replace

*--- NOMINAL Family savings ---*
xtline rsavings_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Family Savings (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\savings\nom_savings_mean.pdf", as(pdf) replace

xtline rsavings_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Family Savings (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\savings\nom_savings_p50.pdf", as(pdf) replace

*--- REAL Family expenditure ---*
xtline real_rtot_exp_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Family Expenditure (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\consumption\real_tot_exp_mean.pdf", as(pdf) replace

xtline real_rtot_exp_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Family Expenditure (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\consumption\real_tot_exp_p50.pdf", as(pdf) replace

*--- NOMINAL Family expenditure ---*
xtline rtot_exp_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Family Expenditure (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\consumption\nom_tot_exp_mean.pdf", as(pdf) replace

xtline rtot_exp_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Family Expenditure (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\consumption\nom_tot_exp_p50.pdf", as(pdf) replace

*--- REAL Net Worth ---*
xtline real_rwealth_eq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Net Worth with Home Equity (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\real_nw_mean.pdf", as(pdf) replace

xtline real_rwealth_eq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Net Worth with Home Equity (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\real_nw_p50.pdf", as(pdf) replace

*--- NOMINAL Net Worth ---*
xtline rwealth_eq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Net Worth with Home Equity (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\nom_nw_mean.pdf", as(pdf) replace

xtline rwealth_eq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Net Worth with Home Equity (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\nom_nw_p50.pdf", as(pdf) replace

*--- REAL Net Worth sans Home Equity ---*
xtline real_rwealth_noeq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Net Worth sans Home Equity (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\real_nw_noeq_mean.pdf", as(pdf) replace

xtline real_rwealth_noeq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Net Worth sans Home Equity (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\real_nw_noeq_p50.pdf", as(pdf) replace

*--- NOMINAL Net Worth sans Home Equity ---*
xtline rwealth_noeq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Net Worth sans Home Equity (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\nom_nw_noeq_mean.pdf", as(pdf) replace

xtline rwealth_noeq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Net Worth sans Home Equity (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\nom_nw_noeq_p50.pdf", as(pdf) replace

*--- REAL Home Equity (Owners only) ---*
xtline real_requity_owners_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Home Equity (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\real_eq_owners_mean.pdf", as(pdf) replace

xtline real_requity_owners_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Home Equity (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\real_eq_owners_p50.pdf", as(pdf) replace

*--- NOMINAL Home Equity (Owners only) ---*
xtline requity_owners_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Home Equity (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\nom_eq_owners_mean.pdf", as(pdf) replace

xtline requity_owners_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Home Equity (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\networth\nom_eq_owners_p50.pdf", as(pdf) replace

*--- REAL Assets ---*
xtline real_rassets_eq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Assets with Home (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\real_assets_eq_mean.pdf", as(pdf) replace

xtline real_rassets_eq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Assets with Home (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\real_assets_eq_p50.pdf", as(pdf) replace

*--- NOMINAL Assets ---*
xtline rassets_eq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Assets with Home (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\nom_assets_eq_mean.pdf", as(pdf) replace

xtline rassets_eq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Assets with Home (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\nom_assets_eq_p50.pdf", as(pdf) replace

*--- REAL Debt ---*
xtline real_rdebt_eq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Debt with Home (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\real_debt_eq_mean.pdf", as(pdf) replace

xtline real_rdebt_eq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Debt with Home (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\real_debt_eq_p50.pdf", as(pdf) replace

*--- NOMINAL Debt ---*
xtline rdebt_eq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Debt with Home (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\nom_debt_eq_mean.pdf", as(pdf) replace

xtline rdebt_eq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Debt with Home (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\nom_debt_eq_p50.pdf", as(pdf) replace

*--- REAL Assets without Home ---*
xtline real_rassets_noeq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Assets without Home (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\real_assets_noeq_mean.pdf", as(pdf) replace

xtline real_rassets_noeq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Assets without Home (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\real_assets_noeq_p50.pdf", as(pdf) replace

*--- NOMINAL Assets without Home ---*
xtline rassets_noeq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Assets without Home (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\nom_assets_noeq_mean.pdf", as(pdf) replace

xtline rassets_noeq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Assets without Home (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\nom_assets_noeq_p50.pdf", as(pdf) replace

*--- REAL Debt without Home---*
xtline real_rdebt_noeq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Debt without Home (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\real_debt_noeq_mean.pdf", as(pdf) replace

xtline real_rdebt_noeq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Debt without Home (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\real_debt_noeq_p50.pdf", as(pdf) replace

*--- NOMINAL Debt without Home ---*
xtline rdebt_noeq_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Debt without Home (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\nom_debt_noeq_mean.pdf", as(pdf) replace

xtline rdebt_noeq_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Debt without Home (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\nom_debt_noeq_p50.pdf", as(pdf) replace

*--- REAL Mortgage (Owners only) ---*
xtline real_rmortgage_owners_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Mortgage for Owners (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\real_mortgage_owners_mean.pdf", as(pdf) replace

xtline real_rmortgage_owners_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Mortgage for Owners (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\real_mortgage_owners_p50.pdf", as(pdf) replace

*--- NOMINAL Mortgage (Owners only) ---*
xtline rmortgage_owners_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Mortgage for Owners (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\nom_mortgage_owners_mean.pdf", as(pdf) replace

xtline rmortgage_owners_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Mortgage for Owners (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\debt\nom_mortgage_owners_p50.pdf", as(pdf) replace

*--- REAL Home Value (Owners only) ---*
xtline real_rhomevalue_owners_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Home Value for Owners (000s of 2017$)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\real_homevalue_owners_mean.pdf", as(pdf) replace

xtline real_rhomevalue_owners_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Home Value for Owners (000s of 2017$)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\real_homevalue_owners_p50.pdf", as(pdf) replace

*--- NOMINAL Home Value (Owners only) ---*
xtline rhomevalue_owners_mean, overlay `xlab_opt' recast(connected) ///
    `xti' ytitle("Home Value for Owners (000s of $)")              ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\nom_homevalue_owners_mean.pdf", as(pdf) replace

xtline rhomevalue_owners_p50, overlay `xlab_opt' recast(connected)  ///
    `xti' ytitle("Home Value for Owners (000s of $)")               ///
    legend(title("Birth Cohort", size(small)))
gr export "`results_path'\wealth\assets\nom_homevalue_owners_p50.pdf", as(pdf) replace