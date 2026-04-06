**************************************************************************
*** THIS FILE COMPILES AND CLEANS THE DATASET FOR:               *********
*** INCOME, CONSUMPTION, AND WEALTH IN THE PSID, 1968–2023       *********
**************************************************************************

clear all

set maxvar 30000
set more off

* PATH AND FILE NAME SETTINGS:

local path "R:\mfa\raon\datasets\psid"   // parent folder for project
local code_dir "`path'/codes"        // all .do files that clean/merge the datasets are stored here
local data_dir "`path'/data"         // all raw data files are stored here
local cleandata_dir "`path'/clean_data"          // all clean data is stored here
*local cleandata_dir2 "`path'/clean_data_renamed" // all clean data is stored here

* EXTRACTING DATA FROM FAMILY LEVEL FILES AND PERFORMING MERGES WITH WEALTH *
* FILES WHERE REQUIRED.                                                     *

forval i = 1968/1997 {

    if (`i'==1984 | `i'==1989 | `i'==1994) {
        include "`data_dir'/fam`i'/FAM`i'.do"
        include "`data_dir'/wlth`i'/WLTH`i'.do"
    }
    else {
        include "`data_dir'/fam`i'/FAM`i'.do"
    }

}

forval i = 1999(2)2023 {

    if `i' <= 2007 {
        include "`data_dir'/fam`i'/FAM`i'.do"
        include "`data_dir'/wlth`i'/WLTH`i'.do"
    }

    if `i' > 2007 {
        include "`data_dir'/fam`i'/FAM`i'.do"
    }

}

* CLEANING THE DATA:

forval i = 1968/1996 {

    use "`data_dir'/fam`i'/fam`i'.dta", clear

    if `i' > 1968 {
        replace rwtrmoved`i' = . if rwtrmoved`i' == 9 | rwtrmoved`i' == 8
        replace rwtrmoved`i' = 0 if rwtrmoved`i' == 5
    }

    if `i' != 1994 & `i' != 1968 {
        replace rwtrmightmove`i' = . if rwtrmightmove`i' == 9 | rwtrmightmove`i' == 8
        replace rwtrmightmove`i' = 0 if rwtrmightmove`i' == 5
    }

    if `i' > 1974 & `i' != 1994 {
        replace rprobmove`i' = . if rprobmove`i' == 9
    }

    if `i' > 1974 & `i' != 1982 {
        replace rmoved_month`i' = . if rmoved_month`i' == 99 | rmoved_month`i' == 98 | rmoved_month`i' == 0
    }

    if `i' > 1992 {
        replace rmoved_year`i' = . if rmoved_year`i' == 8 | rmoved_year`i' == 9 | rmoved_year`i' == 0
        replace rmoved_year`i' = `i' - 1 if rmoved_year`i' == 1
        replace rmoved_year`i' = `i'     if rmoved_year`i' == 2
    }

    * DEMOGRAPHICS

    * add current state
    if `i' > 1984 {
        replace rcurrstate`i' = . if rcurrstate`i' == 99
    }

    replace rpsidstate`i' = . if rpsidstate`i' == 99

    if `i' == 1969 {
        replace redhd1969 = . if redhd1969 == 9
    }


* add family composition change:
if `i' > 1968 {

    * no change:
    gen rfamcomp_noch`i' = .
    replace rfamcomp_noch`i' = 1 if rfamcompch`i' == 0
    replace rfamcomp_noch`i' = 0 if rfamcompch`i' != 0
    label var rfamcomp_noch`i' "FAM COMP -- NO CHANGE `i'"

    * change other than reference person/spouse:
    gen rfamcomp_othch`i' = .
    replace rfamcomp_othch`i' = 1 if rfamcompch`i' == 1
    replace rfamcomp_othch`i' = 0 if rfamcompch`i' != 1
    label var rfamcomp_othch`i' "FAM COMP -- OTHER CHANGE `i'"

    * spouse change (spouse died or changed):
    gen rfamcomp_spch`i' = .
    replace rfamcomp_spch`i' = 1 if rfamcompch`i' == 2
    replace rfamcomp_spch`i' = 0 if rfamcompch`i' != 2
    label var rfamcomp_spch`i' "FAM COMP -- SP CHANGE `i'"

    * spouse became head:
    gen rfamcomp_sphdch`i' = .
    replace rfamcomp_sphdch`i' = 1 if rfamcompch`i' == 3
    replace rfamcomp_sphdch`i' = 0 if rfamcompch`i' != 3
    label var rfamcomp_sphdch`i' "FAM COMP -- SP BECAME HD `i'"
}

* add age and sex of head and age of spouse:

replace ragehd`i' = . if ragehd`i' == 999

gen rgenderhd_fem`i' = .
replace rgenderhd_fem`i' = 1 if rgenderhd`i' == 2
replace rgenderhd_fem`i' = 0 if rgenderhd`i' == 1
label var rgenderhd_fem`i' "GENDER -- FEMALE (HD) `i'"

replace ragesp`i' = . if ragesp`i' == 999 ///
    // ragesp = 0 if reference person is female or single male

if (`i' > 1990 | `i' < 1985) {

    * add education
    if `i' >= 1975 {
        replace redhd`i' = . if redhd`i' == 99
        replace redsp`i' = . if redsp`i' == 99
    }
}

* add marital status:

replace rmarstat`i' = . if rmarstat`i' == 9

gen rmarstat_mar`i' = (rmarstat`i' == 1) if !missing(rmarstat`i')
label var rmarstat_mar`i' "MARITAL STATUS -- MARRIED `i'"

gen rmarstat_sin`i' = (rmarstat`i' == 2) if !missing(rmarstat`i')
label var rmarstat_sin`i' "MARITAL STATUS -- SINGLE `i'"

gen rmarstat_wid`i' = (rmarstat`i' == 3) if !missing(rmarstat`i')
label var rmarstat_wid`i' "MARITAL STATUS -- WIDOWED `i'"

gen rmarstat_div`i' = (rmarstat`i' == 4) if !missing(rmarstat`i')
label var rmarstat_div`i' "MARITAL STATUS -- DIVORCED `i'"

gen rmarstat_sep`i' = (rmarstat`i' == 5) if !missing(rmarstat`i')
label var rmarstat_sep`i' "MARITAL STATUS -- SEPARATED `i'"

* add race of head

replace rracehd`i' = . if rracehd`i' == 9

gen rracehd_bl`i' = (rracehd`i' == 2) if !missing(rracehd`i')
label var rracehd_bl`i' "RACE -- BLACK (HD) `i'"

gen rracehd_wh`i' = (rracehd`i' == 1) if !missing(rracehd`i')
label var rracehd_wh`i' "RACE -- WHITE (HD) `i'"

gen rracehd_ind`i' = (rracehd`i' == 3) if !missing(rracehd`i')
label var rracehd_ind`i' "RACE -- NATIVE AMERICAN (HD) `i'"

gen rracehd_as`i' = (rracehd`i' == 4) if !missing(rracehd`i')
label var rracehd_as`i' "RACE -- ASIAN (HD) `i'"

gen rracehd_haw`i' = (rracehd`i' == 5) if !missing(rracehd`i')
label var rracehd_haw`i' "RACE -- HAWAIIAN (HD) `i'"

