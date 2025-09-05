SELECT * FROM "SHOP"."PUBLIC"."COFFEESHOP"
LIMIT 10;

---DATA CLEANING / UNDERSTANDING THE DATA
--checking for missing values/nulls

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
FROM "SHOP"."PUBLIC"."COFFEESHOP";

--checking for duplicates

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
  COUNT(*) AS duplicate_count
FROM "SHOP"."PUBLIC"."COFFEESHOP"
GROUP BY 
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
  product_detail
HAVING COUNT(*) > 1;


--changing the format of the digit in unit price , to .
--not working

UPDATE shop.public.coffeeshop
SET unit_price = CAST(REPLACE(unit_price, ',', '.') AS DECIMAL(10,2));


--calulating the total amount and creating a new column for it

ALTER TABLE shop.public.coffeeshop 
ADD COLUMN total_amount DECIMAL(10,2); --creating a new column total amount

UPDATE shop.public.coffeeshop
SET total_amount = TO_NUMBER(REPLACE(unit_price, ',','.')) * transaction_qty; --populating the new coulmn

--checking for opening and closing time of store
--January 1st to June the 30th

SELECT MIN(transaction_date),
       MAX(transaction_date)
FROM shop.public.coffeeshop;
 
 --checking min and max time for time bracket
 --06:00 am to 20:59 pm

SELECT MIN(transaction_time),
       MAX(transaction_time)
FROM shop.public.coffeeshop;

--Counting total number of transactions
--149116

SELECT COUNT(transaction_id) AS total_transactions  
FROM shop.public.coffeeshop;





SELECT
     store_location,
     product_category,
     product_type,
     product_detail,

-- breaking down transactional date into date, day of week and month name.
    TO_DATE(transaction_date, 'YYYY/MM/DD') AS T_Date,
    DAYNAME(T_Date) AS Days_of_the_week,
    MONTHNAME(T_Date) AS Month_Name,
    TO_CHAR(transaction_time, 'HH24:MI') AS T_Time,
    
--creating a 1H time interval   
    DATE_TRUNC('hour', transaction_time) AS transaction_time_bucket,
    
--total number of transactions  
    COUNT(*) AS total_transactions,
    COUNT(product_id) unique_products_sold,
    SUM(transaction_qty) AS total_sales,
    SUM(transaction_qty * TO_NUMBER(REPLACE(unit_price, ',','.'))) AS total_amount,

--creating a time bucket  
     CASE 
     WHEN DATE_PART('hour', transaction_time) BETWEEN 6 AND 9 THEN '6am - 9am Morning'
     WHEN DATE_PART('hour', transaction_time) BETWEEN 10 AND 13 THEN '10am - 1pm Midday'
     WHEN DATE_PART('hour', transaction_time) BETWEEN 14 AND 17 THEN '2pm - 5pm Afternoon'
     WHEN DATE_PART('hour', transaction_time) BETWEEN 6 AND 20 THEN '6pm -20pm Evening'
    ELSE 'Out of Range' 
END AS time_bucket  
FROM shop.public.coffeeshop
GROUP BY ALL;