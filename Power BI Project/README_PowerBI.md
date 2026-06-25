# 📊 Bank Customer Churn Dashboard — Power BI

**An interactive executive dashboard analysing customer churn drivers across 10,000 banking customers**

---

## 📌 Problem Statement

A retail bank needed visibility into which customer segments were churning, at what rate, and why — so that retention resources could be directed where they would have the most impact.

This Power BI dashboard translates the SQL analysis into an interactive report that allows bank operations managers to explore churn patterns in real time, filtered by geography, age group, and customer segment.

> **Dashboard Question:** Where should the bank focus its retention effort to maximise impact?

---

## 🔗 Links

| Resource | Link |
|---|---|
| **Live Dashboard** | [View on Power BI Service](#) *(replace with your published URL)* |
| **Walkthrough Video** | [Watch on Loom](#) *(replace with your Loom URL)* |
| **SQL Analysis** | [bank-churn-sql-analysis](#) *(link to SQL repo)* |
| **Source Dataset** | [Kaggle — Bank Customer Churn](https://www.kaggle.com/datasets/shubhammeshram579/bank-customer-churn-prediction) |

---

## 🗃️ Data Source

| Detail | Value |
|---|---|
| **Rows** | 10,000 customer records |
| **Columns** | 18 (including Complain, Satisfaction Score, Card Type, Point Earned) |
| **Target variable** | `Exited` → renamed `Churned` (1 = churned, 0 = stayed) |
| **Overall churn rate** | 20.4% (2,038 of 10,000 customers) |

---

## 🛠️ Tools & Techniques

| Tool / Technique | Used For |
|---|---|
| **Power BI Desktop** | Report design and data modelling |
| **Power Query** | Data import, column type validation, column renaming |
| **DAX** | Dynamic Churn Rate measure, calculated columns (Age Group, Risk Segment) |
| **Power BI Service** | Publishing and public share link |
| **Loom** | Dashboard walkthrough video |

---

## 📐 Data Model

The report uses a single flat table (`customers`) imported from CSV. Key transformations applied in Power Query:

- `Exited` renamed to `Churned` for non-technical audience readability
- Column data types validated: Balance and EstimatedSalary as Decimal, all flag fields as Whole Number

**DAX Measure — Core Calculation:**

```dax
Churn Rate =
DIVIDE(
    SUM( customers[Churned] ),
    COUNT( customers[CustomerId] )
)
```

Formatted as percentage, 1 decimal place. This measure recalculates dynamically with every slicer interaction.

**Calculated Columns:**

```dax
-- Age segmentation
Age Group =
IF([Age] < 30, "Under 30",
IF([Age] < 45, "30–44",
IF([Age] < 60, "45–59", "60+")))
```

```dax
-- Risk segment intersection (Page 2)
Risk Segment =
IF(customers[Geography] = "Germany"
    && customers[Age] >= 45 && customers[Age] < 60
    && customers[NumOfProducts] = 1, "Ultra High Risk",
IF(customers[Geography] = "Germany"
    && customers[Age] >= 45 && customers[Age] < 60, "Germany 45–59",
IF(customers[Geography] = "Germany", "Germany only",
    "All other segments")))
```

---

## 📊 Dashboard Pages

### Page 1 — Executive Summary

| Visual | Type | Business Question |
|---|---|---|
| Churn Rate | KPI Card | What is the overall churn rate? |
| Total Customers | KPI Card | How large is the customer base? |
| Average Balance | KPI Card | What is the average account balance? |
| Churn Rate by Geography | Bar Chart | Which country has the highest churn? |
| Churn Rate by Age Group | Bar Chart | Which age group is most at risk? |
| Geography Slicer | Dropdown Slicer | Filter all visuals by country |
| Key Insights | Text Box | Plain-English summary for non-technical stakeholders |

### Page 2 — Extended Analysis

| Visual | Type | Business Question |
|---|---|---|
| Active Member Status | Bar Chart | Does engagement predict churn? |
| Churn by Gender | Bar Chart | Is there a gender difference in churn? |
| Stacked Risk Segments | Bar Chart | What happens when risk factors combine? |
| Null Finding | Text Box | Which variables showed no meaningful effect? |

---

## 🔍 Key Findings

### Page 1 Findings

| Finding | Churn Rate | Implication |
|---|---|---|
| Germany | 32.4% | Nearly double France and Spain — a localised retention problem |
| Customers aged 45–59 | 49.4% | Almost half of this age group leaves — highest-value cohort at risk |
| Customers with 3+ products | 82.7% | Spike suggests product mis-selling or unwanted bundling |
| Customers who complained | 99.5% | A complaint is effectively a departure notice |

### Page 2 Findings

| Finding | Churn Rate | Implication |
|---|---|---|
| Inactive members | 26.9% | Churn nearly double that of active members — engagement is protective |
| Active members | 14.3% | Lower churn confirms engagement programmes have measurable impact |
| Female customers | 25.1% | 52% higher churn than males — warrants targeted investigation |
| Male customers | 16.5% | Baseline for comparison |

### The Stacked Risk Intersection

| Segment | Churn Rate |
|---|---|
| All customers (baseline) | 20.4% |
| Germany only | 32.4% |
| Germany + Age 45–59 | 66.0% |
| Germany + Age 45–59 + 1 product | **74.8%** |

> **Key Insight:** Stacking three risk factors — German geography, mid-career age, and single-product holding — identifies a segment where nearly 3 in 4 customers will leave. This is the highest-priority retention target in the entire dataset.

### The Null Finding

Card type, credit score, and tenure showed no meaningful variation in churn rate across their range. Ruling these out as primary drivers sharpens the focus on geography, age, complaint history, and product holding — the four variables that actually predict exit.

---

## ✅ Recommendations

**1. Germany — Immediate targeted retention programme**
Germany's 32.4% churn rate has no equivalent in other markets. Prioritise outreach to German customers aged 45–59 with single-product accounts — this segment churns at 74.8%.

**2. Complaint-triggered rapid-response system**
A complaint predicts churn with 99.5% accuracy. Every complaint should automatically trigger a 24-hour escalation and personalised retention offer. This single process change would address the root cause of over 2,000 churned customers in this dataset.

**3. Active member engagement programme**
Inactive members churn at nearly double the rate of active members (26.9% vs 14.3%). A structured re-engagement programme — digital check-ins, product reviews, relationship manager contact — could materially reduce overall churn.

**4. Female customer retention investigation**
Female customers churn at 25.1% vs 16.5% for males. Before designing targeted interventions, qualitative research is needed to understand whether this reflects service gaps, product fit, or competitor activity.

---

## 📂 Repository Structure

```
bank-churn-powerbi/
├── README.md
├── BankChurnDashboard.pbix         ← Power BI file
├── data/
│   └── Customer-Churn-Records.csv  ← Source dataset
└── screenshots/
    ├── page1_executive_summary.png
    └── page2_extended_analysis.png
```

---

## 🔗 Related Project

This Power BI dashboard is built from the same dataset as the **SQL analysis project** — demonstrating end-to-end data pipeline thinking: raw data → SQL exploration → BI reporting.

[→ View the SQL Analysis on GitHub](#) *(replace with your SQL repo URL)*

---

## 👤 About

Built as part of a data analyst portfolio, demonstrating Power BI dashboard design, DAX measure creation, multi-page report structure, and data storytelling for a banking and finance audience.

**Tools:** Power BI Desktop · DAX · Power Query · Power BI Service · Loom

---

*Dataset source: [Kaggle — Bank Customer Churn](https://www.kaggle.com/datasets/shubhammeshram579/bank-customer-churn-prediction)*
