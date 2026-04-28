/*-----------------------------------------------------------------------------
 07_triple_difference.do — Panel-TWFE triple-difference event study
 (paper's equation 1). Puts 1999 homeowners and 1999 renters in the same
 regression and lets the data identify three things at once:

   δ_k (boom × 1[year=k])              : renter-side year-k effect
   γ_k (boom × 1[year=k] × HO_99)      : HO-channel year-k premium
   δ_k + γ_k                           : implied total effect on 1999 HO

 The three quantities answer different questions:

   δ_k       — boom-cycle effect on 1999 renters at year k
   γ_k       — extra effect on 1999 homeowners (the "homeowner channel")
   δ_k + γ_k — total effect on 1999 homeowners (matches the HO subgroup
               regression in 01_ols_panel_twfe.do)

 Run for OLS, panel-TWFE IV (the spec PyFixest cannot handle: 25 endogenous
 regressors with absorbing FE), and reduced form. Followed by `lincom` to
 extract δ_k + γ_k year-by-year with proper SE.
-----------------------------------------------------------------------------*/

do 00_setup.do

display _newline(2) "=========================================================="
display "  Triple-difference event study (paper's equation 1)"
display "  y ~ i(year)*boom*HO99 + state + year + edu_99 FE"
display "=========================================================="

* ──────────────────────────────────────────────────────────────
* (A) OLS triple-difference
* ──────────────────────────────────────────────────────────────
display _newline "--- (A) OLS triple-difference: NW ---"
reghdfe nw_w5 ib1999.year##c.boom_std##i.ho_99 $DEMOG ///
    $WEIGHT, absorb($ABSORB) cluster($CLUSTER)
estimates store td_ols

