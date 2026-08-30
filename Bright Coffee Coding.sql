-- Databricks notebook source
-- Retrieving a sample data from the dataset
SELECT *
FROM workspace.default.bright_coffee_dataset
LIMIT 100;
-----------------------------------------------------------------
DESCRIBE workspace.default.bright_coffee_dataset;
-----------------------------------------------------------------
--Viewing all product category
SELECT DISTINCT product_category
FROM workspace.default.bright_coffee_dataset;
-------------------------------------------------------------------
--Cleaning product category column
SELECT DISTINCT product_category,
CASE
WHEN product_category = ' ' THEN 'Unknown'
WHEN product_category = 'None' THEN 'Unknown'
WHEN product_category IS NULL THEN 'Unknown'
ELSE product_category
END AS Product_cat
FROM workspace.default.bright_coffee_dataset;
-----------------------------------------------------------------
--Viewing product type column
SELECT DISTINCT product_type
FROM workspace.default.bright_coffee_dataset;
---------------------------------------------------------------
--Cleaning product type
SELECT DISTINCT product_type,
CASE
WHEN product_type = ' ' THEN 'Unknown'
WHEN product_type = 'None' THEN 'Unknown'
WHEN product_type IS NULL THEN 'Unknown'
ELSE product_type
END AS Product_typ
FROM workspace.default.bright_coffee_dataset;
-----------------------------------------------------------------
--Checking duplicates
SELECT transaction_id,
        COUNT(*) AS Duplicate_cnt
FROM workspace.default.bright_coffee_dataset
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY Duplicate_cnt DESC;
--------------------------------------------------------------------
SELECT COUNT(*) AS duplicates
FROM workspace.default.bright_coffee_dataset
GROUP BY transaction_id
HAVING COUNT(*)>1;
-----------------------------------------------------------------
--Creating the revenue/total amount column
SELECT
product_category,
product_type,
product_detail,
transaction_qty,
unit_price,
(transaction_qty * unit_price) AS total_amount
FROM workspace.default.bright_coffee_dataset;
----------------------------------------------------------------
--Checking the date column
SELECT DISTINCT transaction_date
FROM workspace.default.bright_coffee_dataset;
---------------------------------------------------------------------
--Checking month name
SELECT DISTINCT DATE_FORMAT(transaction_date,'MMMM') AS month_name
FROM workspace.default.bright_coffee_dataset;
-------------------------------------------------------------
--Classifying days of the week
SELECT
CASE
WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Weekend'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Weekend'
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Weekday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Weekday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'weekday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Weekday'
ELSE 'Unknown'
END AS Day_classification
FROM workspace.default.bright_coffee_dataset;

--Checking the days of the weeks
SELECT
    CASE 
    WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Sunday'
    WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
    WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
    WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
    WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
    WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
    WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
    END AS Day_of_week
FROM workspace.default.bright_coffee_dataset;

------------------------------------------------------------
--Checking transaction time column
SELECT DISTINCT transaction_time
FROM workspace.default.bright_coffee_dataset;

SELECT DISTINCT date_format(transaction_time, 'HH:mm:ss') AS time
FROM workspace.default.bright_coffee_dataset
ORDER BY time ASC;

SELECT*
FROM workspace.default.bright_coffee_dataset
WHERE HOUR (transaction_time) = 6
ORDER BY transaction_time;

SELECT*
FROM workspace.default.bright_coffee_dataset
WHERE HOUR (transaction_time) = 18
ORDER BY transaction_time;

SELECT
transaction_time,
HOUR(transaction_time) AS transaction_hour
FROM workspace.default.bright_coffee_dataset
LIMIT 10;

SELECT DISTINCT DATE_FORMAT(transaction_time,'HH:MM:SS')
FROM workspace.default.bright_coffee_dataset;

SELECT
transaction_time,
HOUR(transaction_time) AS transaction_hour,
CASE
WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN '06:00–09:00'
WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN '09:00–12:00'
WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN '12:00–15:00'
WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN '15:00–18:00'
WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN '18:00–21:00'
END AS transaction_time_bucket
FROM workspace.default.bright_coffee_dataset;
------------------------------------------------------------------------
--Creating time bucket
SELECT 
CASE 
WHEN HOUR(transaction_time) BETWEEN 7 AND 9 THEN 'Morning' 
WHEN HOUR(transaction_time) BETWEEN 10 AND 12 THEN 'Afternoon' 
WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Evening' 
WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Night' 
WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours' 
ELSE 'Night' 
END AS Time_bucket 
FROM workspace.default.bright_coffee_dataset; 
------------------------------------------------------------------------
--Revenue
SELECT transaction_qty, ROUND(SUM (CAST(transaction_qty AS DOUBLE) * CAST (REPLACE(unit_price,',','.')AS DOUBLE)),0) AS Total_Amount 
FROM workspace.default.bright_coffee_dataset
GROUP BY transaction_qty; 
------------------------------------------------------------------------
--Analysing revenue by time bucket
SELECT 
CASE 
WHEN HOUR(transaction_time) BETWEEN 7 AND 9 THEN 'Morning' 
WHEN HOUR(transaction_time) BETWEEN 10 AND 12 THEN 'Afternoon' 
WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Evening' 
WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Night' 
WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours' 
ELSE 'Night' 
END AS Time_bucket, SUM(unit_price * transaction_qty) AS Total_revenue 
FROM workspace.default.bright_coffee_dataset 
GROUP BY Time_bucket 
ORDER BY Total_revenue DESC;
-------------------------------------------------------------------------
--checking total revenue per store location 
SELECT store_location, SUM(unit_price * transaction_qty) AS Total_revenue 
FROM workspace.default.bright_coffee_dataset 
GROUP BY store_location 
ORDER BY Total_revenue DESC;
---------------------------------------------------------------------------
--checking high performing and low performing products
SELECT product_category, SUM(unit_price * transaction_qty) AS Total_revenue 
FROM workspace.default.bright_coffee_dataset 
GROUP BY product_category 
ORDER BY Total_revenue DESC

