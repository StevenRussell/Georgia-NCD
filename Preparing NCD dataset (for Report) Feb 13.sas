
*----------------------------------------------------------------------------------------------------*
*-------------------------------------		NCD Analysis	-----------------------------------------*
*----------------------------------------------------------------------------------------------------*

Physical Measures 								Unit 			Minimum 	Maximum			Georgia Variable(s)
-----------------								----			-------		-------			-------------------

Systolic blood pressure (SBP) 					mmHg 			40 			300				BP_s1 BP_s2 BP_s3
Diastolic blood pressure (DBP) 					mmHg 			30 			200				BP_d1 BP_d2 BP_d3
Height 											cm 				100 		270				height_cm
Weight 											Kg 				20 			350				weight_kg
BMI (body mass index) 							Kg/m2 			11 			75
Waist circumference 							cm 				30 			200				waist_cm
Hip circumference 								cm 				45 			300				hip_cm
Heart rate 										beats/minute 	30 			200				BPM1 BPM2 BPM3

Biochemical Measurements
------------------------

Fasting glucose 								mmol/L  		1 			35.0
Random glucose  								mmol/L 			1 			50.0
Total cholesterol 								mmol/L 			1.75 		20.0
HDL 											mmol/L 			0.10 		5.0
Fasting triglycerides 							mmol/L 			0.25 		50.0
Total cholesterol/HDL ratio 					mmol/L 			1.10 		30.0

http://www.who.int/chp/steps/Part3_Section3.pdf?ua=1
http://www.who.int/chp/steps/Part3_Section4.pdf?ua=1;

*libname ncd "\\cdc.gov\private\L330\ykf1\New folder\Georgia Hep C Serosurvey\Final Analysis Mar 14\wt4_031816";
*libname g "\\cdc.gov\private\L330\ykf1\New folder\Georgia Hep C Serosurvey";
*libname final "\\cdc.gov\private\L330\ykf1\New folder\Georgia Hep C Serosurvey\Final Analysis Mar 14\hepvar_FINAL";

libname n "\\cdc.gov\private\L330\ykf1\New folder\Georgia NCD";

libname test "\\cdc.gov\private\L330\ykf1\New folder\Georgia Hep C Serosurvey\Final Analysis Mar 14\NCD\serosurvey_base";

proc freq data=test.serosurvey_base;
table chronic_thyroid;
run;


*----------------------------------------------------------------------------------------------------*
										STEPS Variables
*----------------------------------------------------------------------------------------------------*;

*test.serosurvey_base;

data compressed (compress=char); 
set test.serosurvey_base (keep= meta_instance_ID start_time final_barcode final_stratum final_cluster final_weight Gender Age Geography
								hypertension_ever diabetes_ever chronic_asthma chronic_arthritis chronic_cancer chronic_COPD 
								chronic_CVD chronic_hemophilia chronic_thyroid chronic_kidney chronic_lung chronic_other
								alc_month alc_female alc_male smoke_current_freq smoke_past BP_treat BP_s1 BP_s2 BP_s3 
								BP_d1 BP_d2 BP_d3 weight_kg height_cm chronic_other_specify chronic_DK sugar_meas
								bp_meas consent_NCD BP_treat alc_drinks alc_ever alc_max alc_month alc_occasions alc_year
								alc_year_freq smoke_other smoke_other_day_week smoke_other_num smoke_past_freq 
								BPM1 BPM2 BPM3 waist_cm hip_cm kyphotic pregnant blood_collected BP_treat language gender
								age education ethnicity ethnicity_other_specify religion religion_other_specify married
								work work_healthcare work_military work_police house house_other_specify resident_num earnings_cat
								earnings_amount earnings_estimate earners_num insurance insurance_type medcare_pay 
								medcare_pay_other_specify displaced medcare_location medcare_location_other_specify
								walk_bike_lastweek walk_bike_typicalweek walk_bike_typicalday smoke_current_freq smoke_past
								smoke_past_freq cig_num cig_day_week hand_cig_num hand_cig_day_week pipe_num pipe_day_week cigar_num
								cigar_day_week smoke_other smoke_other_num smoke_other_day_week geography /*urban or rural*/
								consent_int consent_demo insulin_current chronic_other_specify cancer_type);
run;

*income_year_miss;

proc contents data=compressed;
run;

data n.NCD;
set compressed; 
if consent_int = 1;
***STEPS***;
array systolic (3) BP_s1 BP_s2 BP_s3;
array diastolic (3) BP_d1 BP_d2 BP_d3;
array heart_rate (3) BPM1 BPM2 BPM3;

do i=1 to 3;
if systolic[i] ~ in (40:300) then systolic[i]=.;
if diastolic[i] ~ in (30:200) then diastolic[i]=.;
if heart_rate[i] ~ in (30:200) then heart_rate[i]=.;
end;

*New variables;
mean_sbp = (BP_s2 + BP_s3) / 2;
mean_dbp = (BP_d2 + BP_d3) / 2;
mean_heart_rate = (BPM1 + BPM2) / 2;
BMI = weight_kg / (height_cm / 100)**2;
hip_to_waist_ratio = hip_cm / waist_cm;

