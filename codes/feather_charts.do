clear all

local version = 2023
local data_path "R:\mfa\raon\datasets\psid\clean_data"
use "`data_path'\longfam`version'_ig.dta"

xtset rauid year 

set scheme gg_hue

keep if rhead==1 & (year==1984|year==1989|year==1994|year>=1999)

gen rbyearhd = year - ragehd 


gen cohort = . 
replace cohort = 1 if rbyearhd>=1900 & rbyearhd<=1940
replace cohort = 2 if rbyearhd>1940 & rbyearhd<=1945
replace cohort = 3 if rbyearhd>1945 & rbyearhd<=1950
replace cohort = 4 if rbyearhd>1950 & rbyearhd<=1955
replace cohort = 5 if rbyearhd>1955 & rbyearhd<=1960
replace cohort = 6 if rbyearhd>1960 & rbyearhd<=1965
replace cohort = 7 if rbyearhd>1965 & rbyearhd<=1970
replace cohort = 8 if rbyearhd>1970 & rbyearhd<=1975
replace cohort = 9 if rbyearhd>1975 & rbyearhd<=1980
replace cohort = 10 if rbyearhd>1980 & rbyearhd<=1985
replace cohort = 11 if rbyearhd>1985 & rbyearhd<=1990
replace cohort = 12 if rbyearhd>1990 & rbyearhd<=1995
replace cohort = 13 if rbyearhd>1995 & rbyearhd<=2000
replace cohort = 14 if rbyearhd>2000 & rbyearhd<=2005

label define cohort_lbl ///
    1  "1900–1940" ///
    2  "1941–1945" ///
    3  "1946–1950" ///
    4  "1951–1955" ///
    5  "1956–1960" ///
    6  "1961–1965" ///
    7  "1966–1970" ///
    8  "1971–1975" ///
    9  "1976–1980" ///
    10 "1980–1985" ///
    11 "1986–1990" ///
    12 "1991–1995" ///
    13 "1996–2000" ///
    14 "2001–2005" ///
	
label values cohort cohort_lbl


gen agebin = . 
replace agebin = 1 if ragehd>=17 & ragehd<=20
replace agebin = 2 if ragehd>20 &ragehd<=25
replace agebin = 3 if ragehd>25 &ragehd<=30
replace agebin = 4 if ragehd>30 &ragehd<=35
replace agebin = 5 if ragehd>35 &ragehd<=40
replace agebin = 6 if ragehd>40 &ragehd<=45
replace agebin = 7 if ragehd>45 &ragehd<=50
replace agebin = 8 if ragehd>50 &ragehd<=55
replace agebin = 9 if ragehd>55 &ragehd<=60
replace agebin = 10 if ragehd>60 & ragehd<=65
replace agebin = 11 if ragehd>65 & ragehd<=70
replace agebin = 12 if ragehd>70 & ragehd<=75
replace agebin = 13 if ragehd>75 & ragehd<=80
replace agebin = 14 if ragehd>80 & ragehd<=100

label define agebin_lbl ///
    1  "17–20" ///
    2  "21–25" ///
    3  "26–30" ///
    4  "31–35" ///
    5  "36–40" ///
    6  "41–45" ///
    7  "46–50" ///
    8  "51–55" ///
    9  "56–60" ///
    10 "60–65" ///
    11 "66–70" ///
    12 "71–75" ///
    13 "76–80" ///
    14 "81–100" ///
	
label values agebin agebin_lbl

egen rvalinherit = rowtotal(rvalinherit_one rvalinherit_two rvalinherit_three)
bysort rauid (year): gen rvalinherit_life = sum(rvalinherit)
egen rdebt_noeq_post2011 = rowtotal(rbusdebt rothredebt rccdebt rstuddebt rlegdebt rfamdebt rothdebt) if year>=2011

gen rdebt_noeq = . 
replace rdebt_noeq = ralldebt if year<2011
replace rdebt_noeq = rdebt_noeq_post2011 if year>=2011

gen requity_neg = (-1)*requity
egen rmortgage = rowtotal(rhomevalue requity_neg)
egen rdebt_eq = rowtotal(rdebt_noeq rmortgage)
egen rassets_eq = rowtotal(rwealth_eq rdebt_eq)
egen rassets_noeq = rowtotal(rwealth_noeq rdebt_noeq)
gen rtot_exp_neg = (-1)*rtot_exp 
egen rsavings = rowtotal(rfaminc rtot_exp_neg)
replace rsavings = . if year<1999

gen requity_owners = requity
replace requity_owners = . if rhomeowner==0


local varlist "rfaminc rlabinchd rtransfer_inc rwealth_eq rwealth_noeq requity requity_owners rdebt_eq rassets_eq rdebt_noeq rassets_noeq rmortgage rvalinherit rvalinherit_life rsavings rtot_exp"

keep rauid year rfamweight ragehd rbyearhd cohort agebin cpi_u rhomeowner `varlist' 


foreach var in `varlist'{
	replace `var' = `var'/1000
	gen real_`var' = `var'*cpi_u 
}

local real_varlist ""

foreach var in `varlist'{
	local real_varlist "`real_varlist' real_`var'"
}

drop if missing(agebin)|missing(cohort)

preserve 

collapse (mean) `varlist' `real_varlist' [aw = rfamweight], by(agebin cohort)

xtset cohort agebin

rename r* r*_mean 

tempfile allmeans 
save `allmeans', replace 

restore

preserve 

collapse (p50) `varlist' `real_varlist' [aw = rfamweight], by(agebin cohort)

xtset cohort agebin

rename r* r*_p50

tempfile allp50
save `allp50', replace 

restore


collapse (p75) `varlist' `real_varlist' [aw = rfamweight], by(agebin cohort)

xtset cohort agebin

rename r* r*_p75

merge 1:1 agebin cohort using `allmeans', nogen

merge 1:1 agebin cohort using `allp50', nogen 

xtset cohort agebin


* Charts:


xtline real_rfaminc_mean, overlay xlab(1(2)13, valuelabel) recast(connected) xtitle("Age Group") ytitle("Total Family Income (000s of 2017$)") legend(title("Birth Cohort", size(small)))

xtline real_rfaminc_p50, overlay xlab(1(2)13, valuelabel) recast(connected) xtitle("Age Group") ytitle("Total Family Income (000s of 2017$)") legend(title("Birth Cohort", size(small)))


xtline real_rsavings_mean, overlay xlab(1(2)13, valuelabel) recast(connected) xtitle("Age Group") ytitle("Family Savings (000s of 2017$)") legend(title("Birth Cohort", size(small)))

xtline real_rsavings_p50, overlay xlab(1(2)13, valuelabel) recast(connected) xtitle("Age Group") ytitle("Family Savings (000s of 2017$)") legend(title("Birth Cohort", size(small)))



