/*
Table "books"  **                      **Table "authors"**
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
+------------------+-----------+*/
--
-- 1. Sales volume and quantity by payment type:
--    - What was the total number of sold books and the unique number of sold books,
--      grouped and sorted in descending order by payment_type?
--    (Hint: Use transactions.payment_type, SUM(book_count), and COUNT(DISTINCT book_id).)


-- 2. Customer invitations:
--    - Customers can invite other customers. Find the top 5 inviters with the highest
--      average payment per book. (Calculate as sum(payment_amount)/sum(book_count).)
--    (Hint: Join customers with transactions and group by the inviter.)
--
-- 3. Author statistics:
--    - Count all authors.
--    - Find the proportion of authors whose website URLs match a certain pattern (e.g., '%.com%').
--    - Find the proportion of authors who have never sold a book (no sales associated via books).
--    (Hint: Use subqueries or JOINs with books and transactions.)
--
-- 4. Conceptual questions:
--    - What happens if none of the conditions in a CASE WHEN statement match and there is no ELSE statement?
--    - What is the difference between DROP and TRUNCATE?