if height_cm > 270 or height_cm < 100 then height_cm=.;
if weight_kg > 350 or weight_kg < 20 then weight_kg=.;
if BMI >75 or BMI < 11 then BMI=.; /*change height and weight also?*/
if waist_cm > 200 or waist_cm < 30 then waist_cm=.;
if hip_cm > 300 or hip_cm < 45 then hip_cm=.;

*Prevalence of abdominal obesity (waist-hip ratio, WHR >=0.9 for men and >=0.85 for women);	
waist_hip_ratio = waist_cm / hip_cm;

if alc_ever=2 then alc_max = .;

/*June 13 additions*/

*check; if alc_max ge 50 then alc_max = 88;
*check; if alc_drinks ge 50 then alc_max = 88;

if age ge 18 and age le 29 then age_group="18-29";
else if age ge 30 and age le 44 then age_group="30-44";
else if age ge 45 and age le 59 then age_group="45-59";
else if age ge 60 then age_group="60+";

if mean_sbp ge 140 or mean_dbp ge 90 then raised_bp = 1;
else raised_bp=0;

if alc_male = 88 or alc_male = 888 then alc_male = .;

/*changing alc_year to the variable alc_12_months to get an accurate estimate that accounts for skip pattern*/
if alc_ever = 1 then alc_12_months = alc_year;
else if alc_ever = 2 then alc_12_months = 2;
else if alc_year = 2 then alc_12_months = 2;

/*changing alc_month to the variable alc_30_days to get an accurate estimate that accounts for skip pattern*/
if alc_ever = 1 and alc_year = 1 then alc_30_days = alc_month;
else if alc_ever = 2 then alc_30_days = 2;
else if alc_year = 2 then alc_30_days = 2;

if sugar_meas ne 1 then diabetes_ever=.;

if bmi ge 30 then obese = 1;
else if bmi ge 0 and bmi lt 30 then obese=2;

if bmi ge 25 and bmi < 30 then overweight = 1;
else if bmi ge 0 and bmi <25 then overweight = 2;
else if bmi ge 30 then overweight = 2;

if smoke_current_freq = 1 then past = 1;
else if smoke_current_freq = 2 and smoke_past = 1 then past = 1;
else if smoke_current_freq = 2 and smoke_past = 2 then past = 0;
else if smoke_current_freq = 3 and smoke_past_freq = 1 then past = 1;
else if smoke_current_freq = 3 and smoke_past_freq in (2, 3, 88)  then past = 0;

if gender=1 then alc_male_female = alc_male;
else if gender=2 then alc_male_female = alc_female;

if alc_male_female in (88, 888, 999) then alc_male_female=.;
if alc_male in (88, 888, 999) then alc_male=.;
if alc_female in (88, 888, 999) then alc_female=.;

/*changing from per day and per week to only per day*/

if cig_day_week = 1 then cig_per_day = cig_num;
else if cig_day_week = 2 then cig_per_day = cig_num/7;

if hand_cig_day_week = 1 then hand_cig_per_day = hand_cig_num;
else if hand_cig_day_week = 2 then hand_cig_per_day = hand_cig_num/7;

if pipe_day_week = 1 then pipe_per_day = pipe_num;
else if pipe_day_week = 2 then pipe_per_day = pipe_num/7;

if cigar_day_week = 1 then cigar_per_day = cigar_num;
else if cigar_day_week = 2 then cigar_per_day = cigar_num/7;

if smoke_other_day_week = 1 then smoke_other_per_day = smoke_other_num;
else if smoke_other_day_week = 2 then smoke_other_per_day = smoke_other_num/7;

/* variables suggested by Chaoyang */

if waist_cm = . or hip_cm = . or gender ~ in (1,2) then abdominal_obesity = .;
else if gender = 1 and waist_hip_ratio >= 0.9 then abdominal_obesity = 1;
else if gender = 2 and waist_hip_ratio >= 0.85 then abdominal_obesity = 1;
else abdominal_obesity = 0;

*Cleaning exercise variable;

w = substr(walk_bike_typicalday, 1,5);
if w  = ",01:0" then walk_bike_typicalday2 = "01:00";
	else if w = "00:30" then walk_bike_typicalday2 = "00:30";
	else if w = "0:33:" then walk_bike_typicalday2 = "";
	else if w = "00:30;" then walk_bike_typicalday2 = "00:30";
	else if w = "01::0" then walk_bike_typicalday2 = "01:00";
	else if w = "0:25 " then walk_bike_typicalday2 = "00:25";
	else walk_bike_typicalday2 = w;

if walk_bike_typicalday2 > "08:00" or walk_bike_typicalday2 < "00:10" then walk_bike_typicalday2="";

walk_bike_day_min =  substr(walk_bike_typicalday2, 1,2)*60 + substr(walk_bike_typicalday2, 4,2);

