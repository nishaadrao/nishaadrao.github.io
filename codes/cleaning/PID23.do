cd R:\mfa\raon\datasets\psid\data\pid23\

#delimit ;

**************************************************************************
   Label           : Parent Identification File 2023
   DOI             :  
   Rows            : 103725
   Columns         : 40
   ASCII File Date : December 11, 2025
*************************************************************************;


infix 
      PID1           1 - 1          PID2           2 - 5          PID3           6 - 8    
      PID4           9 - 12         PID5          13 - 15         PID6          16 - 19   
      PID7          20 - 22         PID8          23 - 26         PID9          27 - 29   
      PID10         30 - 30         PID11         31 - 31         PID12         32 - 32   
      PID13         33 - 33         PID14         34 - 34         PID15         35 - 35   
      PID16         36 - 36         PID17         37 - 37         PID18         38 - 38   
      PID19         39 - 39         PID20         40 - 40         PID21         41 - 41   
      PID22         42 - 42         PID23         43 - 46         PID24         47 - 49   
      PID25         50 - 53         PID26         54 - 56         PID27         57 - 60   
      PID28         61 - 63         PID29         64 - 64         PID30         65 - 65   
      PID31         66 - 66         PID32         67 - 67         PID33         68 - 68   
      PID34         69 - 69         PID35         70 - 70         PID36         71 - 71   
      PID37         72 - 72         PID38         73 - 73         PID39         74 - 74   
      PID40         75 - 75   
using PID23.txt, clear 
;
label variable  PID1         "RELEASE NUMBER" ;                                  
label variable  PID2         "1968 INTERVIEW NUMBER OF INDIVIDUAL" ;             
label variable  PID3         "PERSON NUMBER OF INDIVIDUAL" ;                     
label variable  PID4         "1968 INTERVIEW NUMBER OF BIRTH MOTHER" ;           
label variable  PID5         "PERSON NUMBER OF BIRTH MOTHER" ;                   
label variable  PID6         "1968 IW NUMBER OF 1ST ADOPTIVE MOTHER" ;           
label variable  PID7         "PERSON NUMBER OF 1ST ADOPTIVE MOTHER" ;            
label variable  PID8         "1968 IW NUMBER OF 2ND ADOPTIVE MOTHER" ;           
label variable  PID9         "PERSON NUMBER OF 2ND ADOPTIVE MOTHER" ;            
label variable  PID10        "WTR BIRTH MOM CODED IN 1983/84 IW" ;               
label variable  PID11        "WTR BIRTH MOM CODED IN FAM COMP" ;                 
label variable  PID12        "WTR 1ST ADOPTIVE MOM CODED IN FAM COMP" ;          
label variable  PID13        "WTR 2ND ADOPTIVE MOM CODED IN FAM COMP" ;          
label variable  PID14        "WTR MOM INDICATED BY INTERVIEWER" ;                
label variable  PID15        "WTR MOM CODED AS 1997 SUPPORT RECEIVER" ;          
label variable  PID16        "WTR MOM CODED AS 1997 SUPPORT PAYER" ;             
label variable  PID17        "WTR MOM CODED IN 1988 PARENT SUPP" ;               
label variable  PID18        "WTR MOM FROM 1988 TIME/MONEY SUPP" ;               
label variable  PID19        "WTR BIRTH MOM RECORD IN BIRTH HISTORY" ;           
label variable  PID20        "WTR 1ST ADOPTIVE MOM REC BIRTH HISTORY" ;          
label variable  PID21        "WTR 2ND ADOPTIVE MOM REC BIRTH HISTORY" ;          
label variable  PID22        "WTR MOM CODED IN 2013 ROSTERS/TRANSFERS" ;         
label variable  PID23        "1968 INTERVIEW NUMBER OF BIRTH FATHER" ;           
label variable  PID24        "PERSON NUMBER OF BIRTH FATHER" ;                   
label variable  PID25        "1968 IW NUMBER OF 1ST ADOPTIVE FATHER" ;           
label variable  PID26        "PERSON NUMBER OF 1ST ADOPTIVE FATHER" ;            
label variable  PID27        "1968 IW NUMBER OF 2ND ADOPTIVE FATHER" ;           
label variable  PID28        "PERSON NUMBER OF 2ND ADOPTIVE FATHER" ;            
label variable  PID29        "WTR BIRTH DAD CODED IN FAM COMP" ;                 
label variable  PID30        "WTR 1ST ADOPTIVE DAD CODED IN FAM COMP" ;          
label variable  PID31        "WTR 2ND ADOPTIVE DAD CODED IN FAM COMP" ;          
label variable  PID32        "WTR DAD INDICATED BY INTERVIEWER" ;                
label variable  PID33        "WTR DAD CODED AS 1997 SUPPORT RECEIVER" ;          
label variable  PID34        "WTR DAD CODED AS 1997 SUPPORT PAYER" ;             
label variable  PID35        "WTR DAD CODED IN 1988 PARENT SUPP" ;               
label variable  PID36        "WTR DAD FROM 1988 TIME/MONEY SUPP" ;               
label variable  PID37        "WTR BIRTH DAD RECORD IN BIRTH HISTORY" ;           
label variable  PID38        "WTR 1ST ADOPTIVE DAD REC BIRTH HISTORY" ;          
label variable  PID39        "WTR 2ND ADOPTIVE DAD REC BIRTH HISTORY" ;          
label variable  PID40        "WTR DAD CODED IN 2013 ROSTERS/TRANSFERS" ;         

#delimit cr 

rename PID2 rfamiid1968
rename PID3 rperiid1968
gen rauid = (rfamiid*1000) + rperiid1968

rename PID25 rfamiid1968_af
rename PID26 rperiid1968_af 
gen rauid_af = (rfamiid1968_af*1000) + rperiid1968_af

rename PID6 rfamiid1968_am
rename PID7 rperiid1968_am 
gen rauid_am = (rfamiid1968_am*1000) + rperiid1968_am

rename PID23 rfamiid1968_bf
rename PID24 rperiid1968_bf 
gen rauid_bf = (rfamiid1968_bf*1000) + rperiid1968_bf

rename PID4 rfamiid1968_bm
rename PID5 rperiid1968_bm 
gen rauid_bm = (rfamiid1968_bm*1000) + rperiid1968_bm

keep r*

save "R:\mfa\raon\datasets\psid\clean_data\fims_psid.dta", replace