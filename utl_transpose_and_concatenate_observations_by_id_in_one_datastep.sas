How to transpose and concatenate Observations by ID in one datastep;                                                                           
                                                                                                                                               
I suspect you may want to dedup your data. However with                                                                                        
slightly more complex first.dot and last.dot you could                                                                                         
can handle the absolute dups.                                                                                                                  
                                                                                                                                               
I deduped and sorted the original data to demonstrate algorithm?                                                                               
                                                                                                                                               
see                                                                                                                                            
https://goo.gl/82FmX7                                                                                                                          
https://communities.sas.com/t5/SAS-Data-Management/How-to-concatenate-Observations-by-ID-of-a-variable/m-p/423824                              
                                                                                                                                               
                                                                                                                                               
INPUT                                                                                                                                          
=====                                                                                                                                          
                                                                                                                                               
WORK.HAVSRT total obs=21 |                  RULES for Output                                                                                   
                         |                                                                                                                     
   ID    CYCLE    NAME   |                                                                                                                     
                         |                                                                                                                     
   11      1       aa    |   ID   Cycle1  Cycle2  Cycle3   Cycle4 .. Cycle##                                                                   
   11      1       bb    |                                                                                                                     
                         |   11   aa-bb   aa-ss                                                                                                
   11      2       aa    |   22   dd-df   aa-vv    cc                                                                                          
   11      2       ss    |   33   df      vv       cc-ss   ss-vv                                                                               
                         |                                                                                                                     
   22      1       dd    |                                                                                                                     
   22      1       df    |                                                                                                                     
                         |                                                                                                                     
   22      2       aa    |                                                                                                                     
   22      2       vv    |                                                                                                                     
                         |                                                                                                                     
   22      3       cc    |                                                                                                                     
                         |                                                                                                                     
   33      1       df    |                                                                                                                     
                         |                                                                                                                     
   33      2       vv    |                                                                                                                     
                         |                                                                                                                     
   33      3       cc    |                                                                                                                     
   33      3       ss    |                                                                                                                     
                         |                                                                                                                     
   33      4       ss    |                                                                                                                     
   33      4       vv    |                                                                                                                     
 ...                                                                                                                                           
                                                                                                                                               
                                                                                                                                               
PROCESS                                                                                                                                        
=======                                                                                                                                        
                                                                                                                                               
data want(drop=cycle name);                                                                                                                    
                                                                                                                                               
   * get max cycles;                                                                                                                           
   if _n_=0 then do;                                                                                                                           
     %let rc=%sysfunc(dosubl('                                                                                                                 
        proc sql; select max(cycle) into :maxCyc trimmed from havsrt;quit;                                                                     
     '));                                                                                                                                      
   end;                                                                                                                                        
                                                                                                                                               
   retain id cyc1-cyc&maxCyc.;                                                                                                                 
   array cycs[&maxCyc.] $200 cyc1-cyc&maxCyc.;                                                                                                 
                                                                                                                                               
   set havsrt;                                                                                                                                 
   by id;                                                                                                                                      
   cycs[cycle] = catx('-',cycs[cycle],name); * concatenate;                                                                                    
                                                                                                                                               
   if last.id then do;                                                                                                                         
      output;                                                                                                                                  
      call missing(of cycs[*]);                                                                                                                
   end;                                                                                                                                        
                                                                                                                                               
run;quit;                                                                                                                                      
                                                                                                                                               
                                                                                                                                               
OUTPUT                                                                                                                                         
======                                                                                                                                         
                                                                                                                                               
 WORK.WANT total obs=4                                                                                                                         
                                                                                                                                               
    ID    CYC1     CYC2        CYC3     CYC4                                                                                                   
                                                                                                                                               
    11    aa-bb    aa-ss                                                                                                                       
    22    dd-df    aa-vv       cc                                                                                                              
    33    df       vv          cc-ss    ss-vv                                                                                                  
    44    cc       bb-df-vv    aa       df                                                                                                     
                                                                                                                                               
*                _              _       _                                                                                                      
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _                                                                                               
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |                                                                                              
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |                                                                                              
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|                                                                                              
                                                                                                                                               
;                                                                                                                                              
                                                                                                                                               
data have;                                                                                                                                     
input ID$ Cycle Name$;                                                                                                                         
cards4;                                                                                                                                        
11 1 aa                                                                                                                                        
11 1 bb                                                                                                                                        
11 2 aa                                                                                                                                        
11 2 ss                                                                                                                                        
22 1 dd                                                                                                                                        
22 1 df                                                                                                                                        
22 2 aa                                                                                                                                        
22 2 vv                                                                                                                                        
22 3 cc                                                                                                                                        
33 1 df                                                                                                                                        
33 2 vv                                                                                                                                        
33 3 cc                                                                                                                                        
33 3 ss                                                                                                                                        
33 4 ss                                                                                                                                        
33 4 vv                                                                                                                                        
44 1 cc                                                                                                                                        
44 2 bb                                                                                                                                        
44 2 df                                                                                                                                        
44 2 vv                                                                                                                                        
44 3 aa                                                                                                                                        
44 4 df                                                                                                                                        
;;;;                                                                                                                                           
run;quit;                                                                                                                                      
                                                                                                                                               
proc sort data=have out=havsrt nodupkey;                                                                                                       
by id cycle name;                                                                                                                              
run;quit;                                                                                                                                      
                                                                                                                                               
*          _       _   _                                                                                                                       
 ___  ___ | |_   _| |_(_) ___  _ __                                                                                                            
/ __|/ _ \| | | | | __| |/ _ \| '_ \                                                                                                           
\__ \ (_) | | |_| | |_| | (_) | | | |                                                                                                          
|___/\___/|_|\__,_|\__|_|\___/|_| |_|                                                                                                          
                                                                                                                                               
;                                                                                                                                              
                                                                                                                                               
                                                                                                                                               
data want(drop=cycle name);                                                                                                                    
                                                                                                                                               
   * get max cycles;                                                                                                                           
   if _n_=0 then do;                                                                                                                           
     %let rc=%sysfunc(dosubl('                                                                                                                 
        proc sql; select max(cycle) into :maxCyc trimmed from havsrt;quit;                                                                     
     '));                                                                                                                                      
   end;                                                                                                                                        
                                                                                                                                               
   retain id cyc1-cyc&maxCyc.;                                                                                                                 
   array cycs[&maxCyc.] $200 cyc1-cyc&maxCyc.;                                                                                                 
                                                                                                                                               
   set havsrt;                                                                                                                                 
   by id;                                                                                                                                      
   cycs[cycle] = catx('-',cycs[cycle],name);                                                                                                   
                                                                                                                                               
   if last.id then do;                                                                                                                         
      output;                                                                                                                                  
      call missing(of cycs[*]);                                                                                                                
   end;                                                                                                                                        
                                                                                                                                               
run;quit;                                                                                                                                      
                                                                                                                                               
                                 