gen rracehd_oth`i' = (rracehd`i' == 6) if !missing(rracehd`i')
label var rracehd_oth`i' "RACE -- OTHER (HD) `i'"

* INCOME

if `i'>1992{
* add TANF amount:

replace rtanfinchd`i' = . if rtanfinchd`i' >= 999998
replace rtanfincsp`i' = . if rtanfinchd`i' >= 999998

replace rtanfinchdper`i' = . if rtanfinchdper`i' == 9
replace rtanfincspper`i' = . if rtanfincspper`i' == 9

gen rtanfinchd_m`i' = .
replace rtanfinchd_m`i' = rtanfinchd`i'     if rtanfinchdper`i' == 5 | rtanfinchdper`i' == 0
replace rtanfinchd_m`i' = rtanfinchd`i' * 2 if rtanfinchdper`i' == 4
replace rtanfinchd_m`i' = rtanfinchd`i' * 4 if rtanfinchdper`i' == 3
replace rtanfinchd_m`i' = rtanfinchd`i' /12 if rtanfinchdper`i' == 6
replace rtanfinchd_m`i' = .                 if rtanfinchdper`i' == 7
label var rtanfinchd_m`i' "TANF INCOME -- MONTHLY (HD) `i'"

gen rtanfincsp_m`i' = .
replace rtanfincsp_m`i' = rtanfincsp`i'     if rtanfincspper`i' == 5 | rtanfinchdper`i' == 0
replace rtanfincsp_m`i' = rtanfincsp`i' * 2 if rtanfincspper`i' == 4
replace rtanfincsp_m`i' = rtanfincsp`i' * 4 if rtanfincspper`i' == 3
replace rtanfincsp_m`i' = rtanfincsp`i' /12 if rtanfincspper`i' == 6
replace rtanfincsp_m`i' = .                 if rtanfincspper`i' == 7
label var rtanfincsp_m`i' "TANF INCOME -- MONTHLY (SP) `i'"
}

* add food stamps
if (`i'>1992){
replace rvalfs`i' = . if rvalfs`i' >= 999998
}

* EMPLOYMENT
if `i'>1993{
replace rempstathd`i' = . if rempstathd`i' == 99

gen rempstathd_work`i' = (rempstathd`i' == 1) if !missing(rempstathd`i')
label var rempstathd_work`i' "EMP STAT--WORKING (HD) `i'"

gen rempstathd_templo`i' = (rempstathd`i' == 2) if !missing(rempstathd`i')
label var rempstathd_templo`i' "EMP STAT -- TEMP LAID OFF (HD) `i'"

gen rempstathd_unemp`i' = (rempstathd`i' == 3) if !missing(rempstathd`i')
label var rempstathd_unemp`i' "EMP STAT--UNEMPLOYED (HD) `i'"

gen rempstathd_ret`i' = (rempstathd`i' == 4) if !missing(rempstathd`i')
label var rempstathd_ret`i' "EMP STAT--RETIRED (HD) `i'"

gen rempstathd_dis`i' = (rempstathd`i' == 5) if !missing(rempstathd`i')
label var rempstathd_dis`i' "EMP STAT--DISABLED (HD) `i'"

gen rempstathd_hm`i' = (rempstathd`i' == 6) if !missing(rempstathd`i')
label var rempstathd_hm`i' "EMP STAT--KP HOME (HD) `i'"

gen rempstathd_stud`i' = (rempstathd`i' == 7) if !missing(rempstathd`i')
label var rempstathd_stud`i' "EMP STAT--STUDENT (HD) `i'"

gen rempstathd_oth`i' = (rempstathd`i' == 8) if !missing(rempstathd`i')
label var rempstathd_oth`i' "EMP STAT--OTH (HD) `i'"

replace rempstatsp`i' = . if rempstatsp`i' == 99

gen rempstatsp_work`i' = (rempstatsp`i' == 1) if !missing(rempstatsp`i')
label var rempstatsp_work`i' "EMP STAT--WORKING (SP) `i'"

gen rempstatsp_templo`i' = (rempstatsp`i' == 2) if !missing(rempstatsp`i')
label var rempstatsp_templo`i' "EMP STAT--TEMP LAID OFF (SP) `i'"

gen rempstatsp_unemp`i' = (rempstatsp`i' == 3) if !missing(rempstatsp`i')
label var rempstatsp_unemp`i' "EMP STAT--UNEMP (SP) `i'"

gen rempstatsp_ret`i' = (rempstatsp`i' == 4) if !missing(rempstatsp`i')
label var rempstatsp_ret`i' "EMP STAT--RETIRED (SP) `i'"

gen rempstatsp_dis`i' = (rempstatsp`i' == 5) if !missing(rempstatsp`i')
label var rempstatsp_dis`i' "EMP STAT--DISABLED (SP) `i'"

gen rempstatsp_hm`i' = (rempstatsp`i' == 6) if !missing(rempstatsp`i')
label var rempstatsp_hm`i' "EMP STAT--KP HOME (SP) `i'"

gen rempstatsp_stud`i' = (rempstatsp`i' == 7) if !missing(rempstatsp`i')
label var rempstatsp_stud`i' "EMP STAT--STUDENT (SP) `i'"

gen rempstatsp_oth`i' = (rempstatsp`i' == 8) if !missing(rempstatsp`i')
label var rempstatsp_oth`i' "EMP STAT--OTH (SP) `i'"

}

if `i'<1994{
replace rempstathd_old`i' = . if rempstathd_old`i' == 99

gen rempstathd_workold`i' = (rempstathd_old`i' == 1) if !missing(rempstathd_old`i')
label var rempstathd_workold`i' "OLD EMP STAT--WORKING (HD) `i'"

gen rempstathd_temploold`i' = (rempstathd_old`i' == 2) if !missing(rempstathd_old`i')
label var rempstathd_temploold`i' "OLD EMP STAT--TEMP LAID OFF (HD) `i'"

gen rempstathd_unempold`i' = (rempstathd_old`i' == 3) if !missing(rempstathd_old`i')
label var rempstathd_unempold`i' "OLD EMP STAT--UNEMP (HD) `i'"

gen rempstathd_retold`i' = (rempstathd_old`i' == 4) if !missing(rempstathd_old`i')
label var rempstathd_retold`i' "OLD EMP STAT--RETIRED (HD) `i'"

gen rempstathd_disold`i' = (rempstathd_old`i' == 5) if !missing(rempstathd_old`i')
label var rempstathd_disold`i' "OLD EMP STAT--DISABLED (HD) `i'"

gen rempstathd_hmold`i' = (rempstathd_old`i' == 6) if !missing(rempstathd_old`i')
label var rempstathd_hmold`i' "OLD EMP STAT--KP HOME (HD) `i'"

gen rempstathd_studold`i' = (rempstathd_old`i' == 7) if !missing(rempstathd_old`i')
label var rempstathd_studold`i' "OLD EMP STAT--STUDENT (HD) `i'"

gen rempstathd_othold`i' = (rempstathd_old`i' == 8) if !missing(rempstathd_old`i')
label var rempstathd_othold`i' "OLD EMP STAT--OTH (HD) `i'"

