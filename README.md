# Retail-Sales-Analysis

### Project Overview

This data analysis project aims to provide insights into the sales performance of retail sales data from years 2023 to 2025. By analyzing various aspects of the sales data, we seek to identify trends, make data-driven recommendations, and gain a deep understanding of the sales performance.

### Data Source

Primary Dataset: retail_sales.csv
The dataset comprises granular transaction records capturing individual retail sales from 2023 through 2025. Key attributes include order details (order_id, order_date), customer demographics (customer_id, gender, age), geographic metrics (region, city), product catalog details (category, product), financial metrics (unit_price, quantity, discount, sales, profit), and operational fields (channel, payment_method, rating).


### Business Questions
1. What are the macro KPI metrics (Total Revenue, Total Orders, Units Sold, AOV, and ASP)?
2. Are overall sales increasing over time, and what are the Month-over-Month (MoM) growth patterns?
3. Which specific months demonstrate the highest and lowest revenue across years?
4. Which individual products drive the most revenue vs. volume, and do high-selling items align with high revenue generators?
5. Which product categories and geographic regions are top performers vs. underperformers?
### Tools Used
* **Database Management System**: MySQL Workbench / SQL
* **Data Visualization & Dashboarding:** Power BI
* **Version Control**: GitHub
### Data Cleaning & Preparation
Prior to executing business queries, preliminary validation and schema modifications were performed on sales_data:
* **Data Type Casting**: Converted order_date from string/text representation into standard DATE format.
  ```sql
  ALTER TABLE sales_data MODIFY COLUMN order_date DATE;
  ```
* **Granularity Check**: Validated total record counts (20,000 unique `order_id` entries) and distinct customer base (3,985 `customer_id` entries).

* **Deduplication**: Applied SQL Window Functions (ROW_NUMBER() OVER (PARTITION BY ...)) to detect duplicate records across all transactional attributes:

### Deduplication Verification CTE
``` sql
ALTER TABLE sales_data
MODIFY COLUMN order_date DATE;

-- Duplicate Verification CTE
WITH cte_duplicates AS (
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY order_id, order_date, customer_id, gender, age, 
                         region, city, category, product, unit_price, 
                         quantity, discount, sales, profit, channel, 
                         payment_method, rating
        ) AS row_num
    FROM sales_data
)
SELECT * FROM cte_duplicates
WHERE row_num > 1;
```
