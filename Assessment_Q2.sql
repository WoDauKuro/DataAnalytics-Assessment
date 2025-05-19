/*
Task: 
Calculate the average number of transactions per customer per month and categorize them:
	- "High Frequency" (≥10 transactions/month)
	- "Medium Frequency" (3-9 transactions/month)
	- "Low Frequency" (≤2 transactions/month)
*/

-- Count customer transaction frequency by Month
-- Note: Excludes records with NULL transaction dates
WITH MonthlyTransactions AS (
    SELECT
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
        COUNT(*) AS transaction_count
    FROM adashi_staging.savings_savingsaccount
    WHERE transaction_date IS NOT NULL
    GROUP BY owner_id, transaction_month
),

-- Calculate customer Average Monthly transaction count
CustomerAverages AS (
    SELECT
        owner_id,
        AVG(transaction_count) AS avg_transactions_per_month
    FROM MonthlyTransactions
    GROUP BY owner_id
)

-- Group & count customers based on Average transaction frequency
SELECT
    CASE
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM CustomerAverages
GROUP BY frequency_category
ORDER BY avg_transactions_per_month DESC;