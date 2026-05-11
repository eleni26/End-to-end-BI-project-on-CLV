USE [AdventureWorks2019];
GO

CREATE OR ALTER PROCEDURE dbo.sp_Build_Loyalty_Data_Mart
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('v_Fact_Sales_Performance', 'V') IS NOT NULL DROP VIEW v_Fact_Sales_Performance;
    IF OBJECT_ID('v_Customer_Geography', 'V') IS NOT NULL DROP VIEW v_Customer_Geography;
    IF OBJECT_ID('v_Product_Catalog', 'V') IS NOT NULL DROP VIEW v_Product_Catalog;

    IF OBJECT_ID('Fact_Sales', 'U') IS NOT NULL DROP TABLE Fact_Sales;
    IF OBJECT_ID('Dim_Date', 'U') IS NOT NULL DROP TABLE Dim_Date;
    IF OBJECT_ID('Dim_Product', 'U') IS NOT NULL DROP TABLE Dim_Product;
    IF OBJECT_ID('Dim_Territory', 'U') IS NOT NULL DROP TABLE Dim_Territory;
    IF OBJECT_ID('Dim_Customer', 'U') IS NOT NULL DROP TABLE Dim_Customer;

    SELECT DISTINCT
        OrderDate AS DateKey,
        OrderDate AS [FullDate],
        DATEPART(YEAR, OrderDate) AS [Year],
        DATEPART(QUARTER, OrderDate) AS [Quarter],
        DATENAME(MONTH, OrderDate) AS [MonthName],
        DATEPART(MONTH, OrderDate) AS [MonthNumber]
    INTO Dim_Date
    FROM Sales.SalesOrderHeader;

    SELECT 
        p.ProductID AS ProductKey,
        p.Name AS ProductName,
        ps.Name AS SubCategory,
        pc.Name AS Category,
        p.StandardCost,
        p.ListPrice
    INTO Dim_Product
    FROM Production.Product p
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID;

    SELECT 
        TerritoryID AS TerritoryKey,
        [Name] AS TerritoryName,
        [CountryRegionCode] AS CountryCode,
        [Group] AS RegionGroup
    INTO Dim_Territory
    FROM Sales.SalesTerritory;

    SELECT * INTO Dim_Customer FROM (
        SELECT 
            c.CustomerID AS CustomerKey,
            p.FirstName,
            p.LastName,
            CONCAT(p.FirstName, ' ', p.LastName) AS FullName,
            c.AccountNumber,
            st.Name AS TerritoryName,
            ROW_NUMBER() OVER(PARTITION BY c.CustomerID ORDER BY c.CustomerID) as RN
        FROM Sales.Customer c
        JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
        JOIN Sales.SalesTerritory st ON c.TerritoryID = st.TerritoryID
    ) t WHERE RN = 1;

    SELECT 
        sod.SalesOrderID,
        sod.SalesOrderDetailID,
        soh.OrderDate AS DateKey,    
        soh.CustomerID AS CustomerKey, 
        sod.ProductID AS ProductKey,  
        soh.TerritoryID AS TerritoryKey,
        sod.OrderQty,
        sod.UnitPrice,
        sod.LineTotal AS SalesAmount
    INTO Fact_Sales
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID;


    EXEC('CREATE VIEW v_Fact_Sales_Performance AS 
          SELECT f.SalesOrderID, f.SalesOrderDetailID, f.CustomerKey, f.ProductKey, f.TerritoryKey,
                 f.OrderQty, f.UnitPrice, f.SalesAmount, d.FullDate, d.Year, d.Quarter, d.MonthName 
          FROM Fact_Sales f 
          LEFT JOIN Dim_Date d ON f.DateKey = d.DateKey');

    EXEC('CREATE VIEW v_Customer_Geography AS 
          SELECT DISTINCT c.CustomerKey, c.FullName, c.AccountNumber, t.TerritoryName, t.CountryCode, t.RegionGroup 
          FROM Dim_Customer c 
          LEFT JOIN Dim_Territory t ON c.TerritoryName = t.TerritoryName');

    EXEC('CREATE VIEW v_Product_Catalog AS 
          SELECT DISTINCT ProductKey, ProductName, SubCategory, Category, StandardCost, ListPrice 
          FROM Dim_Product');

    PRINT 'Build Success: Star Schema tables and Reporting Views are ready.';
END;
GO