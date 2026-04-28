/*-----------------------------------------------------------------------------
 04_focal_year_iv.do — Cross-section IV at three focal years (s17 in the
 Python project). Useful as a compact summary alongside the full event
 study, and a familiar diagnostic.

 Spec at year y:

   Δ y_i,1999→y = α + β_y boom_std + X_i,1999 γ + ε_i

 with boom_std instrumented by Saiz, GMNS, Bartik 1999--07, or all three
 jointly. 1999-state-clustered SEs. Sample = 1999 homeowners observed at
 year y.
-----------------------------------------------------------------------------*/

do 00_setup.do

display _newline(2) "=========================================================="
display "  Focal-year cross-section IV (2007 / 2011 / 2019)"
display "=========================================================="

* Construct Δ y from 1999 baseline within household
foreach y in nw_w5 eq_w5 noeq_w5 ho_pct {
    capture drop `y'_99 d_`y'
    bysort rauid (year): gen `y'_99 = `y'[1] if year == 1999
    bysort rauid (year): replace `y'_99 = `y'_99[1]
    gen d_`y' = `y' - `y'_99
}

local FOCAL "2007 2011 2019"

foreach y in nw_w5 {  // headline outcome only — extend if needed
    foreach k of local FOCAL {
        display _newline "===== Focal year: `k'  Outcome: d_`y'  Sample: 1999 HO ====="

        * (1) OLS
        display "[OLS]"
        reg d_`y' boom_std $DEMOG_NOINC redhd ///
            $WEIGHT if ho_99 == 1 & year == `k', ///
            cluster(state_99)
        estimates store fy_ols_`y'_`k'

        * (2) IV: Saiz alone
        display "[IV: Saiz]"
        ivreg2 d_`y' $DEMOG_NOINC redhd ///
            (boom_std = saiz_std) ///
            $WEIGHT if ho_99 == 1 & year == `k', ///
            cluster(state_99)
        estimates store fy_saiz_`y'_`k'

        * (3) IV: GMNS alone
        display "[IV: GMNS]"
        ivreg2 d_`y' $DEMOG_NOINC redhd ///
            (boom_std = gmns_std) ///
            $WEIGHT if ho_99 == 1 & year == `k', ///
            cluster(state_99)
        estimates store fy_gmns_`y'_`k'

        * (4) IV: Bartik 1999--07 alone
        display "[IV: Bartik]"
        ivreg2 d_`y' $DEMOG_NOINC redhd ///
            (boom_std = bartik_std) ///
            $WEIGHT if ho_99 == 1 & year == `k', ///
            cluster(state_99)
        estimates store fy_bartik_`y'_`k'

        * (5) IV: all three jointly (over-identified)
        display "[IV: All 3, over-identified]"
        ivreg2 d_`y' $DEMOG_NOINC redhd ///
            (boom_std = saiz_std gmns_std bartik_std) ///
            $WEIGHT if ho_99 == 1 & year == `k', ///
            cluster(state_99)
        estimates store fy_all3_`y'_`k'
    }
}

* Summary table
display _newline "Summary table (focal-year IV, NW 1999-HO):"
estimates table fy_ols_nw_w5_2007 fy_saiz_nw_w5_2007 fy_gmns_nw_w5_2007 ///
                fy_bartik_nw_w5_2007 fy_all3_nw_w5_2007, ///
    keep(boom_std) b(%9.2f) se(%9.2f) stats(N)

display _newline "Focal-year IV done. Next: do 05_first_stage.do"
