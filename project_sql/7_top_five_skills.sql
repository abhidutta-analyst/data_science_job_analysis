/*
Question: What are the top 5 most in-demand skills for each data role?
- Join job postings to skills, filter the four core data roles, and count postings per skill.
- Rank skills within each role using ROW_NUMBER and keep the top 5.
- Why? Shows exactly which skills to prioritise for a chosen career path.
*/

WITH skill_counts AS (
    SELECT
        jp.job_title_short,
        sd.skills,
        COUNT(DISTINCT jp.job_id) AS skill_demand
    FROM job_postings_fact jp
    JOIN skills_job_dim sj
        ON sj.job_id = jp.job_id
    JOIN skills_dim sd
        ON sd.skill_id = sj.skill_id
    WHERE jp.job_title_short IN (
        'Data Analyst',
        'Data Scientist',
        'Data Engineer',
        'Machine Learning Engineer'
    )
    GROUP BY
        jp.job_title_short,
        sd.skills
),
ranked_skills AS (
    SELECT
        job_title_short,
        skills,
        skill_demand,
        ROW_NUMBER() OVER (
            PARTITION BY job_title_short
            ORDER BY skill_demand DESC, skills
        ) AS skill_rank
    FROM skill_counts
)
SELECT
    job_title_short,
    skill_rank,
    skills,
    skill_demand
FROM ranked_skills
WHERE skill_rank <= 5
ORDER BY
    job_title_short,
    skill_rank;