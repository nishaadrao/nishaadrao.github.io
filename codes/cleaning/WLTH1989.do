cd R:\mfa\raon\datasets\psid\data\wlth1989

#delimit ;

**************************************************************************
   Label           : 1989 Family Wealth Data
   Rows            : 7114
   Columns         : 34
   ASCII File Date : March 2, 2011
*************************************************************************;


infix 
      S200            1 - 1         S201            2 - 5         S202            6 - 6    
      S202A           7 - 7         S203            8 - 16        S203A          17 - 17   
      S204           18 - 18        S204A          19 - 19        S205           20 - 28   
      S205A          29 - 29        S206           30 - 30        S206A          31 - 31   
      S207           32 - 40        S207A          41 - 41        S208           42 - 42   
      S208A          43 - 43        S209           44 - 52        S209A          53 - 53   
      S210           54 - 54        S210A          55 - 55        S211           56 - 64   
      S211A          65 - 65        S213           66 - 74        S213A          75 - 75   
      S214           76 - 76        S214A          77 - 77        S215           78 - 86   
      S215A          87 - 87        S220           88 - 96        S220A          97 - 97   
      S216           98 - 106       S216A         107 - 107       S217          108 - 116  
      S217A         117 - 117  
using WLTH1989.txt, clear 
;
label variable  S200       "1989 WEALTH FILE RELEASE NUMBER" ;                 
label variable  S201       "1989 FAMILY ID" ;                                  
label variable  S202       "IMP WTR FARM/BUS (G124) 89" ;                      
label variable  S202A      "ACC WTR FARM/BUS (G124) 89" ;                      
label variable  S203       "IMP VALUE FARM/BUS (G125) 89" ;                    
label variable  S203A      "ACC VALUE FARM/BUS (G125) 89" ;                    
label variable  S204       "IMP WTR CHECKING/SAVING (G135) 89" ;               
label variable  S204A      "ACC WTR CHECKING/SAVING (G135) 89" ;               
label variable  S205       "IMP VAL CHECKING/SAVING (G136) 89" ;               
label variable  S205A      "ACC VAL CHECKING/SAVING (G136) 89" ;               
label variable  S206       "IMP WTR OTH DEBT (G146) 89" ;                      
label variable  S206A      "ACC WTR OTH DEBT (G146) 89" ;                      
label variable  S207       "IMP VALUE OTH DEBT (G147) 89" ;                    
label variable  S207A      "ACC VALUE OTH DEBT (G147) 89" ;                    
label variable  S208       "IMP WTR OTH REAL ESTATE (G115) 89" ;               
label variable  S208A      "ACC WTR OTH REAL ESTATE (G115) 89" ;               
label variable  S209       "IMP VAL OTH REAL ESTATE (G116) 89" ;               
label variable  S209A      "ACC VAL OTH REAL ESTATE (G116) 89" ;               
label variable  S210       "IMP WTR STOCKS (G129) 89" ;                        
label variable  S210A      "ACC WTR STOCKS (G129) 89" ;                        
label variable  S211       "IMP VALUE STOCKS (G130) 89" ;                      
label variable  S211A      "ACC VALUE STOCKS (G130) 89" ;                      
label variable  S213       "IMP VALUE VEHICLES (G120) 89" ;                    
label variable  S213A      "ACC VALUE VEHICLES (G120) 89" ;                    
label variable  S214       "IMP WTR OTH ASSETS (G141) 89" ;                    
label variable  S214A      "ACC WTR OTH ASSETS (G141) 89" ;                    
label variable  S215       "IMP VALUE OTH ASSETS (G142) 89" ;                  
label variable  S215A      "ACC VALUE OTH ASSETS (G142) 89" ;                  
label variable  S220       "IMP VALUE HOME EQUITY 89" ;                        
label variable  S220A      "ACC VALUE HOME EQUITY 89" ;                        
label variable  S216       "IMP WEALTH W/O EQUITY (WEALTH1) 89" ;              
label variable  S216A      "ACC WEALTH W/O EQUITY (WEALTH1) 89" ;              
label variable  S217       "IMP WEALTH W/ EQUITY (WEALTH2) 89" ;               
label variable  S217A      "ACC WEALTH W/ EQUITY (WEALTH2) 89" ;               

#delimit cr
rename 	S201	rfamiid1989
rename	S202	rwtrbus1989
rename	S203	rnetbus1989
rename	S204	rwtrcheck1989
rename	S205	rcheck1989
rename	S207	ralldebt1989
rename	S208	rwtrothre1989
rename	S209	rnetothre1989
rename	S210	rwtrstocks1989
rename	S211	rstocks1989
rename	S213	rvalveh1989
rename	S214	rwtrothas1989
rename	S215	rothas1989
rename	S216	rwealth_noeq1989
rename	S217	rwealth_eq1989
rename	S220	requity1989

keep r*           

save wlth1989, replace

merge 1:1 rfamiid1989 using "R:\mfa\raon\datasets\psid\data\fam1989\fam1989.dta"

drop _merge

compress
save R:\mfa\raon\datasets\psid\data\fam1989\fam1989.dta, replace
 