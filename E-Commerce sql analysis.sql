
--  E-COMMERCE SQL ANALYSIS — MYSQL
--  UK Online Retail Dataset

--  OBJECTIVE
--  ---------
--  Use SQL to uncover business insights about customer
--  behaviour, product performance, sales patterns, and
--  revenue trends that go beyond the Python EDA.
--
--  TABLE OF CONTENTS
--  -----------------
--  SECTION 1  — Database & Table Setup
--  SECTION 2  — Load Data from CSV
--  SECTION 3  — Data Verification
--  SECTION 4  — SIMPLE   Queries
--  SECTION 5  — MEDIUM   Queries
--  SECTION 6  — ADVANCED Queries
--  SECTION 7  — WINDOW FUNCTION Queries
--  SECTION 8  — CTE + SUBQUERY Queries  


-- SECTION 1 — DATABASE & TABLE SETUP

-- Step 1: Create a dedicated database for this project

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;

USE ecommerce_db;

-- Step 3: Create the main transactions table

CREATE TABLE transactions (
    InvoiceNo   VARCHAR(20),
    StockCode   VARCHAR(20),
    Description VARCHAR(255),
    Quantity    INT,
    InvoiceDate DATETIME, 
    UnitPrice   DECIMAL(10, 2),
    CustomerID  INT,
    Country     VARCHAR(100)
);

SHOW TABLES;
DESC transactions;


-- SECTION 2 — LOAD DATA FROM CSV

LOAD DATA LOCAL INFILE 'C:/Users/hp/batch 367/AI framed Interview Questions/Resume Projects/data analytics/project 3/archive/data.csv'   
INTO TABLE transactions
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(	InvoiceNo,StockCode,Description,Quantity,@raw_date,UnitPrice,@raw_cid,Country)
SET
    InvoiceDate = STR_TO_DATE(REPLACE(@raw_date, '-', '/'), '%m/%d/%Y %H:%i'),
    CustomerID  = NULLIF(@raw_cid, '');

SELECT COUNT(*) AS total_rows_loaded FROM transactions;


-- SECTION 3 — DATA VERIFICATION

SELECT * FROM transactions LIMIT 10;

-- 3.2 Checking for the null values in every column
SELECT
    SUM(CASE WHEN InvoiceNo   IS NULL THEN 1 ELSE 0 END) AS null_InvoiceNo,
    SUM(CASE WHEN StockCode   IS NULL THEN 1 ELSE 0 END) AS null_StockCode,
    SUM(CASE WHEN Description IS NULL THEN 1 ELSE 0 END) AS null_Description,
    SUM(CASE WHEN Quantity    IS NULL THEN 1 ELSE 0 END) AS null_Quantity,
    SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) AS null_InvoiceDate,
    SUM(CASE WHEN UnitPrice   IS NULL THEN 1 ELSE 0 END) AS null_UnitPrice,
    SUM(CASE WHEN CustomerID  IS NULL THEN 1 ELSE 0 END) AS null_CustomerID,
    SUM(CASE WHEN Country     IS NULL THEN 1 ELSE 0 END) AS null_Country
FROM transactions;

-- 3.3 Checking the  date range to confirm data loaded correctly or not
SELECT
    MIN(InvoiceDate) AS earliest_date,
    MAX(InvoiceDate) AS latest_date
FROM transactions;

-- 3.4 Checking for anomalies — negative quantity and zero/negative unit price
SELECT
    SUM(CASE WHEN Quantity  <= 0 THEN 1 ELSE 0 END) AS negative_or_zero_quantity,
    SUM(CASE WHEN UnitPrice <= 0 THEN 1 ELSE 0 END) AS negative_or_zero_price,
    SUM(CASE WHEN InvoiceNo LIKE 'C%' THEN 1 ELSE 0 END) AS cancelled_orders
FROM transactions;

-- 3.5 Create a clean working view — this replaces the Python cleaning step

CREATE OR REPLACE VIEW clean_transactions AS
SELECT 
	InvoiceNo,
	StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    ROUND(Quantity * UnitPrice, 2) AS TotalAmount
FROM transactions
WHERE
    CustomerID  IS NOT NULL
    AND InvoiceNo NOT LIKE 'C%'
    AND Quantity  > 0
    AND UnitPrice > 0;

SELECT COUNT(*) AS clean_rows FROM clean_transactions;



-- SECTION 4 — SIMPLE QUERIES

-- Q1: How many unique customers, invoices, and products?

SELECT
    COUNT(DISTINCT CustomerID) AS unique_customers,
    COUNT(DISTINCT InvoiceNo)  AS unique_invoices,
    COUNT(DISTINCT StockCode)  AS unique_products,
    COUNT(DISTINCT Country)    AS countries_served
