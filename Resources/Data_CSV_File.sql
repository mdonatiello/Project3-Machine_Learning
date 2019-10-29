--- The following line of code clears out all of the views I created.  I created several views so the querries could 
--- all be run at one time.  In order to rerun the job, I need to make sure all views have been dropped because you
--- can't create a view that already exists.  This one line, takes care of the six views I created. 

DROP VIEW "FlightsandStats" CASCADE;

--- This is the first query to run, called "FlightsandStats" and this joins
--- the Flights and Statistics Tables together so everything is in one table.

CREATE VIEW "FlightsandStats" as 

SELECT 	"ID",
		"Airline",
		"ACode",
		"NCode",
		"Flights"."Year",
		"Month", 
		"DOM_Flights", 
		"INT_Flights", 
		"TOT_Flights", 
		"DOM_Passengers", 
		"INT_Passengers", 
		"TOT_Passengers", 
		"Arr_flights",
		"Arr_del15", 
		"Carrier_ct", 
		"Weather_ct", 
		"NAS_ct", 
		"Security_ct", 
		"Late_aircraft_ct", 
		"Arr_cancelled", 
		"Arr_diverted", 
		"Arr_delay", 
		"Carrier_delay", 
		"Weather_delay",
		"NAS_delay",
		"Security_delay", 
		"Late_aircraft_delay"

FROM "Flights"

INNER JOIN "Statistics"

ON "Month" = "Period"
AND "Flights"."Year" = "Statistics"."Year"
AND "ACode" = "code"

ORDER BY "ACode", "Month", "Flights"."Year";

--- This section of code performs a running difference on the Total Passenger column.  We needed to determine the monthly increase and decrease change
--- from one year to the next.  This code creates a new column by copying the "Total Passenger" values and placing the copy next to the original "Total Passenger"
--- values but shifts the entire column down by exactly one row. Now you are able to easily subtract the two side by side numbers giving you the difference.  Depeinding
--- on how you need the numbers (positive or negative) you would use either the code in row 64 or 65.  I kept both just to show the difference between the two lines of code.
--- For our project, I needed to use the code in line 65.  

CREATE VIEW "Running_Difference" as 

SELECT 
	"ACode",
	"Year",
	"Month",
	"TOT_Passengers",
	LAG("TOT_Passengers") OVER(PARTITION BY "ACode" ORDER BY "Month") AS PrevValue,
--	LAG("TOT_Passengers") OVER(PARTITION BY "ACode" ORDER BY "Month") - "TOT_Passengers" AS RunningDifference,
	"TOT_Passengers" - LAG("TOT_Passengers") OVER(PARTITION BY "ACode" ORDER BY "Month") AS RunningDifference2

FROM "FlightsandStats"

ORDER BY "ACode", "Month", "Year";

--- This section of code takes the difference calculated above and then assigns either "Decrease" or "Increase" to the row.  We also decided to exclude 2009 because
--- we are comparing the same month but for different years.  Since we are starting with 2009, doing the calculatrion in view "Running Difference", will always result
--- in a zero becuase we don't have 2008 data to take the difference.

CREATE VIEW inc_dec AS 

SELECT 	*,
 	CASE WHEN "runningdifference2"<0 THEN 'Decrease'
 		WHEN "runningdifference2">0 THEN 'Increase'
 		ELSE 'Other'
END
		
FROM "Running_Difference"
WHERE Not "Year" =2009;

--- Now that I know which rows have an increase or a decrease, the following code takes this and assigns it to the appropriate entire row of data.

CREATE VIEW "Combined" AS 

SELECT 	"ID",
		"Airline",
		"public"."FlightsandStats"."ACode",
		"NCode",
		"public"."FlightsandStats"."Year",
		"public"."FlightsandStats"."Month",
		"DOM_Flights", 
		"INT_Flights", 
		"public"."FlightsandStats"."TOT_Flights", 
		"DOM_Passengers", 
		"INT_Passengers", 
		"public"."FlightsandStats"."TOT_Passengers", 
		"Arr_flights",
		"Arr_del15", 
		"Carrier_ct", 
		"Weather_ct", 
		"NAS_ct", 
		"Security_ct", 
		"Late_aircraft_ct", 
		"Arr_cancelled", 
		"Arr_diverted", 
		"Arr_delay", 
		"Carrier_delay", 
		"Weather_delay",
		"NAS_delay",
		"Security_delay", 
		"Late_aircraft_delay",
		"runningdifference2" AS Difference,
		"inc_dec"."case" AS Inc_Dec
		
