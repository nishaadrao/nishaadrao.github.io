cd R:\mfa\raon\datasets\psid\data\rt2013

#delimit ;

**************************************************************************
   Label           : Panel Study of Income Dynamics: 2013  Rosters and Transfers Family Level File - Final Release
   Rows            : 9063
   Columns         : 53
   ASCII File Date : April 8, 2025
*************************************************************************;


infix 
      RT13V1         1 - 1          RT13V2         2 - 6          RT13V3         7 - 7    
      RT13V4         8 - 8          RT13V5         9 - 9          RT13V6        10 - 10   
      RT13V7        11 - 12         RT13V8        13 - 14         RT13V9        15 - 16   
      RT13V10       17 - 18         RT13V11       19 - 19         RT13V12       20 - 20   
      RT13V13       21 - 21         RT13V14       22 - 22         RT13V15       23 - 23   
 long RT13V16       24 - 28         RT13V17       29 - 29         RT13V18       30 - 30   
 long RT13V19       31 - 35         RT13V20       36 - 36         RT13V21       37 - 37   
 long RT13V22       38 - 46         RT13V23       47 - 47         RT13V24       48 - 48   
 long RT13V25       49 - 57         RT13V26       58 - 58         RT13V27       59 - 59   
      RT13V28       60 - 60         RT13V29       61 - 61         RT13V30       62 - 62   
      RT13V31       63 - 63         RT13V32       64 - 64         RT13V33       65 - 65   
 long RT13V34       66 - 70         RT13V35       71 - 71         RT13V36       72 - 72   
 long RT13V37       73 - 77         RT13V38       78 - 78         RT13V39       79 - 79   
 long RT13V40       80 - 88         RT13V41       89 - 89         RT13V42       90 - 90   
 long RT13V43       91 - 99         RT13V44      100 - 100        RT13V45      101 - 101  
 long RT13V46      102 - 110        RT13V47      111 - 111        RT13V48      112 - 112  
 long RT13V49      113 - 121        RT13V50      122 - 122        RT13V51      123 - 123  
 long RT13V52      124 - 132        RT13V53      133 - 133  
