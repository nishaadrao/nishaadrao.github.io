cd R:\mfa\raon\datasets\psid\data\wlth1999

#delimit ;

**************************************************************************
   Label           : 1999 Family Wealth Data
   Rows            : 6997
   Columns         : 38
   ASCII File Date : March 2, 2011
*************************************************************************;


infix 
      S400            1 - 1         S401            2 - 6         S402            7 - 7    
      S402A           8 - 8         S403            9 - 17        S403A          18 - 18   
      S404           19 - 19        S404A          20 - 20        S405           21 - 29   
      S405A          30 - 30        S406           31 - 31        S406A          32 - 32   
      S407           33 - 41        S407A          42 - 42        S408           43 - 43   
      S408A          44 - 44        S409           45 - 53        S409A          54 - 54   
      S410           55 - 55        S410A          56 - 56        S411           57 - 65   
      S411A          66 - 66        S413           67 - 75        S413A          76 - 76   
      S414           77 - 77        S414A          78 - 78        S415           79 - 87   
      S415A          88 - 88        S418           89 - 89        S418A          90 - 90   
      S419           91 - 99        S419A         100 - 100       S420          101 - 109  
      S420A         110 - 110       S416          111 - 119       S416A         120 - 120  
      S417          121 - 129       S417A         130 - 130  
using WLTH1999.txt, clear 
;
label variable  S400       "1999 WEALTH FILE RELEASE NUMBER" ;                 
label variable  S401       "1999 FAMILY ID" ;                                  
label variable  S402       "IMP WTR FARM/BUS (W10) 99" ;                       
label variable  S402A      "ACC WTR FARM/BUS (W10) 99" ;                       
label variable  S403       "IMP VALUE FARM/BUS (W11) 99" ;                     
label variable  S403A      "ACC VALUE FARM/BUS (W11) 99" ;                     
label variable  S404       "IMP WTR CHECKING/SAVING (W27) 99" ;                
label variable  S404A      "ACC WTR CHECKING/SAVING (W27) 99" ;                
label variable  S405       "IMP VAL CHECKING/SAVING (W28) 99" ;                
label variable  S405A      "ACC VAL CHECKING/SAVING (W28) 99" ;                
label variable  S406       "IMP WTR OTH DEBT (W38) 99" ;                       
label variable  S406A      "ACC WTR OTH DEBT (W38) 99" ;                       
label variable  S407       "IMP VALUE OTH DEBT (W39) 99" ;                     
label variable  S407A      "ACC VALUE OTH DEBT (W39) 99" ;                     
label variable  S408       "IMP WTR OTH REAL ESTATE (W1) 99" ;                 
label variable  S408A      "ACC WTR OTH REAL ESTATE (W1) 99" ;                 
label variable  S409       "IMP VAL OTH REAL ESTATE (W2) 99" ;                 
label variable  S409A      "ACC VAL OTH REAL ESTATE (W2) 99" ;                 
label variable  S410       "IMP WTR STOCKS (W15) 99" ;                         
label variable  S410A      "ACC WTR STOCKS (W15) 99" ;                         
label variable  S411       "IMP VALUE STOCKS (W16) 99" ;                       
label variable  S411A      "ACC VALUE STOCKS (W16) 99" ;                       
label variable  S413       "IMP VALUE VEHICLES (W6) 99" ;                      
label variable  S413A      "ACC VALUE VEHICLES (W6) 99" ;                      
label variable  S414       "IMP WTR OTH ASSETS (W33) 99" ;                     
label variable  S414A      "ACC WTR OTH ASSETS (W33) 99" ;                     
label variable  S415       "IMP VALUE OTH ASSETS (W34) 99" ;                   
label variable  S415A      "ACC VALUE OTH ASSETS (W34) 99" ;                   
label variable  S418       "IMP WTR ANNUITY/IRA (W21) 99" ;                    
label variable  S418A      "ACC WTR ANNUITY/IRA (W21) 99" ;                    
label variable  S419       "IMP VALUE ANNUITY/IRA (W22) 99" ;                  
label variable  S419A      "ACC VALUE ANNUITY/IRA (W22) 99" ;                  
label variable  S420       "IMP VALUE HOME EQUITY 99" ;                        
label variable  S420A      "ACC VALUE HOME EQUITY 99" ;                        
label variable  S416       "IMP WEALTH W/O EQUITY (WEALTH1) 99" ;              
label variable  S416A      "ACC WEALTH W/O EQUITY (WEALTH1) 99" ;              
label variable  S417       "IMP WEALTH W/ EQUITY (WEALTH2) 99" ;               
label variable  S417A      "ACC WEALTH W/ EQUITY (WEALTH2) 99" ;               

#delimit cr
rename	S401	rfamiid1999
rename	S402	rwtrbus1999
rename	S403	rnetbus1999
rename	S404	rwtrcheck1999
rename	S405	rcheck1999
rename	S407	ralldebt1999
rename	S408	rwtrothre1999
rename	S409	rnetothre1999
rename	S410	rwtrstocks1999
rename	S411	rstocks1999
rename	S413	rvalveh1999
rename	S414	rwtrothas1999
rename	S415	rothas1999
rename	S416	rwealth_noeq1999
rename	S417	rwealth_eq1999
rename	S418	rwtrira1999
rename	S419	rira1999
rename	S420	requity1999

keep r*

save wlth1999, replace

merge 1:1 rfamiid1999 using "R:\mfa\raon\datasets\psid\data\fam1999\fam1999.dta"

drop _merge

compress
save  R:\mfa\raon\datasets\psid\data\fam1999\fam1999.dta, replace