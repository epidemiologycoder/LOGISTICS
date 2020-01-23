/*MAKE SURE TO NAME THE LIBRARY*/ 

LIBNAME EPI5345 '/folders/myshortcuts/SAS_windows/myfolders/LOGISTIC';

/* EXCLUDE THE WCGS BECAUSE IT'S A SAS FILE. YOU CALL THE FOLDER LOGISTIC
AND THEN SET THE SAS FILE LATER*/ 

* Describe the content of the dataset;
proc contents data=epi5345.wcgs;
run; 

* Exploratory analysis - Descritpive statistics;
* Frequency tables for categorical variables;
proc freq data=epi5345.wcgs;
 table chd69 smoke arcus behpat;
run;
* Recode arcus;
data ready;
 set epi5345.wcgs;
 if arcus="present" then arcusd=1;
 else if arcus="absent" then arcusd=0;
 else arcusd=.;
run;
proc freq data=ready;
 table arcus*arcusd;
run;
* Descriptive statistics for continuous variables;
proc univariate data=ready plots;
 var age sbp dbp chol weightkg bmi;
run;
* Removing an outlier - Note that this should never be done without careful investigation first;
data readynoout;
 set ready;
 if chol=645 then delete;
run;
* Exploratory analysis of the relationships among outcome and predictors;
proc freq data=readynoout;
 tables chd69*(smoke arcusd behpat) smoke*(arcusd behpat) arcusd*behpat / chisq;
run;
* Correlation among continuous variables with graph;
proc corr data=readynoout plots(maxpoints=NONE)=matrix(histogram nvar=all);
 var age sbp dbp chol weightkg bmi;
run;
proc ttest data=readynoout;
 class chd69;
 var age sbp dbp chol weightkg bmi;
run;
proc ttest data=readynoout;
 class smoke;
 var age sbp dbp chol weightkg bmi;
run;
proc ttest data=readynoout;
 class arcusd;
 var age sbp dbp chol weightkg bmi;
run;
* Analysis of variance for behpat (4 categories);
proc anova data=readynoout;
 class behpat;
 model age=behpat;
run;
proc anova data=readynoout;
 class behpat;
 model sbp=behpat;
run;
proc anova data=readynoout;
 class behpat;
 model dbp=behpat;
run;
proc anova data=readynoout;
 class behpat;
 model chol=behpat;
run;
proc anova data=readynoout;
 class behpat;
 model weightkg=behpat;
run;
proc anova data=readynoout;
 class behpat;
 model bmi=behpat;
run;

* Graph of outcome vs. age for illustration purpose (not a useful graph otherwise);
symbol1 color=black value=circle;
proc sgplot ready;
 plot chd69*age;
run;
quit;

* Example of simple logistic regression models;
proc logistic data=readynoout;
 model chd69 (event="yes")=age;
run;
proc logistic data=readynoout;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=smoke;
run;
* Alternative to the class statement by creating dummy variable;
data wcgs2;
 set readynoout;
 if smoke=1 then dsmoke=0;
 else if smoke=2 then dsmoke=1;
run;
proc logistic data=wcgs2;
 model chd69 (event="yes")=dsmoke;
run;

* Output predicted probabilities and estimated parameters from model with age;
proc logistic data=readynoout outest=estparameter;
 model chd69 (event='yes')=age;
 output out=predchd p=chdpred xbeta=chdlogit; 
run;
* Plots of predicted log odds vs. age and predicted probabilities vs. age;
symbol1 color=black value=circle;
proc gplot data=predchd;
 plot chdlogit*age chdpred*age;
run;
quit;

*Example of multiple logistic regression model;
proc logistic data=readynoout;
 class smoke (ref="1") behpat (ref="B4") / param=ref;
 model chd69 (event="yes")=chol age sbp bmi smoke behpat arcusd;
run;
* Changing the units for a continuous variable;
proc logistic data=readynoout;
 class smoke (ref="1") behpat (ref="B4") / param=ref;
 model chd69 (event="yes")=chol age sbp bmi smoke behpat;
 units age=10;
run;

* Collinearity assessment (we will revisit multicollinearity in session 3 when we talke about regression diagnostics);
proc logistic data=readynoout;
 model chd69 (event="yes")=sbp;
run;
proc logistic data=readynoout;
 model chd69 (event="yes")=dbp;
run;
proc logistic data=readynoout;
 model chd69 (event="yes")=sbp dbp;
run;
 
proc logistic data=readynoout;
 model chd69 (event="yes")=weightkg;
run;
proc logistic data=readynoout;
 model chd69 (event="yes")=bmi;
run;
proc logistic data=readynoout;
 model chd69 (event="yes")=weightkg bmi;
run;

* High blood pressure;
data ready2;
 set readynoout;
 if (sbp^=. & dbp^=.) then do;
     * Missing values are the smallest values in SAS - be careful when using comparisons like smaller than <;
      * to avoid attributing missing values to another value;
  if (sbp>=130 | dbp>=80) then hbp=1;
  else hbp=0;
 end;
run;
proc freq data=ready2;
 table hbp;
run;
proc ttest data=ready2;
 class hbp;
 var sbp dbp;
run;
* Would you include both hbp and sbp or dbp in a logistic regression model? Why?;
proc logistic data=ready2;
 model chd69 (event="yes")=sbp;
