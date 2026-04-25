-- E-commerce Project --

USE [Electronics Retailer Project]

--PHASE 1: Understand the dataset. NO CODE--

--Phase 2:
- Step 1. Create a clean joined tablet
- Step 2. Figure out main KPIS and metrics
- Step 3. Create calculations to get total cost, revenue, and profit
- Step 4. Use aggregations to get totals for metrics like revenue, profit, cost, customers, and orders

--Here we are joining the customers, products, and store tables to the sales table to link them all together. The sales table is acting as our master table. --

Select
 Order_Number,
 Sales.CustomerKey,
 Sales.ProductKey,
 Sales.StoreKey
 From Sales
 INNER JOIN Customers
 On Sales.CustomerKey = Customers.CustomerKey
 INNER JOIN Products
 On Sales.ProductKey = Products.ProductKey
 INNER JOIN Stores
 On Sales.StoreKey = Stores.StoreKey

-- Step 2. Work out are main KPIs --

Select
s.Order_Number,
S.CustomerKey,
S.ProductKey,
S.StoreKey,
s.quantity,

p.product_name,
p.category,
p.brand,
p.unit_cost_USD,
p.unit_price_USD,

c.country,

st.country as store_country

From Sales s
INNER JOIN Customers c
On S.CustomerKey = C.CustomerKey
INNER JOIN Products p
On S.ProductKey = P.ProductKey
INNER JOIN Stores st
On S.StoreKey = St.StoreKey

-- Step 3. Add in calculations to get total revenue, cost, and profit per order. We also took out values where unit cost was NULL --

 Select
s.Order_Number,
S.CustomerKey,
S.ProductKey,
S.StoreKey,
s.quantity,

p.product_name,
p.category,
p.brand,
p.unit_cost_USD,
p.unit_price_USD,

c.country,

st.country as store_country,

--calculated fields--

s.quantity * p.unit_price_USD as Revenue,
s.quantity * p.unit_cost_USD as Cost,
(s.quantity * p.unit_price_USD) - ( s.quantity * p.unit_cost_USD) as Profit

From Sales s
INNER JOIN Customers c
On S.CustomerKey = C.CustomerKey
INNER JOIN Products p
On S.ProductKey = P.ProductKey
INNER JOIN Stores st
On S.StoreKey = St.StoreKey
Where p.unit_cost_USD IS NOT NULL

 --Step 4. Turn base data into a CTE and then gather metrics such as total revenue, cost, profit, customer count, and orders --

 With base_data AS (
 Select
 s.Order_Number,
 S.CustomerKey,
 S.ProductKey,
 S.StoreKey,
 s.quantity,

 p.product_name,
 p.category,
 p.brand,
 p.unit_cost_USD,
 p.unit_price_USD,

 c.country,

 st.country as store_country,

 --calculated fields--

 s.quantity * p.unit_price_USD as Revenue,
 s.quantity * p.unit_cost_USD as Cost,
 (s.quantity * p.unit_price_USD) - ( s.quantity * p.unit_cost_USD) as Profit

 From Sales s
 INNER JOIN Customers c
 On S.CustomerKey = C.CustomerKey
 INNER JOIN Products p
 On S.ProductKey = P.ProductKey
 INNER JOIN Stores st
 On S.StoreKey = St.StoreKey
 Where p.unit_cost_USD IS NOT NULL
 )

 Select 
 Sum(revenue) as total_revenue,
Sum(Profit) as total_profit,
Count(DISTINCT order_number) as total_orders,
Count(DISTINCT CustomerKey) as customer_count,
Sum(Quantity) as total_quantity_sold
 From base_data

-- PHASE 3: Key Business Insights --

-- Section 1. Product Analysis: Here we are figuring out what products make the most money and what categories they belong to--


With base_data AS (
 Select
 s.Order_Number,
 S.CustomerKey,
 S.ProductKey,
 S.StoreKey,
 s.quantity,

 p.product_name,
 p.category,
 p.brand,
 p.unit_cost_USD,
 p.unit_price_USD,

 c.country,

 st.country as store_country,

 s.quantity * p.unit_price_USD as Revenue,
 s.quantity * p.unit_cost_USD as Cost,
 (s.quantity * p.unit_price_USD) - ( s.quantity * p.unit_cost_USD) as Profit

 From Sales s
 INNER JOIN Customers c
 On S.CustomerKey = C.CustomerKey
 INNER JOIN Products p
 On S.ProductKey = P.ProductKey
 INNER JOIN Stores st
 On S.StoreKey = St.StoreKey
 Where p.unit_cost_USD IS NOT NULL
 ),

 product_summary AS (
    SELECT
        product_name,
        SUM(Revenue) AS product_revenue,
        SUM(Profit) AS product_profit
    FROM base_data
    GROUP BY product_name
),

