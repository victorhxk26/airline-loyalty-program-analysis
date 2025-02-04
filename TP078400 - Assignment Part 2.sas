/* Data Preprocessing */

/* Reading 2 CSV delimited files - Customer Flight Activity and Loyalty History */
* Customer Flight Activity;
%web_drop_table(WORK.Flight_Activity);

FILENAME REFFILE '/home/u63691887/sasuser.v94/Customer Flight Activity.csv';

PROC IMPORT DATAFILE = REFFILE
	DBMS = CSV
	OUT = WORK.Flight_Activity;
	GETNAMES = YES;
RUN;

%web_open_table(WORK.Flight_Activity);

PROC CONTENTS DATA = WORK.Flight_Activity; /* Checking content of customer flight activity dataset */
RUN;

* Customer Loyalty History;
%web_drop_table(WORK.Loyalty_History);

FILENAME REFFILE '/home/u63691887/sasuser.v94/Customer Loyalty History.csv';

PROC IMPORT DATAFILE = REFFILE
	DBMS = CSV
	OUT = WORK.Loyalty_History;
	GETNAMES = YES;
RUN;

%web_open_table(WORK.Loyalty_History);

PROC CONTENTS DATA = WORK.Loyalty_History; /*Checking content of customer loyalty history dataset */
RUN;

/* Dimensionality Reduction - Dropping unnecessary columns in Flight_Activity dataset - Year and Month */
DATA WORK.Flight_Activity;
	SET WORK.Flight_Activity;
	DROP Year Month;
RUN;

/* Summing up the rest of the numerical & additive columns in Flight_Activity with Loyalty_Number as the basis */
PROC SQL;
    CREATE TABLE WORK.Flight_Activity AS
    SELECT
        Loyalty_Number,
        SUM('Flights Booked'n) AS 'Flights Booked'n,
        SUM('Flights with Companions'n) AS 'Flights with Companions'n,
        SUM('Total Flights'n) AS 'Total Flights'n,
        SUM(Distance) AS Distance,
        SUM('Points Accumulated'n) AS 'Points Accumulated'n,
        SUM('Points Redeemed'n) AS 'Points Redeemed'n,
        SUM('Dollar Cost Points Redeemed'n) AS 'Dollar Cost Points Redeemed'n
    FROM WORK.Flight_Activity
    GROUP BY Loyalty_Number;
QUIT;

/* Data Integration - Merge WORK.Flight_Activity & WORK.Loyalty_History as WORK.Flight_Loyalty */
PROC SQL NOPRINT;
   CREATE TABLE WORK.Flight_Loyalty AS
   SELECT * FROM WORK.Flight_Activity INNER JOIN WORK.Loyalty_History
   ON Flight_Activity.Loyalty_Number = Loyalty_History.Loyalty_Number;
QUIT;

/* Extract first 3,000 observations from the merged dataset */
PROC SQL INOBS = 3000;
	CREATE TABLE WORK.Flight_Loyalty_Extracted AS
	SELECT * FROM WORK.Flight_Loyalty;
QUIT;

/* Dimensionality Reduction - Loyalty_Number, Country and Postal Code */
DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	DROP Loyalty_Number Country 'Postal Code'n;
RUN;

/* Print merged dataset (for 10 observations only) */
PROC PRINT DATA = WORK.Flight_Loyalty_Extracted (OBS = 10);
TITLE 'Flight Activity & Loyalty History of Canadian Airline Customers';
RUN;

/* Exploratory Data Analysis (EDA) */
/* Descriptive statistics for our dataset */
PROC MEANS DATA = WORK.Flight_Loyalty_Extracted 
MAXDEC = 3 N MEAN MODE STD VAR MIN P25 MEDIAN P75 MAX SUM RANGE QRANGE;
TITLE 'Descriptive Statistics of Customer FLight Activity & Loyalty History';
RUN;

/* Distributions of multiple numerical variables using histogram */
PROC UNIVARIATE DATA = WORK.Flight_Loyalty_Extracted NOPRINT;
HISTOGRAM CLV Distance 'Dollar Cost Points Redeemed'n 'Flights Booked'n 'Flights with Companions'n 
'Points Accumulated'n 'Points Redeemed'n Salary 'Total Flights'n 'Enrollment Year'n 'Enrollment Month'n 
'Cancellation Year'n 'Cancellation Month'n / ;
RUN;

