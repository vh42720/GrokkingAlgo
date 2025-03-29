-- **Q1**
/*
**Table "books"  **                      **Table "authors"**
+------------------+-----------+    +-------------+-----------+
|      Column      |   Type    |    |   Column    |   Type    |
+------------------+-----------+    +-------------+-----------+
+->| book_id          | INT (KEY) | +->| author_id   | INT (KEY) |
|  | title            | VARCHAR   | |  | first_name  | VARCHAR   |
|  | author_id        | INT >-----|-+  | last_name   | VARCHAR   |
|  | publication_date | DATE      |    | birthday    | DATE      |
|  | category         | VARCHAR   |    | website_url | VARCHAR   |
|  | price            | DOUBLE    |    +-------------+-----------+
|  +------------------+-----------+
|
|  Table "transactions"                Table "customers"
|  +------------------+-----------+    +--------------------------+-----------+
|  |      Column      |   Type    |    |         Column           |   Type    |
|  +------------------+-----------+    +--------------------------+-----------+
|  | transaction_id   | INT (KEY) | +->| customer_id              | INT (KEY) |<-+
+-<| book_id          | INT       | |  | first_name               | VARCHAR   |  |
| customer_id      | INT >-----|-+  | last_name                | VARCHAR   |  |
| payment_amount   | DOUBLE    |    | registration_date        | DATE      |  |
| book_count       | INT       |    | interested_in_categories | VARCHAR   |  |
| tax_rate         | DOUBLE    |    | is_rewards_member        | BOOLEAN   |  |
| discount_rate    | DOUBLE    |    | invited_by_customer_id   | INT >-----|--+
| transaction_date | DATE      |    +--------------------------+-----------+
| payment_type     | VARCHAR   |
+------------------+-----------+
*/

-- Please write your query here

/* Question #1: What was the total number of sold books and the unique number
of sold books, grouped and sorted in descending order by payment_type?
Expected output:
payment_type | total_sold_books | unique_sold_books
--------------+------------------+-------------------
cheque       |              601 |               151
cash         |             5301 |               561
card         |            27826 |               630
*/


select payment_type,
sum(book_count) as total_sold_books,
count(distinct book_id) as unique_sold_books
from transactions
group by 1
order by 1 desc

-- **Q2**
/* Existing customers can invite other people to join the bookstore.
Question #2: Find the top 3 customers ordered by the total sales value
of the people they directly invited.
Expected output:
customer_id_who_invited_people | sales_value_of_invited_people
--------------------------------+-------------------------------
88 |                      46175.30
1 |                      38347.05
352 |                      37895.20
*/

select c.invited_by_customer_id, sum(book_count)
from transactions t
left join customers c on t.customer_id = c.customer_id
where c.invited_by_customer_id is not null
group by c.invited_by_customer_id
order by 2 desc
limit 3


/* Anyone can register a new author in the bookstore (even if they don't offer a book).
Question #3: Find the number of authors who have website URLs prefixed with "http://"
and that never made a sale. Compare this with the total number of authors.
Expected output:
authors_with_http_and_no_sales | authors_in_total
--------------------------------+------------------
13 |              300
*/

with authors_with_sales as(
    select distinct author_id
    from transactions t
    join books b on t.book_id = b.book_id
)
select
from authors a
left join authors_with_sales aws a

with authors_with_sales as (
    select distinct b.author_id
    from books b
    join transactions t on b.book_id = b.book_id
)
select
    sum(case when aws.author_id is null and a.website_url like '%https//%' then 1 else 0) authors_with_http_and_no_sales,
    count(*) as total_authors
from authors a
left join authors_with_sales aws on aws.author_id = a.author_id


Other possible questions:
1. Find customers who purchased from the same author with at least two categories and the total sales of these books
2. For each customer, find the total number of books and total number of unique books they purchased
3. Find top two months with unique customers who made purchases this month and the previous month


SELECT
  c.customer_id,
  b.author_id,
  COUNT(DISTINCT b.category) AS num_cat,
  SUM(t.payment_amount) AS total_sales
FROM customers c
JOIN transactions t ON t.customer_id = c.customer_id
JOIN books b ON t.book_id = b.book_id
GROUP BY c.customer_id, b.author_id
HAVING COUNT(DISTINCT b.category) >= 2;

SELECT
    c.customer_id,
    SUM(t.book_count) AS total_books_purchased,
    COUNT(DISTINCT b.book_id) AS unique_books_purchased
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
LEFT JOIN books b ON t.book_id = b.book_id
GROUP BY c.customer_id;


with monthly_cust as (
    select distinct customer_id, date_trunc('month', transaction_date) as month
    from transactions
),
customer_in_both as (
    select
    from monthly_cust curr
    join monthly_cust prev on curr.customer_id = prev.customer_id
        and curr.month = prev.month + interval '1 month'
)
select month, count(distinct customer_id) as unique
from customer_in_both
group by month



with monthly_cust as (
    select distinct customer_id, date_trunc('month', transaction_date) as month
    from transactions
),
customers_in_both as (
    select curr.month, curr.customer_id
    from monthly_cust curr
    join monthly_cust prev on curr.customer_id = prev.customer_id
        AND curr.month = prev.month + interval '1 month'
)
select month,
       count(distinct customer_id) as unique_customers
from customers_in_both
group by month
order by count(distinct customer_id) desc
limit 2;
