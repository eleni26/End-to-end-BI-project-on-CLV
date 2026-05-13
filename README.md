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
|--------|-------|
| Total Revenue | 109.85 M |
| Customer Lifetime Value (CLV) | 5.75 K |
| Active Customers | 19 K |
| Average Order Value (AOV) | 3.49 K |
| Retention Rate | 86.83 % |

---

## 🚀 Setup

### Prerequisites
- SQL Server 2019+ with **AdventureWorks2019** restored
- Power BI Desktop

### 1 — Build the data mart

```sql
USE [AdventureWorks2019];
GO
EXEC dbo.sp_Build_Loyalty_Data_Mart;
GO
```

The procedure drops and recreates all objects — safe to re-run at any time.

### 2 — Connect Power BI

1. **Get Data → SQL Server** → point to your AdventureWorks2019 database
2. Import the three reporting views:
   - `v_Fact_Sales_Performance`
   - `v_Customer_Geography`
   - `v_Product_Catalog`
3. In the **Model** view, confirm relationships on `CustomerKey` and `ProductKey`
4. Add DAX measures for CLV, AOV, Retention Rate, etc.

---

## 🛠️ Tech Stack

- **SQL Server 2019** — stored procedure, star schema, views
- **T-SQL** — data transformation and mart build
- **Power BI Desktop** — data model, DAX measures, report visuals