SELECT product_type, SUM(unit_price * transaction_qty) AS Total_revenue 
FROM workspace.default.bright_coffee_dataset
GROUP BY product_type
ORDER BY Total_revenue DESC;
----------------------------------------------------------------------------------
--Cheching earliest and latest dates
SELECT MIN(transaction_date) AS Earliest_date, MAX(transaction_date) AS Latest_date
FROM workspace.default.bright_coffee_dataset;
------------------------------------------------------------------------------------
--Totat units sold by product type
SELECT product_type,
SUM(transaction_qty) AS total_units_sold
FROM workspace.default.bright_coffee_dataset
GROUP BY product_type
ORDER BY total_units_sold DESC;
----------------------------------------------------------------------------------------
--Grouping product type and time bucket
SELECT 
CASE 
WHEN HOUR(transaction_time) BETWEEN 7 AND 9 THEN 'Morning' 
WHEN HOUR(transaction_time) BETWEEN 10 AND 12 THEN 'Afternoon' 
WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Evening' 
WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Night' 
WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours' 
ELSE 'Night' 
END AS Time_bucket, 
product_type,
SUM(transaction_qty) AS total_units_sold,
SUM(unit_price * transaction_qty) AS total_revenue
FROM workspace.default.bright_coffee_dataset
GROUP BY time_bucket, product_type
ORDER BY time_bucket, total_units_sold DESC;
------------------------------------------------------------
--Checking the Sales Value Category
SELECT
MAX (transaction_qty * unit_price) AS High_sales_value,
MIN (transaction_qty * unit_price) AS Low_sales_value
FROM workspace.default.bright_coffee_dataset;
-------------------------------------------------------------
SELECT
CASE 
    WHEN (unit_price * transaction_qty) > 10000 THEN 'high'
    WHEN (unit_price * transaction_qty) BETWEEN 5000 AND 10000 THEN 'Medium'
    ELSE 'Very Low'
END AS Sales_Value_Category
FROM workspace.default.bright_coffee_dataset;
------------------------------------------------------------
--Checking quantity category
SELECT
CASE 
    WHEN transaction_qty =1 THEN 'low'
    WHEN transaction_qty BETWEEN 2 AND 3 THEN 'Medium'
    ELSE 'high'
END AS Quantity_Category
FROM workspace.default.bright_coffee_dataset;

SELECT
CASE 
    WHEN transaction_qty BETWEEN 1 AND 50 THEN 'low'
    WHEN transaction_qty BETWEEN 50 AND 100 THEN 'Medium'
    ELSE 'Very Low'
    END AS Quantity_Category
FROM workspace.default.bright_coffee_dataset;
--------------------------------------------------------
--Creating CTE
CREATE OR REPLACE TABLE IF NOT EXISTS   
workspace.default.bright_coffee_dataset;
AS
SELECT 
transaction_id,
CAST (transaction_date AS DATE) AS transaction_date,
CASE 
DAYOFWEEK(CAST(transaction_date AS DATE)) 
WHEN 1 THEN 'Sunday'
WHEN 2 THEN 'Monday'
WHEN 3 THEN 'Tuesday'
WHEN 4 THEN 'Wednesday'
WHEN 5 THEN 'Thursday'
WHEN 6 THEN 'Friday'
WHEN 7 THEN 'Saturday'
END AS day_name,
DAYOFWEEK(CAST(transaction_date AS DATE)) AS day_number,
CASE
WHEN
DATE_FORMAT (CAST(transaction_date AS DATE)) MMMM AS month_name,
MONTH (CAST(transaction_date AS DATE)) AS month_number,
YEAR (CAST(transaction_date AS DATE)) AS year,
CASE
WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN '06:00–09:00'
WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN '09:00–12:00'
WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN '12:00–15:00'
WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN '15:00–18:00'
WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN '18:00–21:00'
END AS time_of_day,

CASE 
WHEN HOUR(transaction_time) BETWEEN 7 AND 9 THEN 'Morning'
WHEN HOUR(transaction_time) BETWEEN 10 AND 12 THEN 'Afternoon'
WHEN HOUR(transaction_time) BETWEEN 13 AND 15 THEN 'Evening'
WHEN HOUR(transaction_time) BETWEEN 16 AND 18 THEN 'Night'
WHEN HOUR(transaction_time) >= 19 AND HOUR(transaction_time) <= 20 THEN 'Closing hours'
ELSE 'Night'
END AS Time_bucket
transcation_qty AS transaction_qty,
store_id AS store_id,
product_id AS product_id,
product_type AS product_type,
product_detail AS product_detail
CAST (
REPLACED (CAST(unit_price AS STRING), ',', '.') 
AS DECIMAL(10,2)) AS unit_price,

CAST transaction_qty * CAST(unit_price AS DECIMAL(10,2)) AS STRING 
AS DECIMAL(10,2) AS total_amount
FROM workspace.default.bright_coffee_dataset;


-----------------------------------------------------------------------------------

----Creating a CTE table
--total revenue
--total sales
--sales by time bucket
--total unit cold by product category
--total uniy sold by product type
--screen time bucket
--month name
--day name
--day classification


