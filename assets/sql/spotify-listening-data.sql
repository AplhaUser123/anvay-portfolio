--EDA

select COUNT(*) from spotify;

select count(distinct artist) FROM spotify;

select count(distinct album) FROM spotify;

select distinct album_type FROM spotify;

select MAX(duration_min) from spotify;

select Min(duration_min) from spotify;

select * from spotify
where duration_min = 0

delete from spotify
where duration_min = 0

-------------------------
--DATA ANALYSIS EASY TYPE
-------------------------

--Q 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT * FROM spotify
where stream> 1000000000
Order by stream DESC;

--Q 2. List all albums along with their respective artists.

select album, artist from spotify;

select distinct album, artist from spotify;

select distinct album, artist from spotify
order by 1;

--Q 3.Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) as total_comment from spotify 
where licensed = TRUE;

select count(comments) as total_comment from spotify 
where licensed = TRUE;

--Q 4. Find all tracks that belong to the album type single.
SELECT track, album_type from spotify 
where album_type = 'single'

--Q 5. Count the total number of tracks by each artist.
SELECT artist, count(*) as total_no_songs
from spotify
group by artist;

--------------
--Medium Level
--------------

-- Q 1. Calculate the average danceability of tracks in each album.

SELECT album, avg(danceability) as avg_danceability
from spotify
group by 1
order by 2 desc;

--Q 2. Find the top 5 tracks with the highest energy values.

select track, max(energy) from spotify
group by 1
order by 2 desc
LIMIT 5;

--Q 3 . List all tracks along with their views and likes where official_video = TRUE

SELECT track,
sum(views) as total_views,
sum(likes) as total_likes
FROM spotify
WHERE official_video = TRUE
group by 1
order by 2 desc

--Q 4. For each album, calculate the total views of all associated tracks.

select album, track, sum(views) as total_views
from spotify
group by 1,2
order by 3 desc;

--Q 5. Retrieve the track names that have been streamed on Spotify more than YouTube.
select * from 
(SELECT 
	   track, 
	   --most_played_on,
	   coalesce(SUM(CASE WHEN most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
	   coalesce(SUM(CASE WHEN most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify
FROM spotify
GROUP BY 1) as t1
where streamed_on_spotify > streamed_on_youtube
      AND 
	  streamed_on_youtube <>0;


----------------
-- Advance Level
----------------

--Q.1 Find the top 3 most viewed tracks for each artist using window functions.
--each artist and total view fro each track
--track with highest view for each artist (we need top)
--dense rank
--cte and filder rank <=3

with ranking_artist as (
  select artist, track, sum(views) as total_view,
  dense_rank() over (partition by artist order by sum(views) desc) as rank
  from spotify
  group by artist, track
)
select * from ranking_artist
where rank <= 3

--Q 2. Write a query to find tracks where the liveness score is above the average.

SELECT artist, track, liveness FROM spotify
where liveness > 0.19

select avg(liveness) from spotify --0.19

--another option
select artist, track, liveness from spotify
where liveness > (select avg(liveness) from spotify)

/* 
Q3. Use a WITH clause to calculate the difference between
the highest and lowest energy values for tracks in each album.
*/

with cte
as
(SELECT 
album,
max(energy) as highest_energy,
min(energy) as lowest_energy
from spotify
group by 1
)
select 
	album,
	highest_energy - lowest_energy as enery_diffrence
	from cte
order by 2 desc;