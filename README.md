# Customer Loyalty & Lifetime Value (CLV) Dashboard

An end-to-end Business Intelligence project built on **AdventureWorks2019**, delivering a Power BI executive dashboard that surfaces customer loyalty and lifetime value KPIs across regions and product categories.

---

## 🎯 Business Question

Which regions keep customers coming back, and where is customer value concentrated? This dashboard gives sales leadership a one-page view of lifetime value, order size and retention by territory, so they can decide where to focus retention efforts.

---

## 🔍 Key Findings

- **North America holds just over half of active customers** (~10K, 51.7%), followed by Europe (29.3%) and Pacific (19.0%).
- **Only 39% of customers come back.** 7,470 of 19,119 customers placed a second order; the rest bought once.
- **The biggest markets have the weakest loyalty.** Northwest (23%) and Southwest (25%), together about 8,000 customers, have the lowest repeat-purchase rates. Australia leads the large markets at 72%.
- **Europe trails North America on repeat business.** France (27%) and Germany (29%) sit well below the United Kingdom (46%) and Canada (49%).
- **Average unit price peaks in January (~$550)**, bottoms out in June (~$400), and recovers through Q4.

## 💡 Recommendations

- Focus retention efforts on the US West: Northwest and Southwest hold the most customers and lose the most of them after one order.
- Study what Australia does differently (product mix, order timing) and test it in the weakest territories.
- Before planning promotions, check whether the mid-year price dip comes from discounting or from a shift toward cheaper categories.

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
| Retention Rate (as shown on dashboard) | 86.83 % ⚠️ see Known issue |
| Repeat Purchase Rate (corrected) | 39.07 % |

### Metric definitions

| Metric | Definition |
|--------|------------|
| Total Revenue | `SUM(LineTotal)` across all order lines |
| CLV | Total revenue ÷ distinct customers (19,119) |
| AOV | Total revenue ÷ distinct orders (31,465) |
| Retention Rate (dashboard) | Share of customers with more than one order *line* |
| Repeat Purchase Rate | Share of customers with more than one distinct order |

### Data validation

All KPIs were reconciled against the AdventureWorks source tables (`Sales.SalesOrderHeader`, `Sales.SalesOrderDetail`, `Sales.Customer`): revenue, order count, customer count and the largest order line ($27,893.62) match the source exactly.

### ⚠️ Known issue

The dashboard's Retention Rate (86.83%) counts a customer as retained if they bought more than one item, even within a single order. During a post-build audit against the source tables, I found that the true share of customers who placed a second order is **39.07%** (7,470 of 19,119). The Key Findings above use the corrected figure. The Power BI measure is being updated to count distinct orders instead of order lines.

### Limitations

- CLV is a simple historical average. It includes large reseller (store) orders alongside individual online buyers, so it overstates the value of a typical individual customer.
- Central, Northeast and Southeast each have fewer than 100 customers, so their repeat rates (84–87%) are not reliable for comparison.

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
