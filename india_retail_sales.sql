create database india_retail_sales;

drop table if exists sales_data;
create table sales_data
(
	order_id	text,
	order_date	 text,
	customer_id	text,
	gender	text,
	age	int,
	region text,
	city	text,
	category	text,
	product	text,
	unit_price	int,
	quantity	int,
	discount	float,
	sales	decimal(10,2),
	profit	decimal(10,2),
	channel	text,
	payment_method text,	
	rating int
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/jhern/OneDrive/Documents/JJ/SQL + EXCEL/India Retail Store/sales_data.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- Use this line to skip the CSV header row

show warnings;

select * from sales_data;

alter table sales_data
modify column order_date date; -- to modify order_date column to date

select count(distinct order_id) from sales_data; -- there are 20000 unique rows

select count(distinct customer_id) from sales_data; -- 3985 unique customer_id

select 
	min(order_date), 
	max(order_date) 
from sales_data;


-- CHECK FOR DUPLICATES
with cte_duplicates as
(
select
	*,
	row_number() over(partition by order_id, order_date, customer_id,	
    gender,	age, region, city, category, product, unit_price, quantity,	
    discount,	sales,	profit,	channel, payment_method, rating) as row_num
from sales_data
)
select * from cte_duplicates
where row_num > 1;

-- KPI (KEY PERFORMANCE INDICATOR)
-- TOTAL REVENUE
select
	sum(sales) as total_revenue
from sales_data;

-- TOTAL ORDERS
select
	count(distinct order_id) as total_orders
from sales_data;

-- TOTAL UNITS SOLD
select
	sum(quantity) as total_units_sold
from sales_data;

-- AVERAGE ORDER VALUE
-- TOTAL REVENUE / TOTAL ORDERS
with cte as
(
	select
		sum(sales) as total_revenue,
		count(distinct order_id) as total_orders
	from sales_data
)
select
	total_revenue / total_orders as avg_order_value
from cte;

-- AVERAGE SELLING PRICE
-- TOTAL REVENUE / TOTAL UNITS SOLD
with cte as
(
	select
		sum(sales) as total_revenue,
		sum(quantity) as total_units_sold
	from sales_data
)
select
	total_revenue / total_units_sold as avg_selling_price
from cte;

-- What month in each year generated the most revenue?
select
	year(order_date) as year,
	monthname(order_date) as monthname,
    sum(sales) as total_revenue
from sales_data
group by year, monthname
order by year asc, total_revenue desc;

-- What month performed the worst?
select
	year(order_date) as year,
	monthname(order_date) as monthname,
    sum(sales) as total_revenue
from sales_data
group by year, monthname
order by year asc, total_revenue asc;

-- Are sales increasing over time?
with year_month_sales as
(
	select
		year(order_date) as year,
        month(order_date) as month_num,
		monthname(order_date) as monthname,
        sum(sales) as monthly_sales
	from sales_data
    group by year, month_num, monthname
)
select
	year,
    month_num,
    monthname,
    monthly_sales,
    lag(monthly_sales, 1) over(order by year asc, month_num asc) as prev_monthly_sales,
    round(monthly_sales - lag(monthly_sales, 1) over(order by year asc, month_num asc)) as month_over_month_growth,
	round((monthly_sales - lag(monthly_sales, 1) over(order by year asc, month_num asc)) / lag(monthly_sales, 1) over(order by year asc, month_num asc) * 100, 2) as month_over_month_growth_pct
from year_month_sales
order by year asc, month_num asc, monthname;

-- Which products generate the most revenue?
select
	product,
    sum(sales) as total_revenue
from sales_data
group by product
order by total_revenue desc;

-- Which products sell the most units?
select
	product,
    sum(quantity) as total_sold_units
from sales_data
group by product
order by total_sold_units desc;

-- Are the highest-selling products also the highest-revenue products?
with cte as
(	
	select
		product,
		sum(quantity) as total_units_sold,
        sum(sales) as total_sales
	from sales_data
	group by product
)
select 
	product,
    total_units_sold,
    total_sales,
	dense_rank() over(order by total_units_sold desc) as unit_rank,
    dense_rank() over(order by total_sales desc) as revenue_rank
from cte
order by unit_rank asc;

-- Which category generates the most revenue?
select
	category,
    sum(sales) as total_revenue
from sales_data
group by category
order by total_revenue desc;

-- Which category has the lowest performance?
select
	category,
    sum(sales) as total_revenue
from sales_data
group by category
order by total_revenue asc;

-- Which region performs best?
select
	region,
    sum(sales) as total_revenue
from sales_data
group by region
order by total_revenue desc;

-- Which region performs worst?
select
	region,
    sum(sales) as total_revenue
from sales_data
group by region
order by total_revenue asc;