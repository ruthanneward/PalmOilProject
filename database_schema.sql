--create database
CREATE DATABASE "PalmOil";

-- Connect to PalmOil database
\c PalmOil

-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-------- setup
-- create table for Industrial Palm Oil Plantations
CREATE TABLE Ind_PalmOil(
ID varchar(255),
GeoLocation GEOMETRY(Polygon, 4326)
);

-- create table for Smallholder Palm Oil Plantations
CREATE TABLE Small_PalmOil(
ID varchar(255),
GeoLocation GEOMETRY(Polygon, 4326)
);

-- create table for # of people aged 16-18 not in school
CREATE TABLE Not_in_school(
Province_ID int PRIMARY KEY,
Province varchar(255),
Number_of_people int,
GeoLocation GEOMETRY(Polygon, 4326)
);

-- create table for % of people in the poorest 30% between ages 15 and 60 that are employed
CREATE TABLE employed_poverty(
Province_ID int PRIMARY KEY,
Province varchar(255),
Number_of_people int,
GeoLocation GEOMETRY(Polygon, 4326)
);

-- create table for # of households without electricity 
CREATE TABLE no_electricity(
Province_ID int PRIMARY KEY,
Province varchar(255),
Number_of_households int,
GeoLocation GEOMETRY(Polygon, 4326)
);

-- create table for forest/nonforest 2001 raster
CREATE TABLE  forest_2001(
pixel_ID int PRIMARY KEY,
GeoLocation GEOMETRY(Point, 4326)
);

-- create table for forest loss 2001 - 2022 raster
CREATE TABLE  forest_loss(
pixel_ID int PRIMARY KEY,
GeoLocation GEOMETRY(Point, 4326)
);