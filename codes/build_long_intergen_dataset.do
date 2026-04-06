clear all
set maxvar 30000
set more off

cd R:\mfa\raon\datasets\psid\clean_data

local version = 2023

use crossfam`version'_ig, clear


keep rauid* *2023 *2021 *2019 *2017 *2015 *2013 *2011

reshape long rvalveh rcheck rstocks rothre rbus rnetbus rnetothre rstate_grewup rcons_food ///
    rcons_hous rcons_trans rcons_educ rcons_child rcons_health rcons_phone rcons_maintain ///
    rcons_furn rcons_cloth rcons_trips rcons_recr rcons_util rtot_exp rmort_exp rmort ///
    rtypemort_one rremprinmort_one rwtrmort_refin rwtrhelp_rel ramthelp_rel rwtryouhelp_oth ///
    rwtrbeh_mort_one rparpoor rhelp_from_rel rwtr_lumpinher rman_findiff rhelp_findiff rfamcompch ///
    rrent rtaxinc rfaminc rwtroutlf rempstathd_ret rwealth_eq_acc ///
    rwealth_noeq_acc rsechome rwtrmoved rcurrstate rfamweight rpsidstate rfamiid ///
    redhd ragehd rgenderhd_fem rracehd_bl rmarstat_mar rlabinchd rwealth_noeq rwealth_eq ///
    requity rproptax rnumfu rnumkidsfu rnumrooms rhomevalue rhead rempstatsp_unemp ///
    rempstathd_unemp rheattype rhomeowner rwtrinherit rvalinherit_one rvalinherit_two ///
    rvalinherit_three rsellpricehome rsplitoff ralldebt rira rbusdebt rothredebt rccdebt ///
    rstuddebt rmeddebt rlegdebt rfamdebt rothdebt rothas rbonds rtransfer_inc rmainocc rmainind rmainocc_con ///
    rmainind_con rwtr_homeimp rhomeimp rmainocc_dad_con rmainind_dad_con rmainocc_mom_con ///
    rmainind_mom_con rrent_bf rtaxinc_bf rfaminc_bf rwtroutlf_bf ///
    rempstathd_ret_bf rwealth_eq_acc_bf rwealth_noeq_acc_bf rsechome_bf rwtrmoved_bf rcurrstate_bf ///
    rfamweight_bf rpsidstate_bf rfamiid_bf redhd_bf ///
    ragehd_bf rgenderhd_fem_bf rracehd_bl_bf rmarstat_mar_bf rlabinchd_bf rwealth_noeq_bf ///
    rwealth_eq_bf requity_bf rproptax_bf rnumfu_bf rnumkidsfu_bf rnumrooms_bf rhomevalue_bf ///
    rhead_bf rempstatsp_unemp_bf rempstathd_unemp_bf rheattype_bf rhomeowner_bf rsellpricehome_bf ///
    rsplitoff_bf rstocks_bf rwtrstocks_bf rwtryouhelp_oth_bf rwtrmort_refin_bf rmainocc_con_bf ///
    rmainind_con_bf rrent_bm rtaxinc_bm rfaminc_bm rwtroutlf_bm ///
    rempstathd_ret_bm rwealth_eq_acc_bm rwealth_noeq_acc_bm rsechome_bm rwtrmoved_bm rcurrstate_bm ///
    rfamweight_bm rpsidstate_bm rfamiid_bm redhd_bm ///
    ragehd_bm rgenderhd_fem_bm rracehd_bl_bm rmarstat_mar_bm rlabinchd_bm rwealth_noeq_bm ///
    rwealth_eq_bm requity_bm rproptax_bm rnumfu_bm rnumkidsfu_bm rnumrooms_bm rhomevalue_bm ///
    rhead_bm rempstatsp_unemp_bm rempstathd_unemp_bm rheattype_bm rhomeowner_bm rsellpricehome_bm ///
    rsplitoff_bm rstocks_bm rwtrstocks_bm rwtryouhelp_oth_bm rmainocc_con_bm ///
    rmainind_con_bm rwtrmort_refin_bm rrent_af rtaxinc_af rfaminc_af rwtroutlf_af ///
    rempstathd_ret_af rwealth_eq_acc_af rwealth_noeq_acc_af rsechome_af rwtrmoved_af rcurrstate_af ///
    rfamweight_af rpsidstate_af rfamiid_af redhd_af ///
    ragehd_af rgenderhd_fem_af rracehd_bl_af rmarstat_mar_af rlabinchd_af rwealth_noeq_af ///
    rwealth_eq_af requity_af rproptax_af rnumfu_af rnumkidsfu_af rnumrooms_af rhomevalue_af ///
    rsellpricehome_af rhead_af rempstatsp_unemp_af rempstathd_unemp_af rheattype_af rhomeowner_af ///
    rsplitoff_af rstocks_af rwtrstocks_af rwtryouhelp_oth_af rwtrmort_refin_af rmainocc_con_af ///
    rmainind_con_af rrent_am rtaxinc_am rfaminc_am rwtroutlf_am ///
    rempstathd_ret_am rwealth_eq_acc_am rwealth_noeq_acc_am rsechome_am rwtrmoved_am rcurrstate_am ///
    rfamweight_am rpsidstate_am rfamiid_am redhd_am ///
    ragehd_am rgenderhd_fem_am rracehd_bl_am rmarstat_mar_am rlabinchd_am rwealth_noeq_am ///
    rwealth_eq_am requity_am rproptax_am rnumfu_am rnumkidsfu_am rnumrooms_am rhomevalue_am ///
    rhead_am rempstatsp_unemp_am rempstathd_unemp_am rheattype_am rhomeowner_am rsellpricehome_am ///
    rsplitoff_am rstocks_am rwtrstocks_am rwtryouhelp_oth_am rwtrmort_refin_am rmainocc_con_am ///
    rmainind_con_am, i(rauid) j(year)

drop *201* *202*

tempfile longfam2011_`version'_ig
save `longfam2011_`version'_ig', replace

