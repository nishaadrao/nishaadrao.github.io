# Stata Event-Study Package

This folder is a self-contained Stata replication of the boom-cycle event
studies, designed to be run on a separate machine that has Stata + the
SSC packages listed below. The dataset is pre-built from the Python
pipeline; the do-files run OLS, panel-TWFE IV (the spec PyFixest cannot
do because of multiple endogenous regressors), reduced-form, and focal-
year cross-section IV.

## Folder layout

```
stata/
├── build/
│   └── build_stata_dataset.py     Python script that produces the .dta
├── data/
│   └── psid_event_study.dta       Merged PSID + state vars (7.9 MB)
├── do/
│   ├── 00_setup.do                Globals + load data
│   ├── 01_ols_panel_twfe.do       Panel TWFE OLS event study
│   ├── 02_iv_panel_twfe.do        Panel TWFE IV (multi-endog, FE-absorbed)
│   ├── 03_reduced_form.do         RF using each instrument as treatment
│   ├── 04_focal_year_iv.do        Cross-section IV at 2007/2011/2019
│   ├── 05_first_stage.do          First-stage diagnostics + weak-IV tests
│   ├── 06_plot.do                 coefplot for the headline NW figure
│   └── 07_triple_difference.do    Triple-diff (paper's eq.~1, both subgroups)
├── output/                        (plots saved here)
└── README.md                      (this file)
```

## Required Stata packages

Install once (from any Stata session with internet):

```stata
ssc install reghdfe, replace
ssc install ftools, replace
ssc install ivreghdfe, replace
ssc install ivreg2, replace
ssc install ranktest, replace
ssc install coefplot, replace
ssc install weakivtest, replace      // optional, modern weak-IV diagnostic
```

`reghdfe` and `ivreghdfe` are the workhorses. `ivreg2` powers `ivreghdfe`'s
IV machinery and is independently used in the focal-year cross-section
do-file. `ranktest` is required for `ivreg2` weak-identification stats.
`coefplot` powers the figure. `weakivtest` (Pflueger–Wang 2015 / Olea–
Pflueger 2013) is optional but recommended for modern weak-IV inference.

## How to run

1. **Build the dataset** (one-time; runs on the machine with the Python
   project):
   ```bash
   cd wealth_recovery/stata/build
   python build_stata_dataset.py
   ```
   This writes `wealth_recovery/stata/data/psid_event_study.dta` (~8 MB).

2. **Copy the entire `stata/` folder** to the machine that has Stata.

3. **From inside the `stata/` folder in Stata**, run the do-files in
   order:
   ```stata
   cd stata
   do do/00_setup.do
   do do/01_ols_panel_twfe.do
   do do/02_iv_panel_twfe.do        // headline IV
   do do/03_reduced_form.do
   do do/04_focal_year_iv.do
   do do/05_first_stage.do
   do do/06_plot.do
   do do/07_triple_difference.do    // paper's eq. 1 spec, both subgroups
   ```
   Each do-file calls `00_setup.do` at the top so they can also be run
   individually.

## What each do-file does

### 01_ols_panel_twfe.do — Panel TWFE OLS

For each wealth outcome × subgroup (1999 HO or renter), runs

    y_it = α_s + λ_t + μ_e + Σ_k β_k · 1[t=k] · boom_std + X_i,1999 γ + ε

with `reghdfe`, absorbing 1999-state, year, and 1999-education FE
additively (no interactions); clustering at 1999 state; PSID family
weights as `aweight`. Twelve year-specific β_k coefficients per spec.

Mirrors the Python `s28_iv_event_study_full.py` OLS column.

### 02_iv_panel_twfe.do — Panel TWFE IV (the headline IV)

Same outcome / FE / clustering as `01`, but with `ivreghdfe`:

    Σ_k β_k · 1[t=k] · BOOM_HAT_s,
    where Σ_k 1[t=k] · BOOM_HAT_s ~ Σ_k 1[t=k] · Z_s

That is, each year-specific endogenous regressor `boom_std × 1[year=k]`
is instrumented by the corresponding `Z × 1[year=k]`. Run once per
instrument (Saiz, GMNS, Bartik 1999–2007), plus an over-identified spec
using all three together.

This is the spec PyFixest 0.50.1 can't run (multiple endogenous
regressors with absorbing FE). Stata handles it natively. The β_k
coefficients are the IV-causal year-specific magnitudes in boom-σ units,
directly comparable to the panel-TWFE OLS.

### 03_reduced_form.do — Reduced-form sanity check

For comparison, also run the reduced form (instrument enters directly as
the treatment), with the cross-state first-stage slope reported for
rescaling. This is what the Python `s28_iv_event_study_full.py` reports
as the "RF rescaled" magnitudes; the Stata IV in `02` should match these
up to the multi-endog weighting scheme. If they diverge meaningfully,
that's worth flagging.

### 04_focal_year_iv.do — Focal-year cross-section IV