if chronic_COPD ne 1 then chronic_COPD = 2;
if chronic_CVD ne 1 then chronic_CVD = 2;
if chronic_arthritis ne 1 then chronic_arthritis = 2;
if chronic_asthma ne 1 then chronic_asthma = 2;
if chronic_cancer ne 1 then chronic_cancer = 2;
if chronic_hemophilia ne 1 then chronic_hemophilia = 2;
if chronic_kidney ne 1 then chronic_kidney = 2;
if chronic_lung ne 1 then chronic_lung = 2;
if chronic_thyroid ne 1 then chronic_thyroid = 2;
if chronic_other ne 1 then chronic_other = 2;

run;

*---------------------------------------------------------------------------------------------------------*
*                                        Table 1: Demographics                                            *
*---------------------------------------------------------------------------------------------------------;

proc surveyfreq data=test.serosurvey_base nomcar;
/*where consent_int = 1;*/
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group / cl;
run;

proc surveyfreq data=test.serosurvey_base nomcar;
/*where consent_int = 1;*/
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender / cl;
run;

proc surveyfreq data=test.serosurvey_base nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables geography / cl;
run;

*---------------------------------------------------------------------------------------------------------*
*                                     Table 2: Past Tobacco Use                                           *
*---------------------------------------------------------------------------------------------------------;

/* smoke past*/

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables past / cl;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group * past / row cl;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * age_group * past  / row cl;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * past  / row cl;
run;

*---------------------------------------------------------------------------------------------------------*
*                                  Table 3: Current Tobacco Use                                           *
*---------------------------------------------------------------------------------------------------------;

* Current smoking (daily, less than daily, or not at all) ;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables smoke_current_freq  / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group * smoke_current_freq  / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * age_group * smoke_current_freq  / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender *  smoke_current_freq  / row cl nowt nostd;
run;

*---------------------------------------------------------------------------------------------------------*
*                                  Table 4: Current Alcohol Use                                           *
*---------------------------------------------------------------------------------------------------------;

/* Consumed alcohol ever */

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables alc_ever / cl;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group * alc_ever / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * age_group * alc_ever / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * alc_ever / row cl nowt nostd;
run;

/* Consumed alcohol ever in the last 12 months */

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group * alc_12_months / row cl nowt nostd;
*ods output crosstabs = a;
run;

ods html;
ods path sashelp.tmplmst(read) sasuser.templat(update);
ods path sasuser.templat(read) sashelp.tmplmst(update);

proc template;
	EDIT stat.surveyfreq.crosstabfreqs;
		EDIT Percent;
			FORMAT = 4.1;
		END;
		EDIT LowerCL;
			FORMAT = 4.1;
		END;
		EDIT UpperCL;
			FORMAT = 4.1;
		END;
		EDIT RowPercent;
			FORMAT = 4.1;
		END;
		EDIT RowLowerCL;
			FORMAT = 4.1;
		END;
		EDIT RowUpperCL;
			FORMAT = 4.1;
		END; 
	END;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * age_group * alc_12_months / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables alc_12_months / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * alc_12_months / row cl nowt nostd;
run;

/* Consumed alcohol in the last 30 days */

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group * alc_30_days / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * age_group * alc_30_days / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables alc_30_days / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * alc_30_days / row cl nowt nostd;
run;

*---------------------------------------------------------------------------------------------------------*
*                          Table 5: Alcohol Frequency and Quanitity Table                                 *
*---------------------------------------------------------------------------------------------------------;

* Overall ;

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_occasions;
run;

* 18-29 ;

data NCD_alc_18;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* 30-44 ;

data NCD_alc_30;
set n.NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* 45-59 ;

data NCD_alc_45;
set n.NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* 60+ ;

data NCD_alc_60;
set n.NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* M overall ;

data NCD_M_alc;
set n.NCD;
if Gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* M 18-29;

data NCD_M_alc_18;
set n.NCD;
if Gender = 1 and age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* M 30-44;

data NCD_M_alc_30;
set n.NCD;
if Gender = 1 and age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* M 45-59;

data NCD_M_alc_45;
set n.NCD;
if Gender = 1 and age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* M 60+;

data NCD_M_alc_60;
set n.NCD;
if Gender = 1 and age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* F overall ;

data NCD_F_alc;
set n.NCD;
if Gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* F 18-29;

data NCD_F_alc_18;
set n.NCD;
if Gender = 2 and age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* F 30-44;

data NCD_F_alc_30;
set n.NCD;
if Gender = 2 and age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* F 45-59;

data NCD_F_alc_45;
set n.NCD;
if Gender = 2 and age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

* F 60+;

data NCD_F_alc_60;
set n.NCD;
if Gender = 2 and age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_occasions ;
run;

************************************** Average # of Standard Drinks **************************************;

* Overall ;

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_drinks;
run;

* 18-29 ;

data NCD_alc_18;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* 30-44 ;

data NCD_alc_30;
set n.NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* 45-59 ;

data NCD_alc_45;
set n.NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* 60+ ;

