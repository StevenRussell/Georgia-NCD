libname g "\\cdc.gov\private\L330\ykf1\New folder\Georgia NCD";

options nofmterr;

*---------------------------------------------------------------------------------------------------------------------------------*
*----------------------------------------   Creating estimates by region   ------------------------------------------------------*
*---------------------------------------------------------------------------------------------------------------------------------;

*Defining regions based on stratum; 

data NCD2;
set g.NCD;
if final_stratum = 1 then region = "Tbilisi";
else if final_stratum in (2,7) then region = "Adjara";
else if final_stratum in (3,9) then region = "Imereti";
else if final_stratum in (4,10) then region = "Kakheti";
else if final_stratum in (5,15) then region = "Kvemo Kartli";
else if final_stratum in (6,13) then region = "Samegrelo-Zemo Svaneti";
else if final_stratum = 8 then region = "Guria";
else if final_stratum = 11 then region = "Mtskheta-Mtianeti";
else if final_stratum = 12 then region = "Racha-Lechkhumi and Kvemo Svaneti";
else if final_stratum = 14 then region = "Samtskhe-Javakheti";
else if final_stratum = 16 then region = "Shida Kartli";
run;

proc freq data=NCD2;
table region * final_stratum/ list missing;
run;

proc freq data=NCD2;
table region/ list missing;
run;

*Obesity;

proc surveyfreq data=NCD2 nomcar;
table region * obese  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
ods output crosstabs=obese;
run;

data obese2;
set obese;
if F_obese = 1 and region ne "";
keep rowpercent region;
run;

proc print data =obese2;
run;

proc contents data=g.NCD;
run;

*Macro version;

%macro by_region (var);

proc surveyfreq data=NCD2 nomcar;
table region * &var  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
ods output crosstabs=&var;
run;

data &var.2;
set &var;
if F_&var = 1 and region ne "";
keep rowpercent region;
run;

proc print data = &var.2;
run;

%mend;

%by_region(diabetes_ever);
%by_region(raised_bp);
%by_region(hypertension_ever);
%by_region(diabetes_ever);
%by_region(chronic_CVD);
%by_region(overweight);










