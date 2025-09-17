📊 E-Commerce Customer Churn Analysis
📌 Project Overview

In the realm of e-commerce, customer churn poses a significant challenge for sustaining profitability and customer loyalty. This project explores customer churn analysis using historical transactional data to uncover behavioral patterns, drivers of attrition, and actionable insights.

By analyzing factors such as tenure, payment modes, satisfaction scores, cashback usage, complaints, and purchase behavior, the project aims to provide strategies that help businesses reduce churn and retain customers in a competitive digital marketplace.

🎯 Problem Statement

Businesses in e-commerce struggle to identify why customers discontinue using their services. The project investigates customer churn dynamics by analyzing patterns in transactional and behavioral data. The insights generated will enable e-commerce enterprises to:

Understand who is likely to churn.

Discover key churn drivers.

Design targeted retention strategies.

Improve long-term customer relationships.


⚙️ Project Steps
🔹 1. Data Cleaning

Imputed missing values:

Mean for WarehouseToHome, HoursSpentOnApp, OrderAmountHikeFromLastYear, DaySinceLastOrder.

Mode for Tenure, CouponUsed, OrderCount.

Removed outliers: values > 100 in WarehouseToHome.

Resolved inconsistencies:

Replaced "Phone" → "Mobile Phone", "Mobile" → "Mobile Phone".

Standardized Payment Modes: "COD" → "Cash on Delivery", "CC" → "Credit Card".

🔹 2. Data Transformation

Renamed columns:

PreferedOrderCat → PreferredOrderCat

HourSpendOnApp → HoursSpentOnApp

Created new features:

ComplaintReceived (Yes/No)

ChurnStatus (Churned/Active)

Dropped redundant columns: Churn, Complain.

🔹 3. Data Exploration & Analysis

Key business questions addressed:

Count of Churned vs Active customers.

Average tenure & cashback among churned customers.

% of churned customers who complained.

City tier with highest churn in Laptop & Accessory category.

Most preferred payment mode among active customers.

Total order amount hike for single customers preferring mobile phones.

Avg. devices registered for UPI users.

City tier with maximum customers.

Gender using highest number of coupons.

Category-wise customers & max hours spent on app.

Order count for Credit Card users with max satisfaction.

Avg. satisfaction score of customers who complained.

Top 3 categories with highest average cashback.

Distance categorization (Very Close, Close, Moderate, Far) with churn status breakdown.

Customer order details for married, City Tier-1, above-average order counts.

🔹 4. SQL Integration (Customer Returns Table)

Created a new table customer_returns in the ecomm database.

Inserted return details including ReturnID, CustomerID, ReturnDate, RefundAmount.

Queried to display return details with customer information.

📈 Insights (Examples)

Customers with higher complaints have a greater chance of churn.

Laptop & Accessory category shows the highest churn rate in City Tier-2.

Mobile Phone + Single customers exhibited higher order amount hikes.

UPI users tend to register more devices.

Coupon usage is significantly higher among males.

Retention strategies should focus on improving satisfaction and cashback incentives.
