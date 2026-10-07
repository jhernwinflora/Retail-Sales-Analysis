# Retail-Sales-Analysis

### Project Overview

This data analysis project aims to provide insights into the sales performance of retail sales data from years 2023 to 2025. By analyzing various aspects of the sales data, we seek to identify trends, make data-driven recommendations, and gain a deep understanding of the sales performance.

### Data Source

Primary Dataset: [retail_sales_data.csv](./retail_sales_data.csv)

The dataset comprises granular transaction records capturing individual retail sales from 2023 through 2025. Key attributes include order details (order_id, order_date), customer demographics (customer_id, gender, age), geographic metrics (region, city), product catalog details (category, product), financial metrics (unit_price, quantity, discount, sales, profit), and operational fields (channel, payment_method, rating).


### Tools 
* Excel - Raw Data
* MySQL Workbench - Data Analysis 
* Power BI - Creating Reports

### Analysis & SQL Queries

This project utilizes MySQL Workbench to perform end-to-end data processing, exploratory analysis, and key performance indicator (KPI) calculations. Below is the breakdown of the SQL workflows executed on retail_sales_data:

1. Database Setup, Schema
Initial setup involves creating the database, defining the staging table schema for raw data ingestion, standardizing date strings, and updating column data types:
```sql
-- Database and Table Initialization
CREATE DATABASE retail_sales_data;
USE retail_sales_data;

DROP TABLE IF EXISTS sales_data;
CREATE TABLE sales_data
(
    order_id        TEXT,
    order_date      TEXT,
    customer_id     TEXT,
    gender          TEXT,
    age             TEXT,
    region          TEXT,
    city            TEXT,
    category        TEXT,
    product         TEXT,
    unit_price      INT,
    quantity        INT,
    discount        FLOAT,
    sales           DECIMAL(10,2),
    profit          DECIMAL(10,2),
    channel         TEXT,
    payment_method  TEXT,	
    rating          INT
);
```

2. Data Cleaning & Schema Transformation
Standardized string formatted dates into ISO DATE types and altered column attributes for accurate time-series analysis:
```sql
-- Convert string date values to standard DATE format
UPDATE sales_data
SET order_date = STR_TO_DATE(order_date, "%m/%d/%Y");

-- Alter column data type to DATE
ALTER TABLE sales_data
MODIFY COLUMN order_date DATE;
```

3. Dataset Overview & Duplicate Check
Validated record counts, unique entities, timeframes, and duplicate rows across all dimensions:
```sql
-- Check total unique orders and customers
SELECT COUNT(DISTINCT order_id) AS total_unique_orders FROM sales_data; -- 20,000 unique orders
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers FROM sales_data; -- 3,985 unique customers

-- Determine date bounds
SELECT 
    MIN(order_date) -- earliest order date
    MAX(order_date) -- latest order date
FROM sales_data;

-- Check for exact duplicate records across all fields
WITH cte_duplicates AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY order_id, order_date, customer_id, gender, age, region, 
                         city, category, product, unit_price, quantity, discount, 
                         sales, profit, channel, payment_method, rating
        ) AS row_num
    FROM sales_data
)
SELECT * FROM cte_duplicates WHERE row_num > 1;
```

3. Core Key Performance Indicators (KPIs)
Calculated foundational business metrics, including aggregate revenue, volume, and order-level averages:
```sql
-- Total Sales
SELECT SUM(sales) AS total_sales FROM sales_data;

-- Total Orders & Total Units Sold
SELECT COUNT(DISTINCT order_id) AS total_orders FROM sales_data;
SELECT SUM(quantity) AS total_units_sold FROM sales_data;

-- Average Order Value (AOV)
WITH cte AS (
    SELECT 
        SUM(sales) AS total_sales,
        COUNT(DISTINCT order_id) AS total_orders
    FROM sales_data
)
SELECT ROUND(total_sales / total_orders, 2) AS avg_order_value FROM cte;

-- Average Selling Price (ASP)
WITH cte AS (
    SELECT 
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_units_sold
    FROM sales_data
)
SELECT ROUND(total_sales / total_units_sold, 2) AS avg_selling_price FROM cte;
```

4. Time-Series & Trend Analysis
Identified monthly performance highlights, worst-performing periods, and Month-over-Month (MoM) growth trajectory using window functions:
```sql
-- Top & bottom performing months per year
SELECT
    YEAR(order_date) AS year,
    MONTHNAME(order_date) AS monthname,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY year, monthname
ORDER BY year ASC, total_sales DESC;

SELECT
    YEAR(order_date) AS year,
    MONTHNAME(order_date) AS monthname,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY year, monthname
ORDER BY year ASC, total_sales ASC;

-- Month-over-Month (MoM) Growth Analysis
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
```
5. Product & Category Breakdown
Evaluated top/bottom categories and ranked products by volume versus revenue to identify high-value drivers:
```sql
-- Which category generates the most revenue?
SELECT
    category,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY category
ORDER BY total_sales DESC;

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
```
6. Geographic Distribution
Mapped geographic distribution to pinpoint high-growth regional hubs and underperforming markets:
```sql
-- Regional Performance Overview
SELECT region, SUM(sales) AS total_sales
FROM sales_data
GROUP BY region
ORDER BY total_sales DESC;
```
### 📊 Key Insights & Analytical Findings

#### **1. High-Level Performance Metrics (KPIs)**
* **Total Revenue**: Generated $222,077,816.75 across 20,000 unique orders placed by 3,985 unique customers (2023–2025).
* **Units Sold**: 44,814 total units were sold across all categories.
* **Order Dynamics**: The overall Average Order Value (AOV) was $11,103.89, with an Average Selling Price (ASP) of $4,955.55 per unit.

#### **2. Time-Based Trends & Seasonality**
* **Q4 Peak Sales**: Across all three years, the fourth quarter (specifically October and November) consistently generated the highest monthly revenue, peaking at $10,636,182.95 in November 2025.   
* **Q1/Q3 Lulls**: Early spring (March/April) and mid-summer (July) frequently experienced drops in performance. For example, July 2024 saw the lowest monthly revenue for that year at $3,930,909.30.   
* **Growth Volatility**: Month-over-Month (MoM) revenue fluctuates significantly ahead of peak shopping periods, highlighted by a 105.96% spike in October 2023 right before Q4.

#### **3. Product Performance & Revenue vs. Volume**
* **Top Revenue Drivers**: Laptops generated the highest total revenue by a massive margin at $130,717,019.10, followed by Smartphones ($36,655,612.45) and Smartwatches ($11,482,238.35).   
* **Top Volume Leaders**: The highest unit sales came from lower-cost accessories—Wireless Earbuds (2,606 units) and Power Banks (2,583 units).
* **Key Finding (Rank Shift)**: High unit volume does not always equal high revenue. While Wireless Earbuds ranked #1 in units sold, it ranked #6 in revenue. Conversely, Laptops ranked #3 in units sold but dominated as #1 in total revenue due to its higher price point.

#### **4. Category Dominance**
* **Electronics Heavy**: The Electronics category outperformed all other sectors combined, driving $186,893,726.15 in revenue.
* **Underperforming Categories**: Books & Stationery ($2,774,971.70) and Beauty ($3,829,043.20) contributed the least to total sales volume.

#### **5. Regional Insights**
* **South Leads Revenue**: The South region was the top-performing territory, generating $70,069,874.35 in total sales.
* **East Lags Behind**: The East region recorded the lowest total sales at $36,887,909.60, lagging significantly behind the South, North ($58.18M), and West ($56.94M) markets.  
