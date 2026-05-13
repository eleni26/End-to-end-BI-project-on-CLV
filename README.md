# Customer Loyalty & Lifetime Value (CLV) Dashboard

An end-to-end Business Intelligence project built on **AdventureWorks2019**, delivering a Power BI executive dashboard that surfaces customer loyalty and lifetime value KPIs across regions and product categories.

---

## 📊 Dashboard Preview

![CLV Dashboard](CLV%20dashboard.png)

---

## 🗄️ Star Schema

![Star Schema](CLV%20star%20schema.png)

---

## 📐 Architecture

A star schema data mart is built via a single SQL Server stored procedure (`Procedure Script.sql`):

| Object | Type | Description |
|--------|------|-------------|
| `Dim_Date` | Table | Calendar attributes (year, quarter, month) |
| `Dim_Customer` | Table | Customer names, accounts, territory |
| `Dim_Product` | Table | Product hierarchy (category → subcategory) |
| `Dim_Territory` | Table | Region groups and country codes |
| `Fact_Sales` | Table | Order-line grain — qty, unit price, sales amount |
| `v_Fact_Sales_Performance` | View | Fact + date attributes (Power BI source) |
| `v_Customer_Geography` | View | Customer + territory (Power BI source) |
| `v_Product_Catalog` | View | Product dimension (Power BI source) |

---

## 📈 KPI Summary

| Metric | Value |
|-
