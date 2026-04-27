select * from netflix;

select count(*) as total_count from netflix;

select distinct type from netflix;

--Q.1. Count the Number of Movies vs TV Show

select type, count(*) as total_count 
from netflix
group by 1;

--Q.2. Find the Most Common Rating for Movies and TV Shows

select type,
	rating
	from
(
select type,
	rating,
	count(*) as count_rating,
	RANK() over(partition by type order by count(*) desc) as ranking 
	from netflix
group by 1,2
) as t1
where ranking = 1;

--Q.3 List All Movies Released in a Specific Year (e.g., 2020)

SELECT type, title, release_year FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

--Q.4. Find the Top 5 Countries with the Most Content on Netflix

select UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, -- The country in was comming in the same line that why I use this function
count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;

--Q.5. Identify the Longest Movie

SELECT type, title, type, duration from netflix 
where type = 'Movie' and duration = (select max(duration) from netflix;


--Q.6. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

select * from netflix
where director LIKE '%Rajiv Chilaka%'

--Q.7. List All TV Shows with More Than 5 Seasons

SELECT type, title, duration
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5

--Q.9  Count the Number of Content Items in Each Genre

SELECT 
	unnest(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id)
FROM netflix 
group by 1

--Q.10.Find each year and the average numbers of content release in India on netflix.
SELECT release_year, 
    COUNT(*) * 1.0 / COUNT(DISTINCT release_year) AS avg_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY release_year
ORDER BY release_year desc;

--Q.11. Lsit all the movies that are documentries

select * from netflix 
where listed_in Ilike '%documentaries'

--Q.12. Find all content without director

select * from netflix
where director is NULL

--Q.13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

select * from netflix
where 
	casts ILIKE '%Salman Khan%'
	and
	release_year > extract(year from current_date) - 10
	
--Q.14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select 
unnest(string_to_array(casts, ',')) as actor,
count(*) as total_count
from netflix
where country ILIKE '%india%'
group by 1
order by 2 desc
LIMIT 10;

--Q.15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
show_id,
title,
description,
CASE 
when description ILIKE '%kill%' AND description ILIKE '%violence%' THEN 'Contains Kill & Violence'
WHEN description ILIKE '%kill%' THEN 'Contains Kill'
WHEN description ILIKE '%violence%' THEN 'Contains Violence'
ELSE 'Safe Content'
END AS content_category
FROM netflix;

--if you want to count

SELECT 
CASE 
when description ILIKE '%kill%' AND description ILIKE '%violence%' THEN 'Contains Kill & Violence'
WHEN description ILIKE '%kill%' THEN 'Contains Kill'
when description ILIKE '%violence%' THEN 'Contains Violence'
else 'Safe Content'
END as content_category,
COUNT(*) as total_count
FROM netflix
group by content_category
order by total_count DESC;