if (`i'==1976 | (`i'>1978)) {
    replace rempstatsp_old`i' = . if rempstatsp_old`i' == 99

    gen rempstatsp_workold`i' = (rempstatsp_old`i' == 1) if !missing(rempstatsp_old`i')
    label var rempstatsp_workold`i' "OLD EMP STAT--WORKING (SP) `i'"

    gen rempstatsp_temploold`i' = (rempstatsp_old`i' == 2) if !missing(rempstatsp_old`i')
    label var rempstatsp_temploold`i' "OLD EMP STAT--TEMP LAID OFF (SP) `i'"

    gen rempstatsp_unempold`i' = (rempstatsp_old`i' == 3) if !missing(rempstatsp_old`i')
    label var rempstatsp_unempold`i' "OLD EMP STAT--UNEMPLOYED (SP) `i'"

    gen rempstatsp_retold`i' = (rempstatsp_old`i' == 4) if !missing(rempstatsp_old`i')
    label var rempstatsp_retold`i' "OLD EMP STAT--RETIRED (SP) `i'"

    gen rempstatsp_disold`i' = (rempstatsp_old`i' == 5) if !missing(rempstatsp_old`i')
    label var rempstatsp_disold`i' "OLD EMP STAT--DISABLED (SP) `i'"

    gen rempstatsp_hmold`i' = (rempstatsp_old`i' == 6) if !missing(rempstatsp_old`i')
    label var rempstatsp_hmold`i' "OLD EMP STAT--KP HOME (SP) `i'"

    gen rempstatsp_studold`i' = (rempstatsp_old`i' == 7) if !missing(rempstatsp_old`i')
    label var rempstatsp_studold`i' "OLD EMP STAT--STUDENT (SP) `i'"

    gen rempstatsp_othold`i' = (rempstatsp_old`i' == 8) if !missing(rempstatsp_old`i')
    label var rempstatsp_othold`i' "OLD EMP STAT--OTH (SP) `i'"
}
}


* HOME

* add ownership, house value, prop tax, mortgage, rent

gen rhomeowner`i' = (rownrent`i'==1) if !missing(rownrent`i')
label var rhomeowner`i' "HOMEOWNER `i'"

gen rhomerenter`i' = (rownrent`i'==5) if !missing(rownrent`i')
label var rhomerenter`i' "RENTER `i'"

gen rnoownrent`i' = (rownrent`i'==8) if !missing(rownrent`i')
label var rnoownrent`i' "NEITHER OWNER NOR RENTER `i'"

replace rhomevalue`i' = . if rhomevalue`i'>=9999998 ///
    // zero implies renter or neither owner nor renter

if (`i'!=1988 & `i'!=1989 & `i'!=1978) {
    replace rproptax`i' = . if rproptax`i'>=99998 ///
        // zero implies renter or neither owner nor renter
}

if (`i'<1973 | `i'>1978) {
    if `i'!=1982 {
        replace rmort`i' = . if rmort`i'==0   // change renters' mortgage to missing
        replace rmort`i' = 0 if rmort`i'==5
        replace rmort`i' = . if rmort`i'>=8
    }
}

if `i'>1992 {
    * add rent and rent per

    replace rrent`i' = . if rrent`i'>=99998 ///
        // zero rent implies owner or neither owner nor renter

    replace rrentper`i' = . if rrentper`i'>=8

    * generate variable of rent per month even if not reported in terms of months
    gen rrent_imp`i' = .
    replace rrent_imp`i' = rrent`i'*30 if rrentper`i'==2
    replace rrent_imp`i' = rrent`i'*4  if rrentper`i'==3
    replace rrent_imp`i' = rrent`i'*2  if rrentper`i'==4
    replace rrent_imp`i' = rrent`i'/12 if rrentper`i'==6
    replace rrent_imp`i' = rrent`i'    if rrentper`i'==5
    replace rrent_imp`i' = .           if rrentper`i'==7
    label var rrent_imp`i' "RENT CONVERTED TO MONTHS `i'"
}

if `i'>1992 {
    * salary, job 1:
    replace rsalary`i' = . if rsalary`i'>9999997
}

if `i'>1977 {
    * retirement year:
    replace rretyear`i' = . if rretyear`i'==0 | rretyear`i'>9997
}

* total hours of family work:
if `i'<1973 {
    replace rtothrswk_fam`i' = . if rtothrswk_fam`i'==9999
}

* food bought with food stamps:
if (`i'>1979 & `i'<1994) | (`i'==1970) {
    replace rvalfoodst_old`i' = . if rvalfoodst_old`i'==9999
}

* FOOD COSTS:
if `i'>1993 {

    replace rfoodhome_fs`i' = . if rfoodhome_fs`i'>99997

    replace rfoodhome_fs`i' = . if rfoodhomeper_fs`i'>3
    replace rfoodhome_fs`i' = rfoodhome_fs`i'*52 if rfoodhomeper_fs`i'==1
    replace rfoodhome_fs`i' = rfoodhome_fs`i'*26 if rfoodhomeper_fs`i'==2
    replace rfoodhome_fs`i' = rfoodhome_fs`i'*12 if rfoodhomeper_fs`i'==3

    replace rfoodahome_fs`i' = . if rfoodahome_fs`i'>99997

    replace rfoodahome_fs`i' = . if rfoodahomeper_fs`i'>3
    replace rfoodahome_fs`i' = rfoodahome_fs`i'*52 if rfoodahomeper_fs`i'==1
    replace rfoodahome_fs`i' = rfoodahome_fs`i'*26 if rfoodahomeper_fs`i'==2
    replace rfoodahome_fs`i' = rfoodahome_fs`i'*12 if rfoodahomeper_fs`i'==3

    replace rfoodhome_nfs`i' = . if rfoodhome_nfs`i'>99997

    replace rfoodhome_nfs`i' = . if rfoodhomeper_nfs`i'>3
    replace rfoodhome_nfs`i' = rfoodhome_nfs`i'*52 if rfoodhomeper_nfs`i'==1
    replace rfoodhome_nfs`i' = rfoodhome_nfs`i'*26 if rfoodhomeper_nfs`i'==2
    replace rfoodhome_nfs`i' = rfoodhome_nfs`i'*12 if rfoodhomeper_nfs`i'==3

    replace rfoodahome_nfs`i' = . if rfoodahome_nfs`i'>99997


	replace rfoodahome_nfs`i' = . if rfoodahomeper_nfs`i'>3
	replace rfoodahome_nfs`i' = rfoodahome_nfs`i'*52 if rfoodahomeper_nfs`i'==1
	replace rfoodahome_nfs`i' = rfoodahome_nfs`i'*26 if rfoodahomeper_nfs`i'==2
	replace rfoodahome_nfs`i' = rfoodahome_nfs`i'*12 if rfoodahomeper_nfs`i'==3

	egen rfoodhome_imp`i' = rowtotal(rfoodhome_fs`i' rfoodhome_nfs`i')
	label var rfoodhome_imp`i' "IMPUTED ANNUAL FOOD COSTS AT HOME"
	egen rfoodahome_imp`i' = rowtotal(rfoodahome_fs`i' rfoodahome_nfs`i')
	label var rfoodahome_imp`i' "IMPUTED ANNUAL FOOD COSTS EAT OUT"
}

if `i'>1968 {
    rename r68id`i' rfam68id`i'
}

if (`i'>1992) {
    rename rvalfs`i' rvalfoodst`i'
}

replace rnumrooms`i' = . if rnumrooms`i'>=98

