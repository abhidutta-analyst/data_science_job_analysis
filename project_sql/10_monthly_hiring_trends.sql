/*
Question: How has monthly demand for each data role changed through 2023?
- Count postings per role per month and use LAG for month-over-month growth.
- Add a rolling 3-month average to smooth short-term spikes.
- Why? Highlights seasonal patterns and whether demand is growing or slowing per role.
*/

WITH monthly_postings AS (
    SELECT
        DATE_TRUNC('month', jp.job_posted_date)::date AS month_start,
        jp.job_title_short,
        COUNT(*) AS postings
    FROM job_postings_fact jp
    WHERE jp.job_posted_date >= '2023-01-01'
      AND jp.job_posted_date < '2024-01-01'
      AND jp.job_title_short IN (
          'Data Analyst','Data Scientist','Data Engineer','Machine Learning Engineer'
      )
    GROUP BY DATE_TRUNC('month', jp.job_posted_date)::date, jp.job_title_short
),
trend AS (
    SELECT
        month_start,
        job_title_short,
        postings,
        LAG(postings) OVER (
            PARTITION BY job_title_short ORDER BY month_start
        ) AS prev_month_postings,
        AVG(postings) OVER (
            PARTITION BY job_title_short ORDER BY month_start
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3m_avg
    FROM monthly_postings
)
SELECT
    month_start,
    job_title_short,
    postings,
    prev_month_postings,
    ROUND(100.0 * (postings - prev_month_postings) / NULLIF(prev_month_postings, 0), 2) AS mom_growth_pct,
    ROUND(rolling_3m_avg::numeric, 1) AS rolling_3m_avg
FROM trend
ORDER BY job_title_short, month_start;
