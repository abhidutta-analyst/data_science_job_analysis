/*
Question: Which companies post the most data-related jobs, and how do their pay and remote-work patterns look?
- Join job_postings_fact to company_dim and keep only core data roles with 10+ postings.
- Aggregate postings, remote share, and average/median yearly salary per company.
- Why? Spot the biggest employers and see if they lean remote or high-paying.
*/

WITH company_postings AS (
    SELECT
        c.company_id,
        c.name AS company_name,
        COUNT(*) AS total_postings,
        COUNT(*) FILTER (
            WHERE jp.job_work_from_home = TRUE
        ) AS remote_postings,
        ROUND(
            100.0 * COUNT(*) FILTER (
                WHERE jp.job_work_from_home = TRUE
            ) / NULLIF(COUNT(*), 0),
            1
        ) AS remote_share_pct,
        ROUND(AVG(jp.salary_year_avg)::numeric, 0) AS avg_salary,
        ROUND(
            PERCENTILE_CONT(0.5) WITHIN GROUP (
                ORDER BY jp.salary_year_avg
            )::numeric,
            0
        ) AS median_salary
    FROM job_postings_fact jp
    JOIN company_dim c
        ON c.company_id = jp.company_id
    WHERE jp.job_title_short IN (
        'Data Analyst',
        'Data Scientist',
        'Data Engineer',
        'Machine Learning Engineer',
        'Senior Data Scientist',
        'Senior Data Engineer'
    )
    GROUP BY
        c.company_id,
        c.name
    HAVING COUNT(*) >= 10
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY total_postings DESC, avg_salary DESC NULLS LAST
    ) AS rank,
    company_name,
    total_postings,
    remote_postings,
    remote_share_pct,
    avg_salary,
    median_salary,
    ROUND(
        100.0 * total_postings / SUM(total_postings) OVER (),
        2
    ) AS pct_of_total_postings
FROM company_postings
ORDER BY total_postings DESC
LIMIT 15;