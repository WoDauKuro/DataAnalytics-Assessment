# DataAnalytics-Assessment

## Overview
This repository contains SQL solutions to four business problems focused on customer analysis and transaction insights. Below are the approaches and challenges for each question.

---

## Repository Structure
- `Assessment_Q1.sql`: High-value customers with multiple products.
- `Assessment_Q2.sql`: Transaction frequency segmentation.
- `Assessment_Q3.sql`: Inactive account alerts.
- `Assessment_Q4.sql`: Customer lifetime value estimation.

---

## Per-Question Explanations

### **Question 1: High-Value Customers with Multiple Products**
**Task:** Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

**Approach**: 
- Used CTEs to isolate funded savings (`is_regular_savings = 1`) and investment (`is_a_fund = 1`) plans.  
- Joined CTEs to ensure customers have both types.  
- Concatenated `first_name` and `last_name` to resolve `NULL` values in `users.name`.
- Aggregated counts (`COUNT(DISTINCT CASE ... END`) and converted total deposits from kobo to Naira.

---

### Question 2: Transaction Frequency Analysis
**Task:** Calculate the average number of transactions per customer per month and categorize them:

    - "High Frequency" (≥10 transactions/month)
    - "Medium Frequency" (3-9 transactions/month)
    - "Low Frequency" (≤2 transactions/month)

**Approach**:  
- Created `MonthlyTransactions` CTE to count transactions per customer/month.  
- Calculated average transactions per customer in `CustomerAverages` CTE.  
- Used `CASE` to classify into High/Medium/Low frequency tiers. 
**NOTE:**
- Excluded `NULL` transaction dates with `WHERE transaction_date IS NOT NULL`.

---

### Question 3: Account Inactivity Alert
**Task:** Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days) .

**Approach**:  
- Combined savings (`is_regular_savings = 1`) and investment (`is_a_fund = 1`) plans.  
- Used `LEFT JOIN` to include accounts with no transactions.  
- Calculated `inactivity_days` with `DATEDIFF(CURDATE(), MAX(transaction_date))`.  
**Key Logic**:  
- Filtered active accounts via `is_deleted = 0` and `is_archived = 0`.  
- `HAVING` clause flagged accounts with `last_transaction_date IS NULL OR inactivity_days > 365`.

---

### Question 4: Customer Lifetime Value (CLV)
**Task:** For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:

    - Account tenure (months since signup)
    - Total transactions
    - Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
    - Order by estimated CLV from highest to lowest

**Approach**:  
- Concatenated `first_name` and `last_name` to resolve `NULL` values in `users.name`.  
- Calculated tenure in months with `TIMESTAMPDIFF(MONTH, date_jointed, CURDATE())`.  
- Derived CLV:  
  - Converted `confirmed_amount` (kobo) to Naira: `SUM(confirmed_amount * 0.00001)`.  
  - Applied formula: `(total_profit / tenure_months) * 12`, with `NULLIF` to handle division by zero.  
**Edge Cases**:  
- Used `COALESCE(COUNT(savings.id), 0)` to default to 0 transactions.  

---

## Challenges Faced & Solutions

1. **NULL Values in Customer Names (Q1/Q4)**  
   - **Issue**: The `users.name` column had only `NULL` values.
   - **Solution**: Used `CONCAT(first_name, ' ', last_name)` to construct full names. However, I observed that there were customers with `NULL` values in their `first_name` and `last_name`.

2. **Query inefficiency (Q1/Q2)**  
   - **Issue**: Initial joins across large tables had an extended execution time.  
   - **Solution**: Optimized with CTEs and `DISTINCT` to reduce dataset size early.  

3. **Date Handling in Q3**  
   - **Issue**: `transaction_date` included time, which did not align with the expected result.  
   - **Solution**: Used `CAST(transaction_date AS DATE)` to strip time.  

4. **Currency Conversion (Q1/Q4)**  
   - **Issue**: Amounts stored in kobo required conversion to Naira.  
   - **Solution**: Multiplied by `0.01` (Q1) and `0.00001` (Q4) for accurate calculations.

5. **Transaction Volume vs. Value in CLV Calculation (Q4)**
   - **Issue**: Initial confusion between SUM(confirmed_amount) (transaction value) and COUNT(id) (transaction volume).
   - **Solution**: 
     - Read the question severally to understand the problem statement and critically examined the expected result.
     - Used COUNT(id) for transaction volume in results, while keeping SUM(confirmed_amount) for estimated CLV formula.