*------------------------------------------------------------
* PART 2: RESHAPE CROSSFAM WITH GEO (1999–2009) TO LONG FORM
*------------------------------------------------------------

use crossfam`version'_ig, clear

keep rauid* *2009 *2007 *2005 *2003 *2001 *1999

reshape long ///
    rvalveh rcheck rstocks rnetothre rnetbus rothas rbonds rstate_grewup rfamcompch ///
    rrent rtaxinc rfaminc rwtroutlf ///
    rempstathd_ret rwealth_eq_acc rwealth_noeq_acc rsechome ///
    rwtrmoved rcurrstate rfamweight rpsidstate rfamiid ///
    redhd ragehd rgenderhd_fem rracehd_bl ///
    rmarstat_mar rlabinchd rwealth_noeq rwealth_eq requity ///
    rproptax rnumfu rnumkidsfu rnumrooms rhomevalue rhead ///
    rempstatsp_unemp rempstathd_unemp rheattype rhomeowner ///
    rwtrinherit rvalinherit_one rvalinherit_two rvalinherit_three ///
    rsellpricehome rsplitoff ralldebt rira rtransfer_inc ///
    rcons_hous rtot_exp rmort_exp rmort rtypemort_one ///
    rremprinmort_one rwtrmort_refin rwtrhelp_rel ramthelp_rel ///
    rwtryouhelp_oth rwtrbeh_mort_one rparpoor rhelp_from_rel ///
    rwtr_lumpinher rman_findiff rhelp_findiff ///
    rmainocc rmainind rmainocc_con rmainind_con ///
    rwtr_homeimp rhomeimp rmainocc_dad_con rmainind_dad_con ///
    rmainocc_mom_con rmainind_mom_con ///
    rrent_bf rtaxinc_bf rfaminc_bf ///
    rwtroutlf_bf rempstathd_ret_bf rwealth_eq_acc_bf ///
    rwealth_noeq_acc_bf rsechome_bf rwtrmoved_bf rcurrstate_bf ///
    rfamweight_bf rpsidstate_bf rfamiid_bf ///
    redhd_bf ragehd_bf rgenderhd_fem_bf ///
    rracehd_bl_bf rmarstat_mar_bf rlabinchd_bf rwealth_noeq_bf ///
    rwealth_eq_bf requity_bf rproptax_bf rnumfu_bf ///
    rnumkidsfu_bf rnumrooms_bf rhomevalue_bf rhead_bf ///
    rempstatsp_unemp_bf rempstathd_unemp_bf rheattype_bf ///
    rhomeowner_bf rsellpricehome_bf rstocks_bf ///
    rwtrstocks_bf rwtryouhelp_oth_bf rwtrmort_refin_bf ///
    rmainocc_bf rmainocc_con_bf rmainind_con_bf ///
    rrent_bm rtaxinc_bm rfaminc_bm ///
    rwtroutlf_bm rempstathd_ret_bm rwealth_eq_acc_bm ///
    rwealth_noeq_acc_bm rsechome_bm rwtrmoved_bm rcurrstate_bm ///
    rfamweight_bm rpsidstate_bm rfamiid_bm ///
    redhd_bm ragehd_bm rgenderhd_fem_bm ///
    rracehd_bl_bm rmarstat_mar_bm rlabinchd_bm rwealth_noeq_bm ///
    rwealth_eq_bm requity_bm rproptax_bm rnumfu_bm ///
    rnumkidsfu_bm rnumrooms_bm rhomevalue_bm rhead_bm ///
    rempstatsp_unemp_bm rempstathd_unemp_bm rheattype_bm ///
    rhomeowner_bm rsellpricehome_bm rstocks_bm ///
    rwtrstocks_bm rwtryouhelp_oth_bm rwtrmort_refin_bm ///
    rmainocc_con_bm rmainind_con_bm ///
    rrent_af rtaxinc_af rfaminc_af ///
    rwtroutlf_af rempstathd_ret_af rwealth_eq_acc_af ///
    rwealth_noeq_acc_af rsechome_af rwtrmoved_af rcurrstate_af ///
    rfamweight_af rpsidstate_af rfamiid_af ///
    redhd_af ragehd_af rgenderhd_fem_af ///
    rracehd_bl_af rmarstat_mar_af rlabinchd_af rwealth_noeq_af ///
    rwealth_eq_af requity_af rproptax_af rnumfu_af ///
    rnumkidsfu_af rnumrooms_af rhomevalue_af rhead_af ///
    rempstatsp_unemp_af rempstathd_unemp_af rheattype_af ///
    rhomeowner_af rsellpricehome_af rstocks_af ///
    rwtrstocks_af rwtryouhelp_oth_af rwtrmort_refin_af ///
    rmainocc_con_af rmainind_con_af ///
    rrent_am rtaxinc_am rfaminc_am ///
    rwtroutlf_am rempstathd_ret_am rwealth_eq_acc_am ///
    rwealth_noeq_acc_am rsechome_am rwtrmoved_am rcurrstate_am ///
    rfamweight_am rpsidstate_am rfamiid_am ///
    redhd_am ragehd_am rgenderhd_fem_am ///
    rracehd_bl_am rmarstat_mar_am rlabinchd_am rwealth_noeq_am ///
    rwealth_eq_am requity_am rproptax_am rnumfu_am ///
    rnumkidsfu_am rnumrooms_am rhomevalue_am rhead_am ///
    rempstatsp_unemp_am rempstathd_unemp_am rheattype_am ///
    rhomeowner_am rsellpricehome_am rstocks_am ///
    rwtrstocks_am rwtryouhelp_oth_am rwtrmort_refin_am ///
    rmainocc_con_am rmainind_con_am, ///
    i(rauid) j(year)

drop *199* *200*

tempfile longfam1999_2009_ig
save `longfam1999_2009_ig', replace


