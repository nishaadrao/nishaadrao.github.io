/*-----------------------------------------------------------------------------
 06_plot.do — Plot the OLS, IV (Saiz primary), and reduced-form event
 studies for net worth, by 1999 tenure subgroup. Run AFTER 01–03 so the
 estimates store entries exist.

 Outputs to ../output/:
     event_study_nw_HO.pdf
     event_study_nw_renter.pdf
-----------------------------------------------------------------------------*/

do 00_setup.do

* Re-run only the 1999-HO NW models if estimates_store is empty
* (in a fresh session you'd run 01-03 first; this guards against missing stores)
capture estimates restore ols_nw_w5_HO
if _rc != 0 {
    display "Estimates not found; re-running OLS, IV, RF for NW..."
    foreach sg in 1 0 {
        local sg_label = cond(`sg'==1, "HO", "renter")

        reghdfe nw_w5 ib1999.year##c.boom_std $DEMOG ///
            $WEIGHT if ho_99 == `sg', ///
            absorb($ABSORB) cluster($CLUSTER)
        estimates store ols_nw_w5_`sg_label'

        ivreghdfe nw_w5 $DEMOG ///
            (ib1999.year#c.boom_std = ib1999.year#c.saiz_std) ///
            $WEIGHT if ho_99 == `sg', ///
            absorb($ABSORB) cluster($CLUSTER)
        estimates store iv_saiz_std_nw_w5_`sg_label'

        reghdfe nw_w5 ib1999.year##c.saiz_std $DEMOG ///
            $WEIGHT if ho_99 == `sg', ///
            absorb($ABSORB) cluster($CLUSTER)
        estimates store rf_saiz_std_nw_w5_`sg_label'
    }
}

* ── Plot 1999-HO subgroup ──
coefplot ///
    (ols_nw_w5_HO,        keep(*.year#c.boom_std) recast(connected) ///
        ciopts(recast(rcap)) lcolor(navy) mcolor(navy) ///
        label("Panel TWFE OLS")) ///
    (iv_saiz_std_nw_w5_HO, keep(*.year#c.boom_std) recast(connected) ///
        ciopts(recast(rcap)) lcolor(red) mcolor(red) ///
        label("Panel TWFE IV (Saiz)")), ///
    omitted baselevels vertical ///
    yline(0, lcolor(gs10) lwidth(thin)) ///
    xline(2007.5 2011.5, lpattern(dash) lcolor(gs10)) ///
    ytitle("{&Delta} NW per 1{&sigma} boom, vs 1999 (in 2017{char 36}K)") ///
    xtitle("PSID wave") ///
    title("Boom-cycle event study: 1999 homeowners (NW)") ///
    legend(rows(1) position(6)) ///
    grid(none)

graph export "../output/event_study_nw_HO.pdf", replace

* ── Plot 1999-renter subgroup ──
coefplot ///
    (ols_nw_w5_renter,        keep(*.year#c.boom_std) recast(connected) ///
        ciopts(recast(rcap)) lcolor(navy) mcolor(navy) ///
        label("Panel TWFE OLS")) ///
    (iv_saiz_std_nw_w5_renter, keep(*.year#c.boom_std) recast(connected) ///
        ciopts(recast(rcap)) lcolor(red) mcolor(red) ///
        label("Panel TWFE IV (Saiz)")), ///
    omitted baselevels vertical ///
    yline(0, lcolor(gs10) lwidth(thin)) ///
    xline(2007.5 2011.5, lpattern(dash) lcolor(gs10)) ///
    ytitle("{&Delta} NW per 1{&sigma} boom, vs 1999 (in 2017{char 36}K)") ///
    xtitle("PSID wave") ///
    title("Boom-cycle event study: 1999 renters (NW)") ///
    legend(rows(1) position(6)) ///
    grid(none)

graph export "../output/event_study_nw_renter.pdf", replace

display _newline "Plots saved to ../output/"