if (`i'==1984) | (`i'==1989) {
    replace rwtrinherit`i' = . if rwtrinherit`i'==9
    replace rwtrinherit`i' = 0 if rwtrinherit`i'==5
    replace rvalinherit_one`i' = . if rvalinherit_one`i'>9999996
    replace rvalinherit_two`i' = . if rvalinherit_two`i'>9999996
}

if `i'==1994 {
    replace rwtrinherit`i' = . if rwtrinherit`i'==9
    replace rwtrinherit`i' = 0 if rwtrinherit`i'==5
    replace rvalinherit_one`i' = . if rvalinherit_one`i'>9999996
    replace rvalinherit_two`i' = . if rvalinherit_two`i'>9999996
    replace rvalinherit_three`i' = . if rvalinherit_three`i'>9999996
    replace rsellpricehome`i' = . if rsellpricehome`i'>9999996
}

* DIVIDEND INCOME

if `i'>1992{
replace rdivinchd`i' = rdivinchd`i'*12 if rdivinchd_per`i'==5
replace rdivinchd`i' = . if rdivinchd_per`i'>6

replace rdivincsp`i' = rdivincsp`i'*12 if rdivincsp_per`i'==5
replace rdivincsp`i' = . if rdivincsp_per`i'>6

replace rdivinchd`i'=. if rdivinchd`i'>999996
replace rdivincsp`i'=. if rdivincsp`i'>999996
}

if `i'>1968 & `i'<=1974{
	
	replace rdivinchd_old`i'=.

}

if `i'<1983 & `i'>1974{
replace rdivinchd_old`i'=. if rdivinchd_old`i'>999998
replace rdivincsp_old`i'=. if rdivincsp_old`i'>999998
}

* MORTGAGE
if `i'>1968 & (`i'<1973 | `i'>1975) & `i'!=1982{
	replace rmortone_rem`i' = . if rmortone_rem`i'>9999997
	
}
if `i'>1993{
	replace rmorttwo_rem`i' = . if rmortone_rem`i'>9999997
	
}

if `i'>1995{
	
	replace rint_mortone`i' = . if (rint_mortone`i'>50|(rint_mortone`i'>=0.3 & rint_mortone`i'<=0.8))
	replace rint_morttwo`i' = . if (rint_mortone`i'>50|(rint_mortone`i'>=0.3 & rint_mortone`i'<=0.8))
	
}


save "`cleandata_dir'/fam`i'", replace
}

forval i=1997(2)2023 {

use "`data_dir'/fam`i'/fam`i'.dta", clear
* DEMOGRAPHICS

* add current state
replace rcurrstate`i' = . if rcurrstate`i'==99


* add family composition change:

* no change:
gen rfamcomp_noch`i' = .
replace rfamcomp_noch`i' = 1 if rfamcompch`i'==0
replace rfamcomp_noch`i' = 0 if rfamcompch`i'!=0
label var rfamcomp_noch`i' "FAM COMP -- NO CHANGE `i'"

* change other than reference person/spouse:
gen rfamcomp_othch`i' = .
replace rfamcomp_othch`i' = 1 if rfamcompch`i'==1
replace rfamcomp_othch`i' = 0 if rfamcompch`i'!=1
label var rfamcomp_othch`i' "FAM COMP -- OTHER CHANGE `i'"

* spouse change (spouse died or changed):
gen rfamcomp_spch`i' = .
replace rfamcomp_spch`i' = 1 if rfamcompch`i'==2
replace rfamcomp_spch`i' = 0 if rfamcompch`i'!=2
label var rfamcomp_spch`i' "FAM COMP -- SP CHANGE `i'"

* spouse became head:
gen rfamcomp_sphdch`i' = .
replace rfamcomp_sphdch`i' = 1 if rfamcompch`i'==3
replace rfamcomp_sphdch`i' = 0 if rfamcompch`i'!=3
label var rfamcomp_sphdch`i' "FAM COMP -- SP BECAME HD `i'"

* add age and sex of head and age of spouse:

replace ragehd`i' = . if ragehd`i'==999

gen rgenderhd_fem`i' = .
replace rgenderhd_fem`i' = 1 if rgenderhd`i' == 2
replace rgenderhd_fem`i' = 0 if rgenderhd`i'==1
label var rgenderhd_fem`i' "GENDER -- FEMALE (HD) `i'"

replace ragesp`i' = . if ragesp`i'==999 //ragesp=0 if reference person is female or single male

* add education

replace redhd`i' = . if redhd`i'==99
replace redsp`i' = . if redsp`i'==99


* add marital status:

replace rmarstat`i' = . if rmarstat`i'==9

gen rmarstat_mar`i' = (rmarstat`i'==1) if !missing(rmarstat`i')
label var rmarstat_mar`i' "MARITAL STATUS -- MARRIED `i'"

gen rmarstat_sin`i' = (rmarstat`i'==2) if !missing(rmarstat`i')
label var rmarstat_sin`i' "MARITAL STATUS -- SINGLE `i'"

gen rmarstat_wid`i' = (rmarstat`i'==3) if !missing(rmarstat`i')
label var rmarstat_wid`i' "MARITAL STATUS -- WIDOWED `i'"

gen rmarstat_div`i' = (rmarstat`i'==4) if !missing(rmarstat`i')
label var rmarstat_div`i' "MARITAL STATUS -- DIVORCED `i'"

gen rmarstat_sep`i' = (rmarstat`i'==5) if !missing(rmarstat`i')
label var rmarstat_sep`i' "MARITAL STATUS -- SEPARATED `i'"


* add race of head

replace rracehd`i' = . if rracehd`i'==9

gen rracehd_bl`i' = (rracehd`i'==2) if !missing(rracehd`i')
label var rracehd_bl`i' "RACE -- BLACK (HD) `i'"

gen rracehd_wh`i' = (rracehd`i'==1) if !missing(rracehd`i')
label var rracehd_wh`i' "RACE -- WHITE (HD) `i'"

gen rracehd_ind`i' = (rracehd`i'==3) if !missing(rracehd`i')
label var rracehd_ind`i' "RACE -- NATIVE AMERICAN (HD) `i'"

gen rracehd_as`i' = (rracehd`i'==4) if !missing(rracehd`i')
label var rracehd_as`i' "RACE -- ASIAN (HD) `i'"

gen rracehd_haw`i' = (rracehd`i'==5) if !missing(rracehd`i')
label var rracehd_haw`i' "RACE -- HAWAIIAN (HD) `i'"

gen rracehd_oth`i' = (rracehd`i'==6) if !missing(rracehd`i')
label var rracehd_oth`i' "RACE -- OTHER (HD) `i'"


if `i'>1997 {
    replace rstate_grewup`i' = . if rstate_grewup`i'>=98
    replace rstate_grewup`i' = . if rstate_grewup`i'==0
}

* INCOME

* add TANF amount:

replace rtanfinchd`i' = . if rtanfinchd`i'>=999998
replace rtanfincsp`i' = . if rtanfincsp`i'>=999998

replace rtanfinchdper`i' = . if rtanfinchdper`i'==9
replace rtanfincspper`i' = . if rtanfincspper`i'==9