data NCD_alc_60;
set n.NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* M overall ;

data NCD_M_alc;
set n.NCD;
if Gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* M 18-29;

data NCD_M_alc_18;
set n.NCD;
if Gender = 1 and age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* M 30-44;

data NCD_M_alc_30;
set n.NCD;
if Gender = 1 and age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* M 45-59;

data NCD_M_alc_45;
set n.NCD;
if Gender = 1 and age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* M 60+;

data NCD_M_alc_60;
set n.NCD;
if Gender = 1 and age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* F overall ;

data NCD_F_alc;
set n.NCD;
if Gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* F 18-29;

data NCD_F_alc_18;
set n.NCD;
if Gender = 2 and age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* F 30-44;

data NCD_F_alc_30;
set n.NCD;
if Gender = 2 and age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* F 45-59;

data NCD_F_alc_45;
set n.NCD;
if Gender = 2 and age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* F 60+;

data NCD_F_alc_60;
set n.NCD;
if Gender = 2 and age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_drinks ;
run;

* finding n's for table;

data Ns;
set n.NCD;
if alc_drinks ge 0 then alc_drink_answered = 1;
else alc_drink_answered = 0;
run;

proc freq data=Ns;
table gender * age_group * alc_drink_answered / list missing;
run;

proc freq data=Ns;
table age_group * alc_drink_answered / list missing;
run;

proc freq data=Ns;
table gender * alc_drink_answered / list missing;
run;

proc freq data=Ns;
table alc_drink_answered / list missing;
run;


*Table 6?;


/* finding n's */
proc surveymeans data=n.NCD ;
var alc_male_female;
domain age_group;
run;

proc surveymeans data=n.NCD ;
var alc_male;
domain age_group;
run;

proc surveymeans data=n.NCD ;
var alc_female;
domain age_group;
run;

/* overall */

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_male_female ;
run;

/* domain estimates surveymean */

data NCD_18_29;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
/*domain ahcv_posneg;*/
run;

proc freq data=NCD;
table alc_ever * alc_male / list missing;
run;

/* overall domain estimates surveymean */

proc surveymeans data=NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_male_female;
run;

data NCD_MF_18_29;
set NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_MF_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
run;

data NCD_MF_30_44;
set NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_MF_30_44 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
run;

data NCD_MF_45_59;
set NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_MF_45_59 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
run;

data NCD_MF_60;
set NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_MF_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
run;

/* male domain estimates surveymean */

proc surveymeans data=NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_male;
run;

data NCD_M_18_29;
set NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;

data NCD_M_30_44;
set NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_30_44 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;

data NCD_M_45_59;
set NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_45_59 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;

data NCD_M_60;
set NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;

/* Females */

proc surveymeans data=NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_female;
run;

data NCD_F_18_29;
set NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_female ;
run;

data NCD_F_30_44;
set NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_30_44 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_female ;
run;

data NCD_F_45_59;
set NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_45_59 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_female ;
run;

data NCD_F_60;
set NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_female ;
run;





***********************************************************************************************************
***************************************  Binge Drinking Table  ********************************************
***********************************************************************************************************;

/* overall */
/*
proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_male_female ;
run;
*/
/* domain estimates surveymean */
/*
data NCD_18_29;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
/*domain ahcv_posneg;*/
/*run;
*//*
proc freq data=NCD;
table alc_ever * alc_male / list missing;
run;
*/
/* overall domain estimates surveymean */

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_male_female;
domain alc_30_days;
run;

data NCD_MF_18_29;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_MF_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
run;

data NCD_MF_30_44;
set n.NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_MF_30_44 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
run;

data NCD_MF_45_59;
set n.NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_MF_45_59 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
run;

data NCD_MF_60;
set n.NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_MF_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male_female ;
run;

/* male domain estimates number of binge drinking occasions last 30 days */

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_male;
run;

data NCD_M_18_29;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;

data NCD_M_30_44;
set n.NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_30_44 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;

data NCD_M_45_59;
set n.NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_45_59 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;

data NCD_M_60;
set n.NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;

/* Females */

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_female;
run;

data NCD_F_18_29;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_female ;
run;

data NCD_F_30_44;
set n.NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_30_44 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_female ;
run;

data NCD_F_45_59;
set n.NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_45_59 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_female ;
run;

data NCD_F_60;
set n.NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_female ;
run;


* finding n's for table;

data Ns;
set n.NCD;
if alc_male_female ge 0 then alc_male_female_answered = 1;
if alc_female ge 0 then alc_female_answered = 1;
if alc_male ge 0 then alc_male_answered = 1;
run;

proc freq data=Ns;
table alc_male_female_answered / list missing;
run;

proc freq data=Ns;
table age_group * alc_male_female_answered / list missing;
run;

proc freq data=Ns;
table alc_male_answered / list missing;
run;

proc freq data=Ns;
table age_group * alc_male_answered / list missing;
run;

proc freq data=Ns;
table alc_female_answered / list missing;
run;

proc freq data=Ns;
table age_group * alc_female_answered / list missing;
run;


