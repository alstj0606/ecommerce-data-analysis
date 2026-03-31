-- Raw table row counts
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS order_items_count FROM order_items;

-- Preview raw tables
SELECT * FROM orders LIMIT 5;
SELECT * FROM customers LIMIT 5;
SELECT * FROM order_items LIMIT 5;

-- Key structure check
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_order_id
FROM orders;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT customer_id) AS unique_customer_id,
       COUNT(DISTINCT customer_unique_id) AS unique_customer_unique_id
FROM customers;

SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_order_id
FROM order_items;