gen rtanfinchd_m`i' = .
replace rtanfinchd_m`i' = rtanfinchd`i' if rtanfinchdper`i'==5 | rtanfinchdper`i'==0
replace rtanfinchd_m`i' = rtanfinchd`i'*2 if rtanfinchdper`i'==4
replace rtanfinchd_m`i' = rtanfinchd`i'*4 if rtanfinchdper`i'==3
replace rtanfinchd_m`i' = rtanfinchd`i'/12 if rtanfinchdper`i'==6
replace rtanfinchd_m`i' = . if rtanfinchdper`i'==7
label var rtanfinchd_m`i' "TANF INCOME -- MONTHLY (HD) `i'"

gen rtanfincsp_m`i' = .
replace rtanfincsp_m`i' = rtanfincsp`i' if rtanfincspper`i'==5 | rtanfinchdper`i'==0
replace rtanfincsp_m`i' = rtanfincsp`i'*2 if rtanfincspper`i'==4
replace rtanfincsp_m`i' = rtanfincsp`i'*4 if rtanfincspper`i'==3
replace rtanfincsp_m`i' = rtanfincsp`i'/12 if rtanfincspper`i'==6
replace rtanfincsp_m`i' = . if rtanfincspper`i'==7
label var rtanfincsp_m`i' "TANF INCOME -- MONTHLY (SP) `i'"


* add food stamps

replace rvalfs`i' = . if rvalfs`i'>=999998


* EMPLOYMENT

replace rempstathd`i' = . if rempstathd`i'==99

gen rempstathd_work`i' = (rempstathd`i'==1) if !missing(rempstathd`i')
label var rempstathd_work`i' "EMP STAT--WORKING (HD) `i'"

gen rempstathd_templo`i' = (rempstathd`i'==2) if !missing(rempstathd`i')
label var rempstathd_templo`i' "EMP STAT -- TEMP LAID OFF (HD) `i'"

gen rempstathd_unemp`i' = (rempstathd`i'==3) if !missing(rempstathd`i')
label var rempstathd_unemp`i' "EMP STAT--UNEMPLOYED (HD) `i'"

gen rempstathd_ret`i' = (rempstathd`i'==4) if !missing(rempstathd`i')
label var rempstathd_ret`i' "EMP STAT--RETIRED (HD) `i'"

gen rempstathd_dis`i' = (rempstathd`i'==5) if !missing(rempstathd`i')
label var rempstathd_dis`i' "EMP STAT--DISABLED (HD) `i'"

gen rempstathd_hm`i' = (rempstathd`i'==6) if !missing(rempstathd`i')
label var rempstathd_hm`i' "EMP STAT--KP HOME (HD) `i'"

gen rempstathd_stud`i' = (rempstathd`i'==7) if !missing(rempstathd`i')
label var rempstathd_stud`i' "EMP STAT--STUDENT (HD) `i'"

gen rempstathd_oth`i' = (rempstathd`i'==8) if !missing(rempstathd`i')
label var rempstathd_oth`i' "EMP STAT--OTH (HD) `i'"


replace rempstatsp`i' = . if rempstatsp`i'==99

gen rempstatsp_work`i' = (rempstatsp`i'==1) if !missing(rempstatsp`i')
label var rempstatsp_work`i' "EMP STAT--WORKING (SP) `i'"

gen rempstatsp_templo`i' = (rempstatsp`i'==2) if !missing(rempstatsp`i')
label var rempstatsp_templo`i' "EMP STAT--TEMP LAID OFF (SP) `i'"

gen rempstatsp_unemp`i' = (rempstatsp`i'==3) if !missing(rempstatsp`i')
label var rempstatsp_unemp`i' "EMP STAT--UNEMP (SP) `i'"

gen rempstatsp_ret`i' = (rempstatsp`i'==4) if !missing(rempstatsp`i')
label var rempstatsp_ret`i' "EMP STAT--RETIRED (SP) `i'"

gen rempstatsp_dis`i' = (rempstatsp`i'==5) if !missing(rempstatsp`i')
label var rempstatsp_dis`i' "EMP STAT--DISABLED (SP) `i'"

gen rempstatsp_hm`i' = (rempstatsp`i'==6) if !missing(rempstatsp`i')
label var rempstatsp_hm`i' "EMP STAT--KP HOME (SP) `i'"

gen rempstatsp_stud`i' = (rempstatsp`i'==7) if !missing(rempstatsp`i')
label var rempstatsp_stud`i' "EMP STAT--STUDENT (SP) `i'"

gen rempstatsp_oth`i' = (rempstatsp`i'==8) if !missing(rempstatsp`i')
label var rempstatsp_oth`i' "EMP STAT--OTH (SP) `i'"


if `i'>=2003 & `i'<=2015{
    gen rmainocc_con`i' = .
    gen rmainind_con`i' = .
    gen rmainocc_dad_con`i' = .
    gen rmainocc_mom_con`i' = .
    gen rmainind_dad_con`i' = .
    gen rmainind_mom_con`i' = .

    local varlist "rmainocc rmainocc_dad rmainocc_mom"

    foreach var of local varlist{
        replace `var'_con`i' = 1 if `var'`i'>=1   & `var'`i'<=43
        replace `var'_con`i' = 2 if `var'`i'>=50  & `var'`i'<=73
        replace `var'_con`i' = 3 if `var'`i'>=80  & `var'`i'<=95
        replace `var'_con`i' = 4 if `var'`i'>=100 & `var'`i'<=124
        replace `var'_con`i' = 5 if `var'`i'>=130 & `var'`i'<=156
        replace `var'_con`i' = 6 if `var'`i'>=160 & `var'`i'<=196
        replace `var'_con`i' = 7 if `var'`i'>=200 & `var'`i'<=206
        replace `var'_con`i' = 8 if `var'`i'>=210 & `var'`i'<=215
        replace `var'_con`i' = 9 if `var'`i'>=220 & `var'`i'<=255
        replace `var'_con`i' = 10 if `var'`i'>=260 & `var'`i'<=296
        replace `var'_con`i' = 11 if `var'`i'>=300 & `var'`i'<=354
        replace `var'_con`i' = 12 if `var'`i'>=360 & `var'`i'<=365
        replace `var'_con`i' = 13 if `var'`i'>=370 & `var'`i'<=395
        replace `var'_con`i' = 14 if `var'`i'>=400 & `var'`i'<=416
        replace `var'_con`i' = 15 if `var'`i'>=420 & `var'`i'<=425
        replace `var'_con`i' = 16 if `var'`i'>=430 & `var'`i'<=465
        replace `var'_con`i' = 17 if `var'`i'>=470 & `var'`i'<=496
        replace `var'_con`i' = 18 if `var'`i'>=500 & `var'`i'<=593
        replace `var'_con`i' = 19 if `var'`i'>=600 & `var'`i'<=613
        replace `var'_con`i' = 20 if `var'`i'>=620 & `var'`i'<=676
        replace `var'_con`i' = 21 if `var'`i'>=680 & `var'`i'<=694
        replace `var'_con`i' = 22 if `var'`i'>=700 & `var'`i'<=762
        replace `var'_con`i' = 23 if `var'`i'>=770 & `var'`i'<=896
        replace `var'_con`i' = 24 if `var'`i'>=900 & `var'`i'<=975
        replace `var'_con`i' = 25 if `var'`i'>=980 & `var'`i'<=983
        replace `var'_con`i' = 26 if `var'`i'==999
        replace `var'_con`i' = 0  if `var'`i'==0
    }

    local varlist "rmainind rmainind_dad rmainind_mom"

    foreach var of local varlist{

        replace `var'_con`i' = 1 if `var'`i'>=17  & `var'`i'<=29
        replace `var'_con`i' = 2 if `var'`i'>=37  & `var'`i'<=49
        replace `var'_con`i' = 3 if `var'`i'>=57  & `var'`i'<=69
        replace `var'_con`i' = 4 if `var'`i'==77
        replace `var'_con`i' = 5 if `var'`i'>=107 & `var'`i'<=399
        replace `var'_con`i' = 6 if `var'`i'>=407 & `var'`i'<=459
        replace `var'_con`i' = 7 if `var'`i'>=467 & `var'`i'<=579
        replace `var'_con`i' = 8 if `var'`i'>=607 & `var'`i'<=639
        replace `var'_con`i' = 9 if `var'`i'>=647 & `var'`i'<=679
        replace `var'_con`i' = 10 if `var'`i'>=687 & `var'`i'<=699
        replace `var'_con`i' = 11 if `var'`i'>=707 & `var'`i'<=719
        replace `var'_con`i' = 12 if `var'`i'>=727 & `var'`i'<=749
        replace `var'_con`i' = 13 if `var'`i'>=757 & `var'`i'<=779
        replace `var'_con`i' = 14 if `var'`i'>=786 & `var'`i'<=789
        replace `var'_con`i' = 15 if `var'`i'>=797 & `var'`i'<=847
        replace `var'_con`i' = 16 if `var'`i'>=856 & `var'`i'<=859
        replace `var'_con`i' = 17 if `var'`i'>=866 & `var'`i'<=869
        replace `var'_con`i' = 18 if `var'`i'>=877 & `var'`i'<=929
        replace `var'_con`i' = 19 if `var'`i'>=937 & `var'`i'<=987
        replace `var'_con`i' = 26 if `var'`i'==999
        replace `var'_con`i' = 0  if `var'`i'==0
    }
}

if `i'>2001{
    * weeks unemployed last year:

    replace rwkunemp_ly`i' = . if rwkunemp_ly`i'>97
}

