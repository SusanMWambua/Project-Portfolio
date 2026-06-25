# Bank Customer Churn Analysis — SQL

**Analysing what drives customer churn at a retail bank using MS SQL Server and VS Code**

---

## Problem Statement

A retail bank is losing customers without a clear understanding of *which* segments are most at risk or *why* they are leaving. This project uses structured query analysis across 10,000 customer records to identify the key drivers of churn — segmented by geography, age, product holdings, and complaint history — and produces actionable retention recommendations.

> **Business Question:** Which customer segments have the highest churn rate, and what characteristics do they share?

---

## Repository Structure

```
bank-churn-sql-analysis/
├── README.md
├── data/
│   └── Customer-Churn-Records.csv        # Source dataset (Kaggle)
├── queries/
│   ├── 01_churn_by_geography.sql
│   ├── 02_churn_by_products.sql
│   ├── 03_churn_by_age_group.sql
│   ├── 04_balance_rank.sql
│   └── 05_complaint_signal.sql
```

---

## Data Source

| Detail | Value |
|---|---|
| **Source** | [Kaggle — Bank Customer Churn Dataset](https://www.kaggle.com/datasets/shubhammeshram579/bank-customer-churn-prediction) |
| **Rows** | 10,000 customer records |
| **Columns** | 18 |
| **Target variable** | `Exited` (1 = churned, 0 = stayed) |
| **Overall churn rate** | 20.4% (2,038 of 10,000) |

### Column Reference

| Column | Type | Description |
|---|---|---|
| `RowNumber` | int | Row index |
| `CustomerId` | int | Unique customer identifier |
| `Surname` | varchar | Customer surname |
| `CreditScore` | int | Credit score at time of record |
| `Geography` | varchar | Country: France, Germany, Spain |
| `Gender` | varchar | Male / Female |
| `Age` | int | Customer age in years |
| `Tenure` | int | Years as a bank customer |
| `Balance` | float | Account balance |
| `NumOfProducts` | int | Number of bank products held |
| `HasCrCard` | bit | Has a credit card (1 = yes) |
| `IsActiveMember` | bit | Active member status (1 = yes) |
| `EstimatedSalary` | float | Estimated annual salary |
| `Exited` | bit | **Target: churned (1) or stayed (0)** |
| `Complain` | bit | Has raised a complaint (1 = yes) |
| `Satisfaction Score` | int | Customer satisfaction rating 1–5 |
| `Card Type` | varchar | Card tier: DIAMOND, GOLD, PLATINUM, SILVER |
| `Point Earned` | int | Reward points balance |

---

## Tools & Environment

| Tool | Purpose |
|---|---|
| **MS SQL Server (Express)** | Database engine |
| **VS Code + mssql extension** | Query editor and execution |
| **GitHub** | Version control and portfolio publishing |

### Setup: Connecting MS SQL Server to VS Code

1. Install the **SQL Server (mssql)** extension in VS Code (`Ctrl+Shift+X` → search `mssql`)
2. Click the SQL Server icon in the left sidebar → **Add Connection**
3. Server: `localhost` or `.\SQLEXPRESS` · Authentication: **Windows Authentication**
4. Create the database:
   ```sql
   CREATE DATABASE BankChurnDB;
   ```
5. Right-click `BankChurnDB` → **Import Flat File Wizard** → select `Customer-Churn-Records.csv` → table name: `customers`
6. Verify: `SELECT TOP 5 * FROM customers;` — should return 5 rows from 10,000 total

---

## 🔍 Methodology

Five SQL queries were written to systematically answer the business question from different angles. Each query uses a specific SQL technique and is annotated with its business context and key finding.

| Query | Technique | Business Question |
|---|---|---|
| 1 | `GROUP BY`, `AVG(CAST(...))` | Which geography has the highest churn rate? |
| 2 | CTE (`WITH ... AS`) | Does holding more products reduce churn? |
| 3 | `CASE WHEN` segmentation | Which age group is most at risk? |
| 4 | Window function (`RANK() OVER`) | Which high-balance customers are churning? |
| 5 | `GROUP BY` on complaint flag | Does a complaint predict churn? |

> **Note on MS SQL Server syntax:** `AVG()` on an integer column returns an integer in SQL Server.
> All churn rate calculations use `AVG(CAST(Exited AS FLOAT)) * 100` to return a decimal percentage.

---

## Queries & Findings

---

### Query 1 — Churn Rate by Geography

```sql
-- Q1: Which country has the highest churn rate?
-- Finding: Germany at 32.4% — nearly double France and Spain — signals a localised retention problem.

SELECT
    Geography,
    COUNT(*) AS total_customers,
    SUM (CAST(Exited AS INT)) AS churned,
    ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 1) AS churn_rate_pct
FROM customers
GROUP BY Geography
ORDER BY churn_rate_pct DESC;
```

**Result:**

| Geography | Total Customers | Churned | Churn Rate |
|---|---|---|---|
| Germany | 2,509 | 814 | **32.4%** |
| Spain | 2,477 | 413 | 16.7% |
| France | 5,014 | 811 | 16.2% |

> **Finding:** Germany's churn rate (32.4%) is nearly double that of France and Spain. This is not explained by volume — Germany accounts for only 25% of customers but disproportionately high exits. A targeted investigation into German customer satisfaction and competitor activity is warranted.

---

### Query 2 — Churn by Product Holdings (CTE)

```sql
-- Q2: Does holding more products reduce churn? (Cross-sell signal test)
-- Finding: 2-product customers are the most loyal. 3+ products spike dramatically — a red flag.

    SELECT
        NumOfProducts,
        COUNT(*) AS customers,
        SUM(Exited) AS churned,
        ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 1) AS churn_rate_pct
    FROM customers
    GROUP BY NumOfProducts

```

**Result:**

| Products | Customers | Churned | Churn Rate |
|---|---|---|---|
| 1 | 5,084 | 1,409 | 27.7% |
| 2 | 4,590 | 349 | **7.6%** ✅ lowest |
| 3 | 266 | 220 | **82.7%** |
| 4 | 60 | 60 | **100%** |

> **Finding:** The assumption that more products = greater loyalty is wrong. Two-product customers have the lowest churn rate (7.6%), but customers with 3 or 4 products exit at 82.7% and 100% respectively. This pattern suggests potential product mis-selling or forced bundling — customers who did not choose these products are almost certain to leave. The cross-sell strategy requires urgent review.

---

### Query 3 — Churn by Age Group (CASE WHEN)

```sql
-- Q3: Which age group is most at risk of churning?
-- Finding: The 45–59 cohort has a 49.4% churn rate — nearly half leave.

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
```

> **Note:** In MS SQL Server, the `CASE WHEN` expression must be repeated in full in the `GROUP BY` clause. Column aliases defined in `SELECT` cannot be referenced in `GROUP BY`.

**Result:**

| Age Group | Customers | Churn Rate |
|---|---|---|
| **45–59** | 1,814 | **49.4%** ⚠️ |
| 60+ | 526 | 27.9% |
| 30–44 | 6,019 | 14.5% |
| Under 30 | 1,641 | 7.6% |

> **Finding:** Customers aged 45–59 churn at 49.4% — nearly one in two. This group is mid-career, typically high-balance, and likely to have mortgages, savings, and investment products. They are the highest-value customers the bank is losing. Combined with the Germany finding, a German customer aged 45–59 represents a critical at-risk profile.

---

### Query 4 — High-Balance Customer Risk (Window Function)

```sql
-- Q4: Are the bank's highest-balance customers churning?
-- Finding: 25.2% of customers with balances above 100,000 have churned — significant value at risk.

SELECT
    CustomerId,
    Balance,
    Exited,
    RANK() OVER (ORDER BY Balance DESC) AS balance_rank,
    CASE WHEN Exited = 1 THEN 'Churned' ELSE 'Active' END AS status
FROM customers
ORDER BY balance_rank;
```

**Summary — High-Balance Customers (Balance > 100,000):**

| Segment | Customers | Churned | Churn Rate |
|---|---|---|---|
| Balance > 100,000 | 4,799 | 1,211 | **25.2%** |
| Balance ≤ 100,000 | 5,201 | 827 | 15.9% |

> **Finding:** High-balance customers churn 58% more than low-balance customers. `RANK() OVER (ORDER BY Balance DESC)` assigns each customer a position by account balance — surfacing the top-tier accounts that are most at risk. These represent the highest monetary value lost per customer exit. A premium retention programme targeting this segment would have an outsized financial impact.

---

### Query 5 — The Complaint Signal ⚠️

```sql
-- Q5: Does raising a complaint predict churn?
-- Finding: 99.5% of customers who complained have churned. This is the strongest predictor in the dataset.

SELECT
    Complain,
    COUNT(*) AS customers,
    SUM(Exited) AS churned,
    ROUND(AVG(CAST(Exited AS FLOAT)) * 100, 1) AS churn_rate_pct
FROM customers
GROUP BY Complain;
```

**Result:**

| Complain | Customers | Churned | Churn Rate |
|---|---|---|---|
| 0 (No complaint) | 7,956 | 4 | **0.1%** |
| 1 (Complaint filed) | 2,044 | 2,034 | **99.5%** ⚠️ |

> **Finding:** This is the most significant finding in the entire dataset. A customer who files a complaint is almost certain to leave — 99.5% churn rate versus 0.1% for customers who have not complained. This is not a correlation; it is effectively a deterministic signal. The bank's complaint resolution process is failing entirely. A complaint is not a service event to be managed — it is a departure notice.

---

## 💡 Key Findings Summary

| # | Finding | Churn Rate | Implication |
|---|---|---|---|
| 1 | Germany customers | 32.4% | Localised retention problem — investigate urgently |
| 2 | 3-product customers | 82.7% | Product mis-selling signal — review bundling policy |
| 3 | Customers aged 45–59 | 49.4% | Highest-value age cohort leaving at nearly 1 in 2 |
| 4 | High-balance customers (>100K) | 25.2% | Premium segment at risk — highest financial exposure |
| 5 | Customers who complained | 99.5% | Complaint = departure notice. Resolve within 24hrs or lose them. |

---

## ✅ Recommendations

Based on the analysis, three actionable recommendations are proposed:

**1. Launch a Germany-specific retention programme**
Germany's churn rate is 32.4% with no equivalent in France or Spain. Immediate investigation into German competitor activity, service quality, and customer feedback is needed. A targeted outreach programme for at-risk German customers — particularly those aged 45–59 — should be prioritised.

**2. Audit the 3- and 4-product customer base**
The near-total churn rate among 3+ product customers (82.7%–100%) is a critical signal. These customers did not choose depth of relationship — they were put in it. An audit of how these products were sold, combined with personalised outreach to active 3-product customers, could retain a significant volume before they exit.

**3. Build a complaint-triggered rapid-response system**
A complaint predicts churn with 99.5% accuracy. The bank should treat every complaint as an emergency retention event — with a dedicated escalation team, a 24-hour response SLA, and a retention offer deployed automatically when a complaint is logged. This single intervention would address the root cause of more than 2,000 churned customers in this dataset.

---

## About

This project was built as part of a data analyst portfolio, demonstrating end-to-end SQL analysis on a real banking dataset. The SQL project feeds directly into a Power BI dashboard (see linked repository) — showing data pipeline thinking from raw CSV through to executive reporting.

**Tools:** MS SQL Server · VS Code · GitHub  
**Techniques:** GROUP BY aggregation · CTEs · CASE WHEN segmentation · Window functions · Subqueries

---

*Dataset source: [Kaggle — Bank Customer Churn](https://www.kaggle.com/datasets/shubhammeshram579/bank-customer-churn-prediction)*
# Project-Portfolio
