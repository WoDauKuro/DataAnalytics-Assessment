/* 
Task: 
Write a query to find customers with at least one funded savings plan AND 
one funded investment plan, sorted by total deposits.
*/

-- CTE to get funded savings plans
WITH funded_savings AS (
    SELECT DISTINCT p.owner_id
    FROM adashi_staging.plans_plan AS p
    JOIN adashi_staging.savings_savingsaccount AS s ON p.id = s.plan_id
    WHERE p.is_regular_savings = 1 AND s.confirmed_amount > 0
),

-- CTE to get funded investment plans
funded_investments AS (
    SELECT DISTINCT p.owner_id
    FROM adashi_staging.plans_plan AS p
    JOIN adashi_staging.savings_savingsaccount AS s ON p.id = s.plan_id
    WHERE p.is_a_fund = 1 AND s.confirmed_amount > 0
),

-- CTE to get users with valid transactions & sum total deposits per user
user_deposits AS (
    SELECT 
        u.id AS user_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        p.id AS plan_id,
        p.is_regular_savings,
        p.is_a_fund,
        s.confirmed_amount
    FROM adashi_staging.users_customuser AS u
    INNER JOIN adashi_staging.plans_plan AS p ON u.id = p.owner_id
    INNER JOIN adashi_staging.savings_savingsaccount AS s 
        ON p.id = s.plan_id
    WHERE s.confirmed_amount > 0
)

-- Select & count users meeting both conditions
SELECT 
    d.user_id AS owner_id,
    d.name,
    COUNT(DISTINCT CASE WHEN d.is_regular_savings = 1 THEN d.plan_id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN d.is_a_fund = 1 THEN d.plan_id END) AS investment_count,
    -- Convert total deposits to naira, rounded to 2 decimal places
    ROUND(SUM(d.confirmed_amount) * 0.01, 2) AS total_deposits
FROM user_deposits AS d
-- Ensure customers meet funding conditions
INNER JOIN funded_savings fs ON d.user_id = fs.owner_id
INNER JOIN funded_investments fi ON d.user_id = fi.owner_id
GROUP BY d.user_id
ORDER BY total_deposits DESC;