/* Horizontal bar chart to display frequency of values of character variables */
PROC GCHART DATA = WORK.Flight_Loyalty_Extracted;
HBAR Province City Gender Education 'Marital Status'n 'Loyalty Card'n 'Enrollment Type'n;
RUN;
QUIT;

/* Correlation analysis */
PROC CORR DATA = WORK.Flight_Loyalty_Extracted PEARSON NOSIMPLE NOPROB PLOTS = none;
VAR CLV Distance 'Dollar Cost Points Redeemed'n 'Flights Booked'n 'Flights with Companions'n 
'Points Accumulated'n 'Points Redeemed'n Salary 'Total Flights'n ;
RUN;

/* Scatterplots with regression line */
PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Dollar Cost Points Redeemed'n * Distance / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Dollar Cost Points Redeemed'n * 'Flights Booked'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Dollar Cost Points Redeemed'n * 'Flights with Companions'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Dollar Cost Points Redeemed'n * 'Total Flights'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Dollar Cost Points Redeemed'n * 'Points Accumulated'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT Distance * 'Flights Booked'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Dollar Cost Points Redeemed'n * 'Flights Booked'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Points Accumulated'n * 'Flights Booked'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Points Redeemed'n * 'Flights Booked'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT Salary * 'Flights Booked'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT Distance * 'Flights with Companions'n / REG;
RUN; 

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Flights Booked'n * 'Flights with Companions'n / REG;
RUN; 

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Dollar Cost Points Redeemed'n * 'Flights with Companions'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Points Accumulated'n * 'Flights with Companions'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT 'Points Redeemed'n * 'Flights with Companions'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT Salary * 'Flights with Companions'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT Distance * 'Points Accumulated'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT CLV * 'Total Flights'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT Distance * 'Total Flights'n / REG;
RUN;

PROC SGSCATTER
DATA = WORK.Flight_Loyalty_Extracted;
PLOT Distance * 'Points Redeemed'n / REG;
RUN;

/* Chi-Square Tests for Association of Two Categorical Variables */
PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES Gender*'Enrollment Type'n / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES Gender*Education / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES 'Loyalty Card'n*Education / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES 'Loyalty Card'n*'Enrollment Type'n / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES 'Loyalty Card'n*'Marital Status'n / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES Gender*'Loyalty Card'n / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES 'Enrollment Type'n*'Marital Status'n / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES 'Marital Status'n*Education / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES 'Enrollment Type'n*Education / CHISQ;
RUN;

PROC FREQ DATA = WORK.Flight_Loyalty_Extracted;
TABLES Gender*'Marital Status'n / CHISQ;
RUN;

/* Two Sample t-test */
PROC TTEST DATA = WORK.Flight_Loyalty_Extracted PLOTS(unpack) = summary;
CLASS Gender;
VAR CLV Distance 'Dollar Cost Points Redeemed'n 'Flights Booked'n 'Flights with Companions'n 
'Points Accumulated'n 'Points Redeemed'n Salary 'Total Flights'n;
RUN;

PROC TTEST DATA = WORK.Flight_Loyalty_Extracted PLOTS(unpack)=summary;
CLASS 'Enrollment Type'n;
VAR CLV Distance 'Dollar Cost Points Redeemed'n 'Flights Booked'n 'Flights with Companions'n 
'Points Accumulated'n 'Points Redeemed'n Salary 'Total Flights'n;
RUN;