*------------------------------------------------------------
* PART 3: RESHAPE CROSSFAM WITH GEO (1990–1997) TO LONG FORM
*------------------------------------------------------------

use crossfam`version'_ig, clear

keep rauid* *1997 *1996 *1995 *1994 *1993 *1992 *1991 *1990

reshape long ///
    rfamcompch rothas rbonds rrent_old rrent rtaxinc rfaminc ///
    rempstathd_ret rempstathd_retold rwealth_eq_acc rwealth_noeq_acc ///
    rsechome rwtrmoved rcurrstate rfamweight rpsidstate rfamiid ///
    redhd ragehd rgenderhd_fem rracehd_bl ///
    rmarstat_mar rlabinchd rwealth_noeq rwealth_eq requity rproptax ///
    rnumfu rnumkidsfu rhomevalue rhead rempstatsp_unemp rempstathd_unemp ///
    rhomeowner rwtrinherit rvalinherit_one rvalinherit_two ///
    rvalinherit_three rsellpricehome rsplitoff ralldebt rira ///
    rrent_old_bf rrent_bf rtaxinc_bf ///
    rfaminc_bf rempstathd_ret_bf rempstathd_retold_bf ///
    rwealth_eq_acc_bf rwealth_noeq_acc_bf rsechome_bf rwtrmoved_bf ///
    rcurrstate_bf rfamweight_bf rpsidstate_bf rfamiid_bf ///
    redhd_bf ragehd_bf rgenderhd_fem_bf ///
    rracehd_bl_bf rmarstat_mar_bf rlabinchd_bf rwealth_noeq_bf ///
    rwealth_eq_bf requity_bf rproptax_bf rnumfu_bf rnumkidsfu_bf ///
    rhomevalue_bf rhead_bf rempstatsp_unemp_bf rempstathd_unemp_bf ///
    rhomeowner_bf rsellpricehome_bf ///
    rrent_old_bm rrent_bm rtaxinc_bm ///
    rfaminc_bm rempstathd_ret_bm rempstathd_retold_bm ///
    rwealth_eq_acc_bm rwealth_noeq_acc_bm rsechome_bm rwtrmoved_bm ///
    rcurrstate_bm rfamweight_bm rpsidstate_bm rfamiid_bm ///
    redhd_bm ragehd_bm rgenderhd_fem_bm ///
    rracehd_bl_bm rmarstat_mar_bm rlabinchd_bm rwealth_noeq_bm ///
    rwealth_eq_bm requity_bm rproptax_bm rnumfu_bm rnumkidsfu_bm ///
    rhomevalue_bm rhead_bm rempstatsp_unemp_bm rempstathd_unemp_bm ///
    rhomeowner_bm rsellpricehome_bm ///
    rrent_old_af rrent_af rtaxinc_af ///
    rfaminc_af rempstathd_ret_af rempstathd_retold_af ///
    rwealth_eq_acc_af rwealth_noeq_acc_af rsechome_af rwtrmoved_af ///
    rcurrstate_af rfamweight_af rpsidstate_af rfamiid_af ///
    redhd_af ragehd_af rgenderhd_fem_af ///
    rracehd_bl_af rmarstat_mar_af rlabinchd_af rwealth_noeq_af ///
    rwealth_eq_af requity_af rproptax_af rnumfu_af rnumkidsfu_af ///
    rhomevalue_af rhead_af rempstatsp_unemp_af rempstathd_unemp_af ///
    rhomeowner_af rsellpricehome_af ///
    rrent_old_am rrent_am rtaxinc_am ///
    rfaminc_am rempstathd_ret_am rempstathd_retold_am ///
    rwealth_eq_acc_am rwealth_noeq_acc_am rsechome_am rwtrmoved_am ///
    rcurrstate_am rfamweight_am rpsidstate_am rfamiid_am ///
    redhd_am ragehd_am rgenderhd_fem_am ///
    rracehd_bl_am rmarstat_mar_am rlabinchd_am rwealth_noeq_am ///
    rwealth_eq_am requity_am rproptax_am rnumfu_am rnumkidsfu_am ///
    rhomevalue_am rhead_am rempstatsp_unemp_am rempstathd_unemp_am ///
    rhomeowner_am rsellpricehome_am rstocks_bm rwtrstocks_bm, ///
    i(rauid) j(year)

drop *199*

tempfile longfam1990_1997_ig
save `longfam1990_1997_ig', replace