The compact alternative: at each of 2007 / 2011 / 2019, regress
Δy_{1999→k} on `boom_std` instrumented by Saiz / GMNS / Bartik / all-3.
Mirrors the Python `s17` exercise. Useful as a familiar diagnostic and
for comparison with the headline panel-TWFE IV at the same focal years.

### 05_first_stage.do — First-stage diagnostics

(1) Cross-state OLS first stage (single-treatment): regress `boom_std`
    on each instrument at the state level. Reports F-stat.
(2) Panel TWFE multi-endog Kleibergen-Paap rk Wald F (the right
    weak-identification test for multi-endog systems).
(3) Olea–Pflueger weak-IV test via `weakivtest` (modern, robust).
(4) Hansen J over-identification test for the all-3 spec.

### 06_plot.do — coefplot figure

Plots OLS panel-TWFE and IV panel-TWFE (Saiz) side-by-side for the NW
outcome, separately for 1999 HO and 1999 renter subgroups. PDFs saved
to `output/`.

### 07_triple_difference.do — Triple-difference (paper's eq. 1)

Puts 1999 homeowners and 1999 renters in the same regression and lets
the data identify three quantities at once:

    δ_k       — boom-cycle effect on 1999 renters at year k
    γ_k       — extra effect on 1999 homeowners (the "homeowner channel")
    δ_k + γ_k — implied total effect on 1999 homeowners (matches the
                HO subgroup regression in 01_ols_panel_twfe.do)

Run for OLS, panel-TWFE IV with multiple endogenous regressors (~25
endogenous instrumented by ~25 parallel year × instrument interactions —
the spec PyFixest cannot handle), and reduced form. δ_k + γ_k is
extracted via `lincom` with proper joint SE. Plots γ_k by year
(`triple_diff_gamma_ols.pdf` in `output/`).

The δ_k from this triple-difference should match the renter subgroup
β_k from `01_ols_panel_twfe.do` exactly (in a balanced panel; near-
exactly under unbalanced). δ_k + γ_k should match the HO subgroup β_k.
γ_k is the within-state-and-year contrast that's the cleanest "HO
channel" identification — only available in the triple-difference form.

## Variable dictionary

The `.dta` carries 36 variables. Run `describe` after `do 00_setup.do`
to see Stata variable labels. Headline:

- **Outcomes**: `nw_w5`, `eq_w5`, `noeq_w5`, `ho_pct`, `cons_w5`,
  `log_cons`, `ihs_faminc`, `ihs_labinc`, `emp_pct`, `equity_share`,
  `stock_share`, `retirement_share`, `liquid_share`, `cum_refi_post`,
  `heloc_bal`.
- **Treatments / instruments**: `boom_std`, `saiz_std`, `gmns_std`,
  `bartik_std` (all standardized to σ = 1 across states).
- **Subgroup / cohort indicators**: `ho_99` (1999 homeowner indicator),
  `ever_owned` (1 if 1999 renter ever owned post-2009; -1 if HO_99),
  `cum_ho_post_pp` (cumulative ever-owned-post-2009 indicator × 100),
  `cohort` (entry-cohort code: -1=HO99, 0=early-boom 2001–03, 1=late-boom
  2005–07, 2=trough 2009–13, 3=recovery 2015–19, 4=late 2021–23, 5=never).
- **Demographics (1999 baseline, fill-with-median)**: `ragehd`, `age_sq`,
  `rgenderhd_fem`, `rracehd_bl`, `rmarstat_mar`, `sinh_faminc`,
  `rnumkidsfu`, `rnumfu`.
- **FE absorbers**: `state_99` (1999 state FIPS), `year`, `edu_99`.
- **Weights**: `w` (PSID family weight, clipped at 0).

## Sanity-check magnitudes (NW HO, expected from Python migration)

| Year | OLS panel TWFE | IV panel TWFE (Saiz) | RF rescaled |
|------|---:|---:|---:|
| 2007 | $34.3K | (Stata IV — reports here) | $63.1K |
| 2011 | −$1.1K | (Stata IV — reports here) | −$0.9K |
| 2023 | $19.2K | (Stata IV — reports here) | $27.1K |

The Stata IV panel-TWFE should produce a third column close to the RF
rescaled but not identical (multi-endog 2SLS uses a slightly different
weighting than the Wald-style RF/first-stage rescaling).

## Notes / gotchas

- The dataset is balanced on the 1999-observed sample only — every
  household in the .dta has at least a 1999 observation. Households
  observed only at later waves are NOT included (this matches the
  paper's sample).
- `ho_99` is fixed at the 1999 wave; it does NOT update with later
  tenure transitions.
- `cohort = -1` for 1999 homeowners; the cohort variable is only
  meaningful for the 1999-renter subsample.
- The HELOC outcome (`heloc_bal`) is missing in 2019/2021/2023 because
  PSID dropped the second-mortgage-balance variable in those waves.
  Restrict to `year <= 2017` for HELOC regressions.
- Demographic controls are filled to median where missing (matching
  the Python pipeline).
