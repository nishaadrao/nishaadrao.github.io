cd R:\mfa\raon\datasets\psid\data\wlth2005

#delimit ;

**************************************************************************
   Label           : 2005 Family Wealth Data
   Rows            : 8002
   Columns         : 38
   ASCII File Date : March 2, 2011
*************************************************************************;


infix 
      S700            1 - 1         S701            2 - 6         S702            7 - 7    
      S702A           8 - 8         S703            9 - 17        S703A          18 - 18   
      S704           19 - 19        S704A          20 - 20        S705           21 - 29   
      S705A          30 - 30        S706           31 - 31        S706A          32 - 32   
      S707           33 - 41        S707A          42 - 42        S708           43 - 43   
      S708A          44 - 44        S709           45 - 53        S709A          54 - 54   
      S710           55 - 55        S710A          56 - 56        S711           57 - 65   
      S711A          66 - 66        S713           67 - 75        S713A          76 - 76   
      S714           77 - 77        S714A          78 - 78        S715           79 - 87   
      S715A          88 - 88        S718           89 - 89        S718A          90 - 90   
      S719           91 - 99        S719A         100 - 100       S720          101 - 109  
      S720A         110 - 110       S716          111 - 119       S716A         120 - 120  
      S717          121 - 129       S717A         130 - 130  
using WLTH2005.txt, clear 
;
label variable  S700       "2005 WEALTH FILE RELEASE NUMBER" ;                 
label variable  S701       "2005 FAMILY ID" ;                                  
label variable  S702       "IMP WTR FARM/BUS (W10) 05" ;                       
label variable  S702A      "ACC WTR FARM/BUS (W10) 05" ;                       
label variable  S703       "IMP VALUE FARM/BUS (W11) 05" ;                     
label variable  S703A      "ACC VALUE FARM/BUS (W11) 05" ;                     
label variable  S704       "IMP WTR CHECKING/SAVING (W27) 05" ;                
label variable  S704A      "ACC WTR CHECKING/SAVING (W27) 05" ;                
label variable  S705       "IMP VAL CHECKING/SAVING (W28) 05" ;                
label variable  S705A      "ACC VAL CHECKING/SAVING (W28) 05" ;                
label variable  S706       "IMP WTR OTH DEBT (W38) 05" ;                       
label variable  S706A      "ACC WTR OTH DEBT (W38) 05" ;                       
label variable  S707       "IMP VALUE OTH DEBT (W39) 05" ;                     
label variable  S707A      "ACC VALUE OTH DEBT (W39) 05" ;                     
label variable  S708       "IMP WTR OTH REAL ESTATE (W1) 05" ;                 
label variable  S708A      "ACC WTR OTH REAL ESTATE (W1) 05" ;                 
label variable  S709       "IMP VAL OTH REAL ESTATE (W2) 05" ;                 
label variable  S709A      "ACC VAL OTH REAL ESTATE (W2) 05" ;                 
label variable  S710       "IMP WTR STOCKS (W15) 05" ;                         
label variable  S710A      "ACC WTR STOCKS (W15) 05" ;                         
label variable  S711       "IMP VALUE STOCKS (W16) 05" ;                       
label variable  S711A      "ACC VALUE STOCKS (W16) 05" ;                       
label variable  S713       "IMP VALUE VEHICLES (W6) 05" ;                      
label variable  S713A      "ACC VALUE VEHICLES (W6) 05" ;                      
label variable  S714       "IMP WTR OTH ASSETS (W33) 05" ;                     
label variable  S714A      "ACC WTR OTH ASSETS (W33) 05" ;                     
label variable  S715       "IMP VALUE OTH ASSETS (W34) 05" ;                   
label variable  S715A      "ACC VALUE OTH ASSETS (W34) 05" ;                   
label variable  S718       "IMP WTR ANNUITY/IRA (W21) 05" ;                    
label variable  S718A      "ACC WTR ANNUITY/IRA (W21) 05" ;                    
label variable  S719       "IMP VALUE ANNUITY/IRA (W22) 05" ;                  
label variable  S719A      "ACC VALUE ANNUITY/IRA (W22) 05" ;                  
label variable  S720       "IMP VALUE HOME EQUITY 05" ;                        
label variable  S720A      "ACC VALUE HOME EQUITY 05" ;                        
label variable  S716       "IMP WEALTH W/O EQUITY (WEALTH1) 05" ;              
label variable  S716A      "ACC WEALTH W/O EQUITY (WEALTH1) 05" ;              
label variable  S717       "IMP WEALTH W/ EQUITY (WEALTH2) 05" ;               
label variable  S717A      "ACC WEALTH W/ EQUITY (WEALTH2) 05" ;               

#delimit cr

rename S701 rfamiid2005
rename	S702	rwtrbus2005
rename	S703	rnetbus2005
rename	S704	rwtrcheck2005
rename	S705	rcheck2005
rename	S707	ralldebt2005
rename	S708	rwtrothre2005
rename	S709	rnetothre2005
rename	S710	rwtrstocks2005
rename	S711	rstocks2005
rename	S713	rvalveh2005
rename	S714	rwtrothas2005
rename	S715	rothas2005
rename	S716	rwealth_noeq2005
rename	S717	rwealth_eq2005
rename	S718	rwtrira2005
rename	S719	rira2005
rename	S720	requity2005

keep r*

save wlth2005, replace

merge 1:1 rfamiid2005 using "R:\mfa\raon\datasets\psid\data\fam2005\fam2005.dta"

drop _merge

compress
save R:\mfa\raon\datasets\psid\data\fam2005\fam2005.dta, replace
