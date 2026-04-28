/*-----------------------------------------------------------------------------
 03_reduced_form.do — Reduced-form event study using each instrument
 directly as the treatment. Same FE structure as the OLS / IV. Coefficients
 are in instrument-σ units; rescaling by the cross-state first-stage slope
 (boom_std on instrument) gives boom-σ-equivalent magnitudes.

 This is what we used in the Python migration (PyFixest panel TWFE), and it
 should match the Stata IV (02_iv_panel_twfe.do) up to the multi-endog
 weighting scheme — useful as a sanity check.
-----------------------------------------------------------------------------*/

do 00_setup.do

display _newline(2) "=========================================================="
display "  Reduced-form event study (instrument as treatment)"
display "=========================================================="

* Compute and save cross-state first-stage slopes for later rescaling
preserve
    keep if !missing(boom_std, saiz_std, gmns_std, bartik_std)
    collapse (mean) boom_std saiz_std gmns_std bartik_std, by(state_99)
    foreach z in saiz_std gmns_std bartik_std {
        regress boom_std `z'
        local fs_`z' = _b[`z']
        display "  First-stage slope (boom_std on `z'): " %6.3f `fs_`z''
    }
restore

* Note: macros set inside `preserve` are local; redo at the top level
preserve
    keep if !missing(boom_std, saiz_std, gmns_std, bartik_std)
    collapse (mean) boom_std saiz_std gmns_std bartik_std, by(state_99)
    foreach z in saiz_std gmns_std bartik_std {
        regress boom_std `z'
        global fs_`z' = _b[`z']
    }
restore

display _newline "First-stage slopes for rescaling RF coefficients:"
display "  fs_saiz_std   = $fs_saiz_std"
display "  fs_gmns_std   = $fs_gmns_std"
display "  fs_bartik_std = $fs_bartik_std"

* Run reduced-form event studies
foreach y in nw_w5 eq_w5 noeq_w5 ho_pct {
    foreach sg in 1 0 {
        local sg_label = cond(`sg'==1, "HO", "renter")
        foreach z in saiz_std gmns_std bartik_std {
            display _newline "--- RF: `z'  Outcome: `y'  Subgroup: 1999 `sg_label' ---"
            reghdfe `y' ib1999.year##c.`z' $DEMOG ///
                $WEIGHT if ho_99 == `sg', ///
                absorb($ABSORB) cluster($CLUSTER)
            estimates store rf_`z'_`y'_`sg_label'

            foreach yr in 2007 2011 2023 {
                local b = _b[`yr'.year#c.`z']
                local se = _se[`yr'.year#c.`z']
                local b_resc = `b' / ${fs_`z'}
                display "    `yr': beta = " %7.2f `b' " (rescaled = " %7.2f `b_resc' ")"
            }
        }
    }
}

display _newline "Reduced-form estimates saved. Next: do 04_focal_year_iv.do"
