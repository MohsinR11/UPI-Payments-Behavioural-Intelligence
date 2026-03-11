# 🏦 UPI Payments Behavioral Intelligence

> **End-to-end data analytics project** analyzing 500,000 UPI transactions across platforms, merchants, and users - featuring behavioral segmentation, fraud detection, cohort analysis, and an interactive Power BI dashboard built to mirror real fintech analytics workflows.

---

## 📊 Dashboard Preview

### Page 1 - Executive Overview
![Executive Overview](https://github.com/MohsinR11/UPI-Payments-Behavioural-Intelligence/blob/main/Power%20BI%20Dashboard/Dashboard%20Images/Page%201%20Executive%20Overview.png)

### Page 2 - User Intelligence
![User Intelligence](https://github.com/MohsinR11/UPI-Payments-Behavioural-Intelligence/blob/main/Power%20BI%20Dashboard/Dashboard%20Images/Page%202%20User%20Intelligence.png)

### Page 3 - Merchant & Category Intelligence
![Merchant Intelligence](https://github.com/MohsinR11/UPI-Payments-Behavioural-Intelligence/blob/main/Power%20BI%20Dashboard/Dashboard%20Images/Page%203%20Merchant%20%26%20Category.png)

### Page 4 - Fraud Intelligence
![Fraud Intelligence](https://github.com/MohsinR11/UPI-Payments-Behavioural-Intelligence/blob/main/Power%20BI%20Dashboard/Dashboard%20Images/Page%204%20Fraud%20Intelligence.png)

---

## 📌 Project Overview

India processes **15+ billion UPI transactions per month**. Platforms like PhonePe, Google Pay, Paytm, and CRED are constantly trying to answer:

- Why do users transact on one platform for one use case but switch to a competitor for another?
- Which users are high value and how do we retain them?
- Where is fraud occurring and what signals predict it?
- How do festival seasons impact transaction behavior?

This project builds a complete **UPI Payments Behavioral Intelligence System** that answers all of these questions using real-world data analytics techniques.

---

## 🎯 Business Problems Solved

| Problem | Solution Built |
|---|---|
| Platform stickiness unknown | Platform loyalty rate analysis + switching matrix |
| User value not quantified | RFM scoring + behavioral segmentation |
| Fraud detection gaps | Multi-signal fraud scoring + anomaly detection |
| Festival impact unmeasured | Festival vs non-festival spending analysis |
| Merchant quality unknown | Merchant quality scoring system (0-100) |
| Cohort retention blind spot | Month-over-month cohort retention analysis |

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| **Python** | Data generation, cleaning, EDA, ML |
| **Pandas & NumPy** | Data manipulation and feature engineering |
| **Scikit-learn** | K-Means clustering, PCA, StandardScaler |
| **Matplotlib & Seaborn** | Statistical visualizations |
| **PostgreSQL** | Advanced SQL analysis and querying |
| **Power BI** | Interactive 4-page business dashboard |
| **Jupyter Notebook** | Analysis environment |
| **Git & GitHub** | Version control and portfolio hosting |

---

## 📁 Project Structure

```
UPI-Payments-Behavioral-Intelligence/
│
├── Data/
│   ├── Raw/                        # Original generated datasets
│   │   ├── upi_transactions.csv    # 500,000 transactions
│   │   ├── upi_users.csv           # 10,000 users
│   │   └── upi_merchants.csv       # 2,000 merchants
│   │
│   └── Cleaned/                    # Processed datasets
│       ├── cleaned_transactions.csv
│       ├── cleaned_users.csv
│       ├── cleaned_merchants.csv
│       ├── user_aggregates.csv
│       ├── merchant_aggregates.csv
│       ├── users_segmented.csv
│       └── user_features_clustered.csv
│
├── Python Notebooks/
│   ├── 01_Data_Generation.ipynb
│   ├── 02_Data_Cleaning.ipynb
│   ├── 03_EDA.ipynb
│   ├── 04_User_Segmentation.ipynb
│   └── 05_Load_To_PostgreSQL.ipynb
│
├── SQL Scripts/
│   └── upi_analysis_queries.sql    # 15 advanced SQL queries
│
├── Power BI Dashboard/
│   └── UPI_Payments_Intelligence_Dashboard.pbix
│
├── Exports/                        # All chart exports (PNG)
│
└── docs/
    └── images/                     # Dashboard screenshots
```

---

## 📦 Dataset Overview

| Dataset | Rows | Columns | Description |
|---|---|---|---|
| Transactions | 500,000 | 39 | Core transaction data with fraud signals |
| Users | 10,000 | 19 | User profiles with behavioral segments |
| Merchants | 2,000 | 6 | Merchant profiles by category and city |

### Date Range
**January 2022 - December 2023** (24 months, 2 full years)

### Key Metrics
- **Total Transaction Value:** ₹149.86 Crore
- **Average Transaction Amount:** ₹2,997
- **Success Rate:** 90.97%
- **Fraud Rate:** 0.049%
- **Cities Covered:** 43 (Tier 1, 2 & 3)
- **Merchant Categories:** 18

---

## 🔍 Analysis Performed

### Phase 1 - Exploratory Data Analysis
- Monthly transaction volume and value trends
- Platform market share analysis
- Merchant category deep dive (volume vs value)
- Time and behavioral pattern analysis (hourly, daily, seasonal)
- User demographic analysis (age group, gender, city tier)
- Festival vs non-festival spending comparison

### Phase 2 - User Behavioral Segmentation (ML)
Built a **36-feature behavioral matrix** per user and applied K-Means clustering to identify 4 distinct user archetypes:

| Segment | Users | Avg Ticket | Daily Spend | Key Trait |
|---|---|---|---|---|
| Premium Investors | 1,981 | ₹4,022 | ₹292 | High value, investment focused |
| Active Everyday Users | 2,885 | ₹2,876 | ₹208 | High frequency, multi-platform |
| Loyal Digital Users | 2,550 | ₹3,007 | ₹197 | High platform loyalty (89.5%) |
| Casual Small Spenders | 2,584 | ₹2,334 | ₹144 | Low value, food focused |

### Phase 3 - Fraud Signal Detection
Multi-signal fraud scoring system using:
- **Unusual hour flag** - transactions between 1am-5am
- **High amount flag** - amount > 4x category average
- **Round amount flag** - round amounts ≥ ₹5,000
- **Velocity flag** - rapid successive transactions

Key findings:
- Suspicious hours (1am-5am) have **41x higher fraud rate** than normal hours
- Average fraud transaction amount: **₹16,801** vs overall avg ₹2,997
- Rent category has highest fraud rate: **0.297%**
- Fraud only triggers at **score 2+** with 31.87% conversion rate

### Phase 4 - Advanced SQL Analysis (15 Queries)
| Query | Analysis |
|---|---|
| Q1 | Executive KPI Summary |
| Q2 | Monthly Trend with MoM Growth |
| Q3 | Platform Performance Scorecard |
| Q4 | Merchant Category Deep Dive |
| Q5 | User Segment Performance |
| Q6 | Fraud Detection Intelligence |
| Q7 | RFM User Analysis |
| Q8 | City-wise Performance Intelligence |
| Q9 | Cohort Retention Analysis |
| Q10 | Payment Mode & Device Intelligence |
| Q11 | Window Functions & Running Totals |
| Q12 | Merchant Quality Scoring (0-100) |
| Q13 | Festival vs Non-Festival Analysis |
| Q14 | Velocity & Anomaly Detection (Z-Score) |
| Q15 | Complete Executive Summary |

---

## 📈 Key Business Insights

1. **PhonePe leads** with 35% market share but **CRED has highest avg ticket** at ₹3,032 - premium user base
2. **Rent & Investment** categories dominate value (33% combined) despite only 6% of transaction volume
3. **Millennials (26-35)** drive 32.8% of total transaction value
4. **Tier 2 cities** account for 41% of total value - India's next growth engine
5. **November consistently peaks** - Diwali effect drives highest monthly value both years
6. **Loyal Digital Users** show 89.5% platform loyalty - highest retention segment
7. **Fraud at 1-4am** is 41x more likely than during business hours
8. **Premium Investors** (19.8% of users) contribute 28.1% of total value - classic 80/20

---

## 🚀 How to Run This Project

### Prerequisites
```
Python 3.8+
PostgreSQL 13+
Power BI Desktop
Jupyter Notebook
```

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/UPI-Payments-Behavioral-Intelligence.git
cd UPI-Payments-Behavioral-Intelligence

# Install Python dependencies
pip install pandas numpy matplotlib seaborn scikit-learn faker scipy plotly openpyxl xlsxwriter psycopg2-binary jupyter ipykernel
```

### Running the Project
```bash
# Step 1 - Generate Dataset
jupyter notebook "Python Notebooks/01_Data_Generation.ipynb"

# Step 2 - Clean & Engineer Features
jupyter notebook "Python Notebooks/02_Data_Cleaning.ipynb"

# Step 3 - Exploratory Data Analysis
jupyter notebook "Python Notebooks/03_EDA.ipynb"

# Step 4 - User Segmentation (ML)
jupyter notebook "Python Notebooks/04_User_Segmentation.ipynb"

# Step 5 - Load to PostgreSQL
jupyter notebook "Python Notebooks/05_Load_To_PostgreSQL.ipynb"

# Step 6 - Run SQL Queries
# Open SQL Scripts/upi_analysis_queries.sql in pgAdmin

# Step 7 - Open Dashboard
# Open Power BI Dashboard/UPI_Payments_Intelligence_Dashboard.pbix
```

### PostgreSQL Setup
```sql
-- Create database
CREATE DATABASE upi_intelligence;

-- Tables are created automatically via notebook 05
-- Or run the CREATE TABLE statements in upi_analysis_queries.sql
```

---

## 📊 Power BI Dashboard Pages

| Page | Key Visuals |
|---|---|
| Executive Overview | KPI cards, monthly trend, platform share, status breakdown |
| User Intelligence | Segment analysis, demographics, city tier, loyalty rates |
| Merchant & Category | Category treemap, top merchants, payment modes, device types |
| Fraud Intelligence | Fraud by hour, category risk, fraud heatmap (day vs hour) |

---

## 🧠 Skills Demonstrated

- **Data Engineering** - synthetic data generation with realistic Indian behavioral patterns
- **Feature Engineering** - 36 behavioral features per user from raw transaction data
- **Machine Learning** - K-Means clustering, PCA dimensionality reduction, StandardScaler
- **Statistical Analysis** - Z-score anomaly detection, cohort analysis, RFM scoring
- **Advanced SQL** - CTEs, window functions, PERCENTILE_CONT, PARTITION BY, LAG/LEAD
- **Business Intelligence** - 4-page interactive Power BI dashboard with DAX measures
- **Data Storytelling** - every analysis backed by business insight, not just charts

---

## 👤 Author

**Mohsin Raza | Data Analyst**
- [![LinkedIn](https://img.shields.io/badge/LinkedIn-Let's_Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mohsinraza-data/)
- [![Email](https://img.shields.io/badge/Email-Drop_a_Message-EA4335?style=for-the-badge&logo=gmail&logoColor=white)](mailto:mohsinansari1799@gmail.com)

---

## ⭐ If you found this project useful, please give it a star!
