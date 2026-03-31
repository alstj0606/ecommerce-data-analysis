WITH customer_summary AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp::timestamp) AS first_order_date,
        MAX(order_purchase_timestamp::timestamp) AS last_order_date,
        COUNT(order_id) AS total_orders,
        SUM(order_revenue) AS total_revenue,
        SUM(freight_total) AS total_freight
    FROM order_summary_view
    GROUP BY customer_unique_id
)
SELECT *
FROM customer_summary
LIMIT 10;

WITH customer_summary AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp::timestamp) AS first_order_date,
        MAX(order_purchase_timestamp::timestamp) AS last_order_date,
        COUNT(order_id) AS total_orders,
        SUM(order_revenue) AS total_revenue,
        SUM(freight_total) AS total_freight
    FROM order_summary_view
    GROUP BY customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(
        SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END)::numeric
        / COUNT(*) * 100,
        2
    ) AS repeat_customer_ratio_pct
FROM customer_summary;