*******************************************  Alc Max  ****************************************************;

* Overall ;

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var alc_max;
run;

* 18-29 ;

data NCD_alc_18;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* 30-44 ;

data NCD_alc_30;
set n.NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* 45-59 ;

data NCD_alc_45;
set n.NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* 60+ ;

data NCD_alc_60;
set n.NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* M overall ;

data NCD_M_alc;
set n.NCD;
if Gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* M 18-29;

data NCD_M_alc_18;
set n.NCD;
if Gender = 1 and age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* M 30-44;

data NCD_M_alc_30;
set n.NCD;
if Gender = 1 and age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* M 45-59;

data NCD_M_alc_45;
set n.NCD;
if Gender = 1 and age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* M 60+;

data NCD_M_alc_60;
set n.NCD;
if Gender = 1 and age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* F overall ;

data NCD_F_alc;
set n.NCD;
if Gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* F 18-29;

data NCD_F_alc_18;
set n.NCD;
if Gender = 2 and age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* F 30-44;

data NCD_F_alc_30;
set n.NCD;
if Gender = 2 and age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* F 45-59;

data NCD_F_alc_45;
set n.NCD;
if Gender = 2 and age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* F 60+;

data NCD_F_alc_60;
set n.NCD;
if Gender = 2 and age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_F_alc_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_max ;
run;

* finding n's for table;

data Ns;
set NCD;
if alc_max ge 0 then alc_drink_answered = 1;
else alc_drink_answered = 0;
run;

proc freq data=Ns;
table gender * age_group * alc_drink_answered / list missing;
run;

proc freq data=Ns;
table age_group * alc_drink_answered / list missing;
run;

proc freq data=Ns;
table gender * alc_drink_answered / list missing;
run;

proc freq data=Ns;
table alc_drink_answered / list missing;
run;

*---------------------------------------------------------------------------------------------------------*
*                                  Table 7: Lifestyle / Exercise                                          *
*---------------------------------------------------------------------------------------------------------;

/* Walked or biked at least 10 min */

proc report data=s;
columns table percent LowerCL UpperCL CL;
define table / display;
define percent / display;
define lowerCL / display;
define UpperCL / display;
define CL / computed ;
compute CL / character length=20;
CL = cats("(", put(LowerCL,4.1), ",", put(UpperCL,4.1), ")");
ENDCOMP;
run;

ods trace on;

proc surveyfreq data=n.NCD nomcar;
tables walk_bike_lastweek  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
ods output oneway=s;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * walk_bike_lastweek  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
ods output crosstabs=c;
run;

proc print data=c; run;

proc report data=c;
columns table walk_bike_lastweek rowpercent rowLowerCL rowUpperCL CL;
define table / display;
define walk_bike_lastweek / display;
define rowpercent / display noprint;
define rowlowerCL / display noprint;
define rowUpperCL / display noprint;
define CL / computed ;
compute CL / character length=30;
CL = cat(put(rowpercent,4.1), "% ", "(", put(rowLowerCL,4.1), "%,", put(rowUpperCL,4.1), "%)");
ENDCOMP;
run;

proc surveyfreq data=n.NCD nomcar;
table age_group * walk_bike_lastweek  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * walk_bike_lastweek  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

/* Typical week, how many days do you walk or bicycle at least 10 min */

proc freq data=n.NCD;
table walk_bike_lastweek * walk_bike_typicalweek / list missing;
run;

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var walk_bike_typicalweek;
run;

data walk_18;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_30;
set n.NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_45;
set n.NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_60;
set n.NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

*male;

data walk_M;
set n.NCD;
if gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_M nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_18_m;
set n.NCD;
if age_group = "18-29" and gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_18_m nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_30_m;
set n.NCD;
if age_group = "30-44" and gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_30_m nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_45_m;
set n.NCD;
if age_group = "45-59" and gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_45_m nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_60_m;
set n.NCD;
if age_group = "60+" and gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_60_m nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

*female;

data walk_F;
set n.NCD;
if gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_F nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;


data walk_f;
set n.NCD;
if gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_18_f;
set n.NCD;
if age_group = "18-29" and gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_18_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_30_f;
set n.NCD;
if age_group = "30-44" and gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_30_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_45_f;
set n.NCD;
if age_group = "45-59" and gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_45_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

data walk_60_f;
set n.NCD;
if age_group = "60+" and gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_60_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_typicalweek ;
run;

/* How much time do you spend walking or bicycling for travel on a typical day? */

proc freq data=NCD;
table walk_bike_typicalday;
run;

proc surveymeans data=n.NCD nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var walk_bike_day_min;
run;

data walk_18;
set n.NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_18 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_30;
set n.NCD;
if age_group = "30-44" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_30 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_45;
set n.NCD;
if age_group = "45-59" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_45 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_60;
set n.NCD;
if age_group = "60+" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_60 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

*male;

