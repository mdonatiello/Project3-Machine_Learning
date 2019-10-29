CREATE TABLE "Flights" (
    "ID" INT,
    "Airline" VARCHAR(50),
    "ACode" VARCHAR(5),
    "NCode" INT,
    "Year" INT,
    "Month" INT,
    "DOM_Passengers" INT,
    "INT_Passengers" INT,
    "TOT_Passengers" INT,
    "DOM_Flights" INT,
    "INT_Flights" INT,
    "TOT_Flights" INT,
    CONSTRAINT "pk_Flights" PRIMARY KEY (
        "ACode","Year","Month"
     )
);

CREATE TABLE "Statistics" (
    "Year" INT,
    "Period" INT,
    "code" VARCHAR(5),
    "carrier" VARCHAR(50),
    "Arr_flights" Float,
    "Arr_del15" Float,
    "Carrier_ct" Float,
    "Weather_ct" Float,
    "NAS_ct" Float,
    "Security_ct" Float,
    "Late_aircraft_ct" Float,
    "Arr_cancelled" Float,
    "Arr_diverted" Float,
    "Arr_delay" Float,
    "Carrier_delay" Float,
    "Weather_delay" Float,
    "NAS_delay" Float,
    "Security_delay" Float,
    "Late_aircraft_dela" Float
);

ALTER TABLE "Statistics" ADD CONSTRAINT "fk_Statistics_Year_Period_code" FOREIGN KEY("Year", "Period", "code")
REFERENCES "Flights" ("Year", "Month", "ACode");