*------------------------------------------------------------
* PART 4: RESHAPE CROSSFAM WITH GEO (1984–1989) TO LONG FORM
*------------------------------------------------------------

use crossfam`version'_ig, clear

keep rauid* *1989 *1988 *1987 *1986 *1985 *1984

reshape long ///
    rfamcompch rrent_old rtaxinc rfaminc ///
    rempstathd_retold rwealth_eq_acc rwealth_noeq_acc rsechome ///
    rwtrmoved rfamweight rpsidstate rfamiid ///
    redhd ragehd rgenderhd_fem rracehd_bl rmarstat_mar ///
    rlabinchd rwealth_noeq rwealth_eq requity rproptax rnumfu ///
    rnumkidsfu rhomevalue rhead rempstatsp_unemp rempstathd_unemp ///
    rhomeowner rwtrinherit rvalinherit_one rvalinherit_two ///
    rvalinherit_three rsellpricehome rsplitoff ralldebt rira ///
    rrent_old_bf rtaxinc_bf rfaminc_bf ///
    rempstathd_retold_bf rwealth_eq_acc_bf rwealth_noeq_acc_bf ///
    rsechome_bf rwtrmoved_bf rfamweight_bf rpsidstate_bf ///
    rfamiid_bf redhd_bf ///
    ragehd_bf rgenderhd_fem_bf rracehd_bl_bf rmarstat_mar_bf ///
    rlabinchd_bf rwealth_noeq_bf rwealth_eq_bf requity_bf ///
    rproptax_bf rnumfu_bf rnumkidsfu_bf rhomevalue_bf rhead_bf ///
    rempstatsp_unemp_bf rempstathd_unemp_bf rhomeowner_bf ///
    rsellpricehome_bf rstocks_bf rwtrstocks_bf ///
    rrent_old_bm rtaxinc_bm rfaminc_bm ///
    rempstathd_retold_bm rwealth_eq_acc_bm rwealth_noeq_acc_bm ///
    rsechome_bm rwtrmoved_bm rfamweight_bm rpsidstate_bm ///
    rfamiid_bm redhd_bm ///
    ragehd_bm rgenderhd_fem_bm rracehd_bl_bm rmarstat_mar_bm ///
    rlabinchd_bm rwealth_noeq_bm rwealth_eq_bm requity_bm ///
    rproptax_bm rnumfu_bm rnumkidsfu_bm rhomevalue_bm rhead_bm ///
    rempstatsp_unemp_bm rempstathd_unemp_bm rhomeowner_bm ///
    rsellpricehome_bm rstocks_bm rwtrstocks_bm ///
    rrent_old_af rtaxinc_af rfaminc_af ///
    rempstathd_retold_af rwealth_eq_acc_af rwealth_noeq_acc_af ///
    rsechome_af rwtrmoved_af rfamweight_af rpsidstate_af ///
    rfamiid_af redhd_af ///
    ragehd_af rgenderhd_fem_af rracehd_bl_af rmarstat_mar_af ///
    rlabinchd_af rwealth_noeq_af rwealth_eq_af requity_af ///
    rproptax_af rnumfu_af rnumkidsfu_af rhomevalue_af rhead_af ///
    rempstatsp_unemp_af rempstathd_unemp_af rhomeowner_af ///
    rsellpricehome_af rstocks_af rwtrstocks_af ///
    rrent_old_am rtaxinc_am rfaminc_am ///
    rempstathd_retold_am rwealth_eq_acc_am rwealth_noeq_acc_am ///
    rsechome_am rwtrmoved_am rfamweight_am rpsidstate_am ///
    rfamiid_am redhd_am ///
    ragehd_am rgenderhd_fem_am rracehd_bl_am rmarstat_mar_am ///
    rlabinchd_am rwealth_noeq_am rwealth_eq_am requity_am ///
    rproptax_am rnumfu_am rnumkidsfu_am rhomevalue_am rhead_am ///
    rempstatsp_unemp_am rempstathd_unemp_am rhomeowner_am ///
    rsellpricehome_am rstocks_am rwtrstocks_am, ///
    i(rauid) j(year)

drop *198*

tempfile longfam1984_1989_ig
save `longfam1984_1989_ig', replace

local version = 2023

use `longfam2011_`version'_ig', clear 

append using `longfam1999_2009_ig'
append using `longfam1990_1997_ig'
append using `longfam1984_1989_ig'

joinby year using cpi_u 

save longfam`version'_ig, replace 