data walk_M;
set n.NCD;
if gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_M nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_18_m;
set n.NCD;
if age_group = "18-29" and gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_18_m nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_30_m;
set n.NCD;
if age_group = "30-44" and gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_30_m nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_45_m;
set n.NCD;
if age_group = "45-59" and gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_45_m nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_60_m;
set n.NCD;
if age_group = "60+" and gender = 1 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_60_m nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

*female;

data walk_F;
set n.NCD;
if gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_F nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_18_f;
set n.NCD;
if age_group = "18-29" and gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_18_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_30_f;
set n.NCD;
if age_group = "30-44" and gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_30_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_45_f;
set n.NCD;
if age_group = "45-59" and gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_45_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

data walk_60_f;
set n.NCD;
if age_group = "60+" and gender = 2 then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=walk_60_f nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var walk_bike_day_min ;
run;

*---------------------------------------------------------------------------------------------------------*
*                              Table 8: Blood pressure / hypertension                                     *
*---------------------------------------------------------------------------------------------------------;

/* Mean_SBP */

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_sbp;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_sbp;
domain age_group ;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_sbp;
domain gender * age_group;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_sbp;
domain gender  ;
run;

/* Mean DBP */

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_dbp;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_dbp;
domain age_group ;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_dbp;
domain gender * age_group ;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_dbp;
domain gender ;
run;

/* raised DBP */

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
table raised_bp / cl;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
table age_group * raised_bp / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
table gender * age_group * raised_bp / row  cl;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
table chronic_hypertension * raised_bp / row  cl;
run;

***********************************************************************************************************
****************  Comparing Measured Hypertension and Reported Hypertension   ****************************
***********************************************************************************************************;

data meas_repo;
set n.NCD;
if hypertension_ever = . then hypertension_ever = 2;
run;

proc surveyfreq data=meas_repo nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
table  raised_bp * hypertension_ever / row  cl;
run;

proc freq data=meas_repo;
table  raised_bp * hypertension_ever / list missing;
run;

proc surveyfreq data=meas_repo nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
table  gender * raised_bp * hypertension_ever / row  cl  ;
run;

proc surveyfreq data=meas_repo nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
table  gender * age_group * raised_bp * hypertension_ever / row  cl  ;
run;


*---------------------------------------------------------------------------------------------------------*
*                                 Table 9: Self reported hypertension                                     *
*---------------------------------------------------------------------------------------------------------;

/* Hypertension */

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables hypertension_ever / row cl nowt nostd;
run;

/*proc freq data=NCD;
tables bp_meas * hypertension_ever / list missing;
run;*/

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group * hypertension_ever / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * age_group * hypertension_ever / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender  * hypertension_ever / row cl nowt nostd;
run;

*---------------------------------------------------------------------------------------------------------*
*                                 Table 10: Height, Weight, BMI                                           *
*---------------------------------------------------------------------------------------------------------;

*note: consent NCD variable exists but shouldn't matter (those who didn't consent will have missing info);

*height (cm);

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var height_cm;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var height_cm;
domain age_group;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var height_cm;
domain gender * age_group;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var height_cm;
domain gender;
run;

*weight (kg);

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var weight_kg;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var weight_kg;
domain age_group;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var weight_kg;
domain gender * age_group;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var weight_kg;
domain gender;
run;

/* bmi */

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var bmi;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var bmi ;
domain age_group;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var bmi ;
domain gender * age_group;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var bmi ;
domain gender;
run;

*---------------------------------------------------------------------------------------------------------*
*                               Table 11: Hip and Waist                                                   *
*---------------------------------------------------------------------------------------------------------;

/* Hip Circumference */

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var hip_cm;
domain age_group ;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var hip_cm;
domain gender * age_group ;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var hip_cm;
domain gender ;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var hip_cm;
run;


*Waist Circumference;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var waist_cm;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var waist_cm;
domain age_group ;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var waist_cm;
domain gender * age_group;
run;

proc surveymeans data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var waist_cm;
domain gender;
run;

/* Prevalence of abdominal obesity (waist-hip ratio, WHR >=0.9 for men and >=0.85 for women; */

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables abdominal_obesity / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group * abdominal_obesity / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * age_group * abdominal_obesity / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender  * abdominal_obesity / row cl nowt nostd;
run;


*---------------------------------------------------------------------------------------------------------*
*                               Table 11: Overweight and Obesity                                          *
*---------------------------------------------------------------------------------------------------------;
/* overweight */

proc surveyfreq data=n.NCD nomcar;
tables age_group * overweight  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * overweight  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * overweight  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables overweight  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

/* obesity */

proc surveyfreq data=n.NCD nomcar;
tables age_group * obese  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * obese  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * obese  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables obese  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

*---------------------------------------------------------------------------------------------------------*
*                               Table 12: Diabetes and Insulin Therapy                                    *
*---------------------------------------------------------------------------------------------------------;

/* Diabetes */

proc freq data=NCD;
tables sugar_meas * diabetes_ever / list missing;
run;

proc freq data=NCD;
tables bp_meas ;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group * diabetes_ever / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender * age_group * diabetes_ever / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables diabetes_ever / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables gender  * diabetes_ever / row cl nowt nostd;
run;

