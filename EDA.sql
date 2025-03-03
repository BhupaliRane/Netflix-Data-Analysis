
-- 1. Count the number of Movies vs TV Shows
SELECT * from netflix LIMIT 20;

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS ranking
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE ranking  = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) AS country,
    COUNT(*) AS total_content
FROM 
    netflix
JOIN 
    (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) AS numbers
ON 
    CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= numbers.n - 1
WHERE 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) != ''
GROUP BY 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1))
ORDER BY 
    total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
AND duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find content added in the last 5 years
SELECT * 
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'



-- 8. List all TV shows with more than 5 seasons

SELECT * 
FROM netflix
WHERE 
    type = 'TV Show'
    AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre

SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.digit), ',', -1)) AS genre,
       COUNT(*) AS total_content
FROM netflix
JOIN (
    SELECT 1 AS digit UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5 UNION ALL
    SELECT 6 UNION ALL
    SELECT 7 UNION ALL
    SELECT 8 UNION ALL
    SELECT 9 UNION ALL
    SELECT 10
) n
ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= n.digit - 1
GROUP BY genre
HAVING genre IS NOT NULL AND genre != '';


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT EXTRACT(YEAR from STR_TO_DATE(date_added, '%M %d, %Y')) as year, 
        count(*) as Yearly_Content, ROUND(count(*)/(SELECT count(*) from netflix WHERE country = 'India') * 100, 2) as Avg_Content_Per_Year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY Avg_Content_Per_Year DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'



-- 12. content without a director
SELECT * FROM netflix
WHERE director = '';


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Top 10 actors who have appeared in the highest number of movies produced in India.



WITH RECURSIVE split_actors AS (
    SELECT show_id, 
           TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor,
           SUBSTRING(casts FROM LOCATE(',', casts) + 1) AS remaining_casts
    FROM netflix
    WHERE country = 'India'
    
    UNION ALL
    
    SELECT show_id, 
           TRIM(SUBSTRING_INDEX(remaining_casts, ',', 1)) AS actor,
           SUBSTRING(remaining_casts FROM LOCATE(',', remaining_casts) + 1)
    FROM split_actors
    WHERE remaining_casts LIKE '%,%'
)
SELECT actor, COUNT(*) AS total_content
FROM split_actors
WHERE actor IS NOT NULL AND actor != ''
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;

/*
15: Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

with new_table as
(SELECT *,
CASE 
    WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad_Content'
    ELSE 'Good_Content'
END Category
FROM netflix
)
select category, count(*) as total_content
from new_table
GROUP BY 1;
