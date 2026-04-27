SELECT * FROM zepto_v2;

-- DATA EXPLORATION

-- count of rows
SELECT COUNT(*) from zepto_v2;

--Sample DATA
select * from zepto_v2
LIMIT 10;

--null values
select * from zepto_v2
WHERE name is null
or
category is null
or
mrp is null
or
discountpercent is null
or
availablequantity is null
or
discountedsellingprice is null
or
weightingms is null
or
outofstock is null
or
quantity is null;

--Different product category
select distinct category
from zepto_v2;

--adding serial_id coloum
ALTER TABLE zepto_v2
ADD COLUMN no_id SERIAL PRIMARY KEY;

--product in stock Vs out of stock
select outofstock, COUNT(no_id)
from zepto_v2
group by outofstock;

--product name present multiple time
select name, count(no_id) as "Numbers"
from zepto_v2
group by name
having count(no_id)>1
order by count(no_id) DESC;

--DATA CLEANING

--products with price 0
SELECT * FROM zepto_v2
WHERE mrp::int = 0 OR discountedsellingprice::int = 0;

DELETE from zepto_v2
where mrp::int = 0;

--Convert into rupees
UPDATE zepto_v2
SET 
  mrp = mrp::float / 100.0,
  discountedsellingprice = discountedsellingprice::float / 100.0;

SELECT mrp, discountedsellingprice from zepto_v2; 

/*
There's a small mistake here the data in my source file has numbers stored as text
so I have to keep changing the data type in SQL every time.
Okay, Now first i change the data type of all numbers
*/

--Changing datatype
ALTER TABLE zepto_v2
ALTER COLUMN mrp TYPE numeric USING mrp::numeric;

ALTER TABLE zepto_v2
ALTER COLUMN discountpercent TYPE numeric USING discountpercent::numeric;

ALTER TABLE zepto_v2
ALTER COLUMN availablequantity TYPE integer USING availablequantity::integer;

ALTER TABLE zepto_v2
ALTER COLUMN discountedsellingprice TYPE numeric USING discountedsellingprice::numeric;

ALTER TABLE zepto_v2
ALTER COLUMN weightingms TYPE numeric USING weightingms::numeric;

ALTER TABLE zepto_v2
ALTER COLUMN quantity TYPE integer USING quantity::integer;

--BUSINESS INSIGHT QUERIES

-- Q1. Find the top 10 best value products based on the discount percentage.
select distinct name, mrp, discountpercent
from zepto_v2
order by discountpercent desc
limit 10;

-- Q2. List products with a high MRP that are currently out of stock.
SELECT DISTINCT name, mrp
from zepto_v2
where outofstock = TRUE and mrp>300
order by mrp desc;

ALTER TABLE zepto_v2
ALTER COLUMN outofstock TYPE boolean -- Converting text to boolean datatype
USING outofstock::boolean;


-- Q3. Calculate the estimated revenue for each category.
SELECT category, sum(discountedsellingprice*availablequantity) as total_revenue
from zepto_v2
group by category
order by total_revenue desc;

-- Q4. Find all products where MRP is greater than ₹500 and the discount is less than 10%.
SELECT DISTINCT name, mrp, discountpercent
from zepto_v2
where mrp > 500 and discountpercent < 10
order by mrp desc, discountpercent DESC;

-- Q5. Identify the top 5 categories with the highest average discount percentage.
SELECT category,
ROUND(AVG(discountpercent),2) AS avg_discount
from zepto_v2
group by category
order by avg_discount desc
limit 5;

-- Q6. Calculate the price per gram for products over 100g and sort by best value.
select distinct name, weightingms, discountedsellingprice, ROUND(discountedsellingprice/weightingms,2)
as price_per_gram
from zepto_v2
where weightingms >= 100
order by price_per_gram;

-- Q7. Group products into categories such as Low, Medium and Bulk.
SELECT DISTINCT 
name,
weightInGms AS weight_in_grams,
CASE 
WHEN weightInGms < 1000 THEN 'Low'
WHEN weightInGms < 5000 THEN 'Medium'
ELSE 'Bulk'
END AS weight_category
FROM zepto_v2;

-- Q8. Calculate the total inventory weight per category.

SELECT 
category,
SUM(weightInGms* availableQuantity) AS total_weight
FROM zepto_v2
GROUP BY category
ORDER BY total_weight DESC;