using RT13FAM.txt, clear 
;
label variable  RT13V1       "RELEASE NUMBER" ;                                  
label variable  RT13V2       "ROSTERS AND TRANSFERS FILE (ID) NUMBER" ;          
label variable  RT13V3       "WHO WAS THE RESPONDENT?" ;                         
label variable  RT13V4       "WHETHER WF IN FU" ;                                
label variable  RT13V5       "WHICH PARENT CHECKPOINT" ;                         
label variable  RT13V6       "WHICH CHILD CHECKPOINT" ;                          
label variable  RT13V7       "NUMBER OF SIBLINGS -- HEAD" ;                      
label variable  RT13V8       "NUMBER OF SIBLINGS -- WIFE" ;                      
label variable  RT13V9       "NUMBER OF CHILD RECS ON PAR/CHILD FILE" ;          
label variable  RT13V10      "NUMBER OF PARENT RECS ON PAR/CHILD FILE" ;         
label variable  RT13V11      "FATHER'S STATUS -- HEAD" ;                         
label variable  RT13V12      "MOTHER'S STATUS -- HEAD" ;                         
label variable  RT13V13      "FATHER'S STATUS -- WIFE" ;                         
label variable  RT13V14      "MOTHER'S STATUS -- WIFE" ;                         
label variable  RT13V15      "PT1 WTR HD/WF SPEND ANY TIME HELPING PAR" ;        
label variable  RT13V16      "PT2 TOTAL HOURS HD/WF HELPED PARENT(S)" ;          
label variable  RT13V17      "COMPLETENESS OF PT2 HOURS" ;                       
label variable  RT13V18      "PT4 WTR PAR SPEND ANY TIME HELPING HD/WF" ;        
label variable  RT13V19      "PT5 TOTAL HOURS PARENTS HELPED HD/WF" ;            
label variable  RT13V20      "COMPLETENESS OF PT5 HOURS" ;                       
label variable  RT13V21      "PT6 WTR HD/WF GAVE ANY MONEY TO PARENT(S" ;        
label variable  RT13V22      "PT7 TOTAL MONEY HD/WF GAVE TO PARENT(S)" ;         
label variable  RT13V23      "COMPLETENESS OF PT7" ;                             
label variable  RT13V24      "PT8 WTR PARENTS GAVE ANY MONEY TO HD/WF" ;         
label variable  RT13V25      "PT9 TOTAL MONEY PARENT(S) GAVE TO HD/WF" ;         
label variable  RT13V26      "COMPLETENESS OF PT9" ;                             
label variable  RT13V27      "PT10A WTR PAR HELPED PAY SCHOOL-HD" ;              
label variable  RT13V28      "PT11A WTR PAR HLPD WITH HOME PURCHASE-HD" ;        
label variable  RT13V29      "PT12A WTR PAR OTHER FINANCIAL HLP-HD" ;            
label variable  RT13V30      "PT10A WTR PAR HELPED PAY SCHOOL-WF" ;              
label variable  RT13V31      "PT11A WTR PAR HLPD WITH HOME PURCHASE-WF" ;        
label variable  RT13V32      "PT12A WTR PAR OTHER FINANCIAL HLP-WF" ;            
label variable  RT13V33      "CT1 WTR HD/WF SPEND ANY TIME HELPING CLD" ;        
label variable  RT13V34      "CT2 TOTAL HOURS HD/WF HELPED  CHILD" ;             
label variable  RT13V35      "COMPLETENESS OF CT2 HOURS" ;                       
label variable  RT13V36      "CT4 WTR CLD SPEND ANY TIME HELPING HD/WF" ;        
label variable  RT13V37      "CT5 TOTAL HOURS CHILD HELPED HD/WF" ;              
label variable  RT13V38      "COMPLETENESS OF CT5 HOURS" ;                       
label variable  RT13V39      "CT6 WTR HD/WF GAVE MONEY TO CHILD(REN)" ;          
label variable  RT13V40      "CT7 TOTAL MONEY HD/WF GAVE TO CHILD(REN)" ;        
label variable  RT13V41      "COMPLETENESS OF CT7" ;                             
label variable  RT13V42      "CT8 WTR CHILD GAVE MONEY TO HD/WF" ;               
label variable  RT13V43      "CT9 TOTAL MONEY CHILD GAVE TO HD/WF" ;             
label variable  RT13V44      "COMPLETENESS OF CT9" ;                             
label variable  RT13V45      "CT10 WTR HELPED PAY SCHOOL FOR CHILD" ;            
label variable  RT13V46      "CT11 TOTAL AMT TO PAY FOR SCHOOL" ;                
label variable  RT13V47      "COMPLETENESS OF CT11" ;                            
label variable  RT13V48      "CT12 WTR HELPED PAY HOME PURCHASE-CHILD" ;         
label variable  RT13V49      "CT13 TOTAL AMT TO PAY FOR HOME" ;                  
label variable  RT13V50      "COMPLETENESS OF CT13" ;                            
label variable  RT13V51      "CT14 WTR GAVE OTR FINANCIAL HELP-CHILD" ;          
label variable  RT13V52      "CT15 TOTAL AMT OTR FINANCIAL HELP" ;               
label variable  RT13V53      "COMPLETENESS OF CT15" ;                   

#delimit cr 

rename RT13V2 rfamiid
gen year = 2013
rename RT13V25 rpar_tot_xfer
replace rpar_tot_xfer = . if rpar_tot_xfer==999999999

rename RT13V24 rpar_wtrxfer
replace rpar_wtrxfer = . if rpar_wtrxfer == 0
replace rpar_wtrxfer = 0 if rpar_wtrxfer == 5

rename RT13V28 rpar_wtrhelphome
replace rpar_wtrhelphome = . if rpar_wtrhelphome > 5
replace rpar_wtrhelphome = 0 if rpar_wtrhelphome == 5

rename RT13V29 rpar_wtrhelpfin   
replace rpar_wtrhelpfin = . if rpar_wtrhelpfin > 5
replace rpar_wtrhelpfin = 0 if rpar_wtrhelpfin == 5

rename RT13V31 rpar_wtrhelphomesp 
replace rpar_wtrhelphomesp = . if rpar_wtrhelphomesp == 0
replace rpar_wtrhelphomesp = . if rpar_wtrhelphomesp > 5
replace rpar_wtrhelphomesp = 0 if rpar_wtrhelphomesp == 5

rename RT13V32 rpar_wtrhelpfinsp 
replace rpar_wtrhelpfinsp = . if rpar_wtrhelpfinsp == 0
replace rpar_wtrhelpfinsp = . if rpar_wtrhelpfinsp > 5
replace rpar_wtrhelpfinsp = 0 if rpar_wtrhelpfinsp == 5

keep r* year

save "R:\mfa\raon\datasets\psid\clean_data\rt2013.dta", replace

      
