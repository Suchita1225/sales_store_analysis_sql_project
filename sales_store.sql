DROP TABLE IF exists sales_store;
CREATE TABLE sales_store(
transaction_id	VARCHAR(50),
customer_id	 VARCHAR(50) ,
customer_name	VARCHAR(50),
customer_age	INT,
gender	VARCHAR (10),
product_id	VARCHAR(10),
product_name	VARCHAR (50),
product_category	VARCHAR(30),
quantity	INT,
price	FLOAT,
payment_mode	VARCHAR(30),
purchase_date	DATE,
time_of_purchase	TIME,
status VARCHAR(20)
);

SELECT * FROM sales_store;

--DATA CLEANING
COPY sales_store	
FROM 'C:\Users\suchi\Desktop\Sql\Kaggle Sales Sql Project\sales_store.csv'
DELIMiTER ';'
CSV HEADER;


WITH CTE AS(SELECT * ,
ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER bY transaction_id)as row_num
FROM sales_store)

--DELETE FROM sales_store
--WHERE ctid IN ( SELECT ctid FROM cte WHERE row_num > 1
--);


SELECT *
FROM CTE
WHERE transaction_id IN('TXN240646','TXN342128','TXN626832','TXN745076','TXN832908','TXN855235','TXN981773');



----- Check NULL Values
SELECT *
FROM sales_store
WHERE transaction_id is Null;

DELETE FROM sales_store
WHERE transaction_id is Null;

SELECT *
FROM sales_store
WHERE customer_id is Null;

SELECT *
FROM sales_store
WHERE customer_name = 'Ehsaan Ram';

UPDATE sales_store
SET customer_id ='CUST9494'
WHERE transaction_id = 'TXN977900';

SELECT *
FROM sales_store
WHERE customer_name = 'Damini Raju';

UPDATE sales_store
SET customer_id ='CUST1401'
WHERE transaction_id = 'TXN985663';

SELECT *
FROM sales_store
WHERE customer_name is Null;

SELECT *
FROM sales_store
WHERE customer_id = 'CUST1003';

UPDATE sales_store
SET customer_name = 'Mahika Saini' , customer_age = 35, gender ='Male'
WHERE transaction_id = 'TXN432798';

SELECT *
FROM sales_store
WHERE status is Null;

UPDATE sales_store
SET gender ='Male'
WHERE gender ='M';

UPDATE sales_store
SET gender ='Female'
WHERE gender ='F';

SELECT DISTINCT payment_mode
FROM sales_store;

UPDATE sales_store
SET payment_mode ='Credit Card'
WHERE payment_mode ='CC';

SELECT * FROM sales_store;

--Q1) What are the top 5 most selling products by quantity
SELECT product_name, SUM(quantity)As total_quantity
FROM sales_store
WHERE status ='delivered'
GROUP BY product_name
ORDER BY total_quantity desc
LIMIT 5;

--Q2)Which products are most frequently cancelled
SELECT product_name, status, Count(status)As total_cancelled
FROM sales_store
WHERE status = 'cancelled'
GROUP BY product_name, status
ORDER BY total_cancelled desc
LIMIT 5;

--Q3 What time of the day has the highest number of purchases?
WITH orders As (SELECT COUNT(transaction_id)As total_orders,
EXTRACT (HOUR from time_of_purchase)As hour_of_day
FROM sales_store
GROUP BY hour_of_day),

 order_time AS (SELECT total_orders, hour_of_day,
 CASE WHEN hour_of_day BETWEEN 0 and 5 THEN 'Night'
 WHEN hour_of_day BETWEEN 6 and 11 THEN 'Morning'
 WHEN hour_of_day BETWEEN 12 and 17 THEN 'Afternoon'
 WHEN hour_of_day BETWEEN 18 and 23 THEN 'Evening'
END AS order_time
 FROM orders)

 SELECT order_time, SUM(total_orders)As total_orders
 FROM order_time
 GROUP BY order_time
 ORDER BY total_orders desc;

--Q5) Top 5 Highest spending customers
SELECT customer_name , Sum(price*quantity) As total_spent,
DENSE_RANK() OVER (ORDER BY SUM(price*quantity) DESC)As highest_spending
FROM sales_store
GROUP BY customer_name
LIMIT 5;

--Q6) Which product category generates the highest revenue
SELECT product_category , SUM(price * quantity) As total_revenue,
DENSE_RANK() OVER(ORDER BY SUM(price*quantity) DESC)AS highest_revenue
FROM sales_store
GROUP BY product_category;

--Q7)WHat is the return/cancellation rate per product category
SELECT product_category, ROUND(
COUNT (CASE WHEN status ='cancelled' THEN 1 END)*100.0/
COUNT (*) ,2)As cancelled_percent
FROM sales_store
GROup BY product_category;

--Return
SELECT product_category, ROUND(
COUNT(CASE WHEN status ='returned' THEN 1 END)*100.0/
COUNT(*) ,2) AS cancelled_percent
FROM sales_store
GROUP BY product_category
ORDER BY cancelled_percent DESC;

--Q7) What is the most preferred payment mode?
SELECT payment_mode ,Count(payment_mode)As total_purchases
FROM sales_store
GROUP BY payment_mode
ORDER BY total_purchases desc;

--Q8)How does age group affect purchasing behaviour?
SELECT SUM(price* quantity)As total_spends,
CASE WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
WHEN customer_age BETWEEN 36 AND 45 THEN '36-45'
WHEN customer_age BETWEEN 46 AND 55 THEN '46-55'
ELSE '60+'
END AS age_group
FROM sales_store
GROUP BY CASE WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
WHEN customer_age BETWEEN 36 AND 45 THEN '36-45'
WHEN customer_age BETWEEN 46 AND 55 THEN '46-55'
ELSE '60+'
END
ORDER BY SUM(price* quantity) DESC;

--Q9) What is the monthly sales trend
SELECT SUM(price* quantity)As total_sales,
EXTRACT (Month from purchase_date) As month,
EXTRACT (Year from purchase_date) AS year
FROM sales_store
GROUP BY EXTRACT (Month from purchase_date),EXTRACT (Year from purchase_date)
ORDER BY total_sales DESC;


--Q10) Are Certain genders buying more specific product categories?
SELECT gender,product_category, Count(product_category)As total_purchases
FROM sales_store
GROUP BY gender,product_category
ORDER BY gender;

