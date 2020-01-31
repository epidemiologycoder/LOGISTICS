/*assigning my library, filename, and source*/ 
libname framin '/folders/myshortcuts/SAS_windows/myfolders/LOGISTIC';
proc import datafile= '/folders/myshortcuts/SAS_windows/myfolders/LOGISTIC/frmgham1.csv' OUT = exploring
dbms = csv
replace;
run;

/*a list of all the variables in the dataset*/
proc contents data=exploring;
run;

/* QUESTION 1 - EDA*/
/*table 1 categorical frequencies*/ 
proc freq data=exploring;
 table hospmi sex cursmoke diabetes;
run;

/*table 1 continuous frequencies, box plots, and distribution plots*/ 
proc univariate data=exploring plots;
 var  cigpday bmi totchol age sysbp glucose;
run;

/*need to assign the work file to a permanent library*/ 
data FRAMIN.exploring;
set WORK.EXPLORING;
run; quit;

/*exploring outliers*/
data replacing;
 set exploring;
 if cigpday>=43 then delete;
 if bmi >40 then delete;
 if totchol >=355 then delete;
 if sysbp =202 then delete;
 if glucose >190 then delete;
run;
/*re-running it with having removed outliers*/ 
proc univariate data=exploring plots;
 var  cigpday bmi totchol age sysbp glucose;
run;

*testing association between cat vars and hospmi;
proc freq data=exploring;
 tables 
 (sex cursmoke diabetes)*hospmi /chisq;
 run;
/* pearson correlation for assoc of cont and cont vars*/
 proc corr data=exploring plots(maxpoints=NONE)=matrix(histogram nvar=all);
 var cigpday bmi totchol age sysbp glucose;
run;

/*ttest for assoc of outcome and cont variables*/ 
proc ttest data=exploring;
 class hospmi;
 var bmi cigpday totchol age sysbp glucose;
run;

/*ttest for assoc between cat and cont vars*/
proc ttest data=exploring;
 class diabetes;
 var bmi cigpday totchol age sysbp glucose;
run;
proc ttest data=exploring;
 class cursmoke;
 var cigpday bmi totchol age sysbp glucose;
run;
proc ttest data=exploring;
 class sex;
 var cigpday bmi totchol age sysbp glucose;
run;

/*chisq test for assoc b/ween cat & cat vars*/ 
proc freq data = exploring;
tables sex*(cursmoke diabetes) cursmoke*(sex diabetes) diabetes *(sex cursmoke)/chisq;
run;

/*QUESTION 2 - COLLINEARITY*/ 

 /*collinearity between cursmoke and cigsperday*/ 
proc logistic data=exploring;
 model hospmi (event="1")=cursmoke;
run;
proc logistic data=exploring;
 model hospmi (event="1")=cigpday;
run;
proc logistic data=exploring;
 model hospmi (event="1")=cursmoke cigpday;
run;

/*QUESTION 3 - assessing confounding*/

*is cursmoke related to outcome?;
proc logistic data =exploring; /*assessing if current smoking is related to the outcome*/ 
class cursmoke (ref='0')/param=ref; 
model hospmi (event='1') = cursmoke; 
run; 
*is cur smoke related to predictor?;
proc logistic data =exploring; 
model cursmoke (event='1') = bmi; 
run;
/* full model - reduced model*/ 
proc logistic data=exploring;
 class cursmoke (ref="0")/ param=ref;
 model hospmi (event="1")=bmi cursmoke ;
run;
proc logistic data=exploring;
 model hospmi (event="1")=bmi;
run;

/*QUESTION 4 - MULTIPLE LOGISTIC REGRESSION MODEL*/ 
proc logistic data=exploring;
 class cursmoke (ref="0") sex (ref="2") /*female*// param=ref;
 model hospmi (event="1")=totchol age sex cursmoke sysbp bmi; 
run;

*re-saving the work forlder into the library folder at the end; 
data FRAMIN.exploring;
set WORK.exploring;
run; quit;


/*QUESTION 5 - INTERACTION ASSESSMENT*/ 

data interactiontest;
set exploring;
if sex=2 then recodedsex=0;
if sex=1 then recodedsex=1;
run;

proc logistic data=interactiontest; 
 class cursmoke (ref="0") recodedsex (ref="0") /*male*/ diabetes (ref='0')/*female*// param=ref; 
 model hospmi (event="1")=totchol age recodedsex cursmoke sysbp bmi recodedsex|totchol; /*interpret chol as continuous*/
 contrast 'unit higher chol vs. male' totchol 1 totchol*recodedsex 1 / estimate=both; 
 contrast 'higher chol vs. female' totchol 1 totchol*recodedsex 0 / estimate=both; 
run;

*additional codes;
proc sgplot data=exploring;
 scatter y=hospmi x=age /markerattrs=(color=blue symbol=StarFilled);
run; quit;
proc sgplot data=exploring;
 scatter y=glucose x=diabetes /markerattrs=(color=blue symbol=StarFilled);
run; quit;



