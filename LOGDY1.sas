/*MAKE SURE TO NAME THE LIBRARY*/ 

LIBNAME EPI5345 '/folders/myshortcuts/SAS_windows/myfolders/LOGISTIC';

/* EXCLUDE THE WCGS BECAUSE IT'S A SAS FILE. YOU CALL THE FOLDER LOGISTIC
AND THEN SET THE SAS FILE LATER*/ 

data EDA;
 set epi5345.wcgs;
 RUN;

* Describe the content of the dataset;
proc contents data=eda varnum;
run;/*VARNUM ORDERS THE VARIABLES INTO CATEGORIES?*/ 
 
 * Print the dataset SHOWS ALL INDIVIDUAL OBSERVATIONS;
proc print data=epi5345.wcgs;
run;