total AS (
    SELECT SUM(product_revenue) AS total_revenue
    FROM product_summary
)

SELECT TOP 10
    ps.product_name,
    ps.product_revenue,
    ps.product_profit,
    ROW_NUMBER() OVER (ORDER BY ps.product_revenue DESC) AS rank,
    ps.product_revenue * 1.0 / t.total_revenue AS revenue_pct
FROM product_summary ps
CROSS JOIN total t
ORDER BY ps.product_revenue DESC

 -- This query gives us product_name, product_revenue, product_profit, ranks the products by revenue, and tells us what percentage of the total revenue they make up. --

 WITH base_data AS (
    -- your same base CTE
    SELECT
        s.Order_Number,
        s.CustomerKey,
        s.ProductKey,
        s.StoreKey,
        s.Quantity,
        p.product_name,
        p.category,
        p.brand,
        p.unit_cost_USD,
        p.unit_price_USD,
        c.country,
        st.country AS store_country,
        s.quantity * p.unit_price_USD AS Revenue,
        s.quantity * p.unit_cost_USD AS Cost,
        (s.quantity * p.unit_price_USD) - (s.quantity * p.unit_cost_USD) AS Profit
    FROM Sales s
    JOIN Customers c ON s.CustomerKey = c.CustomerKey
    JOIN Products p ON s.ProductKey = p.ProductKey
    JOIN Stores st ON s.StoreKey = st.StoreKey
    WHERE p.unit_cost_USD IS NOT NULL
),

product_summary AS (
    SELECT
        product_name,
        SUM(Revenue) AS product_revenue
    FROM base_data
    GROUP BY product_name
),

top_10 AS (
    SELECT TOP 10
        product_name,
        product_revenue
    FROM product_summary
    ORDER BY product_revenue DESC
),

total AS (
    SELECT SUM(product_revenue) AS total_revenue
    FROM product_summary
)

SELECT
    SUM(t.product_revenue) * 100.0 / MAX(tot.total_revenue) AS top_10_revenue_pct
FROM top_10 t
CROSS JOIN total tot;

-- This query turns the top 10 into its own table and gives us the sum of the profit percentage of the top 10. This allows us to see exactly how much the top 10 products dominate the total profit.--
--Revenue is highly distributed across the product catalog, with the top 10 products contributing only 7.88% of total revenue. 
--This indicates a lstructure where performance is not driven by a small set of hero products, reducing dependency risk but increasing complexity in optimization and inventory management.
 
-- Revenue vs Profit Insights: The top revenue and top profit products largely overlap, indicating a strong alignment between sales volume and profitability. 
--This suggests a consistent margin structure across products, where higher-selling items also contribute proportionally to profit.
 
 -- Now we are going to look at profit instead of revenue --

 With base_data AS (
 Select
 s.Order_Number,
 S.CustomerKey,
 S.ProductKey,
 S.StoreKey,
 s.quantity,

 p.product_name,
 p.category,
 p.brand,
 p.unit_cost_USD,
 p.unit_price_USD,

 c.country,

 st.country as store_country,

 s.quantity * p.unit_price_USD as Revenue,
 s.quantity * p.unit_cost_USD as Cost,
 (s.quantity * p.unit_price_USD) - ( s.quantity * p.unit_cost_USD) as Profit

 From Sales s
 INNER JOIN Customers c
 On S.CustomerKey = C.CustomerKey
 INNER JOIN Products p
 On S.ProductKey = P.ProductKey
 INNER JOIN Stores st
 On S.StoreKey = St.StoreKey
 Where p.unit_cost_USD IS NOT NULL
 ),

 product_summary AS (
    SELECT
        product_name,
        SUM(Revenue) AS product_revenue,
        SUM(Profit) AS product_profit
    FROM base_data
    GROUP BY product_name
),

total AS (
    SELECT SUM(product_profit) AS total_profit
    FROM product_summary
)

SELECT TOP 10
    ps.product_name,
    ps.product_revenue,
    ps.product_profit,
    ROW_NUMBER() OVER (ORDER BY ps.product_profit DESC) AS rank,
    ps.product_profit * 1.0 / t.total_profit AS revenue_pct
FROM product_summary ps
CROSS JOIN total t
ORDER BY ps.product_profit DESC

-- This query gives us product_name, product_revenue, product_profit, ranks the products by profit, and tells us what percentage of the total revenue they make up. --

 WITH base_data AS (
    SELECT
        s.Order_Number,
        s.CustomerKey,
        s.ProductKey,
        s.StoreKey,
        s.Quantity,
        p.product_name,
        p.category,
        p.brand,
        p.unit_cost_USD,
        p.unit_price_USD,
        c.country,
        st.country AS store_country,
        s.quantity * p.unit_price_USD AS Revenue,
        s.quantity * p.unit_cost_USD AS Cost,
        (s.quantity * p.unit_price_USD) - (s.quantity * p.unit_cost_USD) AS Profit
    FROM Sales s
    JOIN Customers c ON s.CustomerKey = c.CustomerKey
    JOIN Products p ON s.ProductKey = p.ProductKey
    JOIN Stores st ON s.StoreKey = st.StoreKey
    WHERE p.unit_cost_USD IS NOT NULL
),

