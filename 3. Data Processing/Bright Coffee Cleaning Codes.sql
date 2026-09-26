-- Databricks notebook source
-- DBTITLE 1,Data Cleaning Queries
-- Retrieving a sample data from the dataset
SELECT *
FROM workspace.default.bright_coffee_dataset
LIMIT 100;

-----------------------------------------------------------------
DESCRIBE workspace.default.bright_coffee_dataset;

-----------------------------------------------------------------
--checking duplicate transaction IDs
SELECT 
    transaction_id,
    COUNT(*) AS duplicate_count
FROM workspace.default.bright_coffee_dataset
GROUP BY transaction_id
HAVING COUNT(*) > 1;
-----------------------------------------------------------------
--Checking and replacing missing values

--Store location
SELECT DISTINCT store_location,
    CASE
        WHEN store_location = ' ' THEN 'Unknown'
        WHEN store_location = 'None' THEN 'Unknown'
        WHEN store_location IS NULL THEN 'Unknown'
    ELSE store_location
END AS Cleaned_store_location
FROM workspace.default.bright_coffee_dataset;

--Product category
SELECT DISTINCT product_category,
    CASE
        WHEN product_category = ' ' THEN 'Unknown'
        WHEN product_category = 'None' THEN 'Unknown'
        WHEN product_category IS NULL THEN 'Unknown'
    ELSE product_category
END AS Cleaned_Product_category
FROM workspace.default.bright_coffee_dataset;

--Product type
SELECT DISTINCT product_type,
    CASE
        WHEN product_type = ' ' THEN 'Unknown'
        WHEN product_type = 'None' THEN 'Unknown'
        WHEN product_type IS NULL THEN 'Unknown'
    ELSE product_type
END AS Cleaned_product_type
FROM workspace.default.bright_coffee_dataset;

--Product detail
SELECT DISTINCT product_detail,
    CASE
        WHEN product_detail = ' ' THEN 'Unknown'
        WHEN product_detail = 'None' THEN 'Unknown'
        WHEN product_detail IS NULL THEN 'Unknown'
    ELSE product_detail
END AS Cleaned_product_detail
FROM workspace.default.bright_coffee_dataset;
-----------------------------------------------------------------
--Checking the date column
SELECT DISTINCT transaction_date
FROM workspace.default.bright_coffee_dataset;
-----------------------------------------------------------------
-- Extracting the dates using DATE Functions (day,month,year,event day)
SELECT
    transaction_id,
    transaction_date,
    DAYNAME(TO_DATE(transaction_date))AS Day_name, -- Extract the day name 
    MONTHNAME(TO_DATE(transaction_date)) AS Month_name, -- Extracts the month name
    YEAR(TO_DATE(transaction_date)) AS Event_year, -- Extracts the year value
    DAY(TO_DATE(transaction_date)) AS Event_day, -- Extracts the day value
    CASE 
        WHEN DAYNAME(TO_DATE(transaction_date)) IN ('Sat', 'Sun') THEN '02. Weekend' 
        ELSE '01. Weekday' 
    END AS day_classification
FROM workspace.default.bright_coffee_dataset;
-----------------------------------------------------------------
--creating month column 
SELECT DATE_FORMAT(transaction_date,'MMMM') AS Month_name
FROM workspace.default.bright_coffee_dataset;
-----------------------------------------------------------------
--Classifying days of the week
SELECT
CASE
WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Weekend'
WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Weekend'
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Weekday'
WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Weekday'
WHEN DAYOFWEEK(transaction_date) = 4 THEN 'weekday'
WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Weekday'
WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Weekday'
ELSE 'Unknown'
END AS Day_classification
FROM workspace.default.bright_coffee_dataset;

--Checking the days of the week
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
-----------------------------------------------------------------
--checking transaction_time column
SELECT
MIN(DATE_FORMAT(transaction_time, 'HH:mm:ss')) AS earliest_time,
MAX(DATE_FORMAT(transaction_time, 'HH:mm:ss')) AS latest_time
FROM workspace.default.bright_coffee_dataset;

SELECT
DATE_FORMAT(transaction_time, 'HH:mm:ss') AS time_of_transaction
FROM workspace.default.bright_coffee_dataset
ORDER BY time_of_transaction ASC;
-----------------------------------------------------------------
--Grouping transactions into 3 hour interval
SELECT
transaction_time,
HOUR(transaction_time) AS transaction_hour,
CASE
WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN '06:00–09:00'
WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN '09:00–12:00'
WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN '12:00–15:00'
WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN '15:00–18:00'
WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN '18:00–21:00'
END AS Transaction_time_bucket
FROM workspace.default.bright_coffee_dataset;
---------------------------------------------------------------------
--creating time buckets
SELECT *,
CASE 
WHEN HOUR(transaction_time) BETWEEN 6 AND 10 THEN 'Morning' 
WHEN HOUR(transaction_time) BETWEEN 11 AND 14 THEN 'Midday'
WHEN HOUR(transaction_time) BETWEEN 15 AND 18 THEN 'Afternoon' 
WHEN HOUR(transaction_time) BETWEEN 19 AND 22 THEN 'Evening'  
ELSE 'Night'
END AS Time_bucket 
FROM workspace.default.bright_coffee_dataset
ORDER BY Time_bucket ASC;
-----------------------------------------------------------------
--Creating transaction quantity price band column 
SELECT
CASE 
    WHEN ROUND(unit_price * transaction_qty) >= 4 THEN 'high'
    WHEN ROUND(unit_price * transaction_qty) BETWEEN 2 AND 3.99 THEN 'Medium'
    ELSE 'Low'
END AS quantity_price_band
FROM workspace.default.bright_coffee_dataset;
-----------------------------------------------------------------
--Creating total amount column
SELECT 
product_category,
transaction_qty,
unit_price,
ROUND(CAST(REPLACE(CAST(unit_price AS STRING), ',' , '.') AS DOUBLE) * CAST(transaction_qty AS DOUBLE),2) AS total_amount
FROM workspace.default.bright_coffee_dataset
GROUP BY all;

--Creating total amount band
SELECT product_category,
transaction_qty,
unit_price,
ROUND(unit_price * transaction_qty,2) AS total_amount,
CASE 
WHEN ROUND(unit_price * transaction_qty,2) >= 20 THEN 'High'
WHEN ROUND(unit_price * transaction_qty,2) BETWEEN 10 AND 19.99 THEN 'Medium'
WHEN ROUND(unit_price * transaction_qty,2) BETWEEN 5 AND 9.99 THEN 'Low'
WHEN ROUND(unit_price * transaction_qty,2) BETWEEN 0 AND 4.99 THEN 'Very Low'
END AS total_amount_band
FROM workspace.default.bright_coffee_dataset
GROUP BY all;
-----------------------------------------------------------------
--Totat units sold by product type
SELECT product_type,
SUM(transaction_qty) AS total_units_sold
FROM workspace.default.bright_coffee_dataset
GROUP BY product_type
ORDER BY total_units_sold DESC;


-- COMMAND ----------

