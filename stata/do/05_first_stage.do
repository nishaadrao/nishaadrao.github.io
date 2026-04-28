/*-----------------------------------------------------------------------------
 05_first_stage.do — First-stage diagnostics. Verifies instrument strength
 in two complementary ways:

 (1) Cross-state OLS first stage of boom_std on each instrument (the
     "naive" first stage that the reduced-form rescaling assumes).

 (2) Joint Kleibergen-Paap weak-IV F (from the 02 panel-IV with multiple
     endog). For multi-endog systems the simple "F > 10" rule of thumb is
     replaced by the Kleibergen-Paap rk Wald F statistic, with critical
     values from Stock-Yogo or (newer) Olea-Pflueger 2013 via `weakivtest`.

 (3) Per-year first-stage F for the panel TWFE IV (one per
     year-specific endogenous regressor). Reports the weakest-link year.
-----------------------------------------------------------------------------*/

do 00_setup.do

display _newline(2) "=========================================================="
display "  First-stage diagnostics"
display "=========================================================="

* ── (1) Cross-state OLS first stage (single-treatment) ──
preserve
    keep if !missing(boom_std, saiz_std, gmns_std, bartik_std)
    collapse (mean) boom_std saiz_std gmns_std bartik_std, by(state_99)

    display _newline "(1) Cross-state OLS first stage:"
    foreach z in saiz_std gmns_std bartik_std {
        regress boom_std `z'
        local b  = _b[`z']
        local se = _se[`z']
        local f  = e(F)
        local n  = e(N)
        display "  boom_std = b * `z' :  b = " %6.3f `b' "  se = " %5.3f `se' ///
                "  F(1," %2.0f `n'-2 ") = " %6.2f `f'
    }
    display _newline "  Joint (boom on all 3):"
    regress boom_std saiz_std gmns_std bartik_std
    display "  F(3, " %2.0f e(N)-4 ") = " %6.2f e(F)
restore

* ── (2) Panel TWFE multi-endog first-stage diagnostics ──
display _newline "(2) Panel TWFE multi-endog Kleibergen-Paap F (1999-HO, NW):"
foreach iv in saiz_std gmns_std bartik_std {
    qui ivreghdfe nw_w5 $DEMOG ///
        (ib1999.year#c.boom_std = ib1999.year#c.`iv') ///
        $WEIGHT if ho_99 == 1, ///
        absorb($ABSORB) cluster($CLUSTER)
    display "  IV `iv':"
    display "    Kleibergen-Paap rk Wald F = " %8.2f e(widstat)
    display "    Underidentification (rk LM)  = " %8.2f e(idstat) ///
            "  (p = " %5.3f e(idp) ")"
}
display _newline "  IV all 3 (over-identified):"
qui ivreghdfe nw_w5 $DEMOG ///
    (ib1999.year#c.boom_std = ib1999.year#c.saiz_std ib1999.year#c.gmns_std ib1999.year#c.bartik_std) ///
    $WEIGHT if ho_99 == 1, ///
    absorb($ABSORB) cluster($CLUSTER)
display "    Kleibergen-Paap rk Wald F = " %8.2f e(widstat)
display "    Hansen J (over-id test)   = " %8.2f e(j) ///
        "  (p = " %5.3f e(jp) ")"

* ── (3) Olea-Pflueger weak-IV test (modern, robust) ──
* Requires: ssc install weakivtest
display _newline "(3) Olea-Pflueger weak-IV test (single-instrument, Saiz):"
capture which weakivtest
if _rc == 0 {
    qui ivreg2 nw_w5 $DEMOG (boom_std = saiz_std) ///
        $WEIGHT if ho_99 == 1 & year == 2007, cluster(state_99)
    weakivtest
}
else {
    display "  weakivtest not installed; skipping. (ssc install weakivtest)"
}

display _newline "First-stage diagnostics done. Next: do 06_plot.do"