FROM clean_transactions;


-- Q2: What is the overall total revenue?

SELECT
    ROUND(SUM(TotalAmount), 2)  AS total_revenue,
    ROUND(AVG(TotalAmount), 2)  AS avg_line_item_value,
    ROUND(MIN(TotalAmount), 2)  AS min_line_item_value,
    ROUND(MAX(TotalAmount), 2)  AS max_line_item_value
FROM clean_transactions;


-- Q3: Which day of the week generates the most revenue?

SELECT
    DAYNAME(InvoiceDate)              AS day_of_week,
    COUNT(DISTINCT InvoiceNo)         AS total_orders,
    ROUND(SUM(TotalAmount), 2)        AS total_revenue
FROM clean_transactions
GROUP BY DAYNAME(InvoiceDate), DAYOFWEEK(InvoiceDate)
ORDER BY DAYOFWEEK(InvoiceDate);

/*
INSIGHT: This reveals which day drives the most business activity.
If Sunday/Saturday shows zero or very low numbers it confirms a B2B-heavy customer base
(businesses don't order on weekends). The busiest weekday is the best time to send
marketing emails or schedule promotions.
*/


-- Q4: How many orders were placed each month?

SELECT
    DATE_FORMAT(InvoiceDate, '%Y-%m')  AS year_months,
    COUNT(DISTINCT InvoiceNo)          AS total_orders,
    COUNT(DISTINCT CustomerID)         AS active_customers,
    ROUND(SUM(TotalAmount), 2)         AS monthly_revenue
FROM clean_transactions
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY year_months;

/*
INSIGHT: Monthly order and customer counts reveal seasonality.
We can see if active customers spike in certain months (holiday season),
or if a dip in orders also means fewer unique customers (vs. same customers buying less).
*/

-- Q5: Top 10 countries by number of unique customers

SELECT
    Country,
    COUNT(DISTINCT CustomerID)  AS unique_customers,
    ROUND(SUM(TotalAmount), 2)  AS total_revenue,
    COUNT(DISTINCT InvoiceNo)   AS total_orders
FROM clean_transactions
GROUP BY Country
ORDER BY unique_customers DESC
LIMIT 10;

/*
INSIGHT: Distinct customer count per country shows WHERE the customer BASE is,
not just where revenue comes from. A country with many customers but low revenue
means small basket sizes — possible opportunity for upsell campaigns.
*/


-- SECTION 5 — MEDIUM QUERIES

-- Q6: Average basket size (revenue per invoice) by country

SELECT
    Country,
    COUNT(DISTINCT InvoiceNo) AS total_invoices,
    ROUND(SUM(TotalAmount), 2) AS total_revenue,
    ROUND(SUM(TotalAmount) / COUNT(DISTINCT InvoiceNo), 2) AS avg_basket_size
FROM clean_transactions
GROUP BY Country
HAVING total_invoices >= 50
ORDER BY avg_basket_size DESC;

/*
INSIGHT: Average basket size by country reveals which markets have high-value orders.
Netherlands, EIRE and certain European markets often show HIGHER basket sizes than the UK.
This suggests international buyers may be wholesale/bulk purchasers — worth targeted B2B outreach.
*/

-- Q7: What percentage of customers are single-purchase buyers?

SELECT
    purchase_type,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_customers
FROM (SELECT CustomerID,
        CASE WHEN COUNT(DISTINCT InvoiceNo) = 1 THEN 'Single Purchase' ELSE 'Repeat Purchase'
        END AS purchase_type
		FROM clean_transactions
		GROUP BY CustomerID
) AS customer_types
GROUP BY purchase_type;

/*
INSIGHT: If more than 50% of customers only ever bought once, this signals a
retention problem — the business may be good at acquisition but poor at keeping customers.
Single-purchase customers should be targeted with second-purchase incentives.
*/


-- Q8: Which hour of the day has the highest order volume?

SELECT HOUR(InvoiceDate) AS order_hour,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(TotalAmount), 2) AS total_revenue,
    COUNT(DISTINCT CustomerID) AS unique_customers
FROM clean_transactions
GROUP BY HOUR(InvoiceDate)
ORDER BY total_orders DESC;


-- Q9: Find products that are ONLY bought by one customer

SELECT
    StockCode,
    Description,
    COUNT(DISTINCT CustomerID)  AS buyer_count,
    SUM(Quantity)               AS total_units_sold
FROM clean_transactions
GROUP BY StockCode, Description
HAVING COUNT(DISTINCT CustomerID) = 1
ORDER BY total_units_sold DESC
LIMIT 20;

