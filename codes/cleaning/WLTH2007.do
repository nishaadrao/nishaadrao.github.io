cd R:\mfa\raon\datasets\psid\data\wlth2007

#delimit ;

**************************************************************************
   Label           : 2007 Family Wealth Data
   Rows            : 8289
   Columns         : 38
   ASCII File Date : March 2, 2011
*************************************************************************;


infix 
      S800            1 - 1         S801            2 - 6         S802            7 - 7    
      S802A           8 - 8         S803            9 - 17        S803A          18 - 18   
      S804           19 - 19        S804A          20 - 20        S805           21 - 29   
      S805A          30 - 30        S806           31 - 31        S806A          32 - 32   
      S807           33 - 41        S807A          42 - 42        S808           43 - 43   
      S808A          44 - 44        S809           45 - 53        S809A          54 - 54   
      S810           55 - 55        S810A          56 - 56        S811           57 - 65   
      S811A          66 - 66        S813           67 - 75        S813A          76 - 76   
      S814           77 - 77        S814A          78 - 78        S815           79 - 87   
      S815A          88 - 88        S818           89 - 89        S818A          90 - 90   
      S819           91 - 99        S819A         100 - 100       S820          101 - 109  
      S820A         110 - 110       S816          111 - 119       S816A         120 - 120  
      S817          121 - 129       S817A         130 - 130  
using WLTH2007.txt, clear 
;
label variable  S800       "2007 WEALTH FILE RELEASE NUMBER" ;                 
label variable  S801       "2007 FAMILY ID" ;                                  
label variable  S802       "IMP WTR FARM/BUS (W10) 07" ;                       
label variable  S802A      "ACC WTR FARM/BUS (W10) 07" ;                       
label variable  S803       "IMP VALUE FARM/BUS (W11) 07" ;                     
label variable  S803A      "ACC VALUE FARM/BUS (W11) 07" ;                     
label variable  S804       "IMP WTR CHECKING/SAVING (W27) 07" ;                
label variable  S804A      "ACC WTR CHECKING/SAVING (W27) 07" ;                
label variable  S805       "IMP VAL CHECKING/SAVING (W28) 07" ;                
label variable  S805A      "ACC VAL CHECKING/SAVING (W28) 07" ;                
label variable  S806       "IMP WTR OTH DEBT (W38) 07" ;                       
label variable  S806A      "ACC WTR OTH DEBT (W38) 07" ;                       
label variable  S807       "IMP VALUE OTH DEBT (W39) 07" ;                     
label variable  S807A      "ACC VALUE OTH DEBT (W39) 07" ;                     
label variable  S808       "IMP WTR OTH REAL ESTATE (W1) 07" ;                 
label variable  S808A      "ACC WTR OTH REAL ESTATE (W1) 07" ;                 
label variable  S809       "IMP VAL OTH REAL ESTATE (W2) 07" ;                 
label variable  S809A      "ACC VAL OTH REAL ESTATE (W2) 07" ;                 
label variable  S810       "IMP WTR STOCKS (W15) 07" ;                         
label variable  S810A      "ACC WTR STOCKS (W15) 07" ;                         
label variable  S811       "IMP VALUE STOCKS (W16) 07" ;                       
label variable  S811A      "ACC VALUE STOCKS (W16) 07" ;                       
label variable  S813       "IMP VALUE VEHICLES (W6) 07" ;                      
label variable  S813A      "ACC VALUE VEHICLES (W6) 07" ;                      
label variable  S814       "IMP WTR OTH ASSETS (W33) 07" ;                     
label variable  S814A      "ACC WTR OTH ASSETS (W33) 07" ;                     
label variable  S815       "IMP VALUE OTH ASSETS (W34) 07" ;                   
label variable  S815A      "ACC VALUE OTH ASSETS (W34) 07" ;                   
label variable  S818       "IMP WTR ANNUITY/IRA (W21) 07" ;                    
label variable  S818A      "ACC WTR ANNUITY/IRA (W21) 07" ;                    
label variable  S819       "IMP VALUE ANNUITY/IRA (W22) 07" ;                  
label variable  S819A      "ACC VALUE ANNUITY/IRA (W22) 07" ;                  
label variable  S820       "IMP VALUE HOME EQUITY 07" ;                        
label variable  S820A      "ACC VALUE HOME EQUITY 07" ;                        
label variable  S816       "IMP WEALTH W/O EQUITY (WEALTH1) 07" ;              
label variable  S816A      "ACC WEALTH W/O EQUITY (WEALTH1) 07" ;              
label variable  S817       "IMP WEALTH W/ EQUITY (WEALTH2) 07" ;               
label variable  S817A      "ACC WEALTH W/ EQUITY (WEALTH2) 07" ;               

#delimit cr
rename S801 rfamiid2007
rename	S802	rwtrbus2007
rename	S803	rnetbus2007
rename	S804	rwtrcheck2007
rename	S805	rcheck2007
rename	S807	ralldebt2007
rename	S808	rwtrothre2007
rename	S809	rnetothre2007
rename	S810	rwtrstocks2007
rename	S811	rstocks2007
rename	S813	rvalveh2007
rename	S814	rwtrothas2007
rename	S815	rothas2007
rename	S816	rwealth_noeq2007
rename	S817	rwealth_eq2007
rename	S818	rwtrira2007
rename	S819	rira2007
rename	S820	requity2007

keep r*

save wlth2007, replace

merge 1:1 rfamiid2007 using "R:\mfa\raon\datasets\psid\data\fam2007\fam2007.dta"

drop _merge

compress
save R:\mfa\raon\datasets\psid\data\fam2007\fam2007.dta, replace