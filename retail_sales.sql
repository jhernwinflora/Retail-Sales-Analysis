CREATE DATABASE retail_sales_data;

DROP TABLE IF EXISTS sales_data;
CREATE TABLE sales_data
(
	order_id	TEXT,
	order_date	 TEXT,
	customer_id	TEXT,
	gender	TEXT,
	age	TEXT,
	region TEXT,
	city	TEXT,
	category	TEXT,
	product	TEXT,
	unit_price	INT,
	quantity	INT,
	discount	FLOAT,
	sales	DECIMAL(10,2),
	profit	DECIMAL(10,2),
	channel	TEXT,
	payment_method TEXT,	
	rating INT
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/jhern/OneDrive/Documents/JJ/SQL + POWERBI/REAL/India Retail Store/retail_sales_data.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- Use this line to skip the CSV header row


SELECT * FROM sales_data;

UPDATE sales_data
SET order_date = STR_TO_DATE(order_date, "%m/%d/%Y");

alter table sales_data
modify column order_date date; -- to modify order_date column to date

SELECT
	COUNT(DISTINCT order_id) AS total_unique_orders
FROM sales_data; -- there are 20000 unique rows

SELECT 
	COUNT(DISTINCT customer_id) AS total_unique_customers
FROM sales_data; -- 3985 unique customer_id

SELECT
	MIN(order_date), -- earliest recorded order date
	MAX(order_date)  -- latest recorded order date
FROM sales_data;


-- CHECK FOR DUPLICATES
WITH cte_duplicates AS
(
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY order_id, order_date, customer_id,
            gender, age, region, city, category, product,
            unit_price, quantity, discount, sales, profit,
            channel, payment_method, rating
        ) AS row_num
    FROM sales_data
)
SELECT *
FROM cte_duplicates
WHERE row_num > 1;


-- KPI (KEY PERFORMANCE INDICATOR)
-- TOTAL SALES
SELECT
    SUM(sales) AS total_sales
FROM sales_data;


-- TOTAL ORDERS
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM sales_data;

-- TOTAL UNITS SOLD
SELECT
    SUM(quantity) AS total_units_sold
FROM sales_data;

-- AVERAGE ORDER VALUE
-- TOTAL SALES / TOTAL ORDERS
WITH cte AS
(
    SELECT
        SUM(sales) AS total_sales,
        COUNT(DISTINCT order_id) AS total_orders
    FROM sales_data
)
SELECT
    round(total_sales / total_orders, 2) AS avg_order_value
FROM cte;


-- AVERAGE SELLING PRICE
-- TOTAL SALES / TOTAL UNITS SOLD
WITH cte AS
(
    SELECT
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_units_sold
    FROM sales_data
)
SELECT
    round(total_sales / total_units_sold, 2) AS avg_selling_price
FROM cte;


-- What month in each year generated the most revenue?
SELECT
    YEAR(order_date) AS year,
    MONTHNAME(order_date) AS monthname,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY year, monthname
ORDER BY year ASC, total_sales DESC;


-- What month performed the worst?
SELECT
    YEAR(order_date) AS year,
    MONTHNAME(order_date) AS monthname,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY year, monthname
ORDER BY year ASC, total_sales ASC;


-- Are sales increasing over time?
WITH year_month_sales AS
(
    SELECT
        YEAR(order_date) AS year,
        MONTH(order_date) AS month_num,
        MONTHNAME(order_date) AS monthname,
        SUM(sales) AS monthly_sales
    FROM sales_data
    GROUP BY year, month_num, monthname
)
SELECT
    year,
    month_num,
    monthname,
    monthly_sales,
    LAG(monthly_sales, 1) OVER(ORDER BY year ASC, month_num ASC) AS prev_monthly_sales,
    ROUND(monthly_sales - LAG(monthly_sales, 1) OVER(ORDER BY year ASC, month_num ASC)) AS month_over_month_growth,
    ROUND((monthly_sales -LAG(monthly_sales, 1) OVER(ORDER BY year ASC, month_num ASC)) 
    / LAG(monthly_sales, 1) OVER(ORDER BY year ASC, month_num ASC) * 100,2) AS month_over_month_growth_pct
FROM year_month_sales
ORDER BY year ASC, month_num ASC, monthname;


-- Which products generate the most revenue?
SELECT
    product,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY product
ORDER BY total_sales DESC;

-- Which products sell the most units?
SELECT
    product,
    SUM(quantity) AS total_sold_units
FROM sales_data
GROUP BY product
ORDER BY total_sold_units DESC;


-- Are the highest-selling products also the highest-revenue products?
WITH cte AS
(
    SELECT
        product,
        SUM(quantity) AS total_units_sold,
        SUM(sales) AS total_sales
    FROM sales_data
    GROUP BY product
)
SELECT
    product,
    total_units_sold,
    total_sales,
    DENSE_RANK() OVER(ORDER BY total_units_sold DESC) AS unit_rank,
    DENSE_RANK() OVER(ORDER BY total_sales DESC) AS revenue_rank
FROM cte
ORDER BY unit_rank ASC;


-- Which category generates the most revenue?
SELECT
    category,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY category
ORDER BY total_sales DESC;


-- Which category has the lowest performance?
SELECT
    category,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY category
ORDER BY total_sales ASC;


-- Which region performs best?
SELECT
    region,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY region
ORDER BY total_sales DESC;


-- Which region performs worst?
SELECT
    region,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY region
ORDER BY total_sales ASC;