/*
INSIGHT: Products with only one buyer could be custom orders, niche items,
or potential candidates for discontinuation. If they sell in high volume to
that one customer, it's a key account dependency risk.
*/

-- Q10: Month-over-month revenue growth

SELECT year_months, monthly_revenue, prev_month_revenue,
    ROUND(monthly_revenue - prev_month_revenue, 2) AS revenue_change,
    ROUND((monthly_revenue - prev_month_revenue) / prev_month_revenue * 100, 2) AS pct_growth
FROM (SELECT DATE_FORMAT(InvoiceDate, '%Y-%m')  AS year_months,
        ROUND(SUM(TotalAmount), 2) AS monthly_revenue,
        LAG(ROUND(SUM(TotalAmount), 2))
            OVER (ORDER BY DATE_FORMAT(InvoiceDate, '%Y-%m'))  AS prev_month_revenue
    FROM clean_transactions
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
) AS monthly_data
ORDER BY year_months;

/*
INSIGHT: Month-over-month growth rates identify acceleration or slowdown in the business.
A negative growth rate in January–February is expected (post-holiday dip).
A sharp positive spike in November confirms the holiday effect on sales.
*/

-- SECTION 6 — ADVANCED QUERIES

-- Q11: Customers who haven't purchased in the last 90 days
--      (at-risk / churn candidates)

SELECT
    CustomerID,
    MAX(InvoiceDate) AS last_purchase_date,
    DATEDIFF(MAX(InvoiceDate),     MIN(InvoiceDate)) AS customer_lifespan_days,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(TotalAmount), 2) AS total_spend,
    DATEDIFF((SELECT MAX(InvoiceDate) FROM clean_transactions),
    MAX(InvoiceDate)) AS days_since_last_purchase
FROM clean_transactions
GROUP BY CustomerID
HAVING days_since_last_purchase >= 90
ORDER BY days_since_last_purchase DESC
LIMIT 30;

/*
INSIGHT: These are high-priority win-back targets. Customers who HAVE spent
before but haven't returned in 90+ days represent real revenue potential.
Filter by total_spend to prioritise high-value dormant customers first.
*/

-- Q12: Products frequently bought together (Market Basket)

SELECT
    a.Description AS product_A,
    b.Description AS product_B,
    COUNT(*) AS times_bought_together
FROM clean_transactions AS a
JOIN clean_transactions AS b
    ON  a.InvoiceNo   = b.InvoiceNo
    AND a.StockCode   < b.StockCode
GROUP BY a.Description, b.Description
HAVING times_bought_together >= 30
ORDER BY times_bought_together DESC
LIMIT 20;

/*
INSIGHT: Products that are frequently bought in the same order are strong candidates
for "Frequently Bought Together" recommendations (like Amazon does).
These can also be bundled into discounted packs to increase average order value.
*/



-- Q13: Rank customers by lifetime value (LTV) using DENSE_RANK

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(TotalAmount), 2) AS lifetime_value,
    ROUND(AVG(TotalAmount), 2) AS avg_order_value,
    DENSE_RANK() OVER (ORDER BY SUM(TotalAmount) DESC) AS ltv_rank
FROM clean_transactions
GROUP BY CustomerID
ORDER BY ltv_rank
LIMIT 20;


/*
INSIGHT: The LTV rank helps the business prioritise which customers deserve
dedicated account management or VIP treatment. The top 20 customers by LTV
should never receive generic mass emails — they need personalised outreach.
*/


-- Q14: What is the average time gap between repeat purchases?

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    DATEDIFF(
        MAX(InvoiceDate),
        MIN(InvoiceDate)) AS days_between_first_and_last,
    ROUND(DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate)) / NULLIF(COUNT(DISTINCT InvoiceNo) - 1, 0), 0) AS avg_days_between_orders
FROM clean_transactions
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) >= 3
ORDER BY avg_days_between_orders ASC
LIMIT 30;

/*
INSIGHT: Average days between orders tells us the "natural reorder cycle" for
loyal customers. If most repeat buyers come back every 30–45 days, then 
sending a re-engagement email on day 40 of inactivity is perfectly timed.
This can drive automated triggered email campaigns.
*/

-- Q15: Product revenue concentration — Pareto (80/20) check
-- Which products contribute to the top 80% of revenue?

SELECT StockCode, Description, ROUND(SUM(TotalAmount), 2) AS product_revenue,
    ROUND(SUM(SUM(TotalAmount)) OVER (ORDER BY SUM(TotalAmount) DESC 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) / SUM(SUM(TotalAmount)) OVER () * 100, 2) AS cumulative_pct
