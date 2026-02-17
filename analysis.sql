/*
Project: GoodThought NGO Impact Analysis (DataCamp)
Database: PostgreSQL
Tables: assignments, donations, donors
Time range: 2010–2023 (per project description)
*/

-- ============================================================
-- 1) highest_donation_assignments
-- ============================================================

/*
Query: highest_donation_assignments

Goal:
Identify the top five assignments by total donation value, broken out by donor type.

Output:
- assignment_name
- region
- rounded_total_donation_amount
- donor_type
*/

WITH assignment_donation_totals AS (
    SELECT
        d.assignment_id,
        donors.donor_type,
        ROUND(SUM(d.amount), 2) AS rounded_total_donation_amount
    FROM donations AS d
    JOIN donors
        ON d.donor_id = donors.donor_id
    GROUP BY
        d.assignment_id,
        donors.donor_type
)

SELECT
    a.assignment_name,
    a.region,
    adt.rounded_total_donation_amount,
    adt.donor_type
FROM assignment_donation_totals AS adt
JOIN assignments AS a
    ON adt.assignment_id = a.assignment_id
ORDER BY
    adt.rounded_total_donation_amount DESC
LIMIT 5;

-- ============================================================
-- 2) top_regional_impact_assignments
-- ============================================================

/*
Query: top_regional_impact_assignments

Goal:
For each region, return the single assignment with the highest impact_score,
including only assignments that have received at least one donation.

Output:
- assignment_name
- region
- impact_score
- num_total_donations
*/

WITH donated_assignments AS (
    SELECT
        a.assignment_id,
        a.assignment_name,
        a.region,
        a.impact_score,
        COUNT(*) AS num_total_donations
    FROM donations AS d
    JOIN assignments AS a
        ON d.assignment_id = a.assignment_id
    GROUP BY
        a.assignment_id,
        a.assignment_name,
        a.region,
        a.impact_score
),
ranked_by_region AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY impact_score DESC, assignment_id ASC
        ) AS impact_rank
    FROM donated_assignments
)

SELECT
    assignment_name,
    region,
    impact_score,
    num_total_donations
FROM ranked_by_region
WHERE impact_rank = 1
ORDER BY region ASC;
