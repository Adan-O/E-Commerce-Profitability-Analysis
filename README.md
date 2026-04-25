# E-Commerce-Profitability-Analysis

## Project Overview

This project analyzes an e-commerce dataset to understand the key drivers of profitability across products, product categories, and customers. The goal is to identify whether profit is driven by a small number of products/customers or broadly distributed across the business.

The analysis focuses on answering:

- Which products and categories generate the most profit?
- Is revenue concentrated in a small number of products or categories?
- Do a small number of customers drive the majority of profit?
- What customer behaviors are most valuable to the business?

---

## Tools & Technologies

- SQL (CTEs, Joins, Aggregations, CASE statements)
- Relational data modeling
- Data cleaning & transformation
- Exploratory data analysis (EDA)

- ## Dataset Structure

The dataset consists of multiple related tables:

- **Sales** → transaction-level data (orders, quantities, dates)
- **Customers** → customer demographics and location
- **Products** → product details, pricing, and categories
- **Stores** → store location and attributes
- **Exchange Rates** → currency conversion data (available but not used in final model)

- ## Data Preparation

A multi-step SQL pipeline was used to prepare the dataset:

### 1. Data Integration
Joined multiple tables:
- Sales ↔ Customers
- Sales ↔ Products
- Sales ↔ Stores

### 2. Feature Engineering
Created key business metrics:
- Revenue = Quantity × Unit Price
- Cost = Quantity × Unit Cost
- Profit = Revenue − Cost

### 3. Aggregation Layers
Built structured views for:
- Product-level performance
- Category-level performance
- Customer-level performance
- Customer segmentation based on purchase frequency

## Product-Level Analysis

### Key Findings:
- No individual product contributes more than ~1% of total profit
- Top 10 products contribute approximately ~9% of total profit

### Insight:
Profit is highly fragmented at the product level, with no dominant “hero” products driving overall performance.

---

## Category-Level Analysis

### Key Findings:
- Computers: 35% of total profit
- Home Appliances: 17%
- Cameras: 12%
- Top 3 categories account for ~64% of total profit

### Insight:
Profitability is concentrated at the category level, with a small number of categories driving the majority of business performance.

---

## Customer Analysis

Customers were segmented based on purchase frequency:

| Segment | Customers | Profit Share | Avg Profit per Customer |
|--------|----------:|-------------:|-------------------------:|
| One-Time | 4,617 | 17.7% | 1,217 |
| Repeat | 6,911 | **73.1%** | 3,362 |
| Loyal | 356 | 9.3% | 8,272 |

### Key Insights:
- **Repeat customers are the primary profit driver**, contributing over 70% of total profit
- Loyal customers generate the highest profit per customer but represent a small segment
- One-time customers contribute relatively low overall value

---

## Key Business Insights

### 1. Product-level performance is highly fragmented
No single product dominates profitability, indicating a long-tail structure across SKUs.

### 2. Category-level performance is concentrated
A small number of categories (especially Computers) drive the majority of profit.

### 3. Customer profitability is driven by repeat behavior
Repeat customers, not one-time or loyal extremes, are the main source of profit.

---

## 💡 Final Recommendations

### 1. Focus on high-performing categories
- Prioritize investment in Computers, Home Appliances, and Cameras

### 2. Improve customer retention strategy
- Repeat customers are the strongest profit driver
- Retention initiatives may yield higher ROI than acquisition campaigns

### 3. Avoid over-investment in individual products
- SKU-level dominance is not present
- Strategic focus should remain at category level

---

## 📌 Executive Summary

> Profitability is driven primarily by category strength and repeat customer behavior, while product-level performance remains highly fragmented. The business is not dependent on individual products or customers but instead relies on consistent repeat purchasing across key categories.

---

## 📈 Potential Next Steps

- Build dashboard (Power BI / Tableau) to visualize:
  - Category profit distribution
  - Customer segment contribution
  - Product long-tail distribution
- Add time-based analysis (seasonality trends)
- Explore geographic profitability differences

