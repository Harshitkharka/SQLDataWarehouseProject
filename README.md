# 📦 Data Warehouse Sales & Customer Analysis Project

A comprehensive SQL-based data analysis project built on a Data Warehouse model. This project focuses on generating actionable business insights from sales and customer data using T-SQL queries across multiple data layers (Bronze, Silver, Gold).

---

## 📌 Project Overview

**Objective**:  
To analyze historical sales and customer data to uncover trends, product performance, customer behavior, and segmentations using structured SQL queries in a data warehousing environment.

**Database Used**: `DataWarehouse`

**Role**: Data Analyst  
**Developer**: Harshit Kharka  
**Tools**: Microsoft SQL Server, SSMS, SQL

---

## 🗂️ Dataset Layers

- **Bronze Layer**: Raw data loaded from external sources
- **Silver Layer**: Cleaned and transformed data
- **Gold Layer**: Final curated tables optimized for reporting and analysis

---

## 📊 Key Analyses

### 1. **Yearly Sales & Customer Trends (2010–2014)**
- Summary of yearly total sales, unique customers, order counts, and quantities.
- Helps identify business growth trends year-over-year.

### 2. **Monthly Sales Trends**
- Tracks monthly average sales and customer activities.
- Useful for seasonal trend analysis and forecasting.

### 3. **Cumulative Sales Over Time**
- Rolling sum of monthly sales.
- Assists in visualizing long-term performance buildup.

### 4. **Product Performance Analysis**
- Evaluates each product’s sales performance against average and previous month.
- Flags whether performance is **Above Average**, **Below Average**, or **Average**.
- Identifies monthly **Increase**, **Decrease**, or **No Change** in sales.

### 5. **Category-wise Sales Contribution**
- Calculates the percentage contribution of each product category to total sales.
- Provides an overview of which categories drive the most revenue.

### 6. **Customer Segmentation**
- Segments customers based on total spending and lifecycle into:
  - **VIP** – Loyal and high-spending customers  
  - **Regular** – Mid-range spending and consistent over time  
  - **New** – Low-spending or short-tenure customers

### 7. **Customer Profile Report**
- Detailed profile for each customer:
  - Lifetime value, total orders, quantity ordered
  - First and last purchase dates
  - Days since last order
  - Age group classification
  - Segmentation tag (VIP/Regular/New)

---


