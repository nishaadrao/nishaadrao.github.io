"""
build_stata_dataset.py — Build a single Stata-ready `.dta` file containing
the merged PSID panel + state-level treatment + instruments, ready for the
event-study do-files. Run once before running any do-file.

Outputs:
    wealth_recovery/stata/data/psid_event_study.dta

Variables in the output dataset (40+ cols):

    Identifiers / panel keys
        rauid           : household ID
        year            : PSID wave (biennial)
        state_99        : 1999 state of residence (FIPS)
        edu_99          : 1999 head's years of education

    Outcomes
        nw_w5           : net worth, 5/95 winsorized within wave (2017$K)
        eq_w5           : home equity, 5/95 winsorized within wave (2017$K)
        noeq_w5         : non-housing wealth, 5/95 winsorized (2017$K)
        ho_pct          : homeowner indicator × 100 (pp)
        cons_w5         : real total consumption, 5/95 wins (2017$K)
        log_cons        : log(real total consumption + 1)
        ihs_faminc      : asinh(family income)
        ihs_labinc      : asinh(head's labor income)
        emp_pct         : head employed indicator × 100
        equity_share    : home equity share of gross assets (pp)
        stock_share     : stock share of gross assets (pp)
        retirement_share: IRA share of gross assets (pp)
        liquid_share    : liquid share of gross assets (pp)
        cum_refi_post   : cumulative count of refinances since 1999
        heloc_bal       : real second-mortgage / HELOC balance (2017$K, 1999--2017)

    Subgroup / cohort indicators
        ho_99           : 1 if homeowner in 1999, 0 otherwise
        ever_owned      : 1 if 1999 renter ever owned post-2009 (else 0; missing for 1999 HO)
        cum_ho_post_pp  : cumulative ever-owned-post-2009 indicator * 100 (1999 renters)
        cohort          : entry cohort label (early_boom, late_boom, trough, recovery, late, never)

    Treatments
        boom_std        : standardized 1999--2007 state HPI growth
        saiz_std        : standardized Saiz (2010) housing supply elasticity
        gmns_std        : standardized GMNS (2021) house-price sensitivity
        bartik_std      : standardized 1999--2007 Bartik labor-demand shock

    Demographic controls (from 1999 baseline)
        ragehd, age_sq, rgenderhd_fem, rracehd_bl, rmarstat_mar,
        sinh_faminc, rnumkidsfu, rnumfu

    Weights
        w               : PSID family weight (rfamweight, clipped at 0)
"""
import os
import sys
import numpy as np
import pandas as pd

# Reuse the project's data paths
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'code'))
from config import PSID_LONG, DATA_DIR, ANALYSIS_YEARS

OUT_PATH = os.path.join(os.path.dirname(__file__), '..', 'data', 'psid_event_study.dta')

print("=" * 70)
print("Building Stata-ready PSID panel for event-study analysis")
print("=" * 70)

# ──────────────────────────────────────────────────────────────
# 1. Load PSID + filter to head-of-household, age >= 18, weight > 0
# ──────────────────────────────────────────────────────────────
panel = pd.read_parquet(PSID_LONG)
print(f"  Loaded PSID: {len(panel):,} rows, {panel['rauid'].nunique():,} HHs")
panel = panel[panel["year"].isin(ANALYSIS_YEARS)].copy()
panel["w"] = panel["rfamweight"].fillna(0).clip(lower=0)
panel = panel[panel["w"] > 0].copy()
panel = panel.dropna(subset=["rcurrstate"])
panel["state_fips"] = panel["rcurrstate"].astype(int)

# ──────────────────────────────────────────────────────────────
# 2. State-level treatment + instruments
# ──────────────────────────────────────────────────────────────
hpi_long = pd.read_parquet(os.path.join(DATA_DIR, "state_hpi_panel.parquet"))
hpi_long["state_fips"] = hpi_long["state_fips"].astype(int)
h99 = hpi_long[hpi_long["year"] == 1999].set_index("state_fips")["hpi"].rename("h99")
h07 = hpi_long[hpi_long["year"] == 2007].set_index("state_fips")["hpi"].rename("h07")
boom_df = pd.concat([h99, h07], axis=1).dropna()
boom_df["boom_9907"] = (boom_df["h07"] - boom_df["h99"]) / boom_df["h99"]
boom_df["boom_std"] = ((boom_df["boom_9907"] - boom_df["boom_9907"].mean())
                       / boom_df["boom_9907"].std())
