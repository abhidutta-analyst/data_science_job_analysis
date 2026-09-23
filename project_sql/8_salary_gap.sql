/*
Question: How much more do remote data jobs pay compared to onsite ones?
- Filter core data roles with non-null yearly salary.
- Compare average remote vs onsite salary per role and compute the premium in dollars and percent.
- Why? Quantifies the salary gap so candidates can evaluate remote offers fairly.
*/

WITH role_salaries AS (
    SELECT job_title_short, job_work_from_home, salary_year_avg
    FROM job_postings_fact
    WHERE job_title_short IN (
        'Data Analyst','Data Scientist','Data Engineer','Machine Learning Engineer'
    )
    AND salary_year_avg IS NOT NULL
)
SELECT
    job_title_short,
    ROUND(AVG(salary_year_avg) FILTER (WHERE job_work_from_home = TRUE)::numeric, 0) AS avg_remote_salary,
    ROUND(AVG(salary_year_avg) FILTER (WHERE job_work_from_home = FALSE)::numeric, 0) AS avg_onsite_salary,
    ROUND(
        AVG(salary_year_avg) FILTER (WHERE job_work_from_home = TRUE)
        - AVG(salary_year_avg) FILTER (WHERE job_work_from_home = FALSE),
        0
    ) AS remote_premium,
    ROUND(
        100.0 * (
            AVG(salary_year_avg) FILTER (WHERE job_work_from_home = TRUE)
            - AVG(salary_year_avg) FILTER (WHERE job_work_from_home = FALSE)
        ) / NULLIF(AVG(salary_year_avg) FILTER (WHERE job_work_from_home = FALSE), 0),
        2
    ) AS remote_premium_pct
FROM role_salaries
GROUP BY job_title_short
ORDER BY remote_premium DESC;
