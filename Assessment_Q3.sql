/*
Task: Find all active accounts (savings or investments) with no transactions 
in the last 1 year (365 days) .
*/

-- Select active savings & investment accounts with transaction date and inactive days
SELECT
    p.id AS plan_id,
    p.owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
    END AS type,
    MAX(CAST(s.transaction_date AS DATE)) AS last_transaction_date, -- Ensures DATE-only format
    DATEDIFF(CURDATE(), MAX(CAST(s.transaction_date AS DATE))) AS inactivity_days
FROM adashi_staging.plans_plan AS p
-- Include only inflow transactions i.e. confirmed_amount > 0
LEFT JOIN adashi_staging.savings_savingsaccount AS s
    ON p.id = s.plan_id
    AND s.confirmed_amount > 0
WHERE
    p.is_deleted = 0 -- Not deleted (Active accounts)
    AND p.is_archived = 0 -- Not archived (Active accounts)
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
GROUP BY p.id, p.owner_id, type
-- Filter for active accounts with no transactions ever OR no inflow in the last 365 days
HAVING
    last_transaction_date IS NULL -- No transactions
    OR inactivity_days > 365
ORDER BY inactivity_days DESC;