run;
proc logistic data=ready2;
 model chd69 (event="yes")=dbp;
run;
proc logistic data=ready2;
 model chd69 (event="yes")=hbp;
run;
proc logistic data=ready2;
 model chd69 (event="yes")=hbp sbp;
run;
proc logistic data=ready2;
 model chd69 (event="yes")=hbp dbp;
run;

* Confounding assessment in full model;
proc logistic data=ready2;
 class smoke (ref="1") behpat (ref="B4") / param=ref;
 model chd69 (event="yes")=chol age hbp bmi smoke behpat;
run;
proc logistic data=ready2;
 class smoke (ref="1") behpat (ref="B4") / param=ref;
 model chd69 (event="yes")=chol age hbp bmi behpat;
run;


/*****
EPI5345 Example SAS code for session 2

MH Roy-Gagnon
01/20/2014
Last modified: 01/17/2019
*****/

* Create library to indicate where your datasets are stored;

* Interactions;
* Remove missing values and create dichotomized age variable;
data ready;
 set epi5345.wcgs;
 if chol=645 then delete;
 if age<50 then age50=0;
 else age50=1;
 if arcus="present" then arcusd=1;
 else if arcus="absent" then arcusd=0;
 else arcusd=.;
run;

proc freq data=ready;
 tables arcusd age50;
run;

* Long and short ways of specifying interactions;
proc logistic data=ready;
 class arcusd (ref="0") / param=ref;
 model chd69 (event="yes")=age50 arcusd age50*arcusd;
run;
proc logistic data=ready;
 class arcusd (ref="0") / param=ref;
 model chd69 (event="yes")=age50|arcusd;
run;
* Odds ratios;
/* you will . not get OR becuase you have diff levels - they don't mean anything.*/ 


proc logistic data=ready;
 class arcusd (ref="0") / param=ref;
 model chd69 (event="yes")=age50|arcusd;
 contrast 'arcus vs. no for age<50' arcusd 1 age50*arcusd 0 / estimate=both;
 contrast 'arcus vs. no for age>=50' arcusd 1 age50*arcusd 1 / estimate=both;
 contrast 'age50 vs. no without arcus' age50 1 age50*arcusd 0 / estimate=both;
 contrast 'age50 vs. no with arcus' age50 1 age50*arcusd 1 / estimate=both;
 contrast 'arcus and age50 vs. neither' age50 1 arcusd 1 age50*arcusd 1 / estimate=both;
run;
/* you need to see this effect for sure. arcus for upper and higher age and lower age
1 is comparing to ref group. not taking interaction term into account. when you pu tthe * at 1
it will tell you to put it into the arcus study. CALCULATE THE ESTIMATE BY HAND*/


proc logistic data=ready;
 class arcusd (ref="0") / param=ref;
 model chd69 (event="yes")=age|arcusd;
 contrast 'arcus vs. no at age 55' arcusd 1 age*arcusd 55 / estimate=both;
 contrast 'age change 1 without arcus' age 1 age*arcusd 0 / estimate=both;
 contrast 'age change 1 with arcus' age 1 age*arcusd 1 / estimate=both;
 output out=predchd p=chdpred xbeta=chdlogit;
run;
* Graph of estimated log odds vs. age by arcus status;
symbol1 color=black value=circle;
symbol2 color=black value=square;
proc gplot data=predchd;
 plot chdlogit*age=arcusd;
run;
quit;

* Backward selection;
proc logistic data=ready;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=age sbp dbp chol weightkg heightm bmi smoke arcusd / selection=backward slstay=0.05;
run;
* Forward selection;
proc logistic data=ready;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=age sbp dbp chol weightkg heightm bmi smoke arcusd / selection=forward slentry=0.05;
run;
* Stepwise selection;
proc logistic data=ready;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=age sbp dbp chol weightkg heightm bmi smoke arcusd / selection=stepwise slentry=0.1 slstay=0.05;
run;
proc logistic data=ready;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=age sbp dbp chol weightkg heightm bmi smoke arcusd / selection=stepwise slentry=0.05 slstay=0.05;
run;
* Force include predictors;
proc logistic data=ready;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=bmi age sbp dbp chol weightkg heightm smoke arcusd / selection=backward slstay=0.05 include=2;
run;
proc logistic data=ready;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=bmi age sbp dbp chol weightkg heightm smoke arcusd / selection=forward slentry=0.05 include=2;
run;
proc logistic data=ready;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=bmi age sbp dbp chol weightkg heightm smoke arcusd / selection=stepwise slentry=0.1 slstay=0.05 include=2;
run;

* Mediation analysis of bmi-chol-chd;
proc logistic data=ready;
 model chd69 (event="yes")=bmi;
run;
proc reg data=ready plots=none;
 model chol=bmi;
run;
proc logistic data=ready;
 model chd69 (event="yes")=chol;
run;
proc logistic data=ready;
 model chd69 (event="yes")=bmi chol;
run;


* Additional code for best subsets selection;

* Best subsets selection using the likelihood ratio chi-square is implemented in SAS;
* The best=2 option tells SAS to display the best 2 models of each size instead of all models;
proc logistic data=ready;
 class smoke (ref="1") / param=ref;
 model chd69 (event="yes")=bmi age sbp dbp chol weightkg heightm smoke arcusd / selection=score best=2;
run;