FROM "public"."FlightsandStats"

INNER JOIN "public"."inc_dec"

ON "public"."FlightsandStats"."ACode" = "public"."inc_dec"."ACode"
AND "public"."FlightsandStats"."Year" = "public"."inc_dec"."Year"
AND "public"."FlightsandStats"."Month" = "public"."inc_dec"."Month";

--- Our project ran two different Machine Learning modules and instead of using the words Increase and Decrease, this module used "1" and "2".  This section of code
--- assigns either "1" to Increase and "2" to Decrease

CREATE VIEW inc_dec_label AS

 SELECT *,
 	CASE WHEN "inc_dec" = 'Increase' THEN '1'
 		WHEN "inc_dec" = 'Decrease' THEN '2'
 		ELSE '0'
 	END
		
 FROM "public"."Combined";

--- The following code adds the numerical designation for Increase and Decrease to the final file which will be used in each of the modules.

CREATE VIEW "Final_File" AS 

SELECT 	"public"."Combined"."ID",
		"public"."Combined"."Airline",
		"public"."Combined"."ACode",
		"public"."Combined"."NCode",
		"public"."Combined"."Year",
		"public"."Combined"."Month",
		"public"."Combined"."DOM_Flights", 
		"public"."Combined"."INT_Flights", 
		"public"."Combined"."TOT_Flights", 
		"public"."Combined"."DOM_Passengers", 
		"public"."Combined"."INT_Passengers", 
		"public"."Combined"."TOT_Passengers", 
		"public"."Combined"."Arr_flights",
		"public"."Combined"."Arr_del15", 
		"public"."Combined"."Carrier_ct", 
		"public"."Combined"."Weather_ct", 
		"public"."Combined"."NAS_ct", 
		"public"."Combined"."Security_ct", 
		"public"."Combined"."Late_aircraft_ct", 
		"public"."Combined"."Arr_cancelled", 
		"public"."Combined"."Arr_diverted", 
		"public"."Combined"."Arr_delay", 
		"public"."Combined"."Carrier_delay", 
		"public"."Combined"."Weather_delay",
		"public"."Combined"."NAS_delay",
		"public"."Combined"."Security_delay", 
		"public"."Combined"."Late_aircraft_delay",
        "public"."Combined"."difference",
        "public"."Combined"."inc_dec",
		"public"."inc_dec_label"."case" AS Inc_Dec_Label
		
FROM "public"."Combined"

INNER JOIN "public"."inc_dec_label"

ON "public"."Combined"."ACode" = "public"."inc_dec_label"."ACode"
AND "public"."Combined"."Year" = "public"."inc_dec_label"."Year"
AND "public"."Combined"."Month" = "public"."inc_dec_label"."Month";

--- The next two sections of code takes the entire file created in the previous view and then only includes the columns needed for that particular Machine Learning Module.
--- The Drop Table coding deletes any existing table so you don't get the error message indicating the table already exists.   

DROP TABLE IF EXISTS "Regression_Final_Table";

CREATE TABLE "Regression_Final_Table" AS 

SELECT	"NCode",
		"Year",
		"Month",
		"difference",
		"Carrier_delay", 
		"Weather_delay",
		"NAS_delay",
		"Security_delay", 
		"Late_aircraft_delay",
        "inc_dec"

From "public"."Final_File";

DROP TABLE IF EXISTS "KNN_Final_Table";

CREATE TABLE "KNN_Final_Table" AS 

SELECT	"NCode",
		"Year",
		"Month",
		"TOT_Flights", 
		"TOT_Passengers",
        "difference", 
		"Arr_flights",
		"Arr_del15",
		"Carrier_ct",
		"Arr_cancelled", 
		"Arr_diverted", 
		"Arr_delay", 
		"inc_dec",
		"inc_dec_label"

From "public"."Final_File";