* salary, job 1:

replace rsalary`i' = . if rsalary`i'>9999997

* retirement year:

replace rretyear`i' = . if rretyear`i'==0 | rretyear`i'>9997

* HOME

* add ownership, house value, prop tax, mortgage, rent

gen rhomeowner`i' = (rownrent`i'==1) if !missing(rownrent`i')
label var rhomeowner`i' "HOMEOWNER `i'"

gen rhomerenter`i' = (rownrent`i'==5) if !missing(rownrent`i')
label var rhomerenter`i' "RENTER `i'"

gen rnoownrent`i' = (rownrent`i'==8) if !missing(rownrent`i')
label var rnoownrent`i' "NEITHER OWNER NOR RENTER `i'"

replace rhomevalue`i' = . if rhomevalue`i'>=9999998 ///
    // zero implies renter or neither owner nor renter

replace rproptax`i' = . if rproptax`i'>=99998 ///
    // zero implies renter or neither owner nor renter

replace rmort`i' = 0 if rmort`i'==5
replace rmort`i' = . if rmort`i'>=8

if `i'>1997{
    replace rtypemort_one`i' = . if rtypemort_one`i'>=8

    replace rwtrmortrefin_one`i' = . if rwtrmortrefin_one`i'>=8
    gen rwtrmort_refin`i' = (rwtrmortrefin_one`i'==2)

    replace rremprinmort_one`i' = . if rremprinmort_one`i'>=9999998
    replace rmort_mthly_one`i' = . if rmort_mthly_one`i'>=99998

    replace rwtr_lumpinher`i' = . if rwtr_lumpinher`i'>=8
    replace rwtr_lumpinher`i' = 0 if rwtr_lumpinher`i'==5

    replace rwtrhelp_rel`i' = . if rwtrhelp_rel`i'>=8
    replace rwtrhelp_rel`i' = 0 if rwtrhelp_rel`i'==5
    replace ramthelp_rel`i' = . if ramthelp_rel`i'>=9999998
    replace ramthelp_rel_per`i' = . if ramthelp_rel_per`i'>=7

    replace ramthelp_rel`i' = ramthelp_rel`i'*52 if ramthelp_rel_per`i'==3
    replace ramthelp_rel`i' = ramthelp_rel`i'*26 if ramthelp_rel_per`i'==4
    replace ramthelp_rel`i' = ramthelp_rel`i'*12 if ramthelp_rel_per`i'==5

    replace rwtryouhelp_oth`i' = . if rwtryouhelp_oth`i'>=8
    replace rwtryouhelp_oth`i' = 0 if rwtryouhelp_oth`i'==5
    replace rwtr_par_poor`i' = . if rwtr_par_poor`i'==9

    gen rparpoor`i' = .
    replace rparpoor`i' = 1 if rwtr_par_poor`i'==1
    replace rparpoor`i' = 0 if (rwtr_par_poor`i'==3 | rwtr_par_poor`i'==5)

    gen rparrich`i' = .
    replace rparrich`i' = 1 if rwtr_par_poor`i'==5
    replace rparrich`i' = 0 if (rwtr_par_poor`i'==1 | rwtr_par_poor`i'==3)
}

* add rent and rent per

replace rrent`i' = . if rrent`i'>=99998 ///
    // zero rent implies owner or neither own nor rent

replace rrentper`i' = . if rrentper`i'>=8

* generate variable of rent per month even if not reported in terms of months
gen rrent_imp`i' = .
replace rrent_imp`i' = rrent`i'*30 if rrentper`i'==2
replace rrent_imp`i' = rrent`i'*4  if rrentper`i'==3
replace rrent_imp`i' = rrent`i'*2  if rrentper`i'==4
replace rrent_imp`i' = rrent`i'/12 if rrentper`i'==6
replace rrent_imp`i' = rrent`i'    if rrentper`i'==5
replace rrent_imp`i' = .           if rrentper`i'==7
label var rrent_imp`i' "RENT CONVERTED TO MONTHS `i'"

* UTILITIES
if `i'>1997{
    if `i'>2005 & `i'<2021{
        replace rutil_onebill`i' = . if rutil_onebill`i'>7

        replace rcombutil`i' = . if rcombutil`i'>9997
        replace rcombutil`i' = . if rutil_onebill`i'==1 | rutil_onebill`i'==5 | missing(rutil_onebill`i')

        replace rcombutil`i' = rcombutil`i'/12 if rcombutilper`i'==6
        replace rcombutil`i' = . if rcombutilper`i'>7

        replace rfuel`i' = . if rfuel`i'>9997
        replace rfuel`i' = . if rutil_onebill`i'==2

        replace rfuel`i' = rfuel`i'/12 if rfuelper`i'==6
        replace rfuel`i' = . if rfuelper`i'==9

        replace relec`i' = . if relec`i'>9997
        replace relec`i' = . if rutil_onebill`i'==2

        replace relec`i' = relec`i'/12 if relecper`i'==6
        replace relec`i' = . if relecper`i'==9
    }

    if `i'<=2005{
        replace rfuel`i' = . if rfuel`i'>9997

        replace rfuel`i' = rfuel`i'/12 if rfuelper`i'==6
        replace rfuel`i' = . if rfuelper`i'==9

        replace relec`i' = . if relec`i'>9997

        replace relec`i' = relec`i'/12 if relecper`i'==6
        replace relec`i' = . if relecper`i'==9
    }

    * impute total utilities
    * gen rutil_tot`i' = .
    * replace rutil_tot`i' = relec`i' + rfuel`i' if !missing(rfuel`i') & !missing(relec`i')


