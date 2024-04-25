# Mapping the Impacts of Palm Oil Plantations in Indonesia
## Author: Ruthanne Ward
## Last Updated: April 24, 2024

**Introduction**

Palm oil is one of the most valuable vegatable oils traded on the world market due to its land use efficency, relativley low production costs and growing demand from the commercial food industry. The palm oil sector employs a growing number of people in Indonesia. The rapidly growing palm oil industry in Indonesia has increased incomes and living standards of its employees. Although there have been positive effects of the growing industry, there are many evironmental, social and political concerns. The expansion of plantations has lead to loss of biodiversity and forest loss. It has also triggered social conflicts and caused land disputes between local communities and palm oil companies. It is commonly known that communities are being cheated by companies. Just becuase people are employed, does not mean that labor condiitons are acceptable. The plantation jobs are low-skilled, low-wage jobs. Indonesias government either indends to keep a large portion of its population in a poor, laboring class or invite an influx of migrant workers from other developing countries to perform the necessary labor. This project investigates the environmental and social impact of palm oil plantations on Indonesias through spatial analysis of economic factors, urban development and deforestation.  


**Objectives**

Assess the social, economic, and environmental impacts of Palm Oil Plantations in Indonesia by assessing the spatial characteristics of palm oil plantations in relation to deforestation between 2001 and 2019, settlement type and location and the economic status of different regions. The final output should be a comprehensive report that includes a methodology section, descriptions of the database schema and spatial queries used, and an analysis of the findings. Maps and visualizations created with QGIS should be used to illustrate how Indonesia’s social and environmental landscape has been impacted by the rapid increase in palm oil production.

### Assignment 1

**Data**

Vector: 
1. Industrial palm oil plantations 2019
2. Smallholder palm oil plantations 2019
3. Number of people aged 16 - 18 not in school 2015
4. Percentage of people in the poorest 30% between the ages of 15 and 60 that are employed 2015
5. Number of households without electricity 2015

Raster: 
1. Hansen forest/non forest at 2001
2. Hansen forest loss from 2001 - 2022


**Data Preprocessing**

Palm Oil: 

The palm oil data set is sourced from Biopama Programme through the Google Earth Engine Catalog. It was processed, downloaded and exported through this code in GEE:

```
// DEFINE STUDY AREA

// Load FAO GAUL dataset
var gaul = ee.FeatureCollection("FAO/GAUL/2015/level0");

// Filter the dataset for Guyana
var Indonesia = gaul.filter(ee.Filter.eq('ADM0_NAME', 'Indonesia'));

// Visualize the boundary
Map.centerObject(Indonesia, 5);
Map.addLayer(Indonesia, {color: 'blue'}, 'Indonesia Boundary');

// PALM OIL DATASET

// Import the palm oil dataset; a collection of composite granules from 2019.
var dataset = ee.ImageCollection('BIOPAMA/GlobalOilPalm/v1');

// Select the classification band.
var opClass = dataset.select('classification');

// Mosaic all of the granules into a single image.
var mosaic = opClass.mosaic().clip(Indonesia);

// Export palm oil image to drive
Export.image.toDrive({
  image: mosaic,
  description: 'palm_oil',
  crs: indonesia_crs,
  region: Indonesia,
  maxPixels: 600000000 // Increase maxPixels value
})

```

After downloading the .tif image through GEE, it was opened in ArcPro. The raster image has values 0 through 3. The image was reclassed into two seperate images one with just the value of 1 (industrial palm oil) and another with just the value of 2 (smallholder palm oil). The two images were then transformed from rasters to polygons. The final producet looks like this: 