/* One-way ANOVA */
PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS Education;
MODEL CLV = Education;
MEANS Education / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS Education;
MODEL 'Dollar Cost Points Redeemed'n = Education;
MEANS Education / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS Education;
MODEL 'Points Redeemed'n = Education;
MEANS Education / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS Education;
MODEL 'Points Accumulated'n = Education;
MEANS Education / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS Education;
MODEL 'Total Flights'n = Education;
MEANS Education / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS Education;
MODEL 'Flights Booked'n = Education;
MEANS Education / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS Education;
MODEL 'Flights with Companions'n = Education;
MEANS Education / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS Education;
MODEL Salary = Education;
MEANS Education / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Loyalty Card'n;
MODEL CLV = 'Loyalty Card'n;
MEANS 'Loyalty Card'n / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Loyalty Card'n;
MODEL 'Dollar Cost Points Redeemed'n = 'Loyalty Card'n;
MEANS 'Loyalty Card'n / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Loyalty Card'n;
MODEL 'Points Redeemed'n = 'Loyalty Card'n;
MEANS 'Loyalty Card'n / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Loyalty Card'n;
MODEL 'Points Accumulated'n = 'Loyalty Card'n;
MEANS 'Loyalty Card'n / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Loyalty Card'n;
MODEL 'Total Flights'n = 'Loyalty Card'n;
MEANS 'Loyalty Card'n / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Loyalty Card'n;
MODEL 'Flights Booked'n = 'Loyalty Card'n;
MEANS 'Loyalty Card'n / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Loyalty Card'n;
MODEL 'Flights with Companions'n = 'Loyalty Card'n;
MEANS 'Loyalty Card'n / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Loyalty Card'n;
MODEL Salary = 'Loyalty Card'n;
MEANS 'Loyalty Card'n / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Marital Status'n;
MODEL CLV = 'Marital Status'n;
MEANS 'Marital Status'n / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Marital Status'n;
MODEL 'Dollar Cost Points Redeemed'n = 'Marital Status'n;
MEANS 'Marital Status'n / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Marital Status'n;
MODEL 'Points Redeemed'n = 'Marital Status'n;
MEANS 'Marital Status'n / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Marital Status'n;
MODEL 'Points Accumulated'n = 'Marital Status'n;
MEANS 'Marital Status'n / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Marital Status'n;
MODEL 'Total Flights'n = 'Marital Status'n;
MEANS 'Marital Status'n / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Marital Status'n;
MODEL 'Flights Booked'n = 'Marital Status'n;
MEANS 'Marital Status'n / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Marital Status'n;
MODEL 'Flights with Companions'n = 'Marital Status'n;
MEANS 'Marital Status'n / HOVTEST = LEVENE(TYPE = ABS) TUKEY CLDIFF;
RUN;

PROC ANOVA DATA = WORK.Flight_Loyalty_Extracted;
CLASS 'Marital Status'n;
MODEL Salary = 'Marital Status'n;
MEANS 'Marital Status'n / HOVTEST = LEVENE(TYPE = ABS) WELCH CLDIFF;
RUN;

/* Feature Engineering */
/* Variable Creation */
DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF 'Cancellation Year'n = . & 'Cancellation Month'n = . THEN
		'Cancellation Status'n = "0"; /* 0 = Not Exited */
	ELSE 
		'Cancellation Status'n = "1"; /* 1 = Exited */
RUN;
		
DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	DROP 'Cancellation Year'n'Cancellation Month'n; /* Drop cancellation year and month */
RUN;

/* One Hot Encoding */
/* Gender */
PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
ADD Gender_Male num,
    Gender_Female num;
QUIT;

PROC SQL; 
UPDATE WORK.Flight_Loyalty_Extracted
SET Gender_Male = (CASE WHEN UPCASE(Gender) EQ 'MALE' THEN 1 ELSE 0 END)
WHERE ( GENDER NE '' OR GENDER IS NOT MISSING );
QUIT;

PROC SQL; 
UPDATE WORK.Flight_Loyalty_Extracted
SET Gender_Female  = (CASE WHEN UPCASE(Gender) EQ 'FEMALE' THEN 1 ELSE 0 END)
WHERE ( GENDER NE '' OR GENDER IS NOT MISSING );
QUIT;

PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
DROP Gender;
QUIT;

/* Enrollment Type */
PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
ADD Enrollment_2018_Promotion num,
    Enrollment_Standard num;
QUIT;

PROC SQL; 
UPDATE WORK.Flight_Loyalty_Extracted
SET Enrollment_2018_Promotion = (CASE WHEN 'Enrollment Type'n EQ '2018 Promotion' THEN 1 ELSE 0 END),
    Enrollment_Standard = (CASE WHEN 'Enrollment Type'n EQ 'Standard' THEN 1 ELSE 0 END);
