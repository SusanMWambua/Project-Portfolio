-- Question: Which country has the highest churn rate?--
SELECT Geography,
    COUNT(*) AS Total_Customers,
    SUM(CAST(Exited AS INT)) AS Churned_Customers,
    ROUND(AVG(CAST(Exited AS FLOAT)*100),1) AS Churn_Rate_Pct
FROM customers
GROUP BY Geography
ORDER BY Churn_Rate_Pct DESC;


-- Q2: Does holding more products reduce churn? (Cross-sell signal test)--


    SELECT
        NumOfProducts,
        COUNT(*) AS customers,
        SUM(CAST(Exited AS INT)) AS churned,
        ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 1) AS churn_rate_pct
    FROM customers
    GROUP BY NumOfProducts
    ORDER BY NumOfProducts;

--Q3: Which age group is most at risk of churning?--

SELECT
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age < 45 THEN '30–44'
        WHEN Age < 60 THEN '45–59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS customers,
    ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 1) AS churn_rate_pct
FROM customers
GROUP BY
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age < 45 THEN '30–44'
        WHEN Age < 60 THEN '45–59'
        ELSE '60+'
    END
ORDER BY churn_rate_pct DESC;


-- Q4: Are the bank's highest-balance customers churning?--

SELECT
    CustomerId,
    Balance,
    Exited,
    COUNT(*) OVER () AS total_customers,
    RANK() OVER (ORDER BY Balance DESC) AS balance_rank,
    CASE WHEN Exited = 1 THEN 'Churned' ELSE 'Active' END AS status
FROM customers
ORDER BY balance_rank;


-- Q5: Does customer satisfaction (complaints) correlate with churn?--

SELECT
    Complain,
    COUNT(*) AS customers,
    SUM(CAST(Exited AS INT)) AS churned,
    ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 1) AS churn_rate_pct
FROM customers
GROUP BY Complain;