product_summary AS (
    SELECT
        product_name,
        SUM(profit) AS product_profit
    FROM base_data
    GROUP BY product_name
),

top_10 AS (
    SELECT TOP 10
        product_name,
        product_profit
    FROM product_summary
    ORDER BY product_profit DESC
),

total AS (
    SELECT SUM(product_profit) AS total_profit
    FROM product_summary
)

SELECT
    SUM(t.product_profit) * 100.0 / MAX(tot.total_profit) AS top_10_profit_pct
FROM top_10 t
CROSS JOIN total tot;

-- This query gave us the sum of the percentage of the top 10 profitable products --

-- Insights: Although revenue is broadly distributed across the product catalog, profit is more concentrated among a smaller group of products. 
--This suggests that not all high-revenue products contribute equally to profitability, highlighting the importance of margin-focused analysis.
 
 
-- Here we will look at the revenue and profit of product categories --

 With base_data AS (
 Select
 s.Order_Number,
 S.CustomerKey,
 S.ProductKey,
 S.StoreKey,
 s.quantity,

 p.product_name,
 p.category,
 p.brand,
 p.unit_cost_USD,
 p.unit_price_USD,

 c.country,

 st.country as store_country,

 s.quantity * p.unit_price_USD as Revenue,
 s.quantity * p.unit_cost_USD as Cost,
 (s.quantity * p.unit_price_USD) - ( s.quantity * p.unit_cost_USD) as Profit

 From Sales s
 INNER JOIN Customers c
 On S.CustomerKey = C.CustomerKey
 INNER JOIN Products p
 On S.ProductKey = P.ProductKey
 INNER JOIN Stores st
 On S.StoreKey = St.StoreKey
 Where p.unit_cost_USD IS NOT NULL
 )

 Select
 category,
 Sum(revenue) as category_revenue,
 Sum(profit) as category_profit
 From base_data
 Group by category
 Order by category_profit desc


 -- Category Insights: While Computers is the most profitable category overall, profitability within the category is heavily concentrated in desktop products, suggesting that a small subset of SKUs drives most of the value. 
 -- Similarly, televisions also appear among the top profit-generating products, indicating that the TV & Video category contains additional high-value products beyond the category average. --
 
  With base_data AS (
 Select
 s.Order_Number,
 S.CustomerKey,
 S.ProductKey,
 S.StoreKey,
 s.quantity,

 p.product_name,
 p.category,
 p.brand,
 p.unit_cost_USD,
 p.unit_price_USD,

 c.country,

 st.country as store_country,

 s.quantity * p.unit_price_USD as Revenue,
 s.quantity * p.unit_cost_USD as Cost,
 (s.quantity * p.unit_price_USD) - ( s.quantity * p.unit_cost_USD) as Profit

 From Sales s
 INNER JOIN Customers c
 On S.CustomerKey = C.CustomerKey
 INNER JOIN Products p
 On S.ProductKey = P.ProductKey
 INNER JOIN Stores st
 On S.StoreKey = St.StoreKey
 Where p.unit_cost_USD IS NOT NULL
 ),

 Ranked_Products as (
 Select
 Product_name,
 category,
 Sum(revenue) as total_revenue,
 Sum(profit) as total_profit,
 Row_Number() OVER (Partition by category order by SUM(profit) desc) as product_rank
 From base_data
 Group by category, product_name
 )

 Select *
 From ranked_products
 Where product_rank <= 3
 Order by category, product_rank

 -- This query gives us the top 3 products for each category -- 

WITH base_data AS (
    SELECT
        s.Order_Number,
        s.CustomerKey,
        s.ProductKey,
        s.StoreKey,
        s.Quantity,
        p.product_name,
        p.category,
        p.brand,
        p.unit_cost_USD,
        p.unit_price_USD,
        c.country,
        st.country AS store_country,
        s.quantity * p.unit_price_USD AS Revenue,
        s.quantity * p.unit_cost_USD AS Cost,
        (s.quantity * p.unit_price_USD) - (s.quantity * p.unit_cost_USD) AS Profit
    FROM Sales s
    JOIN Customers c ON s.CustomerKey = c.CustomerKey
    JOIN Products p ON s.ProductKey = p.ProductKey
    JOIN Stores st ON s.StoreKey = st.StoreKey
    WHERE p.unit_cost_USD IS NOT NULL
),

category_profit AS (
    SELECT
        category,
        SUM(Profit) AS total_category_profit
    FROM base_data
    GROUP BY category
),

