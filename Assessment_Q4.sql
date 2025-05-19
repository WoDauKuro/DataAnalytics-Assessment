/*
Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
	- Account tenure (months since signup)
	- Total transactions
	- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
	- Order by estimated CLV from highest to lowest
*/

-- Calculate CLV using transaction count and Naira conversion
SELECT
    users.id AS customer_id,
    CONCAT(users.first_name, ' ', users.last_name) AS name,
    -- Tenure in months since signup
    TIMESTAMPDIFF(MONTH, users.date_joined, CURDATE()) AS tenure_months,
    -- Total transactions (count of funded transactions)
    COALESCE(COUNT(savings.id), 0) AS total_transactions,
     -- Estimated CLV calculation:
    -- 1. Convert confirmed_amount from kobo to Naira and apply 0.1% profit (0.00001 factor)
    -- 2. Sum these profits for each user
    -- 3. Divide by tenure_months to get monthly profit average (protect against division by zero using NULLIF)
    -- 4. Annualize by multiplying by 12
    -- 5. Round to 2 decimal places and default to 0 if no transactions or tenure is zero
    ROUND(
    COALESCE(
        (
            SUM(savings.confirmed_amount * 0.00001) / -- Converts kobo to Naira & applies 0.1% profit rate (because 0.001 × 0.01 = 0.00001)
            NULLIF(TIMESTAMPDIFF(MONTH, users.date_joined, CURDATE()), 0)
            * 12
        ), 0
    ), 2
) AS estimated_clv

FROM adashi_staging.users_customuser AS users
-- Join the deposit transactions table & filter for funded transactions
LEFT JOIN adashi_staging.savings_savingsaccount AS savings
    ON users.id = savings.owner_id
    AND savings.confirmed_amount > 0  -- Only funded transactions
GROUP BY users.id
ORDER BY estimated_clv DESC;