boom_df = boom_df.reset_index()
print(f"  Boom growth merged: {len(boom_df)} states; mean={boom_df['boom_9907'].mean():.3f}, "
      f"sd={boom_df['boom_9907'].std():.3f}")

inst = pd.read_parquet(os.path.join(DATA_DIR, "state_instruments.parquet"))
inst["state_fips"] = inst["state_fips"].astype(int)
for col in ["saiz_elasticity", "gmns_gamma", "bartik_1990_9907"]:
    s = inst[col]
    short = col.split('_')[0]
    inst[f"{short}_std"] = (s - s.mean()) / s.std()
print(f"  Instruments merged: {len(inst)} states")

# ──────────────────────────────────────────────────────────────
# 3. Build 1999 baseline indicators
# ──────────────────────────────────────────────────────────────
base_99 = panel[panel["year"] == 1999].groupby("rauid").first().reset_index()
base_99 = base_99[["rauid", "rhomeowner", "state_fips", "redhd"]].rename(
    columns={"rhomeowner": "ho_99",
             "state_fips": "state_99",
             "redhd": "edu_99"})
panel = panel.merge(base_99, on="rauid", how="left")
panel = panel.merge(boom_df[["state_fips", "boom_std"]].rename(
    columns={"state_fips": "state_99"}), on="state_99", how="left")
panel = panel.merge(inst[["state_fips", "saiz_std", "gmns_std", "bartik_std"]].rename(
    columns={"state_fips": "state_99"}), on="state_99", how="left")

# ──────────────────────────────────────────────────────────────
# 4. Demographic controls (fill missing with column median)
# ──────────────────────────────────────────────────────────────
panel["age_sq"] = panel["ragehd"] ** 2
panel["sinh_faminc"] = np.arcsinh(panel["real_rfaminc"].clip(lower=0))
for c in ["ragehd", "age_sq", "rgenderhd_fem", "rracehd_bl", "rmarstat_mar",
          "sinh_faminc", "rnumkidsfu", "rnumfu", "redhd"]:
    panel[c] = panel[c].fillna(panel[c].median())
panel["edu_99"] = panel["edu_99"].fillna(panel["redhd"].median()).astype(int)

# ──────────────────────────────────────────────────────────────
# 5. Wealth outcomes (winsorize 5/95 within wave)
# ──────────────────────────────────────────────────────────────
for src, dst in [("real_rwealth_eq",   "nw_w5"),
                 ("real_requity",      "eq_w5"),
                 ("real_rwealth_noeq", "noeq_w5")]:
    lo, hi = panel[src].quantile(0.05), panel[src].quantile(0.95)
    panel[dst] = panel[src].clip(lower=lo, upper=hi)
panel["ho_pct"] = panel["rhomeowner"].astype(float) * 100.0

# ──────────────────────────────────────────────────────────────
# 6. Consumption outcomes
# ──────────────────────────────────────────────────────────────
cons = panel["real_rtot_exp"].clip(lower=0)
clo, chi = cons.quantile(0.05), cons.quantile(0.95)
panel["cons_w5"]  = cons.clip(lower=clo, upper=chi)
panel["log_cons"] = np.log(cons + 1.0)

# ──────────────────────────────────────────────────────────────
# 7. Income / labor outcomes
# ──────────────────────────────────────────────────────────────
panel["ihs_faminc"] = panel["sinh_faminc"]
panel["ihs_labinc"] = np.arcsinh(panel["real_rlabinchd"].fillna(0).clip(lower=0))
panel["emp_pct"] = (panel["real_rlabinchd"].fillna(0) > 0).astype(float) * 100.0

# ──────────────────────────────────────────────────────────────
# 8. Portfolio shares (gross-assets denominator, four-component)
# ──────────────────────────────────────────────────────────────
panel["liquid"] = (panel["real_rsavings"].fillna(0)
                   + panel["real_rcheckbonds"].fillna(0))
