SELECT * FROM "BUSI"."PUBLIC"."BRIGHT_COFFEE_SHOP"
LIMIT 10;
 
---DATA CLEANING
--missing values/nulls

SELECT
     SUM( CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS transaction_id_missing,
     SUM( CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS transaction_id_missing,
     SUM( CASE WHEN transaction_time IS NULL THEN 1 ELSE 0 END) AS transaction_id_missing,
     SUM( CASE WHEN transaction_qty IS NULL THEN 1 ELSE 0 END) AS transaction_qty_missing,
     SUM( CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS store_id_missing,
     SUM( CASE WHEN store_location IS NULL THEN 1 ELSE 0 END) AS store_location_missing,
     SUM( CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS pro_id_missing,
     SUM( CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price_missing,
     SUM( CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) AS pro_cate_missing,
     SUM( CASE WHEN product_type IS NULL THEN 1 ELSE 0 END) AS pro_type_missing,
     SUM( CASE WHEN product_detail IS NULL THEN 1 ELSE 0 END) AS pro_detail_missing,
FROM "BUSI"."PUBLIC"."BRIGHT_COFFEE_SHOP";

--checking for duplicates

SELECT *,
       COUNT(*) AS duplicate_count
FROM "BUSI"."PUBLIC"."BRIGHT_COFFEE_SHOP" 
GROUP BY transaction_id, transaction_date,transaction_time,transaction_qty,store_id,store_location,product_id,unit_price,product_category,product_type,product_detail
HAVING COUNT(*) > 1;



--changing the format of the digit in unit price , to .

UPDATE bright_coffee_shop
SET unit_price = CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2)); 

--calulating the total amount and creating a new column for it

ALTER TABLE bright_coffee_shop 
ADD COLUMN total_amount DECIMAL(10,2); --creating a new column total amount

UPDATE bright_coffee_shop 
SET total_amount = unit_price * transaction_qty; --populating the new coulmn

--date info

SELECT MIN(transaction_date),
       MAX(transaction_date)
FROM bright_coffee_shop;
 

 --time bracket

SELECT MIN(transaction_time),
       MAX(transaction_time)
FROM "BUSI"."PUBLIC"."BRIGHT_COFFEE_SHOP" ;

--Count total number of transactions

SELECT COUNT(transaction_id) AS total_transactions  
FROM bright_coffee_shop;

--adding new column transaction_time_but with 1H intervals and time bucket

SELECT
     store_location,
     product_category,
     product_type,
     product_detail,
    TO_DATE(transaction_date, 'YYYY/MM/DD') AS T_Date,
    DAYNAME(T_Date) AS Days_of_the_week,
    MONTHNAME(T_Date) AS Month_Name,
    TO_CHAR(transaction_time, 'HH24:MI') AS T_Time,
    DATE_TRUNC('hour', transaction_time) AS transaction_time_bucket, --creates a 1H time interval
    COUNT(*) AS total_transactions,
    COUNT(product_id) unique_products_sold,
    SUM(transaction_qty) AS total_sales,
    SUM(transaction_qty * TO_NUMBER(REPLACE(unit_price, ',','.'))) AS toatal_amount,
    CASE  
    WHEN DATE_PART('hour', transaction_time) BETWEEN 6 AND 9 THEN 'Early Morning'  
    WHEN DATE_PART('hour', transaction_time) BETWEEN 10 AND 13 THEN 'Mid-Morning'  
    WHEN DATE_PART('hour', transaction_time) BETWEEN 14 AND 17 THEN 'Afternoon'  
    WHEN DATE_PART('hour', transaction_time) BETWEEN 18 AND 20 THEN 'Evening'  
    ELSE 'Unknown'  
END AS time_bucket  
FROM bright_coffee_shop
GROUP BY ALL;