replace rwater`i' = . if rwater`i'>9997

replace rwater`i' = rwater`i'/12 if rwaterper`i'==6
replace rwater`i' = rwater`i'/4  if rwaterper`i'==4
replace rwater`i' = .            if rwaterper`i'>7
}

* VEHICLES
if `i'>1997{
    replace rnumveh`i' = . if rnumveh`i'>=98
    replace rnumveh`i' = . if (rwtrveh`i'==8 | rwtrveh`i'==9)

    replace rwtrveh`i' = . if rwtrveh`i'>7
    replace rwtrveh`i' = 0 if rwtrveh`i'==5
}

if `i'>2003{
    * COSTS (ONLY AVAILABLE 2005 ONWARDS)

    replace rcostfurn_ly`i'  = . if rcostfurn_ly`i'>=999998
    replace rcostcloth_ly`i' = . if rcostcloth_ly`i'>=999998
    replace rcostvac_ly`i'   = . if rcostvac_ly`i'>=999998
    replace rcostrec_ly`i'   = . if rcostrec_ly`i'>=999998
}

* FOOD:

replace rfoodhome_fs`i' = . if rfoodhome_fs`i'>99997

replace rfoodhome_fs`i' = . if rfoodhomeper_fs`i'>3
replace rfoodhome_fs`i' = rfoodhome_fs`i'*52 if rfoodhomeper_fs`i'==1
replace rfoodhome_fs`i' = rfoodhome_fs`i'*26 if rfoodhomeper_fs`i'==2
replace rfoodhome_fs`i' = rfoodhome_fs`i'*12 if rfoodhomeper_fs`i'==3

replace rfoodahome_fs`i' = . if rfoodahome_fs`i'>99997

replace rfoodahome_fs`i' = . if rfoodahomeper_fs`i'>3
replace rfoodahome_fs`i' = rfoodahome_fs`i'*52 if rfoodahomeper_fs`i'==1
replace rfoodahome_fs`i' = rfoodahome_fs`i'*26 if rfoodahomeper_fs`i'==2
replace rfoodahome_fs`i' = rfoodahome_fs`i'*12 if rfoodahomeper_fs`i'==3

replace rfoodhome_nfs`i' = . if rfoodhome_nfs`i'>99997

replace rfoodhome_nfs`i' = . if rfoodhomeper_nfs`i'>3
replace rfoodhome_nfs`i' = rfoodhome_nfs`i'*52 if rfoodhomeper_nfs`i'==1
replace rfoodhome_nfs`i' = rfoodhome_nfs`i'*26 if rfoodhomeper_nfs`i'==2
replace rfoodhome_nfs`i' = rfoodhome_nfs`i'*12 if rfoodhomeper_nfs`i'==3

replace rfoodahome_nfs`i' = . if rfoodahome_nfs`i'>99997

replace rfoodahome_nfs`i' = . if rfoodahomeper_nfs`i'>3
replace rfoodahome_nfs`i' = rfoodahome_nfs`i'*52 if rfoodahomeper_nfs`i'==1
replace rfoodahome_nfs`i' = rfoodahome_nfs`i'*26 if rfoodahomeper_nfs`i'==2
replace rfoodahome_nfs`i' = rfoodahome_nfs`i'*12 if rfoodahomeper_nfs`i'==3

egen rfoodhome_imp`i' = rowtotal(rfoodhome_fs`i' rfoodhome_nfs`i')
label var rfoodhome_imp`i' "IMPUTED ANNUAL FOOD COSTS AT HOME"
egen rfoodahome_imp`i' = rowtotal(rfoodahome_fs`i' rfoodahome_nfs`i')
label var rfoodahome_imp`i' "IMPUTED ANNUAL FOOD COSTS EAT OUT"

replace rnumrooms`i' = . if rnumrooms`i'>=98

rename r68id`i' rfam68id`i'
rename rvalfs`i' rvalfoodst`i'

if `i'>=2017{
    replace rrent_equiv`i' = . if rrent_equiv`i'>=99998
    replace rrent_equiv`i' = . if rrent_equivper`i'>=7
    replace rrent_equiv`i' = rrent_equiv`i'*4 if rrent_equivper`i'==3
    replace rrent_equiv`i' = rrent_equiv`i'/12 if rrent_equivper`i'==6
}

/*
if `i'>=2021{
    egen rcons21_all`i' = rowtotal(rcons_food`i' rcons_hous`i' rcons_trans`i' rcons_educ`i' rcons_child`i' rcons_health`i')
    egen rcons21_05all`i' = rowtotal(rcons_food`i' rcons_hous`i' rcons_trans`i' rcons_educ`i' rcons_child`i' rcons_health`i' ///
        rcons_phone`i' rcons_maintain`i' rcons_furn`i' rcons_cloth`i' rcons_trips`i' rcons_recr`i')
}
*/

if `i'==2021{
    gen rhelp_findiff`i' = .
    replace rhelp_findiff`i' = 1 if rman_findiff`i'==1
    replace rhelp_findiff`i' = 0 if rman_findiff`i'==5 | rman_findiff`i'==0

    replace rman_findiff`i' = . if (rman_findiff`i'>=8 | rman_findiff`i'==0)
    replace rman_findiff`i' = 0 if rman_findiff`i'==5
}

if `i'>2007{
    replace rwtrbeh_mort_one`i' = . if rwtrbeh_mort_one`i'>=8 | rwtrbeh_mort_one`i'==0   // missing if not homeowner
    replace rwtrbeh_mort_one`i' = 0 if rwtrbeh_mort_one`i'==5

    replace rlikebeh_mort_one`i' = . if rlikebeh_mort_one`i'>=8
}

replace rwtrmoved`i' = . if rwtrmoved`i'==9 | rwtrmoved`i'==8
replace rwtrmoved`i' = 0 if rwtrmoved`i'==5

replace rwtrmightmove`i' = . if rwtrmightmove`i'==9 | rwtrmightmove`i'==8
replace rwtrmightmove`i' = 0 if rwtrmightmove`i'==5

replace rprobmove`i' = . if rprobmove`i'==9
replace rmoved_month`i' = . if rmoved_month`i'==99 | rmoved_month`i'==98 | rmoved_month`i'==0
replace rmoved_year`i' = . if rmoved_year`i'>9995 | rmoved_year`i'==0 | rmoved_year`i'==8 | rmoved_year`i'==9

if `i'<2003{
    replace rmoved_year`i' = `i'-2 if rmoved_year`i'==1
    replace rmoved_year`i' = `i'-1 if rmoved_year`i'==2
    replace rmoved_year`i' = `i'   if rmoved_year`i'==3
}

if `i'>2001{
    replace rwtroutlf`i' = . if rwtroutlf`i'==8 | rwtroutlf`i'==9
    replace rwtroutlf`i' = 0 if rwtroutlf`i'==5

    replace rwtrunemp_ly`i' = . if rwtrunemp_ly`i'==8 | rwtrunemp_ly`i'==9
    replace rwtrunemp_ly`i' = 0 if rwtrunemp_ly`i'==5

    replace rwtrunemp_lly`i' = . if rwtrunemp_lly`i'==8 | rwtrunemp_lly`i'==9
    replace rwtrunemp_lly`i' = 0 if rwtrunemp_lly`i'==5
}

