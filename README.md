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

1. Data Cleaning & Schema Transformation
Standardized string formatted dates into ISO DATE types and altered column attributes for accurate time-series analysis:
```sql
-- Convert string date values to standard DATE format
UPDATE sales_data
SET order_date = STR_TO_DATE(order_date, "%m/%d/%Y");

-- Alter column data type to DATE
ALTER TABLE sales_data
MODIFY COLUMN order_date DATE;
```
2. Dataset Overview & Duplicate Check
Validated record counts, unique entities, timeframes, and duplicate rows across all dimensions:
```
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