panel["gross_assets"] = (
    panel["real_requity"].clip(lower=0).fillna(0)
    + panel["real_rstocks"].clip(lower=0).fillna(0)
    + panel["real_rira"].clip(lower=0).fillna(0)
    + panel["liquid"].clip(lower=0)
)
ga = panel["gross_assets"].replace(0, np.nan)
panel["equity_share"]    = panel["real_requity"].clip(lower=0).fillna(0) / ga * 100.0
panel["stock_share"]     = panel["real_rstocks"].clip(lower=0).fillna(0) / ga * 100.0
panel["retirement_share"] = panel["real_rira"].clip(lower=0).fillna(0) / ga * 100.0
panel["liquid_share"]    = panel["liquid"].clip(lower=0) / ga * 100.0

# ──────────────────────────────────────────────────────────────
# 9. Transaction outcomes (cum_refi_post, heloc_bal) from s26 panel
# ──────────────────────────────────────────────────────────────
trans_path = os.path.join(DATA_DIR, "transaction_events.parquet")
if os.path.exists(trans_path):
    trans = pd.read_parquet(trans_path)
    trans["rauid"] = trans["rauid"].astype(int)
    panel["rauid"] = panel["rauid"].astype(int)
    panel = panel.merge(trans, on=["rauid", "year"], how="left")
    panel["refi_post"] = panel["rwtrmort_refin"].where(panel["year"] >= 2001, 0).fillna(0)
    panel = panel.sort_values(["rauid", "year"])
    panel["cum_refi_post"] = panel.groupby("rauid")["refi_post"].cumsum()
    panel["heloc_bal"] = panel["real_rmorttwo_rem"]
else:
    print("  WARN: transaction_events.parquet not found; skipping cum_refi_post / heloc_bal")
    panel["cum_refi_post"] = np.nan
    panel["heloc_bal"] = np.nan

# ──────────────────────────────────────────────────────────────
# 10. 1999-renter entry cohort + extensive margin
# ──────────────────────────────────────────────────────────────
# rh_post = homeowner indicator × (year >= 2009)
panel["rh_post"] = panel["rhomeowner"].fillna(0).astype(int) * (panel["year"] >= 2009).astype(int)
panel["cum_ho_post"] = panel.groupby("rauid")["rh_post"].cummax()
panel["cum_ho_post_pp"] = panel["cum_ho_post"] * 100.0

# ever_owned: only meaningful for 1999 renters
ever_owned_ids = panel[panel["ho_99"] == 0].groupby("rauid")["cum_ho_post"].max()
ever_owned_ids = ever_owned_ids[ever_owned_ids == 1].index
panel["ever_owned"] = np.where(panel["ho_99"] == 0,
                                panel["rauid"].isin(ever_owned_ids).astype(int),
                                np.nan)

# Cohort: among 1999 renters, year of first observed homeownership
ren_panel = panel[panel["ho_99"] == 0].copy().sort_values(["rauid", "year"])
ren_panel["is_ho_year"] = (ren_panel["rhomeowner"].fillna(0).astype(int) == 1) & \
                          (ren_panel["year"] >= 2001)
first_ho = ren_panel[ren_panel["is_ho_year"]].groupby("rauid")["year"].min()
panel = panel.merge(first_ho.rename("first_ho_year").reset_index(), on="rauid", how="left")

def entry_cohort_int(yr):
    """Encode cohort as integer 0..5 (Stata-friendly)."""
    if pd.isna(yr): return 5  # never
    if yr <= 2003: return 0   # early_boom
    if yr <= 2007: return 1   # late_boom
    if yr <= 2013: return 2   # trough
    if yr <= 2019: return 3   # recovery
    return 4                  # late
panel["cohort"] = panel["first_ho_year"].apply(entry_cohort_int)
# Mark non-renters as missing cohort
panel.loc[panel["ho_99"] == 1, "cohort"] = -1

# ──────────────────────────────────────────────────────────────
# 11. Sample restrictions (matching the Python event studies)
# ──────────────────────────────────────────────────────────────
panel = panel.dropna(subset=["ho_99", "boom_std", "state_99",
                              "saiz_std", "gmns_std", "bartik_std"])
panel = panel[panel["ragehd"] >= 18].copy()
panel["state_99"] = panel["state_99"].astype(int)
panel["ho_99"] = panel["ho_99"].astype(int)
panel["edu_99"] = panel["edu_99"].astype(int)
panel["cohort"] = panel["cohort"].astype(int)
panel["ever_owned"] = panel["ever_owned"].astype("Int64")  # nullable for HO==1

