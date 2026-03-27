🛒 E-Commerce Customer Segmentation & RFM Analysis
![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=flat&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat&logo=powerbi&logoColor=black)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Analysis-150458?style=flat&logo=pandas&logoColor=white)
![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-ML-F7931E?style=flat&logo=scikitlearn&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat) 
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat)
---
📌 Project Overview
This end-to-end data analytics project analyses 541,909 real transactions from a UK-based online retailer to understand customer behaviour and design targeted marketing campaigns.
Using RFM Analysis (Recency, Frequency, Monetary) and K-Means Clustering, customers are segmented into actionable groups — Champions, Loyal Customers, At-Risk buyers, and Lost customers — enabling the marketing team to personalise offers, improve retention, and grow revenue.
> **Dataset:** [UK Online Retail Dataset](https://www.kaggle.com/datasets/carrie1/ecommerce-data) — Kaggle  
> **Period:** December 2010 – December 2011  
> **Records:** 541,909 transactions | 4,338 unique customers | 38 countries
---
🎯 Business Problem
An online retailer wants to move away from mass marketing and instead send the right message to the right customer at the right time. Without customer segmentation, the marketing team treats a £280,000 lifetime-value customer the same as a one-time buyer — wasting budget and losing VIP customers to competitors.
This project answers:
Who are our most valuable customers?
Which customers are about to churn?
What products drive the most revenue?
When do customers actually buy?
Which markets should we expand in?
---
🛠️ Tools & Technologies
Tool	Purpose
Python 3.9+	Data loading, cleaning, EDA, RFM feature engineering
Pandas	Data manipulation and transformation
Matplotlib / Seaborn	Exploratory data visualisation
Scikit-Learn	StandardScaler, K-Means clustering, PCA
MySQL 8.0	Advanced SQL queries and business insights
Power BI Desktop	Interactive dashboard and stakeholder reporting
---
📁 Repository Structure
```
ecommerce-rfm-customer-segmentation/
│
├── 📓 E-Commerce_rfm_analysis.ipynb     ← Main Python notebook (full analysis)
├── 🗄️  E-Commerce_sql_analysis.sql       ← MySQL queries (simple → advanced)
├── 📊 E-Commerce_Customer_Intelligence.pbix  ← Power BI dashboard file
│
├── 📂 data/
│   ├── data.xlsx                         ← Raw transaction dataset
│   └── rfm_segmentation_output.csv       ← Cleaned RFM output (Python export)
│
├── 📂 assets/
│   └── dashboard_preview.png             ← Dashboard screenshot (add yours here)
│
├── requirements.txt                      ← Python dependencies
├── LICENSE                               ← MIT License
└── README.md                             ← This file
```
---
📊 Project Workflow
```
Raw Data (data.xlsx)
       │
       ▼
  Python Notebook
  ┌─────────────────────────────────────────┐
  │  Step 1 → Load & Explore (541,909 rows) │
  │  Step 2 → Clean (remove nulls/returns)  │
  │  Step 3 → EDA (5 charts + insights)     │
  │  Step 4 → RFM Feature Engineering      │
  │  Step 5 → RFM Scoring (1–5 scale)      │
  │  Step 6 → K-Means Clustering (k=4)     │
  └─────────────────────────────────────────┘
       │
       ▼
  rfm_segmentation_output.csv
       │
       ├──────────────────────┐
       ▼                      ▼
  MySQL Analysis         Power BI Dashboard
  (14 SQL queries)       (8 visuals, 1 page)
```
---
🔍 Key Findings
From Python Analysis
24.9% of records had no CustomerID (guest checkouts) — removed before analysis
Revenue spikes 3× in November–December — holiday season dominates the business
Orders peak on weekdays 10 AM–3 PM — confirms a B2B-heavy customer base
Top 5% of customers generate ~45% of total revenue — classic Pareto pattern
K-Means identified 4 natural clusters confirmed by the Elbow Method at k=4
From SQL Analysis
Netherlands customers spend 2.4× more per order than UK customers on average
60.2% of customers made only one purchase — retention is the biggest gap
Month-over-month growth hit +42% in November 2011 — strongest acceleration
Top 3 product pairs are frequently bought together — bundling opportunity
High-value dormant customers (90+ days inactive, £10K+ LTV) = win-back priority
Customer Segments
Segment	Customers	Avg Spend	Strategy
Champion	819	£5,127	VIP loyalty programme, early access
Loyal Customer	1,102	£2,814	Reward points, personalised offers
At Risk	638	£2,508	Win-back email, time-limited discount
Needs Attention	892	£672	Second-purchase incentive
Lost	887	£226	Last-chance reactivation or suppress
---
🖥️ Power BI Dashboard
The dashboard is a single-page, interactive view built on both data sources.
8 Visuals:
KPI Cards — Revenue, Orders, Customers, Avg Order Value, Revenue per Customer
Area Chart — Monthly Revenue Trend (with holiday annotation)
Donut Chart — Customer Segment Distribution
Segment Summary Table — with conditional formatting on Revenue
Filled Map — Revenue by Country
RFM Scatter Plot — Recency vs Monetary, bubble size = Frequency
Product Revenue Treemap — Top 20 products by revenue
Gauge Chart — Repeat Customer Rate vs 70% target
> **To open:** Download `E-Commerce_Customer_Intelligence.pbix` and open in Power BI Desktop (free download from Microsoft).
<!-- REPLACE THIS LINE with your actual dashboard screenshot -->
<!-- ![Dashboard Preview](assets/dashboard_preview.png) -->
---
🚀 How to Run the Python Notebook
Prerequisites
Make sure you have Python 3.9 or higher installed.
Step 1 — Clone the repository
```bash
git clone https://github.com/Siddharthkeshwani/ecommerce-rfm-customer-segmentation.git
cd ecommerce-rfm-customer-segmentation
```
> Replace `Siddharthkeshwani` with your actual GitHub username.
Step 2 — Install dependencies
```bash
pip install -r requirements.txt
```
Step 3 — Place the dataset
Make sure `data.xlsx` is inside the `data/` folder.
Step 4 — Open the notebook
```bash
jupyter notebook E-Commerce_rfm_analysis.ipynb
```
Step 5 — Run all cells
In Jupyter: click Kernel → Restart & Run All
The notebook will automatically export `rfm_segmentation_output.csv` at the end.
---
🗄️ How to Run the SQL Queries
Prerequisites
MySQL 8.0+ installed
MySQL Workbench (recommended) or any MySQL client
Step 1 — Export data.xlsx to CSV
Open `data.xlsx` in Excel → File → Save As → CSV UTF-8 → save as `data.csv`
Step 2 — Open the SQL file
Open `E-Commerce_sql_analysis.sql` in MySQL Workbench.
Step 3 — Update the file path
In Section 2 of the SQL file, replace the path:
```sql
LOAD DATA LOCAL INFILE '/path/to/data.csv'
-- Change to your actual CSV file path, for example:
LOAD DATA LOCAL INFILE 'C:/Users/YourName/Desktop/data.csv'
```
Step 4 — Run the file
Press Ctrl + Shift + Enter to run the entire script, or run section by section.
---
📦 Requirements
```
pandas>=1.5.0
numpy>=1.23.0
matplotlib>=3.6.0
seaborn>=0.12.0
scikit-learn>=1.1.0
openpyxl>=3.0.0
jupyter>=1.0.0
```
Install all at once:
```bash

pip install -r requirements.txt
---
🌱 Future Improvements
[ ] Add a cohort retention heatmap in Python (Month 0 → Month 6 visualised)
[ ] Build a product recommendation engine using association rules (Apriori)
[ ] Deploy the RFM model as a Streamlit web app so non-technical users can upload their own data
[ ] Connect Power BI directly to MySQL using live connection instead of CSV
[ ] Add automated email campaign triggers based on segment changes
---
👤 About Me
Siddharth Keshwani  
Aspiring Data Analyst | Python · SQL · Power BI
🌐 Portfolio: https://github.com/Siddharthkeshwani
💼 LinkedIn: https://www.linkedin.com/in/siddharthkeshwani/
📧 Email: siddharthkeshwani10@gmail.com/sidkeshwani16@gmail.com
---
📄 License
This project is licensed under the MIT License — see the LICENSE file for details.
You are free to use, copy, modify, and share this project for personal or commercial purposes as long as you include the original licence notice.

🙏 Acknowledgements
Dataset: Carrie1 on Kaggle — UK Online Retail Dataset
RFM segmentation methodology inspired by industry-standard marketing analytics frameworks
K-Means clustering approach following standard machine learning best practices

If you found this project helpful, please consider giving it a ⭐ — it helps other students find it!
