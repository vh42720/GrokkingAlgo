------------------------------------------------------------
-- Grocery Chain Schema Diagram
------------------------------------------------------------
--     # sales                             # products
--        |-------------------|               |-------------------|
--        | product_id        | INTEGER >-----| product_id        | INTEGER
--        | store_id          | INTEGER       | product_class_id  | INTEGER
--   +---<| customer_id       | INTEGER       | brand_name        | VARCHAR
--   |    | promotion_id      | INTEGER       | product_name      | VARCHAR
--   |    | store_sales       | DECIMAL       | is_low_fat_flg    | TINYINT
--   |    | store_cost        | DECIMAL       | is_recyclable_flg | TINYINT
--   |    | units_sold        | DECIMAL       | gross_weight      | DECIMAL
--   |    | transaction_date  | DATE          | net_weight        | DECIMAL
--   |    |-------------------|               |-------------------|
--   |
--   |     # promotions                   |     # product_classes
--   |    |-------------------|            |   |------------------------|
--   +----| promotion_id      | INTEGER      +---| product_class_id       | INTEGER
--        | promotion_name    | VARCHAR          | product_subcategory    | VARCHAR
--        | media_type        | VARCHAR          | product_category       | VARCHAR
--        | cost              | DECIMAL          | product_department     | VARCHAR
--        | start_date        | DATE             | product_family         | VARCHAR
--        | end_date          | DATE             |------------------------|
--        |-------------------|

-- 1. Product Quality:
--    - What percent of all products in the grocery chain's catalog are both low fat and recyclable?
--    (Hint: Use the products table and check is_low_fat_flg and is_recyclable_flg.)

-- 2. Promotional Campaign Spending:
--    - What are the top five single-channel media types (ranked in decreasing order)
--      that correspond to the most money spent on promotional campaigns?
--    (Hint: Use promotions.media_type and sum(promotions.cost) grouped by media_type.)

-- 3. Promotion Timing Analysis:
--    - For sales with a valid promotion, what percent of transactions occur on either the very first day
--      or the very last day of a promotion campaign?
--    (Hint: Join sales with promotions and compare transaction_date with start_date and end_date.)

-- 4. Brand and Product Analysis:
--    - Which brands have an average price above $3 and contain at least 2 different products?
--    (Hint: Average price might require joining with products and possibly aggregating price if available.)
select brand_name, avg(price), count(distinct product_id)
from product
group by brand_name
having avg(prive) > 3.0 and count(distinct product_id) >= 2

-- 5. Promotion Effectiveness:
--    - What percent of sales transactions had a valid promotion applied?
--    (Hint: Check for non-null promotion_id in sales.)
select sum(case when promotion_id is null then 0 else 1 end)*100.0 / count(*) as percentage
from sales

-- 6. Top Selling Product Classes:
--    - Find the top 3 selling product classes by total sales.
--    (Hint: Join sales with product_classes and group by product_class_id.)

SELECT
    pc.product_class_id,
    SUM(s.units_sold) AS total_sales
FROM product_classes pc
JOIN products p ON pc.product_class_id = p.product_class_id
LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY pc.product_class_id
ORDER BY total_sales DESC
LIMIT 3;

-- 7. Cross-Brand Customer Targeting:
--    - Identify customers who have bought products from both the “Fort West” and the “Golden” brands.
--    (Hint: Use sales and products, filtering on brand_name.)
select distinct s.customer_id
from sales s
join products p on s.product_id = p.product_id
where brand_name = 'Fort West' and brand_name = 'Golden'

-- 8. Additional Questions:
--    - What percentage of products have both non fat and trans fat?
--      (Note: This might require additional columns in products if not already present.)
--    - Find the top 5 sales products that had promotions.
--    - What percentage of sales happened on the first and last day of a promotion?
--    - Which product had the highest sales with promotions? (Use a WHERE clause on two flag columns as needed.)
--    - Analyze how promotions on certain products are performing by calculating the percentage of promoted sales.
--    - Get the top 3 product_class_ids by total sales.
--    - Calculate the percentage increase in revenue compared to promoted and non-promoted products.
--    - Identify the product classes that have the highest number of transactions.
--    - Count the number of customers who bought two types of items (for example, items A and B).
--
select product_id
from sales
where promotion_id is not null
group by product_id
order by sum(units_sold) desc
limit 5


select sum(case when transaction_date = p.start_date or transaction_date = p.end_date then 1 else 0 end)*100.00 / count(*) as percentage
from sales s
join promotion p on s.promotion_id = p.promotion_id

select p.product_id, p.product_name
    , count(*) as total_sales
    , sum(case when s.promotion_id is not null then units_sold else 0 end) as total_promoted_sales
    , 100.0 * SUM(CASE WHEN s.promotion_id IS NOT NULL THEN s.units_sold ELSE 0 END) / SUM(s.units_sold) AS promoted_sales_percentage
from product p
join sales s on p.product_id = s.product_id
group by p.product_id, p.product_name