QUIT;

PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
DROP 'Enrollment Type'n;
QUIT;

/* Marital Status */
PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
ADD Marital_Married num,
    Marital_Single num,
    Marital_Divorced num;
QUIT;

PROC SQL; 
UPDATE WORK.Flight_Loyalty_Extracted
SET Marital_Married = (CASE WHEN 'Marital Status'n EQ 'Married' THEN 1 ELSE 0 END),
    Marital_Single = (CASE WHEN 'Marital Status'n EQ 'Single' THEN 1 ELSE 0 END),
    Marital_Divorced = (CASE WHEN 'Marital Status'n EQ 'Divorced' THEN 1 ELSE 0 END);
QUIT;

PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
DROP 'Marital Status'n;
QUIT;

/* Loyalty Card */
PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
ADD Loyalty_Star num,
    Loyalty_Aurora num,
    Loyalty_Nova num;
QUIT;

PROC SQL; 
UPDATE WORK.Flight_Loyalty_Extracted
SET Loyalty_Star = (CASE WHEN 'Loyalty Card'n EQ 'Star' THEN 1 ELSE 0 END),
    Loyalty_Aurora = (CASE WHEN 'Loyalty Card'n EQ 'Aurora' THEN 1 ELSE 0 END),
    Loyalty_Nova = (CASE WHEN 'Loyalty Card'n EQ 'Nova' THEN 1 ELSE 0 END);
QUIT;

PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
DROP 'Loyalty Card'n;
QUIT;

/* Education */
PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
ADD Education_High_School_or_Below num,
    Education_College num,
    Education_Bachelor num,
    Education_Master num,
    Education_Doctorate num;
QUIT;

PROC SQL; 
UPDATE WORK.Flight_Loyalty_Extracted
SET Education_High_School_or_Below = (CASE WHEN Education EQ 'High School or Below' THEN 1 ELSE 0 END),
    Education_College = (CASE WHEN Education EQ 'College' THEN 1 ELSE 0 END),
    Education_Bachelor = (CASE WHEN Education EQ 'Bachelor' THEN 1 ELSE 0 END),
    Education_Master = (CASE WHEN Education EQ 'Master' THEN 1 ELSE 0 END),
    Education_Doctorate = (CASE WHEN Education EQ 'Doctorate' THEN 1 ELSE 0 END);
QUIT;

PROC SQL;
ALTER TABLE WORK.Flight_Loyalty_Extracted
DROP Education;
QUIT;

/* Dimensionality Reduction - City and Province */
DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	DROP City Province;
RUN;

/* Identifying outliers */
* Flights Booked ;
ODS OUTPUT SGPLOT = WORK.Boxplot_FlightsBooked;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Flights Booked'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_FlightsBooked;

* Flights with Companions ;
ODS OUTPUT SGPLOT = WORK.Boxplot_FlightswithCompanions;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Flights with Companions'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_FlightswithCompanions;

* Total Flights ;   
ODS OUTPUT SGPLOT = WORK.Boxplot_TotalFlights;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Total Flights'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_TotalFlights;

* Distance ; 
ODS OUTPUT SGPLOT = WORK.Boxplot_Distance;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX Distance;
RUN;

PROC PRINT DATA = WORK.Boxplot_Distance;

* Points Accumulated ;
ODS OUTPUT SGPLOT = WORK.Boxplot_PointsAccumulated;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Points Accumulated'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_PointsAccumulated;

* Points Redeemed ;
ODS OUTPUT SGPLOT = WORK.Boxplot_PointsRedeemed;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Points Redeemed'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_PointsRedeemed;

* Dollar Cost Points Redeemed ; 
ODS OUTPUT SGPLOT = WORK.Boxplot_DollarCostPointsRedeemed;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Dollar Cost Points Redeemed'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_DollarCostPointsRedeemed;

* Salary ;
ODS OUTPUT SGPLOT = WORK.Boxplot_Salary;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX Salary;
RUN;

PROC PRINT DATA = WORK.Boxplot_Salary;