/* Insulin Therapy */

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables diabetes_ever * age_group * insulin_current / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables diabetes_ever * gender * age_group * insulin_current / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables diabetes_ever * insulin_current / row cl nowt nostd;
run;

proc surveyfreq data=n.NCD nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables diabetes_ever * gender * insulin_current   / row cl nowt nostd;
run;

proc freq data=n.NCD;
table diabetes_ever * insulin_current / list missing;
run;

*---------------------------------------------------------------------------------------------------------*
*                                  Table 13: Cardiovascular Disease                                       *
*---------------------------------------------------------------------------------------------------------;

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_cvd / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_cvd   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_cvd   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_cvd   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

*---------------------------------------------------------------------------------------------------------*
*                               Table 14: Other Chronic Disease                                           *
*---------------------------------------------------------------------------------------------------------;

/* Asthma */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_asthma / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_asthma  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_asthma  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_asthma  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

/* Arthritis */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_arthritis / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_arthritis  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_arthritis  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_arthritis  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

/* Cancer */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_cancer / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_cancer   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_cancer   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_cancer   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

/* COPD */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_copd / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_copd  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_copd   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_copd  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;


/* CKD */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_kidney / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_kidney  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_kidney   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_kidney  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;


/* Hemophilia */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_hemophilia / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_hemophilia  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_hemophilia   / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_hemophilia  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;



/* Thyroid Condition */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_thyroid / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_thyroid  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_thyroid  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_thyroid  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

/* Lung Problems */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_lung / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_lung  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_lung  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_lung  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

/* Other */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_other / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_other  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables chronic_other  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender  * chronic_other  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

/* Chronic_other_specify */

proc surveyfreq data=n.NCD nomcar;
tables age_group * chronic_other_specify  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;

proc surveyfreq data=n.NCD nomcar;
tables gender * age_group * chronic_other_specify  / row cl nowt nostd;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
run;












*************************************
Chronic Other
*************************************;

proc freq data=NCD;
table chronic_other_specify;
run;

*-----------------------------------------------------------------------------------------------------------------;
*                                               Age Adjusted                                                      ;
*-----------------------------------------------------------------------------------------------------------------;

data aa;
set n.NCD;
if age ge 15 and age lt 20 then age_group_std = "15-19";
else if age ge 20 and age lt 25 then age_group_std = "20-24";
else if age ge 25 and age lt 30 then age_group_std = "25-29";
else if age ge 30 and age lt 35 then age_group_std = "30-34"; 
else if age ge 35 and age lt 40 then age_group_std = "35-39"; 
else if age ge 40 and age lt 45 then age_group_std = "40-44"; 
else if age ge 45 and age lt 50 then age_group_std = "45-49"; 
else if age ge 50 and age lt 55 then age_group_std = "50-54"; 
else if age ge 55 and age lt 60 then age_group_std = "55-59"; 
else if age ge 60 and age lt 65 then age_group_std = "60-64"; 
else if age ge 65 and age lt 70 then age_group_std = "65-69"; 
else if age ge 70 and age lt 75 then age_group_std = "70-74"; 
else if age ge 75 and age lt 80 then age_group_std = "75-79"; 
else if age ge 80 and age lt 85 then age_group_std = "80-84"; 
else if age ge 85 then age_group_std = "85+";
run;

proc surveyfreq data=aa nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group_std  / row cl nowt nostd;
run;

ods trace on;

%macro aa(var);

proc surveyfreq data=aa nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group_std * &var   / row cl nowt nostd;
ods output crosstabs=&var._out;
run;

data a;
set &var._out;
if &var = 1 and F_age_group_std ne 'Total';

if F_age_group_std = "15-19" then weight = 2.1175 / 67.5275;
	else if F_age_group_std = "20-24" then weight = 8.22 / 67.5275;
	else if F_age_group_std = "25-29" then weight = 7.93 / 67.5275;
	else if F_age_group_std = "30-34" then weight = 7.61 / 67.5275;
	else if F_age_group_std = "35-39" then weight = 7.15 / 67.5275;
	else if F_age_group_std = "40-44" then weight = 6.59 / 67.5275;
	else if F_age_group_std = "45-49" then weight = 6.04 / 67.5275;
	else if F_age_group_std = "50-54" then weight = 5.37 / 67.5275;
	else if F_age_group_std = "55-59" then weight = 4.55 / 67.5275;
	else if F_age_group_std = "60-64" then weight = 3.72 / 67.5275;
	else if F_age_group_std = "65-69" then weight = 2.96 / 67.5275;
	else if F_age_group_std = "70-74" then weight = 2.21 / 67.5275;
	else if F_age_group_std = "75-79" then weight = 1.52 / 67.5275;
	else if F_age_group_std = "80-84" then weight = 0.91 / 67.5275;
	else if F_age_group_std = "85+"   then weight = 0.63 / 67.5275;

