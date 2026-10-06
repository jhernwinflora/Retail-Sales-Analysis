# Retail-Sales-Analysis
## Project Overview
This project performs an end-to-end exploratory and analytical investigation of transactional retail sales data comprising 20,000 orders across 3,985 unique customers. The goal of this analysis is to evaluate core sales KPIs, examine product and category performance, identify regional sales distributions, and evaluate Month-over-Month (MoM) revenue trends to uncover growth opportunities.
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
* Data Type Casting: Converted order_date from string/text representation into standard DATE format.
* Granularity Check: Validated total record counts (20,000 unique order_id entries) and distinct customer base (3,985 customer_id entries).
* Deduplication: Applied SQL Window Functions (ROW_NUMBER() OVER (PARTITION BY ...)) to detect duplicate records across all transactional attributes:
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
