# Mapping the Impacts of Palm Oil Plantations in Indonesia
## Author: Ruthanne Ward
## Last Updated: April 11, 2024

**Introduction**

Palm oil is one of the most valuable vegatable oils traded on the world market due to its land use efficency, relativley low production costs and growing demand from the commercial food industry. The palm oil sector employs a growing number of people in Indonesia. The rapidly growing palm oil industry in Indonesia has increased incomes and living standards of its employees. Although there have been positive effects of the growing industry, there are many evoronmental, social and political concerns. The expansion of plantations has lead to loss of biodiversity and forest loss. It has also triggered social conflicts and caused land disputes between local communities and palm oil companies. It is commonly known that communities are being cheated by companies. Just becuase people are employed, does not mean that labor condiitons are acceptable. The plantation jobs are low-skilled, low-wage jobs. Indonesias government either indends to keep a large portion of its population in a poor, laboring class or invite an influx of migrant workers from other developing countries to perform the necessary labor. This project investigates the environmental and social impact of palm oil plantations on Indonesias through spatial analysis of economic factors, urban development and deforestation.  


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



**References**

https://books.google.com/books?hl=en&lr=&id=y_ugDwAAQBAJ&oi=fnd&pg=PA173&dq=palm+oil+plantations+indonesia&ots=xHudvYkmiB&sig=YRY74xSKGfAHFUgmq8tPDnFL1jE#v=onepage&q&f=false
