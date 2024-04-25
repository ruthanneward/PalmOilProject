-- Title: Spatial Queries 
-- Author: Ruthanne Ward

-- CREATE NEW TABLE THAT INCLUDES # OF PLANTATIONS PER PROVINCE

-- Create a new table to store the desired values
CREATE TABLE economic_variables (
	gid INT PRIMARY KEY,
	province character varying (30),
	number_of_planations numeric,
 number_of_smallholder_plantations numeric
);

-- Insert gid and province into economic_variables table
INSERT INTO economic_variables(gid, province)
SELECT gid, province
FROM school_attendance_clean;

-- Calculate number of smallholder plantations that are in each province 
UPDATE economic_variables AS ev
SET number_of_smallholder_plantations = 
(
    SELECT COUNT(*) 
    FROM smallholder_palmoil AS sp 
    JOIN household_electricity_clean AS he 
    ON ST_Contains(he.geom, sp.geom) 
    WHERE he.province = ev.province
);

-- Calculate number of industrial plantations that are in each province 
UPDATE economic_variables AS ev
SET number_of_planations = 
(
    SELECT COUNT(*) 
    FROM industrial_palmoil AS ip 
    JOIN household_electricity_clean AS he 
    ON ST_Contains(he.geom, ip.geom) 
    WHERE he.province = ev.province
);

-- FIND HOW MANY PIXELS OF FOREST LOSS ARE WITHIN 1KM OF AN INDUSTRIAL PALM OIL PLANTATION 

-- Convert raster forest loss data into points
CREATE TABLE forest_loss_points AS
SELECT 
    (ST_PixelAsCentroids(rast)).*
FROM 
    forest_loss;
	
-- Use ST_DWITHIN to determine how many points of forest loss are within 1km of plantations 
SELECT 
    p.gid AS palm_oil_id,
    COUNT(flp.*) AS forest_loss_points_within_1km
FROM 
    smallholder_palmoil AS p,
    forest_loss_points AS flp
WHERE 
    ST_DWithin(p.geom, flp.geom, 1000) -- Within a distance of 1km (1000 meters)
GROUP BY 
    p.gid;