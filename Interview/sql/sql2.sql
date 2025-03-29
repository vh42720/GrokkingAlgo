     # sales                             # products
        |-------------------|               |-------------------|
        | product_id        | INTEGER >-----| product_id        | INTEGER
        | store_id          | INTEGER   +--<| product_class_id  | INTEGER
   +---<| customer_id       | INTEGER   |   | brand_name        | VARCHAR
   |    | promotion_id      | INTEGER   |   | product_name      | VARCHAR
   |    | store_sales       | DECIMAL   |   | is_low_fat_flg    | TINYINT
   |    | store_cost        | DECIMAL   |   | is_recyclable_flg | TINYINT
   |    | units_sold        | DECIMAL   |   | gross_weight      | DECIMAL
   |    | transaction_date  | DATE      |   | net_weight        | DECIMAL
   |    |-------------------|           |   |-------------------|
   |                                    |
   |     # promotions                   |     # product_classes
   |    |-------------------|           |   |------------------------|
   +----| promotion_id      | INTEGER   +---| product_class_id       | INTEGER
        | promotion_name    | VARCHAR       | product_subcategory    | VARCHAR
        | media_type        | VARCHAR       | product_category       | VARCHAR
        | cost              | DECIMAL       | product_department     | VARCHAR
        | start_date        | DATE          | product_family         | VARCHAR
        | end_date          | DATE          |------------------------|
        |-------------------|


Write SQL to answer the following questions:
1. What percentage of products are both low-fat and recyclable?
2. What are the top five single-channel media types based on promotional spending?
3. For sales with valid promotions, what percentage of transactions occur on the first or last day of the campaign?
4. Show total units sold for each product family and the ratio of promoted to non-promoted sales, sorted by total units sold.

select sum(case when is_low_fat_flg = 1 and is_recyclable_flg = 1 then 1 else 0 end) / count(product_id) as percentage
from products;

select media_type as single_channel_media_type, sum(cost)
from promotion
where media_type not like '%,%'
group by 1
order by sum(cost) desc
limit 5











select sum(case when transaction_date = start_date or transaction_date = end_date then 1 else 0 end) / count(*)
from sales s
join promotion p on s.promotion_id = p.promotion_id
where s.transaction_date between p.start_date and p.end_date

select ps.product_family
    , sum(units_sold) as total_unit_sold
    , sum(case when promotion_id is not null then 1 else 0 end) / sum(case when promotion_id is null then 1 else 0 end) as ratio
from products p
join product_classes ps on p.product_class_id = ps.product_class_id
left join sales on p.product_id = s.product_id
left join promotions pr on pr.promotion_id = s.promotion_id
group by 1

