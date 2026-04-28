/*-----------------------------------------------------------------------------
 01_ols_panel_twfe.do — Panel TWFE OLS event study (paper's eq. 1 spec).

   y_it = α_s + λ_t + μ_e + Σ_k β_k * 1[t=k] * boom_std + X_i,1999 γ + ε_it
        absorb: state_99 + year + edu_99 (additive)
        cluster: state_99
        weights: PSID family weights

 Run separately for the 1999 homeowner and 1999 renter subgroups.
 Outcomes: net worth, home equity, non-housing wealth, homeowner indicator.
 Saves estimates for later coefplot.
-----------------------------------------------------------------------------*/

do 00_setup.do

display _newline(2) "=========================================================="
display "  Panel TWFE OLS event study (paper's eq. 1)"
display "=========================================================="

* Loop over outcomes × subgroups
foreach y in nw_w5 eq_w5 noeq_w5 ho_pct {
    foreach sg in 1 0 {
        local sg_label = cond(`sg'==1, "HO", "renter")
        display _newline "--- Outcome: `y'  Subgroup: 1999 `sg_label' ---"
        reghdfe `y' ib1999.year##c.boom_std $DEMOG ///
            $WEIGHT if ho_99 == `sg', ///
            absorb($ABSORB) cluster($CLUSTER)
        estimates store ols_`y'_`sg_label'

        * Quick peek at peak / trough / 2023
        foreach yr in 2007 2011 2023 {
            local b = _b[`yr'.year#c.boom_std]
            local se = _se[`yr'.year#c.boom_std]
            display "    `yr': beta = " %7.2f `b' "  se = " %5.2f `se'
        }
    }
}

display _newline "OLS estimates saved (ols_<outcome>_<HO|renter>). Next: do 02_iv_panel_twfe.do"