* CLV ; 
ODS OUTPUT SGPLOT = WORK.Boxplot_CLV;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX CLV;
RUN;

PROC PRINT DATA = WORK.Boxplot_CLV;

* Enrollment Year ;
ODS OUTPUT SGPLOT = WORK.Boxplot_EnrollmentYear;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Enrollment Year'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_EnrollmentYear;

* Enrollment Month ;
ODS OUTPUT SGPLOT = WORK.Boxplot_EnrollmentMonth;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Enrollment Month'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_EnrollmentMonth;

* Cancellation Year ;
ODS OUTPUT SGPLOT = WORK.Boxplot_CancellationYear;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Cancellation Year'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_CancellationYear;

* Cancellation Month ;
ODS OUTPUT SGPLOT = WORK.Boxplot_CancellationMonth;
PROC SGPLOT DATA = WORK.Flight_Loyalty_Extracted;
   	 VBOX 'Cancellation Month'n;
RUN;

PROC PRINT DATA = WORK.Boxplot_CancellationMonth;

/* Outliers are converted to . */
DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF 'Points Redeemed'n >= 3034.00 THEN
        'Points Redeemed'n = .;
RUN;

DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF 'Flights Booked'n >= 265.00 THEN
        'Flights Booked'n = .;
RUN;

DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF Salary >= 135464 & Salary < 0 THEN
        Salary = .;
RUN;

DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF 'Total Flights'n >= 328.00 THEN 
        'Total Flights'n = .;
RUN;

DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF 'Flights with Companions'n >= 71.00 THEN
        'Flights with Companions'n = .;
RUN;

DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF Distance >= 78159.00 THEN 
        Distance = .;
RUN;

DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF 'Dollar Cost Points Redeemed'n >= 246.00 THEN
        'Dollar Cost Points Redeemed'n = .;
RUN;

DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF 'Points Accumulated'n >= 8068.68 THEN
        'Points Accumulated'n = .;
RUN;

DATA WORK.Flight_Loyalty_Extracted;
	SET WORK.Flight_Loyalty_Extracted;
	IF CLV >= 12516.92 THEN
        CLV = .;
RUN;

/* Imputation using median value */
PROC MEANS DATA = WORK.Flight_Loyalty_Extracted NMISS; /* Check missing values in our merged dataset */
RUN;

PROC STDIZE DATA = WORK.Flight_Loyalty_Extracted 
	OUT = WORK.Flight_Loyalty_Extracted
	REPONLY METHOD = median; 
	VAR Salary CLV 'Points Accumulated'n 'Dollar Cost Points Redeemed'n 'Flights with Companions'n
		Distance 'Total Flights'n 'Flights Booked'n 'Points Redeemed'n;
RUN;

/* Log Transform */
DATA WORK.Flight_Loyalty_Extracted;
    SET WORK.Flight_Loyalty_Extracted;
    CLV_log = LOG(CLV + 1);
    Distance_log = LOG(Distance + 1);
    Dollar_Cost_Points_Redeemed_log = LOG('Dollar Cost Points Redeemed'n + 1);
    Flights_Booked_log = LOG('Flights Booked'n + 1);
    Flights_with_Companions_log = LOG('Flights with Companions'n + 1);
    Points_Accumulated_log = LOG('Points Accumulated'n + 1);
    Points_Redeemed_log = LOG('Points Redeemed'n + 1);
    Salary_log = LOG(Salary + 1);
    Total_Flights_log = LOG('Total Flights'n + 1);
RUN;

/* Scaling - Normalization */
PROC STDIZE DATA = WORK.Flight_Loyalty_Extracted OUT = WORK.Flight_Loyalty_Normalized METHOD = RANGE;
VAR CLV Distance 'Dollar Cost Points Redeemed'n 'Flights Booked'n 'Flights with Companions'n 
'Points Accumulated'n 'Points Redeemed'n Salary 'Total Flights'n;
RUN;

/* Print merged dataset (for 10 observations only) */
PROC PRINT DATA = WORK.Flight_Loyalty_Normalized (OBS = 10);
TITLE 'Flight Activity & Loyalty History of Canadian Airline Customers (Normalized & Log Transformed)';
RUN;
