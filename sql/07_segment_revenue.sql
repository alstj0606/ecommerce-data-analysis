WITH analysis_date AS (
    SELECT MAX(order_purchase_timestamp::timestamp) + INTERVAL '1 day' AS analysis_date
    FROM order_summary_view
),
rfm_base AS (
    SELECT
        osv.customer_unique_id,
        (SELECT analysis_date FROM analysis_date)::date
            - MAX(osv.order_purchase_timestamp::timestamp)::date AS recency,
        COUNT(osv.order_id) AS frequency,
        SUM(osv.order_revenue) AS monetary
    FROM order_summary_view osv
    GROUP BY osv.customer_unique_id
),
rfm_score AS (
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        (6 - NTILE(5) OVER (ORDER BY recency ASC)) AS r_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score,
        CASE
            WHEN frequency >= 5 THEN 5
            WHEN frequency = 4 THEN 4
            WHEN frequency = 3 THEN 3
            WHEN frequency = 2 THEN 2
            ELSE 1
        END AS f_score
    FROM rfm_base
),
rfm_segment AS (
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        r_score + f_score + m_score AS rfm_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 2 AND m_score >= 4 THEN 'VIP'
            WHEN r_score >= 3 AND f_score >= 2 THEN 'Loyal'
            WHEN m_score >= 4 AND f_score = 1 THEN 'Big Spenders'
            WHEN r_score >= 4 AND f_score = 1 THEN 'Recent Customers'
            WHEN r_score <= 2 AND m_score >= 3 THEN 'At Risk'
            ELSE 'Hibernating'
        END AS segment
    FROM rfm_score
)
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND((COUNT(*)::numeric / SUM(COUNT(*)) OVER ()::numeric) * 100, 2) AS customer_share_pct,
    ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND(AVG(monetary)::numeric, 2) AS avg_revenue,
    ROUND((SUM(monetary)::numeric / SUM(SUM(monetary)) OVER ()::numeric) * 100, 2) AS revenue_share_pct,
    ROUND(
        (
            (SUM(monetary)::numeric / SUM(SUM(monetary)) OVER ()::numeric)
            /
            (COUNT(*)::numeric / SUM(COUNT(*)) OVER ()::numeric)
        )::numeric,
        2
    ) AS revenue_efficiency
FROM rfm_segment
GROUP BY segment
ORDER BY total_revenue DESC;