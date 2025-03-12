use "/Users/nishaadrao/Documents/bartik/cbp/clean_data/bartik_cbsa_long_nocons.dta", replace

merge m:1 cbsa using "/Users/nishaadrao/Documents/zillow/data/mapfiles/cbsanames.dta"

reghdfe bartik_nocons_cbsa10yr_roll i.year, a(cbsa) resid

predict res_bartik, res

xtset cbsa year


gr tw (line res_bartik year if cbsa==35260) (line res_bartik year if cbsa==11460), legend(order(1 "New York" 2 "Ann Arbor")) xtitle("Year")
gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/residual_constant.pdf", as(pdf) replace


gr tw (line res_bartik year if cbsa==41940) (line res_bartik year if cbsa==14500) (line res_bartik year if cbsa==35300), legend(order(1 "San Jose" 2 "Boulder" 3 "New Haven")) xtitle("Year")

gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/residual_downup.pdf", as(pdf) replace


gr tw (line res_bartik year if cbsa==41860) (line res_bartik year if cbsa==19820) (line res_bartik year if cbsa==31080) (line res_bartik year if cbsa==26900) (line res_bartik year if cbsa==14460) (line res_bartik year if cbsa==33100) (line res_bartik year if cbsa==16980), legend(order(1 "San Francisco" 2 "Detroit" 3 "Los Angeles" 4 "Indianapolis" 5 "Boston" 6 "Miami" 7 "Chicago")) xtitle("Year")
gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/residual_updown.pdf", as(pdf) replace


gr tw (line res_bartik year if cbsa==41860) (line res_bartik year if cbsa==19820) (line res_bartik year if cbsa==31080) (line res_bartik year if cbsa==26900) (line res_bartik year if cbsa==14460) (line res_bartik year if cbsa==33100) (line res_bartik year if cbsa==16980) (line res_bartik year if cbsa==35260) (line res_bartik year if cbsa==11460) (line res_bartik year if cbsa==41940) (line res_bartik year if cbsa==14500) (line res_bartik year if cbsa==35300), legend(order(1 "San Francisco" 2 "Detroit" 3 "Los Angeles" 4 "Indianapolis" 5 "Boston" 6 "Miami" 7 "Chicago" 8 "New York" 9 "Ann Arbor" 10 "San Jose" 11 "Boulder" 12 "New Haven")) xtitle("Year")

gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/residual_allareas.pdf", as(pdf) replace

cap drop _merge 

merge m:1 cbsa using "/Users/nishaadrao/Documents/zillow/data/mapfiles/usdb_cbsa.dta"

drop _merge


spmap bartik_nocons_cbsa10yr_roll using "/Users/nishaadrao/Documents/zillow/data/mapfiles/uscoord.dta" if year==2011 & id!=378 & id!=548 & id!=695 & id!=708 & id!=354 & id!=356 & id!=386 & id!=883 & id!=884 & id!=622 & id!=686 & id!=470 & id!=331 & id!=34 & id!=55 & id!=59 & id!=164 & id!=645 & id!=696 & id!=701, id(id) fcolor(RdYlBu)  clmethod(custom)  clbreaks(-0.3 -0.2 -0.1 0 0.1 0.2 0.5)

gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/bartik_2011_map.pdf", as(pdf) replace

spmap bartik_nocons_cbsa10yr_roll using "/Users/nishaadrao/Documents/zillow/data/mapfiles/uscoord.dta" if year==1999 & id!=378 & id!=548 & id!=695 & id!=708 & id!=354 & id!=356 & id!=386 & id!=883 & id!=884 & id!=622 & id!=686 & id!=470 & id!=331 & id!=34 & id!=55 & id!=59 & id!=164 & id!=645 & id!=696 & id!=701, id(id) fcolor(RdYlBu)  clmethod(custom)  clbreaks(-0.3 -0.2 -0.1 0 0.1 0.2 0.5)
gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/bartik_1999_map.pdf", as(pdf) replace

spmap bartik_nocons_cbsa10yr_roll using "/Users/nishaadrao/Documents/zillow/data/mapfiles/uscoord.dta" if year==2017 & id!=378 & id!=548 & id!=695 & id!=708 & id!=354 & id!=356 & id!=386 & id!=883 & id!=884 & id!=622 & id!=686 & id!=470 & id!=331 & id!=34 & id!=55 & id!=59 & id!=164 & id!=645 & id!=696 & id!=701, id(id) fcolor(RdYlBu)  clmethod(custom)  clbreaks(-0.3 -0.2 -0.1 0 0.1 0.2 0.5)

gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/bartik_2017_map.pdf", as(pdf) replace


spmap bartik_nocons_cbsa10yr_roll using "/Users/nishaadrao/Documents/zillow/data/mapfiles/uscoord.dta" if year==2009 & id!=378 & id!=548 & id!=695 & id!=708 & id!=354 & id!=356 & id!=386 & id!=883 & id!=884 & id!=622 & id!=686 & id!=470 & id!=331 & id!=34 & id!=55 & id!=59 & id!=164 & id!=645 & id!=696 & id!=701, id(id) fcolor(RdYlBu)  clmethod(custom)  clbreaks(-0.3 -0.2 -0.1 0 0.1 0.2 0.5)

gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/bartik10yr_2009_map.pdf", as(pdf) replace


spmap bartik_nocons_cbsa2yr_roll using "/Users/nishaadrao/Documents/zillow/data/mapfiles/uscoord.dta" if year==2009 & id!=378 & id!=548 & id!=695 & id!=708 & id!=354 & id!=356 & id!=386 & id!=883 & id!=884 & id!=622 & id!=686 & id!=470 & id!=331 & id!=34 & id!=55 & id!=59 & id!=164 & id!=645 & id!=696 & id!=701, id(id) fcolor(RdYlBu)  clmethod(custom)  clbreaks(-0.3 -0.2 -0.1 0 0.1 0.2 0.5)

gr export "/Users/nishaadrao/Downloads/mobility_ineq/papers/Project Proposal/bartik2yr_2009_map.pdf", as(pdf) replace