if `i'>2001{
    replace rwtr_homeimp`i' = 0 if rwtr_homeimp`i'==5
    replace rwtr_homeimp`i' = . if rwtr_homeimp`i'>=8

    replace rhomeimp`i' = . if rhomeimp`i'>=999999998
}

if `i'>1997{
    replace rwtrinherit`i' = . if (rwtrinherit`i'==9 | rwtrinherit`i'==8)
    replace rwtrinherit`i' = 0 if rwtrinherit`i'==5

    replace rvalinherit_one`i'   = . if rvalinherit_one`i'>9999997
    replace rvalinherit_two`i'   = . if rvalinherit_two`i'>9999997
    replace rvalinherit_three`i' = . if rvalinherit_three`i'>9999997
    replace rsellpricehome`i'    = . if rsellpricehome`i'>9999997
}

replace rpsidstate`i' = . if rpsidstate`i'==99
save "`cleandata_dir'/fam`i'", replace
}

* EXTRACT IDENTIFIERS FROM CROSS YEAR INDIVIDUAL DATASET:

local path "R:\mfa\raon\datasets\psid\"   //parent folder for project
local code_dir "`path'/codes"      // all .do files that clean/merge the datasets are stored here
local data_dir "`path'/data"       // all raw data files are stored here
local cleandata_dir "`path'/clean_data"        // all clean data is stored here
*local cleandata_dir2 "`path'/clean_data_renamed"   // all clean data is stored here

include "`data_dir'/ind2023er/IND2023ER.do"
rename redyrs* redhd*
compress
save "`cleandata_dir'/ind2023", replace

* MERGE YEAR LEVEL FILES TO GET WIDE FORM PANEL DATASET

use "`cleandata_dir'/ind2023", clear

forval i = 1968/1997 {

    merge m:1 rfamiid`i' using "`cleandata_dir'/fam`i'.dta"

    if `i'==1968 {

        preserve
        drop if _merge==1
        keep *`i'
        drop rrelhead`i' rhead`i'
		compress
        save "`cleandata_dir'/fam`i'.dta", replace

        restore
    }

if `i'==1970/1974 {

    preserve
    keep *`i'
    drop rseqnum`i' rrelhead`i' rhead`i'
    drop if _merge==1
	compress
    save "`cleandata_dir'/fam`i'.dta", replace
    restore
}

if `i'==1985/1990 {

    preserve
    keep *`i'
    drop rseqnum`i' rrelhead`i' rhead`i'
    drop if _merge==1
	compress
    save "`cleandata_dir'/fam`i'.dta", replace
    restore
}

drop _merge

compress
save "`cleandata_dir'/intmd_merge/merge_`i'.dta", replace
}

forval i = 1999(2)2023 {

    merge m:1 rfamiid`i' using "`cleandata_dir'/fam`i'.dta"

    drop _merge
	compress
    save "`cleandata_dir'/intmd_merge/merge_`i'.dta", replace
}

gen rmainocc_con1999 = rmainocc_con2003
gen rmainind_con1999 = rmainind_con2003
gen rmainocc_dad_con1999 = rmainocc_dad_con2003
gen rmainocc_mom_con1999 = rmainocc_mom_con2003
gen rmainind_dad_con1999 = rmainind_dad_con2003
gen rmainind_mom_con1999 = rmainind_mom_con2003

gen rmainocc_con2001 = rmainocc_con2003
gen rmainind_con2001 = rmainind_con2003
gen rmainocc_dad_con2001 = rmainocc_dad_con2003
gen rmainocc_mom_con2001 = rmainocc_mom_con2003
gen rmainind_dad_con2001 = rmainind_dad_con2003
gen rmainind_mom_con2001 = rmainind_mom_con2003
gen rmainocc_con2017 = rmainocc_con2015
gen rmainind_con2017 = rmainind_con2015
gen rmainocc_dad_con2017 = rmainocc_dad_con2015
gen rmainocc_mom_con2017 = rmainocc_mom_con2015
gen rmainind_dad_con2017 = rmainind_dad_con2015
gen rmainind_mom_con2017 = rmainind_mom_con2015

gen rmainocc_con2021 = rmainocc_con2015
gen rmainind_con2021 = rmainind_con2015
gen rmainocc_dad_con2021 = rmainocc_dad_con2015
gen rmainocc_mom_con2021 = rmainocc_mom_con2015
gen rmainind_dad_con2021 = rmainind_dad_con2015
gen rmainind_mom_con2021 = rmainind_mom_con2015

gen rmainocc_con2023 = rmainocc_con2015
gen rmainind_con2023 = rmainind_con2015
gen rmainocc_dad_con2023 = rmainocc_dad_con2015
gen rmainocc_mom_con2023 = rmainocc_mom_con2015
gen rmainind_dad_con2023 = rmainind_dad_con2015
gen rmainind_mom_con2023 = rmainind_mom_con2015

gen rmainocc_con2019 = rmainocc_con2015
gen rmainind_con2019 = rmainind_con2015
gen rmainocc_dad_con2019 = rmainocc_dad_con2015
gen rmainocc_mom_con2019 = rmainocc_mom_con2015
gen rmainind_dad_con2019 = rmainind_dad_con2015
gen rmainind_mom_con2019 = rmainind_mom_con2015

compress 
save "`cleandata_dir'/crossfam2023.dta", replace

* Output variable names and labels to an excel file:

quietly describe

preserve
if r(k) > r(N) set obs `r(k)'

quietly ds
local varlist `r(varlist)'

foreach new in newlist varname varlabel {
    quietly generate str `new' = ""
}

local k 1
foreach var of varlist `varlist' {
    local varlabel : variable label `var'
    quietly replace varname = "`var'" in `k'
    quietly replace varlabel = "`varlabel'" in `k'
    local ++k
}
quietly export excel varname varlabel using ///
    "R:\mfa\raon\datasets\psid\clean_data\Varnamesnlabels.xlsx", ///
    sheet("Names & Labels", replace) firstrow(variables)

* Rename variables in family file so that they are just the STUB, not r-STUB-YYYY:
/*
forval i = 1968/1997 {
    use "`cleandata_dir'/fam`i'.dta", clear

    rename r*`i' *
	
	compress
    save "`cleandata_dir2'/fam`i'.dta", replace

    quietly describe

    if r(k) > r(N) set obs `r(k)'

    quietly ds
    local varlist `r(varlist)'

    foreach new in newlist varname varlabel {
        quietly generate str `new' = ""
    }

    local k 1
    foreach var of varlist `varlist' {
        local varlabel : variable label `var'
        quietly replace varname = "`var'" in `k'
        quietly replace varlabel = "`varlabel'" in `k'
        local ++k
    }

    quietly export excel varname varlabel using ///
        "R:\mfa\raon\datasets\psid\VarNamesLabels.xlsx", ///
        sheet("Names & Labels `i'", replace) firstrow(variables)
}

forval i = 1999(2)2023 {
    use "`cleandata_dir'/fam`i'.dta", clear

    rename r*`i' *
	
	compress
    save "`cleandata_dir2'/fam`i'.dta", replace

    quietly describe
}
*/

