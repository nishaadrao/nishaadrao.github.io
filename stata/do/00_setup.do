/*-----------------------------------------------------------------------------
 00_setup.do — Load the merged PSID panel + define globals used by every
 subsequent do-file.

 Dataset: ../data/psid_event_study.dta (built by build_stata_dataset.py)

 Required Stata packages (install once):

     ssc install reghdfe, replace
     ssc install ftools, replace
     ssc install ivreghdfe, replace
     ssc install ivreg2, replace
     ssc install ranktest, replace
     ssc install coefplot, replace
     ssc install weakivtest, replace      // optional, Olea-Pflueger weak-IV test

 Run order:
     do 00_setup.do
     do 01_ols_panel_twfe.do
     do 02_iv_panel_twfe.do          <-- the headline IV (multi-endog, FE-absorbed)
     do 03_reduced_form.do
     do 04_focal_year_iv.do
     do 05_first_stage.do
     do 06_plot.do
-----------------------------------------------------------------------------*/

clear all
set more off
capture log close

* Project root — adjust if your local path differs
local project = "`c(pwd)'"
display "Working directory: `project'"

* Locate the data file relative to this do-file
* Assumes do-files are run from stata/do/ or stata/
capture confirm file "../data/psid_event_study.dta"
if _rc == 0 {
    use "../data/psid_event_study.dta", clear
}
else {
    capture confirm file "data/psid_event_study.dta"
    if _rc == 0 {
        use "data/psid_event_study.dta", clear
    }
    else {
        di as err "Cannot find psid_event_study.dta. cd into the stata/ folder before running."
        exit 198
    }
}

* Panel set
xtset rauid year

* ── Globals: control set, FE absorb list, weights, cluster ──
global DEMOG       "ragehd age_sq rgenderhd_fem rracehd_bl rmarstat_mar sinh_faminc"
global DEMOG_NOINC "ragehd age_sq rgenderhd_fem rracehd_bl rmarstat_mar"
global ABSORB      "state_99 year edu_99"
global CLUSTER     "state_99"
global WEIGHT      "[aweight=w]"

* Reference year for event-study `i.year, ref=1999`
global REF_YEAR    1999

* Sanity-print sample sizes
display _newline "Sample sizes:"
count
display "  Total household-years: " r(N)
count if ho_99 == 1
display "  1999-HO subsample:     " r(N)
count if ho_99 == 0
display "  1999-renter subsample: " r(N)

display _newline "Globals defined:"
display "  DEMOG    = $DEMOG"
display "  ABSORB   = $ABSORB"
display "  CLUSTER  = $CLUSTER"
display "  WEIGHT   = $WEIGHT"
display "  REF_YEAR = $REF_YEAR"

display _newline "Setup complete. Next: do 01_ols_panel_twfe.do"
