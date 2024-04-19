-- NORMLALIZE TABLES 

-- Create three new tables and populate them with columns relevent to our analysis. The smallholder_palmoil and industrial_palmoil tables can remain the same becuase they only have relevant information. 

-- Households without electricity

-- create empty table with same (or new if desired) column names from the source table
CREATE TABLE household_electricity_clean(
gid int PRIMARY KEY,
province character varying (30),
with_electricity numeric,
without_electricity numeric,
geom GEOMETRY
);

-- populate the new table with columns
INSERT INTO household_electricity_clean(gid, province, with_electricity, without_electricity, geom)
SELECT gid, provinsi, SUM_Electr, SUM_Withou, geom
FROM households_without_electricity;

SELECT * FROM household_electricity_clean

--------------------------------------

-- Teen School Attendence
-- create empty table with same (or new if desired) column names from the source table
CREATE TABLE school_attendance_clean(
    gid int PRIMARY KEY,
    province character varying (30),
    sum_ages_16_18_not_in_school numeric,
    geom GEOMETRY
);

-- populate the new table with columns
INSERT INTO school_attendance_clean(gid, province, sum_ages_16_18_not_in_school, geom)
SELECT gid, provinsi, SUM_Juml_5, geom
FROM not_in_school;

SELECT * FROM school_attendance_clean

---------------------

-- Percentage employed of the poorest 30%
-- create empty table with same (or new if desired) column names from the source table
CREATE TABLE employed_in_poverty_clean(
    gid int PRIMARY KEY,
    province character varying (30),
    percentage_employed numeric,
    geom GEOMETRY
);

-- populate the new table with columns
INSERT INTO employed_in_poverty_clean (gid, province, percentage_employed, geom)
SELECT gid, provinsi, MEAN_Per_1, geom
FROM percentage_employed_poorest_30;
