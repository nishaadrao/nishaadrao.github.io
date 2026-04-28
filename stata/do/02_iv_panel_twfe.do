/*-----------------------------------------------------------------------------
 02_iv_panel_twfe.do — Panel TWFE IV event study with multiple endogenous
 regressors (year × treatment interactions instrumented by year × instrument
 interactions). This is the spec PyFixest cannot run; Stata's `ivreghdfe`
 handles it natively.

 Spec:

   y_it = α_s + λ_t + μ_e + Σ_k β_k * 1[t=k] * BOOM_HAT_s + X_i,1999 γ + ε_it
                             ↑
                        instrumented by Σ_k 1[t=k] * Z_s
                        for Z ∈ { Saiz, GMNS, Bartik 1999--2007 }

 Each year-specific endogenous regressor `boom_std × 1[year=k]` is
 instrumented by the corresponding `Z × 1[year=k]`. With T-1 = 12 endogenous
 and 12 instruments, the system is exactly identified per instrument, and
 we run separately for each of the three instruments. The over-identified
 spec uses all three instruments together.

 First-stage diagnostics: per-year first-stage F-stat and Kleibergen-Paap
 weak-identification F (the joint multi-endog analog).
-----------------------------------------------------------------------------*/

do 00_setup.do

display _newline(2) "=========================================================="
display "  Panel TWFE IV event study (multi-endog, absorbing FE)"
display "=========================================================="

* Outcomes × subgroups × instruments
foreach y in nw_w5 eq_w5 noeq_w5 ho_pct {
    foreach sg in 1 0 {
        local sg_label = cond(`sg'==1, "HO", "renter")

        foreach iv in saiz_std gmns_std bartik_std {
            display _newline "--- IV: `iv'  Outcome: `y'  Subgroup: 1999 `sg_label' ---"
            ivreghdfe `y' $DEMOG ///
                (ib1999.year#c.boom_std = ib1999.year#c.`iv') ///
                $WEIGHT if ho_99 == `sg', ///
                absorb($ABSORB) cluster($CLUSTER)
            estimates store iv_`iv'_`y'_`sg_label'

            * Peek at peak / trough / 2023
            foreach yr in 2007 2011 2023 {
                local b = _b[`yr'.year#c.boom_std]
                local se = _se[`yr'.year#c.boom_std]
                display "    `yr': beta = " %7.2f `b' "  se = " %5.2f `se'
            }
        }

        * Over-identified: all three instruments together
        display _newline "--- IV (all 3): Outcome: `y'  Subgroup: 1999 `sg_label' ---"
        ivreghdfe `y' $DEMOG ///
            (ib1999.year#c.boom_std = ib1999.year#c.saiz_std ib1999.year#c.gmns_std ib1999.year#c.bartik_std) ///
            $WEIGHT if ho_99 == `sg', ///
            absorb($ABSORB) cluster($CLUSTER)
        estimates store iv_all3_`y'_`sg_label'

        foreach yr in 2007 2011 2023 {
            local b = _b[`yr'.year#c.boom_std]
            local se = _se[`yr'.year#c.boom_std]
            display "    `yr' (all3): beta = " %7.2f `b' "  se = " %5.2f `se'
        }
    }
}

display _newline "IV estimates saved. Next: do 03_reduced_form.do"
