DROP VIEW IF EXISTS order_summary_view;

CREATE VIEW order_summary_view AS
SELECT
    o.order_id,
    c.customer_unique_id,
    o.order_purchase_timestamp,
    o.order_status,
    COUNT(oi.order_item_id) AS items_count,
    SUM(oi.price) AS order_revenue,
    SUM(oi.freight_value) AS freight_total
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    o.order_id,
    c.customer_unique_id,
    o.order_purchase_timestamp,
    o.order_status;

SELECT COUNT(*) AS total_orders
FROM order_summary_view;

SELECT *
FROM order_summary_view
LIMIT 10;