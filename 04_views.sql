USE OlistDW;
GO

CREATE VIEW dw.vw_MonthlySales AS
SELECT
    d.[Year],
    d.[Month],
    d.MonthName,
    COUNT(DISTINCT f.OrderID) AS Orders,
    SUM(f.Price) AS Revenue,
    SUM(f.FreightValue) AS Freight
FROM dw.FactOrderItems f
JOIN dw.DimDate d ON d.DateKey = f.PurchaseDateKey
WHERE f.OrderStatus <> 'canceled'
GROUP BY d.[Year], d.[Month], d.MonthName;
GO

CREATE VIEW dw.vw_TopCategories AS
SELECT
    p.CategoryEN,
    COUNT(*) AS ItemsSold,
    SUM(f.Price) AS Revenue
FROM dw.FactOrderItems f
JOIN dw.DimProduct p ON p.ProductKey = f.ProductKey
WHERE f.OrderStatus <> 'canceled'
GROUP BY p.CategoryEN;
GO