display _newline "  Renter response δ_k (= year_k # c.boom_std):"
foreach yr in 2007 2011 2023 {
    local d  = _b[`yr'.year#c.boom_std]
    local sd = _se[`yr'.year#c.boom_std]
    display "    `yr':  δ = " %7.2f `d' "  (se " %5.2f `sd' ")"
}

display _newline "  Homeowner-channel premium γ_k (= year_k # c.boom_std # 1.ho_99):"
foreach yr in 2007 2011 2023 {
    local g  = _b[`yr'.year#c.boom_std#1.ho_99]
    local sg = _se[`yr'.year#c.boom_std#1.ho_99]
    display "    `yr':  γ = " %7.2f `g' "  (se " %5.2f `sg' ")"
}

display _newline "  Implied total effect on 1999 HO (δ_k + γ_k) via lincom:"
foreach yr in 2007 2011 2023 {
    qui lincom `yr'.year#c.boom_std + `yr'.year#c.boom_std#1.ho_99
    display "    `yr':  δ+γ = " %7.2f r(estimate) "  (se " %5.2f r(se) ")  " ///
            "p = " %5.3f r(p)
}

* ──────────────────────────────────────────────────────────────
* (B) Panel TWFE IV triple-difference (the headline causal spec)
* ──────────────────────────────────────────────────────────────
display _newline(2) "--- (B) Panel-TWFE IV triple-difference: NW (Saiz) ---"
* 25 endogenous variables (year × boom + boom × HO + year × boom × HO),
* instrumented by 25 parallel year × saiz / saiz × HO / year × saiz × HO.
* Exogenous: i.ho_99 main + year × HO interactions + demographic controls.
ivreghdfe nw_w5 i.ho_99 ib1999.year#i.ho_99 $DEMOG ///
    (ib1999.year#c.boom_std c.boom_std#i.ho_99 ib1999.year#c.boom_std#i.ho_99 = ///
     ib1999.year#c.saiz_std c.saiz_std#i.ho_99 ib1999.year#c.saiz_std#i.ho_99) ///
    $WEIGHT, absorb($ABSORB) cluster($CLUSTER)
estimates store td_iv_saiz

display _newline "  Renter response δ_k (IV):"
foreach yr in 2007 2011 2023 {
    capture local d  = _b[`yr'.year#c.boom_std]
    capture local sd = _se[`yr'.year#c.boom_std]
    if !_rc display "    `yr':  δ = " %7.2f `d' "  (se " %5.2f `sd' ")"
}

display _newline "  Homeowner-channel premium γ_k (IV):"
foreach yr in 2007 2011 2023 {
    capture local g  = _b[`yr'.year#c.boom_std#1.ho_99]
    capture local sg = _se[`yr'.year#c.boom_std#1.ho_99]
    if !_rc display "    `yr':  γ = " %7.2f `g' "  (se " %5.2f `sg' ")"
}

display _newline "  Implied total effect on 1999 HO (δ_k + γ_k) via lincom (IV):"
foreach yr in 2007 2011 2023 {
    capture qui lincom `yr'.year#c.boom_std + `yr'.year#c.boom_std#1.ho_99
    if !_rc display "    `yr':  δ+γ = " %7.2f r(estimate) "  (se " %5.2f r(se) ")"
}

* ──────────────────────────────────────────────────────────────
* (C) Reduced-form triple-difference (Saiz as treatment)
* ──────────────────────────────────────────────────────────────
display _newline(2) "--- (C) Reduced-form triple-difference: NW (Saiz) ---"
reghdfe nw_w5 ib1999.year##c.saiz_std##i.ho_99 $DEMOG ///
    $WEIGHT, absorb($ABSORB) cluster($CLUSTER)
estimates store td_rf_saiz

display _newline "  Reduced-form coefficients (in saiz-σ units; rescale by first-stage slope):"
foreach yr in 2007 2011 2023 {
    local d_rf  = _b[`yr'.year#c.saiz_std]
    local g_rf  = _b[`yr'.year#c.saiz_std#1.ho_99]
    display "    `yr':  δ_rf = " %7.2f `d_rf' "  γ_rf = " %7.2f `g_rf'
}

* ──────────────────────────────────────────────────────────────
* (D) Loop the triple-difference over the four core wealth outcomes
* ──────────────────────────────────────────────────────────────
display _newline(2) "--- (D) Triple-difference OLS, all 4 wealth outcomes ---"
foreach y in nw_w5 eq_w5 noeq_w5 ho_pct {
    qui reghdfe `y' ib1999.year##c.boom_std##i.ho_99 $DEMOG ///
        $WEIGHT, absorb($ABSORB) cluster($CLUSTER)
    estimates store td_ols_`y'

    display _newline "  Outcome: `y'  (peak/trough/2023)"
    foreach yr in 2007 2011 2023 {
        qui lincom `yr'.year#c.boom_std + `yr'.year#c.boom_std#1.ho_99
        local total = r(estimate)
        local total_se = r(se)
        local g = _b[`yr'.year#c.boom_std#1.ho_99]
        local d = _b[`yr'.year#c.boom_std]
        display "    `yr':  δ=" %7.2f `d' "  γ=" %7.2f `g' "  δ+γ=" %7.2f `total' ///
                " (se " %5.2f `total_se' ")"
    }
}

* ──────────────────────────────────────────────────────────────
* Optional: coefplot the γ_k series (HO-channel premium) from OLS triple-diff
* ──────────────────────────────────────────────────────────────
estimates restore td_ols
coefplot, keep(*.year#c.boom_std#1.ho_99) ///
    omitted baselevels vertical recast(connected) ciopts(recast(rcap)) ///
    yline(0, lcolor(gs10) lwidth(thin)) ///
    ytitle("{&gamma}_k (HO-channel premium per 1{&sigma} boom)") ///
    xtitle("PSID wave") ///
    title("Triple-difference: HO-channel premium {&gamma}_k by year (OLS)") ///
    legend(off) grid(none)
graph export "../output/triple_diff_gamma_ols.pdf", replace

display _newline "Triple-difference results saved. PDF: ../output/triple_diff_gamma_ols.pdf"
display "Estimates stored: td_ols, td_iv_saiz, td_rf_saiz, td_ols_<outcome>"
