/*
Question: Which skills appear together most often in job postings?
- Self-join job-skill pairs to build combinations and count postings per pair.
- Compute confidence and lift to measure how strongly the two skills co-occur.
- Why? Reveals natural skill bundles employers expect so learners study complementary tools together.
*/


WITH job_skills AS (
    SELECT
        sj.job_id,
        sd.skills
    FROM skills_job_dim sj
    JOIN skills_dim sd
        ON sd.skill_id = sj.skill_id
),
skill_pairs AS (
    SELECT
        a.skills AS skill_a,
        b.skills AS skill_b,
        COUNT(DISTINCT a.job_id) AS pair_count
    FROM job_skills a
    JOIN job_skills b
        ON a.job_id = b.job_id
       AND a.skills < b.skills
    GROUP BY
        a.skills,
        b.skills
    HAVING COUNT(DISTINCT a.job_id) >= 100
),
skill_totals AS (
    SELECT
        skills,
        COUNT(DISTINCT job_id) AS skill_count
    FROM job_skills
    GROUP BY skills
),
total_jobs AS (
    SELECT COUNT(DISTINCT job_id) AS n
    FROM job_skills
)
SELECT
    sp.skill_a,
    sp.skill_b,
    sp.pair_count,
    st_a.skill_count AS skill_a_count,
    st_b.skill_count AS skill_b_count,
    ROUND(
        100.0 * sp.pair_count / NULLIF(st_a.skill_count, 0),
        2
    ) AS confidence_a_to_b,
    ROUND(
        100.0 * sp.pair_count / NULLIF(st_b.skill_count, 0),
        2
    ) AS confidence_b_to_a,
    ROUND(
        1.0 * sp.pair_count * tj.n
        / NULLIF(st_a.skill_count * st_b.skill_count, 0),
        2
    ) AS lift
FROM skill_pairs sp
JOIN skill_totals st_a
    ON st_a.skills = sp.skill_a
JOIN skill_totals st_b
    ON st_b.skills = sp.skill_b
CROSS JOIN total_jobs tj
ORDER BY
    lift DESC,
    pair_count DESC
LIMIT 20;
