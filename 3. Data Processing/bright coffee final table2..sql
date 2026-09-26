-- Databricks notebook source
CREATE OR REPLACE TABLE workspace.default.bright_coffee_cleaned_table1 AS
SELECT
    transaction_id,
    transaction_date,
    transaction_time,
    transaction_qty,
    store_id,
    store_location,
    product_id,
    unit_price,
    product_category,
    product_type,
    product_detail,

        CASE
        WHEN store_location = ' ' THEN 'Unknown'
        WHEN store_location = 'None' THEN 'Unknown'
        WHEN store_location IS NULL THEN 'Unknown'
    ELSE store_location
END AS Cleaned_store_location,

    CASE
        WHEN product_category = ' ' THEN 'Unknown'
        WHEN product_category = 'None' THEN 'Unknown'
        WHEN product_category IS NULL THEN 'Unknown'
    ELSE product_category
END AS Cleaned_Product_category,

    CASE
        WHEN product_type = ' ' THEN 'Unknown'
        WHEN product_type = 'None' THEN 'Unknown'
        WHEN product_type IS NULL THEN 'Unknown'
    ELSE product_type
END AS Cleaned_product_type,

    CASE
        WHEN product_detail = ' ' THEN 'Unknown'
        WHEN product_detail = 'None' THEN 'Unknown'
        WHEN product_detail IS NULL THEN 'Unknown'
    ELSE product_detail
END AS Cleaned_product_detail,

    DAYNAME(TO_DATE(transaction_date)) AS Day_name,
    YEAR(TO_DATE(transaction_date)) AS Event_year,
    DAY(TO_DATE(transaction_date)) AS Event_day,

DATE_FORMAT(transaction_date,'MMMM') AS Month_name,

    CASE 
    WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Sunday'
    WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
    WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
    WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
    WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
    WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
    WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
END AS Day_of_week,

    CASE
    WHEN DAYOFWEEK(transaction_date) = 1 THEN 'Weekend'
    WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Weekend'
    WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Weekday'
    WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Weekday'
    WHEN DAYOFWEEK(transaction_date) = 4 THEN 'weekday'
    WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Weekday'
    WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Weekday'
    ELSE 'Unknown'
END AS Day_classification,

    CASE 
    WHEN HOUR(transaction_time) BETWEEN 6 AND 10 THEN 'Morning' 
    WHEN HOUR(transaction_time) BETWEEN 11 AND 14 THEN 'Midday'
    WHEN HOUR(transaction_time) BETWEEN 15 AND 18 THEN 'Afternoon' 
    WHEN HOUR(transaction_time) BETWEEN 19 AND 22 THEN 'Evening'  
    ELSE 'Night'
END AS Time_bucket,

 HOUR(transaction_time) AS Hour_of_day,

    CASE
    WHEN HOUR(transaction_time) BETWEEN 6 AND 8 THEN '06:00–09:00'
    WHEN HOUR(transaction_time) BETWEEN 9 AND 11 THEN '09:00–12:00'
    WHEN HOUR(transaction_time) BETWEEN 12 AND 14 THEN '12:00–15:00'
    WHEN HOUR(transaction_time) BETWEEN 15 AND 17 THEN '15:00–18:00'
    WHEN HOUR(transaction_time) BETWEEN 18 AND 20 THEN '18:00–21:00'
END AS `3hour_time_bucket`,

    ROUND(CAST(REPLACE(CAST(unit_price AS STRING), ',' , '.') AS DOUBLE) * CAST(transaction_qty AS DOUBLE), 2) AS total_amount,

    CASE
    WHEN unit_price * transaction_qty >= 20
    THEN 'Very High'
    WHEN unit_price * transaction_qty >= 15
    THEN 'High'
    WHEN unit_price * transaction_qty >= 10
    THEN 'Medium'
    WHEN unit_price * transaction_qty >= 5
    THEN 'Low'
    ELSE 'Very Low'
END AS total_amount_band

FROM workspace.default.bright_coffee_cleaned_table1;

SELECT*
FROM workspace.default.bright_coffee_cleaned_table1;