# ──────────────────────────────────────────────────────────────
# 12. Subset to the columns Stata needs and write .dta
# ──────────────────────────────────────────────────────────────
KEEP = [
    # Identifiers
    "rauid", "year", "state_99", "edu_99",
    # Outcomes
    "nw_w5", "eq_w5", "noeq_w5", "ho_pct",
    "cons_w5", "log_cons",
    "ihs_faminc", "ihs_labinc", "emp_pct",
    "equity_share", "stock_share", "retirement_share", "liquid_share",
    "cum_refi_post", "heloc_bal",
    # Subgroup / cohort
    "ho_99", "ever_owned", "cum_ho_post_pp", "cohort",
    # Treatments
    "boom_std", "saiz_std", "gmns_std", "bartik_std",
    # Demographic controls
    "ragehd", "age_sq", "rgenderhd_fem", "rracehd_bl", "rmarstat_mar",
    "sinh_faminc", "rnumkidsfu", "rnumfu",
    # Weights
    "w",
]
KEEP = [c for c in KEEP if c in panel.columns]
out = panel[KEEP].copy()

# Stata can't handle pandas Int64 nullable directly via to_stata;
# downcast to float (NaN-preserving) then int where appropriate.
for c in ["ever_owned"]:
    out[c] = out[c].astype("float").fillna(-1).astype(int)
    # convention: -1 = missing (not 1999 renter)

# Cast all numerics to float64 for Stata compatibility
for c in out.columns:
    if pd.api.types.is_integer_dtype(out[c]):
        out[c] = out[c].astype("int32")
    elif pd.api.types.is_float_dtype(out[c]):
        out[c] = out[c].astype("float32")

print(f"\n  Final shape: {out.shape}")
print(f"  Households: {out['rauid'].nunique():,}")
print(f"  Years: {sorted(out['year'].unique())}")
print(f"  HO subgroup: {(out['ho_99']==1).sum():,} obs (1999-HO household-years)")
print(f"  Renter subgroup: {(out['ho_99']==0).sum():,} obs (1999-renter household-years)")

# Write .dta — Stata format 118 (Stata 14+, supports up to 32K vars and long strings)
out.to_stata(OUT_PATH, write_index=False, version=118,
             variable_labels={
                 "nw_w5": "Net worth (5/95 wins, 2017$K)",
                 "eq_w5": "Home equity (5/95 wins, 2017$K)",
                 "noeq_w5": "Non-housing wealth (5/95 wins, 2017$K)",
                 "ho_pct": "Homeowner rate (pp)",
                 "cons_w5": "Total consumption (5/95 wins, 2017$K)",
                 "log_cons": "log(real_rtot_exp + 1)",
                 "ihs_faminc": "asinh(family income)",
                 "ihs_labinc": "asinh(head labor income)",
                 "emp_pct": "Head employed (pp)",
                 "equity_share": "Home equity share of gross assets (pp)",
                 "stock_share": "Stock share of gross assets (pp)",
                 "retirement_share": "IRA share of gross assets (pp)",
                 "liquid_share": "Liquid share of gross assets (pp)",
                 "cum_refi_post": "Cumulative refis since 1999",
                 "heloc_bal": "HELOC balance (2017$K, 1999-2017 only)",
                 "ho_99": "1999 homeowner indicator",
                 "ever_owned": "1999 renter ever owned post-2009 (-1 if HO_99)",
                 "cum_ho_post_pp": "Cumulative ever-owned post-2009 indicator (pp)",
                 "cohort": "Entry cohort code (-1=HO99, 0..4=earlyB,lateB,trough,recov,late, 5=never)",
                 "boom_std": "Std 1999-2007 state HPI growth",
                 "saiz_std": "Std Saiz (2010) housing supply elasticity",
                 "gmns_std": "Std GMNS (2021) house-price sensitivity",
                 "bartik_std": "Std 1999-2007 Bartik labor-demand shock",
                 "state_99": "1999 state of residence (FIPS)",
                 "edu_99": "1999 head years of education",
                 "w": "PSID family weight (clipped at 0)",
             })
sz = os.path.getsize(OUT_PATH) / 1024 / 1024
print(f"\n  Saved: {OUT_PATH}  ({sz:.1f} MB)")
print("\nDone.")