![palmoil](https://github.com/ruthanneward/PalmOilProject/assets/98286245/54c624e4-a706-4a73-a24c-9eb347d61b9a)

Number of people aged 16 - 18 not in school:

This dataset is sourced from USAID. This data was accessed through ArcGIS online. The data looks like this: 

![image](https://github.com/ruthanneward/PalmOilProject/assets/98286245/2e234b82-69e1-459d-92d2-fda012578816)


Percentage of people in the poorest 30% between the ages of 15 and 60 that are employed: 

This dataset is sourced from USAID. This data was accessed through ArcGIS online. The data looks like this: 

![employed](https://github.com/ruthanneward/PalmOilProject/assets/98286245/ced521b9-a744-4577-8fdb-56f2f5f825b0)

Number of households without electricity 2015:

This dataset is sourced from USAID. This data was accessed through ArcGIS online. The data looks like this: 

![electricity](https://github.com/ruthanneward/PalmOilProject/assets/98286245/cff78dc8-4b6a-499f-94ba-2ad4d508b6f4)

Hansen Forest Loss: 

The hansen forest loss is sourced from the Hansen Global Forest Change Project through the Google Earth Engine Data Catalog. It was processed, downloaded and exported through this code in GEE:

```
// FOREST LOSS DATASET 

// Define scale values and crs
var modis_scale = 463.3127165275;
var modis_crs = 'SR-ORG:6974';
var landsat_scale = 27.829872698318393;
var indonesia_crs = 'EPSG:4326'


// Load Hansen global forest change data.
var gfc2022 = ee.Image('UMD/hansen/global_forest_change_2022_v1_10');

// Load Palettes
var palettes = require('users/gena/packages:palettes');
var palette = palettes.matplotlib.magma[7];

// Create new images for the treeCover2000, loss year and loss bands using select.
var tc_2000 = gfc2022.select(['treecover2000']);
var loss_year = gfc2022.select(['lossyear']);
var loss = gfc2022.select(['loss']);

// build multi-band images, where each band is forest area in a given year
// Initialize
var fcf = ee.Image().select([]);
for (var year = 1; year < 23; year++) { // 1-22 = 2001-2022

  var year_str = '20' + ee.Number(year).format('%02d').getInfo();

  // Tree (forest) cover fraction for each year
  var tmp_loss_mask = ee.Image(1).where(loss_year.lt(year),0); // exluding 2001
  var tmp_fcf = tc_2000
    .multiply(tmp_loss_mask)
    .rename('fcf_' + year_str);
  var fcf = fcf.addBands(tmp_fcf);
  
}

// Get forested pixels at any given year based on newly created forest loss bands
var forest_mask = fcf.select(['fcf_2001']).gt(25) // defining forest as greater than 25% of tree cover. nonforest = 0, forest = 1
var forest_mask = forest_mask.unmask().updateMask(forest_mask.eq(1)).mask(); // nonforest = 0, forest = 1

// Clip image to the region of interest
var forest_indonesia = forest_mask.clip(Indonesia); //insert region of interest

//var loss_year_guyana = loss_year.eq(16).clip(guyanaBoundary); //insert region of interest

var forest_loss_indonesia = loss_year.clip(Indonesia)

// Export image to drive
Export.image.toDrive({
  image: forest_indonesia,
  description: 'forest_2001',
  scale: landsat_scale,
  crs: indonesia_crs,
  region: Indonesia,
  maxPixels: 13000000000 // Increase maxPixels value
})

// Export image to drive
Export.image.toDrive({
  image: forest_loss_indonesia,
  description: 'forest_loss_indonesia',
  scale: landsat_scale,
  crs: indonesia_crs,
  region: Indonesia,
  maxPixels: 13000000000 // Increase maxPixels value
})

```

This code exports two products. One of them is forest/nonforest 2001. The other is forest loss for every year from 2001 - 2022. The forest/nonforest 2011 product was downloaded in 18 seperate .tif images becuase of its size. In ArcPro the images were then mosaiced into one raster image. The forest loss producet was downloaded in 6 seperate .tif images and mosaiced into one raster image. A visualization of the two products is:

![image](https://github.com/ruthanneward/PalmOilProject/assets/98286245/9d98ee81-3b9e-4403-89d3-d06bfcf28463)

### Assignment 2

**Inport Data into Postgres**
The data was inported through the command prompt using the following code: 

```
# SHAPEFILE .SQL FILE CREATION
-- -s flag specifies the spatial reference of the source file
-- -I flag creates an index which speeds up sptial querying

# Create .sql file for ages 16-18 not in school shp
C:\Program Files\PostgreSQL\16\bin> shp2pgsql -s 4326 -I "Y:\GEOG382-01-S24\Personal\ruward\PalmOilProject\count_16_18_not_in_school.shp" public.not_in_school > "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\not_in_school.sql"

# Create .sql file for households without electricity shp
C:\Program Files\PostgreSQL\16\bin> shp2pgsql -s 4326 -I "Y:\GEOG382-01-S24\Personal\ruward\PalmOilProject\count_households_without_electricity.shp" public.households_without_electricity > "C:\Users\rutha\OneDrive - Clark University\Documen
ts\SpatialDatabase\PalmOilProject\sql_data_inport_files\households_without_electricity.sql"

# Create .sql file for percentage of people employed in the poorest 30%
C:\Program Files\PostgreSQL\16\bin> shp2pgsql -s 4326 -I "Y:\GEOG382-01-S24\Personal\ruward\PalmOilProject\percentage_of_employed_ppl_in_the_poorest_30%.shp" public.percentage_employed_poorest_30 > "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\percentage_employed_poorest_30.sql"

# Create .sql file for smallholder palm oil plantations shp
C:\Program Files\PostgreSQL\16\bin> shp2pgsql -s 4326 -I "Y:\GEOG382-01-S24\Personal\ruward\PalmOilProject\smallholder_palmoil_vector.shp" public.smallholder_palmoil > "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\Pa
lmOilProject\sql_data_inport_files\smallholder_palmoil.sql"

# Create .sql file for industrial palmoil plantations shp
C:\Program Files\PostgreSQL\16\bin> 

# RASTER .SQL FILE CREATION
-- -s flag specifies the spatial reference of the source file
-- -I flag creates an index on the raster column which speeds up spatial querying
-- -C flag adds raster contraints to use that the data is imported in the correct format
-- -M flag vacuum analyze the raster file after loading

# Create .sql file for forest loss 2001 - 2022
C:\Program Files\PostgreSQL\16\bin> raster2pgsql -s 4326 -I -C -M "C:\Users\rutha\Downloads\forest_loss_indonesia_test.tif" public.forest_loss > "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\forest_loss.sql"

# IMPORT SQL FILES USING COMMAND PROMPT
-- -U connects to the database as a specific user
-- -d points to the destiniation database
-- -f points to the .sql file to be imported

psql -U postgres -d PalmOilProject -f "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\percentage_employed_poorest_30%.sql"

psql -U postgres -d PalmOilProject -f "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\not_in_school.sql"

psql -U postgres -d PalmOilProject -f "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\smallholder_palmoil.sql"

psql -U postgres -d PalmOilProject -f "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\industrial_palmoil.sql"

psql -U postgres -d PalmOilProject -f "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\households_without_electricity.sql"

psql -U postgres -d PalmOilProject -f "C:\Users\rutha\OneDrive - Clark University\Documents\SpatialDatabase\PalmOilProject\sql_data_inport_files\forest_loss.sql"
```
The raster data hwas clipped to a small area of interest before it was inported into SQL becuase of the size of the files. 

**Normalize Tables**

The tables were normalized by creating new tables and inporting the necessary data into them. 

```
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
```
**Household Electricity Table**

![household electricity](https://github.com/ruthanneward/PalmOilProject/assets/98286245/01b4f36d-d938-4394-857c-bdf01604049f)

**School Attendance**

![school Attendance](https://github.com/ruthanneward/PalmOilProject/assets/98286245/14e9e398-229e-4371-b7c4-48fcde513b04)

**Employed in Poverty**

![employed in poverty](https://github.com/ruthanneward/PalmOilProject/assets/98286245/2f859b01-98b9-44a1-9ad1-a987d9ff15ee)

**Industrial Palm Oil**

![industrial palm oil](https://github.com/ruthanneward/PalmOilProject/assets/98286245/a158d722-b73f-499a-9de1-17b3c4b61d7b)

**Smallholder Palm Oil**

![smallholder palm oil](https://github.com/ruthanneward/PalmOilProject/assets/98286245/9c0f2897-6fb8-475f-86b5-c2eb67c4422f)


**Why Normalization?**

Normalization is an important pre-analysis step in any database managment case. Normalization is preformed to prevent redundanct in data, simplyfy table structure, maintain consisten relationships between tables and faciliate easy editing and maintenance of tables. 

All of the tables above satisfy first normal form becuase there are no repeating columns of values. All of the tables satisfy second normal form becuase they are already in 1NF, there are no partial dependencies, meaning that all attributes depend on the primary key. The tables satisfies third normal for becuase it satisfies 2NF and there are no transitive dependencies. All of the tables satisfy fourth normal form becuase it satisfies 3NF and there are no multi-valued dependencies. 



### Assignment 3

The following spatial queries were used in SQL: 

```
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
```

ST_Contains was used to figure out how many palm oil plantations were located in each province. ST_DWithin was used to figure out how many points of forest loss are within 1km of plantations. 

After performing spatial queries in .SQL, the tables were transferred to R to create figures: 

```
# Load libraries 
library(RPostgres)
library(ggplot2)

# Connect to the PostgreSQL database
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "PalmOilProject",
  host = "localhost",
  port = 5432,
  user = " ",
  password = " "
)

# Retrieve data from the database 
data <- dbGetQuery(con, "SELECT * FROM economic_variables")
school_attendance <- dbGetQuery(con, "SELECT * FROM school_attendance_clean")
poverty <- dbGetQuery(con, "SELECT * FROM employed_in_poverty_clean")
electricity <- dbGetQuery(con, "SELECT * FROM household_electricity_clean")

# Merge data into one table 
merged_data <- merge(data, school_attendance, by = "province")
merged_data2 <- merge(merged_data, poverty, by = "province")
merged_data3 <- merge(data, electricity, by = "province")

# create proportion of households without electricity 
merged_data3$proportion_without_electricity <- merged_data3$without_electricity / merged_data3$total_electricity 

# Create stacked bar chart
ggplot(data, aes(x = province)) +
  geom_bar(aes(y = number_of_smallholder_plantations), stat = "identity", fill = "#0072B2", alpha = 0.8) +
  geom_bar(aes(y = number_of_plantations), stat = "identity", fill = "#D55E00", alpha = 0.8) +
  labs(x = "Province", y = "Number of Plantations", fill = NULL) +
  ggtitle("Comparison of Smallholder and Total Plantations by Province") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        axis.title = element_text(size = 12),
        plot.title = element_text(size = 14, face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(color = "black"))


# Create scatterplots
ggplot(merged_data2, aes(x = number_of_smallholder_plantations, y = percentage_employed)) +
  geom_point(color = "#0072B2", alpha = 0.8) +  # Set color and transparency
  geom_smooth(method = "lm", se = FALSE, color = "#D55E00") + 
  labs(x = "Number of Smallholder Plantations", y = "Percentage of the Poorest 30% that is Employed") +
  ggtitle("Scatterplot of Employed in Poverty and Number of Smallholder Plantations") +
  theme_minimal()
  ```

**Results**

This bar chart shows how many of each type of planation there are in each province. 


![bar chart](https://github.com/ruthanneward/PalmOilProject/assets/98286245/7408e6e6-1441-4bec-9476-a9f47b17b888)


This scatterplot shows the smallholder plantation variable compared to the percentage of the poorest 30% that is employed.


![scatterplot (poverty & employment)](https://github.com/ruthanneward/PalmOilProject/assets/98286245/636d42ca-820f-490a-a40d-ba88afc2c097)


This scatterplot shows the smallholder plantation variable compared to school absence.

![image](https://github.com/ruthanneward/PalmOilProject/assets/98286245/49b26b57-be14-43f4-a37d-6188e86c3320)


This scatterplot shows the smallholder plantation variable compated to percentage of households without electricity. 

![image](https://github.com/ruthanneward/PalmOilProject/assets/98286245/e2ab4271-5d28-44c6-b700-a29d5fa3536a)


Overall, the results were inconclusive and a bit underwhelming. They did not yield any strong conclusions. 




**References**

https://books.google.com/books?hl=en&lr=&id=y_ugDwAAQBAJ&oi=fnd&pg=PA173&dq=palm+oil+plantations+indonesia&ots=xHudvYkmiB&sig=YRY74xSKGfAHFUgmq8tPDnFL1jE#v=onepage&q&f=false
