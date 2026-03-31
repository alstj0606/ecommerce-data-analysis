SELECT
    TO_CHAR(order_purchase_timestamp::timestamp, 'YYYY-MM') AS order_month,
    COUNT(order_id) AS total_orders,
    SUM(order_revenue) AS total_revenue,
    AVG(order_revenue) AS average_order_value
FROM order_summary_view
GROUP BY TO_CHAR(order_purchase_timestamp::timestamp, 'YYYY-MM')
ORDER BY order_month;

SELECT
    COUNT(order_id) AS total_orders,
    SUM(order_revenue) AS total_revenue,
    AVG(order_revenue) AS average_order_value
FROM order_summary_view;