age_adjusted_est + rowpercent * weight;
age_adjusted_se +  RowStdErr **2 * weight ** 2;
lower_bound = age_adjusted_est - 1.96 * age_adjusted_se;
upper_bound = age_adjusted_est + 1.96 * age_adjusted_se;

keep rowpercent RowStdErr weight age_adjusted_est age_adjusted_se lower_bound upper_bound;

run;

proc print data=a;
run;

%mend;

%aa(overweight);
%aa(obese);
%aa(diabetes_ever);
*%aa(mean_sbp);
%aa(hypertension_ever);
%aa(chronic_COPD);
%aa(chronic_CVD);
%aa(chronic_arthritis);
%aa(chronic_asthma);
%aa(chronic_cancer);
%aa(chronic_hemophilia);
%aa(chronic_kidney);
%aa(chronic_lung);
%aa(chronic_thyroid);

ods trace on;

proc surveyfreq data=aa nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group_std * chronic_thyroid   / row cl nowt nostd;
run;

proc surveyfreq data=aa nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
tables age_group* chronic_thyroid   / row cl nowt nostd;
run;



* mean systolic blood pressure (continous variable);

proc surveymeans data=aa nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_sbp;
domain age_group_std;
ods output domain=out_data;
run;

data a;
set out_data;

if age_group_std = "15-19" then weight = 2.1175 / 67.5275;
	else if age_group_std = "20-24" then weight = 8.22 / 67.5275;
	else if age_group_std = "25-29" then weight = 7.93 / 67.5275;
	else if age_group_std = "30-34" then weight = 7.61 / 67.5275;
	else if age_group_std = "35-39" then weight = 7.15 / 67.5275;
	else if age_group_std = "40-44" then weight = 6.59 / 67.5275;
	else if age_group_std = "45-49" then weight = 6.04 / 67.5275;
	else if age_group_std = "50-54" then weight = 5.37 / 67.5275;
	else if age_group_std = "55-59" then weight = 4.55 / 67.5275;
	else if age_group_std = "60-64" then weight = 3.72 / 67.5275;
	else if age_group_std = "65-69" then weight = 2.96 / 67.5275;
	else if age_group_std = "70-74" then weight = 2.21 / 67.5275;
	else if age_group_std = "75-79" then weight = 1.52 / 67.5275;
	else if age_group_std = "80-84" then weight = 0.91 / 67.5275;
	else if age_group_std = "85+"   then weight = 0.63 / 67.5275;

age_adjusted_est + mean * weight;
age_adjusted_se +  StdErr **2 * weight ** 2;
lower_bound = age_adjusted_est - 1.96 * age_adjusted_se;
upper_bound = age_adjusted_est + 1.96 * age_adjusted_se;

keep mean StdErr weight age_adjusted_est age_adjusted_se lower_bound upper_bound;

run;

proc print data=a;
run;

* mean systolic blood pressure (continous variable);

proc surveymeans data=aa nomcar;
stratum final_stratum;
cluster final_cluster;
weight final_weight;
var mean_dbp;
domain age_group_std;
ods output domain=out_data2;
run;

data b;
set out_data2;

if age_group_std = "15-19" then weight = 2.1175 / 67.5275;
	else if age_group_std = "20-24" then weight = 8.22 / 67.5275;
	else if age_group_std = "25-29" then weight = 7.93 / 67.5275;
	else if age_group_std = "30-34" then weight = 7.61 / 67.5275;
	else if age_group_std = "35-39" then weight = 7.15 / 67.5275;
	else if age_group_std = "40-44" then weight = 6.59 / 67.5275;
	else if age_group_std = "45-49" then weight = 6.04 / 67.5275;
	else if age_group_std = "50-54" then weight = 5.37 / 67.5275;
	else if age_group_std = "55-59" then weight = 4.55 / 67.5275;
	else if age_group_std = "60-64" then weight = 3.72 / 67.5275;
	else if age_group_std = "65-69" then weight = 2.96 / 67.5275;
	else if age_group_std = "70-74" then weight = 2.21 / 67.5275;
	else if age_group_std = "75-79" then weight = 1.52 / 67.5275;
	else if age_group_std = "80-84" then weight = 0.91 / 67.5275;
	else if age_group_std = "85+"   then weight = 0.63 / 67.5275;

age_adjusted_est + mean * weight;
age_adjusted_se +  StdErr **2 * weight ** 2;
lower_bound = age_adjusted_est - 1.96 * age_adjusted_se;
upper_bound = age_adjusted_est + 1.96 * age_adjusted_se;

keep mean StdErr weight age_adjusted_est age_adjusted_se lower_bound upper_bound;

run;

proc print data=b;
run;


proc contents data=n.NCD;
run;





data NCD_M_18_29;
set NCD;
if age_group = "18-29" then new_weights = final_weight;
else new_weights=.00000000001;
run;

proc surveymeans data=NCD_M_18_29 nomcar median Q1 Q3;
stratum final_stratum;
cluster final_cluster;
weight new_weights;
var alc_male ;
run;





