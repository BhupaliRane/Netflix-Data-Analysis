-- Active: 1740480796298@@localhost@3306@dataanalysis
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

DESCRIBE netflix;

SET SESSION sql_mode = '';

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.2\\Uploads\\netflix_titles.csv' 
INTO TABLE netflix
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\n'  
IGNORE 1 ROWS;


select * from netflix;