total AS (
    SELECT
        SUM(total_category_profit) AS total_profit
    FROM category_profit
)

SELECT
    cp.category,
    cp.total_category_profit,
    cp.total_category_profit * 100.0 / t.total_profit AS profit_pct
FROM category_profit cp
CROSS JOIN total t
ORDER BY profit_pct DESC;

--Key Insights on the categories: 

-- Profitability is concentrated at the category level, with Computers alone accounting for 35% of total profit and the top three categories contributing nearly two-thirds overall.
--However, at the product level, profit is highly fragmented, with no single product contributing more than 1%.
--This indicates that performance is driven by strong categories rather than individual high-performing products.

-- Section 2: Customer Insights -- 

With base_data AS (
 Select
 s.Order_Number,
 S.CustomerKey,
 S.ProductKey,
 S.StoreKey,
 s.quantity,

 p.product_name,
 p.category,
 p.brand,
 p.unit_cost_USD,
 p.unit_price_USD,

 c.country,
 c.Name,
 c.Gender,

 st.country as store_country,

 s.quantity * p.unit_price_USD as Revenue,
 s.quantity * p.unit_cost_USD as Cost,
 (s.quantity * p.unit_price_USD) - ( s.quantity * p.unit_cost_USD) as Profit

 From Sales s
 INNER JOIN Customers c
 On S.CustomerKey = C.CustomerKey
 INNER JOIN Products p
 On S.ProductKey = P.ProductKey
 INNER JOIN Stores st
 On S.StoreKey = St.StoreKey
 Where p.unit_cost_USD IS NOT NULL
 ),

 customer_summary as (
 Select name,
 CustomerKey,
 Sum(profit) as total_customer_profit
 From base_data
 Group by name, CustomerKey
 ),

 top_10 AS (
    SELECT TOP 10
        name,
        total_customer_profit
    FROM customer_summary
    ORDER BY total_customer_profit DESC
),

 total as (
 Select Sum(total_customer_profit) as total_profit
 From customer_summary
 )

 SELECT
    SUM(t.total_customer_profit) * 100.0 / MAX(tot.total_profit) AS top_10_profit_pct
FROM top_10 t
CROSS JOIN total tot;

-- This query gives us the percentage of the total profit between only the top 10 customers --

-- Customer Insights: --
--Profitability is concentrated at the category level but broadly distributed across both products and customers, suggesting business performance is driven more by strong category demand across a diversified customer base than by dependence on individual products or high-value customers. --

With base_data AS (
 Select
 s.Order_Number,
 S.CustomerKey,
 S.ProductKey,
 S.StoreKey,
 s.quantity,

 p.product_name,
 p.category,
 p.brand,
 p.unit_cost_USD,
 p.unit_price_USD,

 c.country,
 c.Name,
 c.Gender,

 st.country as store_country,

 s.quantity * p.unit_price_USD as Revenue,
 s.quantity * p.unit_cost_USD as Cost,
 (s.quantity * p.unit_price_USD) - ( s.quantity * p.unit_cost_USD) as Profit

 From Sales s
 INNER JOIN Customers c
 On S.CustomerKey = C.CustomerKey
 INNER JOIN Products p
 On S.ProductKey = P.ProductKey
 INNER JOIN Stores st
 On S.StoreKey = St.StoreKey
 Where p.unit_cost_USD IS NOT NULL
 ),

 customer_summary as (
 Select
 CustomerKey,
 Name,
 count(distinct order_number) as total_orders,
 Sum(profit) as total_customer_profit
 From base_data
 Group by CustomerKey, Name
 ),

 customer_categories as (
 Select 
 CustomerKey,
 Name,
 total_orders,
 total_customer_profit,
 Case
    When total_orders = 1 Then 'One_Time'
    When total_orders BETWEEN 2 and 5 Then 'Repeat'
    When total_orders >= 6 Then 'Loyal'
End as customer_category
From customer_summary
),

category_totals as (
Select Sum(total_customer_profit) as total_profit
From customer_categories
)

 Select 
 customer_category,
 Count(CustomerKey) as customer_count,
 Sum(total_customer_profit) as total_category_profit,
 AVG(total_customer_profit) as average_profit,
 Sum(total_customer_profit)*100.0/MAX(total_profit) as profit_pct
 From customer_categories
 CROSS JOIN category_totals ct
 Group by customer_category
 

 -- In this query we grouped customers into One-Time, Repeat, and loyal customers. --
 -- We made a CTE for the customer summary and then another CTE for our case statements to create the categories--
 -- We also found the percentage of profit that each category made up --

 -- Key insights on customer categories: -
 -- Profit is primarily driven by repeat customers, not one-time or highly loyal segments.
 -- While loyal customers generate the highest profit per customer, they are too few to significantly influence overall profitability. --