FROM clean_transactions
GROUP BY StockCode, Description
ORDER BY product_revenue DESC
LIMIT 50;

/*
INSIGHT: This reveals how top-heavy the product revenue is.
If 50 products account for 80% of revenue, the retailer should focus
inventory management, discounts, and promotions on that core set.
Out-of-stock on those 50 products = serious revenue risk.
*/

-- SECTION 7 — WINDOW FUNCTION QUERIES

-- Q16: First purchase date and most recent purchase per customer

SELECT DISTINCT CustomerID, FIRST_VALUE(InvoiceDate)
        OVER (PARTITION BY CustomerID ORDER BY InvoiceDate
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS first_purchase_date,
    LAST_VALUE(InvoiceDate)
        OVER (PARTITION BY CustomerID ORDER BY InvoiceDate
              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_purchase_date,
    DATEDIFF(
        LAST_VALUE(InvoiceDate)
            OVER (PARTITION BY CustomerID ORDER BY InvoiceDate
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
        FIRST_VALUE(InvoiceDate)
            OVER (PARTITION BY CustomerID ORDER BY InvoiceDate
                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) AS customer_lifespan_days
FROM clean_transactions
ORDER BY customer_lifespan_days DESC
LIMIT 30;

/*
INSIGHT: Customer lifespan (days between first and last purchase) is a strong 
indicator of loyalty. Customers with a long lifespan AND high order count
are your most committed, relationship-worth-investing-in customers.
*/

-- Q17: Rank products within each country by revenue
--      (Which product is #1 in each market?)

SELECT *
FROM (SELECT Country,Description,ROUND(SUM(TotalAmount), 2) AS country_product_revenue,
        ROW_NUMBER() OVER (PARTITION BY Country ORDER BY SUM(TotalAmount) DESC) AS rank_in_country
    FROM clean_transactions
    GROUP BY Country, Description) AS ranked
WHERE rank_in_country <= 3
ORDER BY Country, rank_in_country;

/*
INSIGHT: The top products in each country may differ significantly.
The UK's bestseller might not even appear in the top 10 in Germany.
This supports localised product catalogues and country-specific homepage recommendations.
*/



-- Q18: Segment customers into 4 equal spend quartiles using NTILE

SELECT
    spend_quartile,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(MIN(total_spend), 2) AS min_spend,
    ROUND(MAX(total_spend), 2) AS max_spend
FROM (SELECT CustomerID, ROUND(SUM(TotalAmount), 2) AS total_spend,
	  NTILE(4) OVER (ORDER BY SUM(TotalAmount)) AS spend_quartile
    FROM clean_transactions
    GROUP BY CustomerID) AS quartile_data
GROUP BY spend_quartile
ORDER BY spend_quartile DESC;

/*
INSIGHT: NTILE quartiles help define marketing spend tiers.
Q4 customers (top 25%) deserve premium treatment.
Q1 customers (bottom 25%) may not be worth heavy investment —
or they could be newly acquired customers with high growth potential.
*/


-- Q19: Running cumulative revenue by month

SELECT year_months, monthly_revenue,SUM(monthly_revenue) 
OVER (ORDER BY year_months
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_revenue
FROM (SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS year_months,
			 ROUND(SUM(TotalAmount), 2) AS monthly_revenue
FROM clean_transactions
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')) AS monthly_data
ORDER BY year_months;

/*
INSIGHT: The cumulative revenue chart shows how fast the business hit 
major milestones (first £1M, first £5M, etc.). If cumulative revenue 
accelerates in the final 3 months of the year, this quantifies how critical
the Q4 holiday season is to the full-year result.
*/

-- SECTION 8 — CTE + SUBQUERY QUERIES

-- Q20: New vs Returning customer revenue split by month

WITH customer_first_month AS (
    SELECT CustomerID, DATE_FORMAT(MIN(InvoiceDate), '%Y-%m') AS first_month
    FROM clean_transactions
    GROUP BY CustomerID),
tagged_transactions AS (
    SELECT t.InvoiceNo,t.CustomerID,t.TotalAmount,
        DATE_FORMAT(t.InvoiceDate, '%Y-%m') AS txn_month,
        CASE WHEN DATE_FORMAT(t.InvoiceDate, '%Y-%m') = cf.first_month THEN 'New Customer' ELSE 'Returning Customer'
        END AS customer_type
    FROM clean_transactions t
    JOIN customer_first_month cf ON t.CustomerID = cf.CustomerID)
SELECT 
	txn_month,customer_type,
    COUNT(DISTINCT CustomerID)   AS unique_customers,
    ROUND(SUM(TotalAmount), 2)   AS revenue
FROM tagged_transactions
GROUP BY txn_month, customer_type
ORDER BY txn_month, customer_type;

/*
INSIGHT: This query splits revenue into NEW vs RETURNING each month.
If new customer revenue dominates, the business is acquisition-heavy.
If returning customers dominate, retention is strong. 
A healthy business should see returning customer revenue grow over time.
*/

-- Q21: Customer Cohort Retention — how many customers 
--      who first bought in Month 0 came back in Month 1, 2, 3?

WITH cohort_base AS (
    SELECT CustomerID,DATE_FORMAT(MIN(InvoiceDate), '%Y-%m') AS cohort_month
    FROM clean_transactions
    GROUP BY CustomerID),
customer_activity AS (SELECT DISTINCT CustomerID,
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS activity_month
    FROM clean_transactions),
cohort_joined AS (
    SELECT
        c.cohort_month,
        TIMESTAMPDIFF(MONTH,STR_TO_DATE(CONCAT(c.cohort_month, '-01'), '%Y-%m-%d'),
							STR_TO_DATE(CONCAT(a.activity_month, '-01'), '%Y-%m-%d')
        ) AS months_since_first_purchase
    FROM cohort_base c
    JOIN customer_activity a ON c.CustomerID = a.CustomerID)
SELECT
    cohort_month,
    months_since_first_purchase,
    COUNT(*) AS retained_customers
FROM cohort_joined
WHERE months_since_first_purchase BETWEEN 0 AND 6
GROUP BY cohort_month, months_since_first_purchase
ORDER BY cohort_month, months_since_first_purchase;

/*
INSIGHT: Cohort retention is one of the most important metrics for any e-commerce business.
Month 0 = all customers in that cohort (100% by definition).
Month 1 = what % came back. Month 2 = what % stayed.
A steep drop from Month 0 to Month 1 (say 100% → 20%) means most customers never return.
This justifies investing heavily in the second-purchase email nurture sequence.
*/


-- Q22: Products with declining sales — 
--      compare H1 (first 6 months) vs H2 (last 6 months)

WITH h1_sales AS (
    SELECT StockCode,Description,ROUND(SUM(TotalAmount), 2) AS h1_revenue
    FROM clean_transactions
    WHERE InvoiceDate < '2011-07-01'
    GROUP BY StockCode, Description),
h2_sales AS (
    SELECT StockCode,Description,ROUND(SUM(TotalAmount), 2) AS h2_revenue
    FROM clean_transactions
    WHERE InvoiceDate >= '2011-07-01'
    GROUP BY StockCode, Description)
SELECT h1.StockCode,h1.Description,h1.h1_revenue,
    COALESCE(h2.h2_revenue, 0)  AS h2_revenue,
    ROUND(COALESCE(h2.h2_revenue, 0) - h1.h1_revenue, 2) AS revenue_change,
    CASE 
		WHEN COALESCE(h2.h2_revenue, 0) < h1.h1_revenue THEN 'Declining'
        WHEN COALESCE(h2.h2_revenue, 0) > h1.h1_revenue THEN 'Growing'
        ELSE 'Stable'END AS sales_trend
FROM h1_sales h1
LEFT JOIN h2_sales h2 ON h1.StockCode = h2.StockCode
ORDER BY revenue_change ASC
LIMIT 30;

/*
INSIGHT: Products where revenue dropped from H1 to H2 may be seasonal, 
discontinued, or losing customer interest. 
Products with GROWTH from H1 to H2 are momentum items worth promoting more aggressively.
This directly feeds into category management and buying decisions.
*/


-- SUMMARY OF INSIGHTS FOUND THROUGH SQL
-- ----------------------------------------
-- 1.  Day-of-week revenue pattern: weekdays heavily dominate
-- 2.  Monthly revenue growth rates: identified holiday acceleration
-- 3.  Single vs repeat buyer split: majority may be one-time buyers
-- 4.  Peak order hour: 10 AM–12 PM confirms B2B buying behaviour
-- 5.  Products with only one buyer: niche or bespoke items identified
-- 6.  Average basket size by country: international buyers spend more per order
-- 7.  Market basket / product pairs: frequently co-purchased items found
-- 8.  Customer purchase cadence: average days between repeat orders
-- 9.  Product revenue concentration: Pareto 80/20 confirmed at product level
-- 10. High-value dormant customers: priority win-back list built
-- 11. New vs returning revenue split: retention vs acquisition balance visible
-- 12. Cohort retention: Month 0 → 1 retention drop quantified
-- 13. Declining vs growing products: H1 vs H2 sales comparison
