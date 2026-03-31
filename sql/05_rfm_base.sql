WITH analysis_date AS (
    SELECT MAX(order_purchase_timestamp::timestamp) + INTERVAL '1 day' AS analysis_date
    FROM order_summary_view
),
rfm AS (
    SELECT
        osv.customer_unique_id,
        (SELECT analysis_date FROM analysis_date)::date
            - MAX(osv.order_purchase_timestamp::timestamp)::date AS recency,
        COUNT(osv.order_id) AS frequency,
        SUM(osv.order_revenue) AS monetary
    FROM order_summary_view osv
    GROUP BY osv.customer_unique_id
)
SELECT *
FROM rfm
LIMIT 10;

WITH analysis_date AS (
    SELECT MAX(order_purchase_timestamp::timestamp) + INTERVAL '1 day' AS analysis_date
    FROM order_summary_view
),
rfm AS (
    SELECT
        osv.customer_unique_id,
        (SELECT analysis_date FROM analysis_date)::date
            - MAX(osv.order_purchase_timestamp::timestamp)::date AS recency,
        COUNT(osv.order_id) AS frequency,
        SUM(osv.order_revenue) AS monetary
    FROM order_summary_view osv
    GROUP BY osv.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    ROUND(AVG(recency)::numeric, 2) AS avg_recency,
    ROUND(AVG(frequency)::numeric, 4) AS avg_frequency,
    ROUND(AVG(monetary)::numeric, 2) AS avg_monetary,
    MIN(recency) AS min_recency,
    MAX(recency) AS max_recency,
    MAX(frequency) AS max_frequency,
    MAX(monetary) AS max_monetary
FROM rfm;