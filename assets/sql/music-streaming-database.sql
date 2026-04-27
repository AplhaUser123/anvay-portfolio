-------------------
--East Task
-------------------

--Q.1 Who is the senior most employee based on job title?

Select * from employee
order by levels desc
limit 1;

--Q.2 Which countries have the most invoices?

SELECT count(*) as total_count, billing_country
from invoice
group by billing_country
order by 1 desc;

--Q.3 What are 3 values of total invoice?

select invoice_id, invoice_date,billing_city,total from invoice
order by total desc
limit 3;

-- Q4: Find the city with the best customers.
-- The city with the highest total invoice amount is where we earned the most.
-- We want to host a promotional Music Festival in that city.
-- Return the city name along with the total of all invoice amounts.

select billing_city, sum(total) as total_invoice
from invoice
group by billing_city
order by 2 desc;

-- Q5: Identify the best customer.
-- The best customer is the one who has spent the most money.
-- Return the customer's full name and the total amount they've spent.

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total_invoice
from customer c
join
invoice i on c.customer_id=i.customer_id
group by 1
order by 4 desc
limit 1;

-------------------
--Moderate Task
-------------------

-- Q1: Return the email, first name, last name, and genre of all customers who listen to Rock music.
-- Only include customers whose email starts with the letter 'A'.
-- Sort the results alphabetically by email.

SELECT DISTINCT c.email, c.first_name, c.last_name, g.name as genre
from customer c
JOIN invoice i ON c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
and c.email LIKE 'a%'
ORDER BY c.email;

-- Q2: Find the top 10 artists who have composed the most Rock music tracks.
-- Return the artist name and the total count of their rock tracks.

SELECT ar.name AS artist_name, COUNT(*) AS rock_track_count
FROM track t
join genre g on t.genre_id = g.genre_id
join album al ON t.album_id = al.album_id
join artist ar ON al.artist_id = ar.artist_id
where g.name = 'Rock'
group BY ar.name
ORDER BY 2 DESC
LIMIT 10;

-- Q3: Return all track names that have a song length longer than the average song length.
-- Display the track name and its length in milliseconds.
-- Sort the results in descending order, so the longest songs appear first.

select name, milliseconds
from track
where milliseconds > 393599.212103910933
--select avg(milliseconds) as avg_milli_track_length from track
order by milliseconds desc;

-------------------
--Advance Task
-------------------

-- Q1: Find how much money each customer has spent on each artist.
-- Return: customer name, artist name, and total amount spent.

WITH best_selling_artist AS (
SELECT ar.artist_id, ar.name AS artist_name, SUM(il.unit_price * il.quantity) AS total_sales
FROM 
invoice_line il
JOIN 
track t ON t.track_id = il.track_id
JOIN 
album a ON a.album_id = t.album_id
JOIN 
artist ar ON ar.artist_id = a.artist_id
GROUP BY ar.artist_id, ar.name
ORDER BY total_sales DESC
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price * il.quantity) AS amount_spent
FROM customer c
JOIN 
invoice i ON i.customer_id = c.customer_id
JOIN 
invoice_line il ON il.invoice_id = i.invoice_id
JOIN 
track t ON t.track_id = il.track_id
JOIN 
album a ON a.album_id = t.album_id
JOIN 
best_selling_artist bsa ON bsa.artist_id = a.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

-- Q2: Find the most popular music genre in each country.
-- A genre is considered most popular if it has the highest number of purchases in that country.
-- Return: country name and top genre(s).
-- If there is a tie for top genres in a country, return all tied genres.

WITH popular_genre AS (
SELECT c.country, g.name AS genre_name,
COUNT(*) AS total_purchases,
ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY COUNT(*) DESC) AS rnk
FROM invoice_line il
JOIN invoice i ON i.invoice_id = il.invoice_id
JOIN customer c ON c.customer_id = i.customer_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id
GROUP BY c.country, g.name
)
SELECT *
FROM popular_genre
WHERE rnk = 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH Top_Customer_Per_Country AS 
(
SELECT c.customer_id, c.first_name, c.last_name, i.billing_country,
SUM(i.total) AS total_spending,
ROW_NUMBER() over(partition by i.billing_country ORDER BY SUM(i.total) DESC) AS rank_in_country
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
)
SELECT * FROM Top_Customer_Per_Country
WHERE rank_in_country = 1;
